from sqlalchemy import Boolean, Column, ForeignKey, Integer, String, DateTime, Date, Float, Sequence, text 
from sqlalchemy.orm import relationship
from sqlalchemy.ext.asyncio import AsyncSession
from fastapi import Depends, FastAPI, HTTPException, status
from passlib.context import CryptContext
from datetime import date, datetime,  timedelta 
from sqlalchemy.exc import IntegrityError
from sqlalchemy.future import select
from sqlalchemy import update
from .warehouse import CurrentFactoryWarehouse
from .users import Product, UserProductPlan
from .doctors import DoctorFact, DoctorPostupleniyaFact, Bonus
import calendar
from .database import get_db, get_or_404
from db.db import Base



class Hospital(Base):
    __tablename__ = "hospital"
    __table_args__ = {"extend_existing": True}

    id = Column(Integer, primary_key=True)
    company_name = Column(String)
    company_address = Column(String)
    inter_branch_turnover = Column(String)
    bank_account_number = Column(String)
    director = Column(String)
    purchasing_manager = Column(String)
    contact = Column(String)
    region = relationship("Region", backref="hospital", lazy='selectin')
    region_id = Column(Integer, ForeignKey("region.id"), index=True) 
    med_rep_id = Column(Integer, ForeignKey("users.id"), index=True)
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
    __table_args__ = {"extend_existing": True}

    id = Column(Integer, primary_key=True)
    monthly_plan = Column(Integer)
    date = Column(DateTime, default=datetime.now(), index=True)
    product = relationship("Product",  backref="hospitalmonthlyplan", lazy="selectin")
    product_id = Column(Integer, ForeignKey("products.id"), index=True)
    price = Column(Integer)
    discount_price = Column(Integer)
    hospital_id = Column(Integer, ForeignKey("hospital.id", ondelete="CASCADE"), index=True)
    hospital = relationship("Hospital", backref="hospital_monthly_plan", cascade="all, delete", lazy='selectin')
 
    async def save(self, db: AsyncSession):
        try:
            db.add(self)
            await db.commit()
            await db.refresh(self)
        except IntegrityError as e:
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
            if self.monthly_plan == 0:
                result = await db.execute(select(HospitalPostupleniyaFact).filter(HospitalPostupleniyaFact.hospital_id==self.hospital_id, HospitalPostupleniyaFact.product_id==self.product_id))
                postupleniya = result.scalars().first()
                if postupleniya:
                    raise HTTPException(status_code=400, detail="There is postuplenuya fact whith this product in this hospital")
                query = f"delete from hospital_monthly_plan WHERE id={self.id}"
                result = await db.execute(text(query))
            db.add(self)
            await db.commit()
        except IntegrityError as e:
            raise HTTPException(status_code=404, detail=str(e.orig).split('DETAIL:  ')[1].replace('.\n', ''))


class HospitalReservationPayedAmounts(Base):
    __tablename__ = "hospital_reservation_payed_amounts"
    __table_args__ = {"extend_existing": True}

    id = Column(Integer, primary_key=True)
    amount = Column(Integer)
    total_sum = Column(Integer)
    remainder_sum = Column(Integer)
    bonus = Column(Boolean, default=True)
    bonus_discount = Column(Integer)
    doctor_id = Column(Integer)
    quantity = Column(Integer)
    description = Column(String)
    date = Column(DateTime, default=datetime.now())
    product_id = Column(Integer, ForeignKey("products.id", ondelete="CASCADE"), index=True)
    product = relationship("Product", cascade="all, delete", backref="hospital_reservation_payed_amounts", lazy='selectin')
    reservation_id = Column(Integer, ForeignKey("hospital_reservation.id", ondelete="CASCADE"), index=True)
    reservation = relationship("HospitalReservation", cascade="all, delete", backref="payed_amounts", lazy='selectin'   )

    async def save(self, db: AsyncSession):
        try:
            db.add(self)
            # await db.commit()
            # await db.refresh(self)
        except IntegrityError as e:
            raise HTTPException(status_code=404, detail=str(e.orig).split('DETAIL:  ')[1].replace('.\n', ''))


invoice_number_seq = Sequence('invoice_number_seq')


