from sqlalchemy import Boolean, Column, ForeignKey, Integer, String, DateTime, Date, Float, Sequence
from sqlalchemy.orm import relationship
from sqlalchemy.ext.asyncio import AsyncSession
from fastapi import Depends, FastAPI, HTTPException, status
from passlib.context import CryptContext
from datetime import date, datetime,  timedelta 
from sqlalchemy.exc import IntegrityError
from .database import Base, get_db, get_or_404
from sqlalchemy.future import select
from sqlalchemy import update
from .warehouse import CurrentWholesaleWarehouse, CurrentFactoryWarehouse
from .users import Products, UserProductPlan
import calendar


class Hospital(Base):
    __tablename__ = "hospital"

    id = Column(Integer, primary_key=True)
    company_name = Column(String)
    company_address = Column(String)
    inter_branch_turnover = Column(String)
    bank_account_number = Column(String)
    director = Column(String)
    purchasing_manager = Column(String)
    contact = Column(String)
    med_rep_id = Column(Integer, ForeignKey("users.id"))
    med_rep = relationship("Users",  backref="mr_hospital", lazy='selectin')

    async def save(self, db: AsyncSession):
        try:
            db.add(self)
            await db.commit()
            await db.refresh(self)
        except IntegrityError as e:
            raise HTTPException(status_code=404, detail=str(e.orig).split('DETAIL:  ')[1].replace('.\n', ''))

    async def update(self, db: AsyncSession, **kwargs):
        try:
            for key in list(kwargs.keys()):
                kwargs.pop(key) if kwargs[key]==None else None 
            self.company_name = kwargs.get('company_name', self.company_name)
            self.company_address = kwargs.get('company_address', self.company_address)
            self.contact = kwargs.get('contact', self.contact)
            self.bank_account_number = kwargs.get('bank_account_number', self.bank_account_number)
            self.inter_branch_turnover = kwargs.get('inter_branch_turnover', self.inter_branch_turnover)
            self.director = kwargs.get('director', self.director)
            self.purchasing_manager = kwargs.get('purchasing_manager', self.purchasing_manager)
            db.add(self)
            await db.commit()
            await db.refresh(self)
        except IntegrityError as e:
            raise HTTPException(status_code=404, detail=str(e.orig).split('DETAIL:  ')[1].replace('.\n', ''))


class HospitalMonthlyPlan(Base):
    __tablename__ = "hospital_monthly_plan"

    id = Column(Integer, primary_key=True)
    monthly_plan = Column(Integer)
    date = Column(DateTime, default=datetime.now())
    product = relationship("Products",  backref="hospitalmonthlyplan", lazy="selectin")
    product_id = Column(Integer, ForeignKey("products.id"))
    price = Column(Integer)
    discount_price = Column(Integer)
    hospital_id = Column(Integer, ForeignKey("hospital.id", ondelete="CASCADE"))
    hospital = relationship("Hospital", backref="hospital_monthly_plan", cascade="all, delete", lazy='selectin')
 
    async def save(self, db: AsyncSession):
        try:
            db.add(self)
            await db.commit()
            await db.refresh(self)
        except:
            raise HTTPException(status_code=404, detail=str(e.orig).split('DETAIL:  ')[1].replace('.\n', ''))

    async def update(self, amount: int, db: AsyncSession):
        try:
            difference = self.monthly_plan - amount
            self.monthly_plan = amount
            result = await db.execute(select(UserProductPlan).filter(UserProductPlan.med_rep_id==self.hospital.med_rep_id, UserProductPlan.product_id==self.product_id))
            user_plan = result.scalar()
            user_plan.current_amount += difference
            if user_plan.current_amount < 0:
                raise HTTPException(status_code=404, detail="Med rep plan should be grater than 0 for tis product")
            db.add(self)
            await db.commit()
            await db.refresh(self)
        except IntegrityError as e:
            raise HTTPException(status_code=404, detail=str(e.orig).split('DETAIL:  ')[1].replace('.\n', ''))


class HospitalReservationPayedAmounts(Base):
    __tablename__ = "hospital_reservation_payed_amounts"

    id = Column(Integer, primary_key=True)
    amount = Column(Integer)
    description = Column(String)
    date = Column(DateTime, default=date.today())
    reservation_id = Column(Integer, ForeignKey("hospital_reservation.id", ondelete="CASCADE"))
    reservation = relationship("HospitalReservation", cascade="all, delete", backref="payed_amounts")
   
    async def save(self, db: AsyncSession):
        try:
            db.add(self)
            await db.commit()
            await db.refresh(self)
        except IntegrityError as e:
            raise HTTPException(status_code=404, detail=str(e.orig).split('DETAIL:  ')[1].replace('.\n', ''))


invoice_number_seq = Sequence('invoice_number_seq')