class HospitalReservation(Base):
    __tablename__ = "hospital_reservation"
    __table_args__ = {"extend_existing": True}

    id = Column(Integer, primary_key=True)
    date = Column(DateTime, default=datetime.now(), index=True)
    date_implementation = Column(DateTime)
    expire_date = Column(DateTime, default=(datetime.now() + timedelta(days=30)))
    discount = Column(Float)
    bonus = Column(Boolean, default=True)
    total_quantity = Column(Integer)
    total_amount = Column(Float)
    total_payable = Column(Float)
    total_payable_with_nds = Column(Float)
    invoice_number = Column(Integer, invoice_number_seq, unique=True, server_default=invoice_number_seq.next_value())
    profit = Column(Integer, default=0)
    debt = Column(Integer, default=0)
    med_rep_id = Column(Integer, ForeignKey("users.id"), index=True)        
    med_rep = relationship("Users",  backref="hospital_reservation")
    prosrochenniy_debt = Column(Boolean, default=False)
    hospital_id = Column(Integer, ForeignKey("hospital.id", ondelete="CASCADE"), index=True)
    hospital = relationship("Hospital", backref="hospital_reservation", cascade="all, delete", lazy='selectin')
    products = relationship("HospitalReservationProducts", cascade="all, delete", back_populates="reservation", lazy='selectin')
    manufactured_company_id = Column(Integer, ForeignKey("manufactured_company.id"), index=True)
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
                prd = await get_or_404(Product, product['product_id'], db)
                price = product['price'] if product['price'] else prd.price
                del product['price']
                result = await db.execute(select(CurrentFactoryWarehouse).filter(CurrentFactoryWarehouse.factory_id==kwargs['manufactured_company_id'], CurrentFactoryWarehouse.product_id==product['product_id']))
                wrh = result.scalar()
                if (not wrh) or wrh.amount < product['quantity']: 
                    raise HTTPException(status_code=404, detail=f"There is not enough {prd.name} in factory warehouse")
                res_products.append(HospitalReservationProducts(**product, reservation_price=price, reservation_discount_price=prd.discount_price))
                total_quantity += product['quantity']
                total_amount += product['quantity'] * price
            total_payable = (total_amount - total_amount * kwargs['discount'] / 100)
            reservation = cls(**kwargs,
                                total_quantity = total_quantity,
                                total_amount = total_amount,
                                total_payable = total_payable,
                                total_payable_with_nds = (total_payable + total_payable * 0.12),
                                debt = (total_payable + total_payable * 0.12)
                                )
            db.add(reservation)
            for p in res_products:
                p.reservation_id=reservation.id
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
            result = await db.execute(select(CurrentFactoryWarehouse).filter(CurrentFactoryWarehouse.factory_id==self.manufactured_company_id, CurrentFactoryWarehouse.product_id==product.product_id))
            wrh = result.scalar()
            if (not wrh) or wrh.amount < product.quantity: 
                raise HTTPException(status_code=404, detail=f"There is not enough {product.product.name} in warehouse")
            wrh.amount -= product.quantity
            # await UserProductPlan.user_plan_minus(product_id=product.product_id, med_rep_id=self.hospital.med_rep_id, quantity=product.quantity, db=db)
            # await HospitalFact.set_fact(product_id=product.product_id, product_quantity=product.quantity, hospital_id=self.hospital_id, db=db)
        await db.commit()

    async def check_if_payed_reservation(self, db: AsyncSession, **kwargs):
        if self.checked == False:
            raise HTTPException(status_code=400, detail=f"This reservation not checked")
        if self.payed == True:
            raise HTTPException(status_code=400, detail=f"This reservation already payed")
        self.payed = kwargs.get('payed')
        await db.commit()

    async def update_date_implementation(self, date, db: AsyncSession):
        try:
            self.date_implementation = date
            await db.commit()
        except IntegrityError as e:
            raise HTTPException(status_code=404, detail=str(e.orig).split('DETAIL:  ')[1].replace('.\n', ''))

    async def delete(self, db: AsyncSession):
        if self.checked == True:
            raise HTTPException(status_code=404, detail="This reservstion checked")
        query = f"delete from hospital_reservation WHERE id={self.id}"  
        result = await db.execute(text(query))
        await db.commit()

    async def update_discount(self, discount: float, db: AsyncSession):
        # if self.checked == True:
        #     raise HTTPException(status_code=400, detail=f"This reservation already checked")
        for product in self.products:
            product.reservation_price = (product.reservation_price * (100 / (100 - self.discount)) * (1 - discount / 100))
        self.total_payable = (self.total_payable * (100 / (100 - self.discount)) * (1 - discount / 100))
        self.total_payable_with_nds = (self.total_payable_with_nds * (100 / (100 - self.discount)) * (1 - discount / 100))
        self.debt = (self.debt * (100 / (100 - self.discount)) * (1 - discount / 100))
        self.discount = discount
        await db.commit()

    async def pay_reservation(self, db: AsyncSession, **kwargs):
        try:
            self.debt -= kwargs['amount']
            self.profit += kwargs['amount']
            reservation = HospitalReservationPayedAmounts(quantity=self.total_quantity, doctor_id=kwargs['doctor_id'], bonus_discount=kwargs['bonus_discount'], amount=kwargs['amount'], description=kwargs['description'], reservation_id=self.id)
            await reservation.save(db)
            if self.debt < 0:
                raise HTTPException(status_code=400, detail=f"Something went wrong")
            for prd in self.products:
                product_price = (prd.product.price * 1.12) * (100 - self.discount)/100
                fact_price = prd.quantity * product_price
                bonus_sum = fact_price * kwargs['bonus_discount']/100
                await DoctorFact.set_fact_to_hospital(month_number=kwargs['month_number'], doctor_id=kwargs['doctor_id'], product_id=prd.product.id, compleated=prd.quantity, db=db)
                await DoctorPostupleniyaFact.set_fact(price=product_price, fact_price=fact_price, product_id=prd.product.id, doctor_id=kwargs['doctor_id'], compleated=prd.quantity, month_number=kwargs['month_number'], db=db)
                if self.bonus == True:
                    await Bonus.set_bonus_to_hospital(bonus_sum=bonus_sum, product_id=prd.product.id, doctor_id=kwargs['doctor_id'], compleated=prd.quantity, month_number=kwargs['month_number'], db=db)
            await db.commit()
        except IntegrityError as e:
            raise HTTPException(status_code=404, detail=str(e.orig).split('DETAIL:  ')[1].replace('.\n', ''))

    async def edit_invoice_number(self, invoice_number: int, db: AsyncSession):
        try:
            self.invoice_number = invoice_number
            await db.commit()
            await db.refresh(self)
        except IntegrityError as e:
            raise HTTPException(status_code=404, detail=str(e.orig).split('DETAIL:  ')[1].replace('.\n', ''))


class HospitalReservationProducts(Base):
    __tablename__ = "hospital_reservation_products"
    __table_args__ = {"extend_existing": True}

    id = Column(Integer, primary_key=True)
    quantity = Column(Integer)
    not_payed_quantity = Column(Integer)
    reservation_price = Column(Integer)
    reservation_discount_price = Column(Integer)
    product_id = Column(Integer, ForeignKey("products.id"))
    product = relationship("Product", backref="hospital_reservation_products", lazy='selectin')
    reservation_id = Column(Integer, ForeignKey("hospital_reservation.id", ondelete="CASCADE"))
    reservation = relationship("HospitalReservation", cascade="all, delete", back_populates="products")

    @classmethod
    async def set_payed_quantity(cls, db: AsyncSession, **kwargs):
        query = f"update hospital_reservation_products set not_payed_quantity=not_payed_quantity-{kwargs['quantity']} WHERE reservation_id={kwargs['reservation_id']} AND product_id={kwargs['product_id']} returning not_payed_quantity"  
        result = await db.execute(text(query))
        quantity = result.scalar()
        if quantity < 0:
            raise HTTPException(status_code=400, detail="Quantity couldn't be lower then 0")
        await db.commit()


class HospitalBonus(Base):
    __tablename__ = "hospital_bonus"
    __table_args__ = {"extend_existing": True}

    id = Column(Integer, primary_key=True)
    date = Column(DateTime, default=datetime.now())
    amount = Column(Integer)
    payed = Column(Integer, default=0)
    product_quantity = Column(Integer)
    hospital_id = Column(Integer, ForeignKey("hospital.id", ondelete="CASCADE"))
    hospital = relationship("Hospital", backref="hospital_bonus", cascade="all, delete")
    product = relationship("Product",  backref="hospital_bonus", lazy='selectin')
    product_id = Column(Integer, ForeignKey("products.id"))

    async def paying_bonus(self, amount: int, db: AsyncSession):
        self.payed += amount
        await db.commit()

    @classmethod
    async def set_bonus(cls, db: AsyncSession, **kwargs):
        product = await get_or_404(Product, kwargs['product_id'], db)
        month_bonus = cls(hospital_id=kwargs['hospital_id'], product_id=kwargs['product_id'], product_quantity=kwargs['product_quantity'], amount=kwargs['bonus_sum'])
        db.add(month_bonus)