class HospitalReservation(Base):
    __tablename__ = "hospital_reservation"

    id = Column(Integer, primary_key=True)
    date = Column(DateTime, default=date.today())
    date_implementation = Column(DateTime)
    expire_date = Column(DateTime, default=(datetime.now() + timedelta(days=10)))
    discount = Column(Float)
    total_quantity = Column(Integer)
    total_amount = Column(Float)
    total_payable = Column(Float)
    total_payable_with_nds = Column(Float)
    invoice_number = Column(Integer, invoice_number_seq, primary_key=True, server_default=invoice_number_seq.next_value())
    profit = Column(Integer, default=0)
    debt = Column(Integer)
    hospital_id = Column(Integer, ForeignKey("hospital.id", ondelete="CASCADE"))
    hospital = relationship("Hospital", backref="hospital_reservation", cascade="all, delete", lazy='selectin')
    products = relationship("HospitalReservationProducts", cascade="all, delete", back_populates="reservation", lazy='selectin')
    manufactured_company_id = Column(Integer, ForeignKey("manufactured_company.id"))
    manufactured_company = relationship("ManufacturedCompany", backref="hospital_reservation", lazy='selectin')
    checked = Column(Boolean, default=False)
    payed = Column(Boolean, default=False)

    @classmethod
    async def save(cls, db: AsyncSession, **kwargs):
        try:
            total_quantity = 0
            total_amount = 0
            total_payable = 0
            res_products = []
            products = kwargs.pop('products')
            for product in products:
                prd = await get_or_404(Products, product['product_id'], db)
                result = await db.execute(select(CurrentFactoryWarehouse).filter(CurrentFactoryWarehouse.factory_id==kwargs['manufactured_company_id'], CurrentFactoryWarehouse.product_id==product['product_id']))
                wrh = result.scalar()
                if (not wrh) or wrh.amount < product['quantity']: 
                    raise HTTPException(status_code=404, detail=f"There is not enough {prd.name} in factory warehouse")
                res_products.append(HospitalReservationProducts(**product, reservation_price=prd.price, reservation_discount_price=prd.discount_price))
                total_quantity += product['quantity']
                total_amount += product['quantity'] * prd.price
            total_payable = total_amount - total_amount * kwargs['discount'] / 100
            reservation = cls(**kwargs,
                                total_quantity = total_quantity,
                                total_amount = total_amount,
                                total_payable = total_payable,
                                total_payable_with_nds = total_payable + total_payable * 0.12,
                                debt = total_payable + total_payable * 0.12
                                )
            db.add(reservation)
            for p in res_products:
                reservation.products.append(p)
            await db.commit()
            return reservation
        except IntegrityError as e:
            raise HTTPException(status_code=404, detail=str(e.orig).split('DETAIL:  ')[1].replace('.\n', ''))
            
    async def check_reservation(self, db: AsyncSession, **kwargs):
        if self.checked == True:
            raise HTTPException(status_code=400, detail=f"This reservation already checked")
        self.checked = kwargs.get('checked')
        self.date_implementation = datetime.now()
        for product in self.products:
            result = await db.execute(select(CurrentFactoryWarehouse).filter(CurrentFactoryWarehouse.factory_id==self.manufactured_company_id))
            wrh = result.scalar()
            if (not wrh) or wrh.amount < product.quantity: 
                raise HTTPException(status_code=404, detail=f"There is not enough {product.name} in warehouse")
            wrh.amount -= product.quantity
            await UserProductPlan.user_plan_minus(product_id=product.product_id, med_rep_id=self.hospital.med_rep_id, quantity=product.quantity, db=db)
            await HospitalFact.set_fact(product_id=product.product_id, product_quantity=product.quantity, hospital_id=self.hospital_id, db=db)
        await db.commit()

    async def check_if_payed_reservation(self, db: AsyncSession, **kwargs):
        if self.checked == False:
            raise HTTPException(status_code=400, detail=f"This reservation not checked")
        if self.payed == True:
            raise HTTPException(status_code=400, detail=f"This reservation already payed")
        self.payed = kwargs.get('payed')
        await db.commit()

    async def update_expire_date(self, date: date, db: AsyncSession):
        try:
            self.expire_date = date
            await db.commit()
        except IntegrityError as e:
            raise HTTPException(status_code=404, detail=str(e.orig).split('DETAIL:  ')[1].replace('.\n', ''))

    async def delete(self, db: AsyncSession):
        if self.checked == True:
            raise HTTPException(status_code=404, detail="This reservstion checked")
        for product in self.products:
            result = await db.execute(select(CurrentFactoryWarehouse).filter(CurrentFactoryWarehouse.factory_id==self.manufactured_company_id, CurrentFactoryWarehouse.product_id==product.product_id))
            wrh = result.scalars().first()
            wrh.amount += product.quantity
        await db.delete(self)
        await db.commit()

    async def update_discount(self, discount: int, db: AsyncSession):
        if self.checked == True:
            raise HTTPException(status_code=400, detail=f"This reservation already checked")
        for product in self.products:
            product.reservation_price = product.reservation_price * (100 / (100 - self.discount)) * (1 - discount / 100)
        self.total_payable = self.total_payable * (100 / (100 - self.discount)) * (1 - discount / 100)
        self.total_payable_with_nds = self.total_payable_with_nds * (100 / (100 - self.discount)) * (1 - discount / 100)
        self.discount = discount
        await db.commit()

    async def pay_reservation(self, db: AsyncSession, **kwargs):
        self.debt -= kwargs['amount']
        self.profit += kwargs['amount']
        reservation = HospitalReservationPayedAmounts(amount=kwargs['amount'], description=kwargs['description'], reservation_id=self.id)
        await reservation.save(db)
        if self.debt < 0:
            raise HTTPException(status_code=400, detail=f"This reservation already chacked")
        db.commit()