class HospitalFact(Base):
    __tablename__ = "hospital_fact"
    __table_args__ = {"extend_existing": True}

    id = Column(Integer, primary_key=True)
    fact = Column(Integer)
    price = Column(Integer)
    discount_price = Column(Integer)
    date = Column(DateTime, default=datetime.now(), index=True)
    hospital_id = Column(Integer, ForeignKey("hospital.id", ondelete="CASCADE"), index=True)
    hospital = relationship("Hospital", backref="hospital_fact", cascade="all, delete", lazy='selectin')
    product = relationship("Product",  backref="hospital_fact")
    product_id = Column(Integer, ForeignKey("products.id"), index=True)

    @classmethod
    async def set_fact(cls, db: AsyncSession, **kwargs):
        year = datetime.now().year
        month = datetime.now().month  
        num_days = calendar.monthrange(year, month)[1]
        start_date = datetime(year, month, 1)  
        end_date = datetime(year, month, num_days, 23, 59)
        product = await get_or_404(Product, kwargs['product_id'], db)
        result = await db.execute(select(cls).filter(cls.hospital_id==kwargs['hospital_id'], cls.product_id==kwargs['product_id'], cls.date>=start_date, cls.date<=end_date))
        month_fact = result.scalars().first()
        if month_fact is None:
            month_fact = cls(hospital_id=kwargs['hospital_id'], product_id=kwargs['product_id'], fact=kwargs['product_quantity'], price=product.price, discount_price=product.discount_price)
            db.add(month_fact)
        else:
            month_fact.fact += kwargs['product_quantity']


class HospitalPostupleniyaFact(Base):
    __tablename__ = 'hospital_postupleniya_fact'
    __table_args__ = {"extend_existing": True}

    id = Column(Integer, primary_key=True)
    fact = Column(Integer)
    fact_price = Column(Integer, default=0)
    price = Column(Integer)
    discount_price = Column(Integer)
    date = Column(DateTime, default=datetime.now())
    hospital_id = Column(Integer, ForeignKey("hospital.id", ondelete="CASCADE"))
    hospital = relationship("Hospital", backref="hospital_postupleniya_fact", cascade="all, delete", lazy='selectin')
    product = relationship("Product",  backref="hospital_postupleniya_fact")
    product_id = Column(Integer, ForeignKey("products.id"))

    @classmethod
    async def set_fact(cls, db: AsyncSession, **kwargs):
        year = datetime.now().year
        num_days = calendar.monthrange(year, kwargs['month_number'])[1]
        start_date = datetime(year, kwargs['month_number'], 1)  
        end_date = datetime(year, kwargs['month_number'], num_days, 23, 59)
        product = await get_or_404(Product, kwargs['product_id'], db)
        result = await db.execute(select(cls).filter(cls.hospital_id==kwargs['hospital_id'], cls.product_id==kwargs['product_id'], cls.date>=start_date, cls.date<=end_date))
        month_fact = result.scalars().first()
        if month_fact is None:
            month_fact = cls(fact_price = kwargs['fact_price'], hospital_id=kwargs['hospital_id'], product_id=kwargs['product_id'], fact=kwargs['compleated'], price=product.price, discount_price=product.discount_price)
            db.add(month_fact)
        else:
            month_fact.fact += kwargs['compleated']
            month_fact.fact_price += kwargs['fact_price']