class HospitalReservationProducts(Base):
    __tablename__ = "hospital_reservation_products"

    id = Column(Integer, primary_key=True)
    quantity = Column(Integer)
    reservation_price = Column(Integer)
    reservation_discount_price = Column(Integer)
    product_id = Column(Integer, ForeignKey("products.id"))
    product = relationship("Products", backref="hospital_reservation_products", lazy='selectin')
    reservation_id = Column(Integer, ForeignKey("hospital_reservation.id", ondelete="CASCADE"))
    reservation = relationship("HospitalReservation", cascade="all, delete", back_populates="products")


class HospitalBonus(Base):
    __tablename__ = "hospital_bonus"

    id = Column(Integer, primary_key=True)
    date = Column(DateTime, default=datetime.now())
    amount = Column(Integer)
    payed = Column(Integer, default=0)
    product_quantity = Column(Integer)
    hospital_id = Column(Integer, ForeignKey("hospital.id", ondelete="CASCADE"))
    hospital = relationship("Hospital", backref="hospital_bonus", cascade="all, delete")
    product = relationship("Products",  backref="hospital_bonus", lazy='selectin')
    product_id = Column(Integer, ForeignKey("products.id"))

    async def paying_bonus(self, amount: int, db: AsyncSession):
        self.payed += amount
        await db.commit()

    @classmethod
    async def set_bonus(cls, db: AsyncSession, **kwargs):
        product = await get_or_404(Products, kwargs['product_id'], db)
        amount = product.marketing_expenses * kwargs['product_quantity']
        result = await db.execute(select(cls).filter(cls.hospital_id==kwargs['hospital_id'], cls.product_id==kwargs['product_id'], cls.date>=kwargs['start_date'], cls.date<=kwargs['end_date']))
        month_bonus = result.scalars().first()
        if month_bonus is None:
            month_bonus = cls(hospital_id=kwargs['hospital_id'], product_id=kwargs['product_id'], product_quantity=kwargs['product_quantity'], amount=amount)
            db.add(month_bonus)
        else:
            month_bonus.amount += amount
            month_bonus.product_quantity += kwargs['product_quantity']


class HospitalFact(Base):
    __tablename__ = "hospital_fact"

    id = Column(Integer, primary_key=True)
    fact = Column(Integer)
    price = Column(Integer)
    discount_price = Column(Integer)
    date = Column(DateTime, default=datetime.now())
    hospital_id = Column(Integer, ForeignKey("hospital.id", ondelete="CASCADE"))
    hospital = relationship("Hospital", backref="hospital_fact", cascade="all, delete", lazy='selectin')
    product = relationship("Products",  backref="hospital_fact")
    product_id = Column(Integer, ForeignKey("products.id"))

    @classmethod
    async def set_fact(cls, db: AsyncSession, **kwargs):
        year = datetime.now().year
        month = datetime.now().month  
        num_days = calendar.monthrange(year, month)[1]
        start_date = date(year, month, 1)  
        end_date = date(year, month, num_days)
        product = await get_or_404(Products, kwargs['product_id'], db)
        result = await db.execute(select(cls).filter(cls.hospital_id==kwargs['hospital_id'], cls.product_id==kwargs['product_id'], cls.date>=start_date, cls.date<=end_date))
        month_fact = result.scalars().first()
        if month_fact is None:
            month_fact = cls(hospital_id=kwargs['hospital_id'], product_id=kwargs['product_id'], fact=kwargs['product_quantity'], price=product.price, discount_price=product.discount_price)
            db.add(month_fact)
        else:
            month_fact.fact += kwargs['product_quantity']
        await HospitalBonus.set_bonus(**kwargs, start_date=start_date, end_date=end_date, db=db)