class RemainderSumFromReservation(Base):
    __tablename__ = "remainder_sum_from_reservation"
    __table_args__ = {"extend_existing": True}

    id = Column(Integer, primary_key=True)
    amonut = Column(Integer)
    date = Column(DateTime, default=datetime.now())
    pharmacy_id = Column(Integer, ForeignKey("pharmacy.id", ondelete="CASCADE"))
    pharmacy = relationship("Pharmacy", cascade="all, delete", backref='remainder')
    wholesale_id = Column(Integer, ForeignKey("wholesale.id"), nullable=True)
    wholesale = relationship("Wholesale", backref="remainder", cascade="all, delete", lazy='selectin')
    reservation_invoice_number = Column(Integer)

    @classmethod
    async def set_remainder(cls, db: AsyncSession, **kwargs):
        try:
            obj = cls(**kwargs)
            db.add(obj)
        except IntegrityError as e:
            raise HTTPException(status_code=404, detail=str(e.orig).split('DETAIL:  ')[1].replace('.\n', ''))

    @classmethod
    async def get_reminder(cls, db: AsyncSession, **kwargs):
        if kwargs.get('pharmacy_id', None):
            query = select(cls).filter(cls.pharmacy_id==kwargs['pharmacy_id'])
        elif kwargs.get('wholesale_id', None):
            query = select(cls).filter(cls.wholesale_id==kwargs['wholesale_id'])
        result = await db.execute(query)
        remainder = result.scalar()
        return remainder


class ReturnTable(Base):
    __tablename__ = 'return_table'
    __table_args__ = {"extend_existing": True}

    id = Column(Integer, primary_key=True)
    date = Column(DateTime, default=datetime.now())
    invoice_number = Column(Integer, unique=True)
    return_summa = Column(Integer)

    pharmacy_reservation_id = Column(Integer, ForeignKey("reservation.id", ondelete="CASCADE"))
    pharmacy_reservation = relationship("Reservation", cascade="all, delete", backref="return", lazy='selectin')
    wholesale_reservation_id = Column(Integer, ForeignKey("wholesale_reservation.id", ondelete="CASCADE"))                                             
    wholesale_reservation = relationship("WholesaleReservation", cascade="all, delete", backref="return", lazy='selectin')
    hospital_reservation_id = Column(Integer, ForeignKey("hospital_reservation.id", ondelete="CASCADE"))
    hospital_reservation = relationship("HospitalReservation", cascade="all, delete", backref="return", lazy='selectin')

    @classmethod
    async def save(cls, db: AsyncSession, **kwargs):
        try:
            # invoice_number, vozvrat, reservation, db
            reservation = kwargs['reservation']
            for product in kwargs['vozvrat'].products:
                await reservation.vozvrat(product_id=product.product_id, quantity=product.return_quantity, db=db)
            vozvrat = cls(    
                invoice_number=kwargs['vozvrat'].return_invoice_number,
                return_summa=kwargs['vozvrat'].return_summa,
            )
            if getattr(reservation, 'wholesale_id', False):
                vozvrat.wholesale_reservation_id = reservation.id
            elif getattr(reservation, 'pharmacy_id', False):
                vozvrat.pharmacy_reservation_id = reservation.id
            elif getattr(reservation, 'hospital_id', False):
                vozvrat.hospital_reservation_id = reservation.id

            db.add(vozvrat)
            await db.commit()
            return vozvrat
        except IntegrityError as e:
            raise HTTPException(status_code=404, detail=str(e.orig).split('DETAIL:  ')[1].replace('.\n', ''))



class ReturnProducts(Base):
    __tablename__ = "return_products"
    __table_args__ = {"extend_existing": True}

    id = Column(Integer, primary_key=True)
    reservation_quantity = Column(Integer) 
    return_quantity = Column(Integer)
    product_id = Column(Integer, ForeignKey("products.id"))
    product = relationship("Product", backref="return_products", lazy='selectin')
    return_table_id = Column(Integer, ForeignKey("return_table.id", ondelete="CASCADE"))
    return_table = relationship("ReturnTable", cascade="all, delete", backref="products", lazy='selectin')
