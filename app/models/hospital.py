from sqlalchemy import Boolean, Column, ForeignKey, Integer, String, DateTime, Date, Float
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
from .users import Products


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


class HospitalReservation(Base):
    __tablename__ = "hospital_reservation"

    id = Column(Integer, primary_key=True)
    date = Column(DateTime, default=date.today())
    expire_date = Column(DateTime, default=(datetime.now() + timedelta(days=10)))
    discount = Column(Float)
    total_quantity = Column(Integer)
    total_amount = Column(Float)
    total_payable = Column(Float)
    total_payable_with_nds = Column(Float)
    hospital_id = Column(Integer, ForeignKey("hospital.id", ondelete="CASCADE"))
    hospital = relationship("Hospital", backref="hospital_reservation", cascade="all, delete")
    products = relationship("HospitalReservationProducts", cascade="all, delete", back_populates="reservation", lazy='selectin')
    manufactured_company_id = Column(Integer, ForeignKey("manufactured_company.id"))
    manufactured_company = relationship("ManufacturedCompany", backref="hospital_reservation", lazy='selectin')
    confirmed = Column(Boolean, default=False)
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
                                total_payable_with_nds = total_payable + total_payable * 0.12
                                )
            db.add(reservation)
            for p in res_products:
                reservation.products.append(p)
            await db.commit()
            return reservation
        except IntegrityError as e:
            raise HTTPException(status_code=404, detail=str(e.orig).split('DETAIL:  ')[1].replace('.\n', ''))
            
    async def check_reservation(self, db: AsyncSession, **kwargs):
        if self.confirmed == True:
            raise HTTPException(status_code=400, detail=f"This reservation already confirmed")
        self.confirmed = kwargs.get('confirmed')
        for product in self.products:
            result = await db.execute(select(CurrentFactoryWarehouse).filter(CurrentFactoryWarehouse.factory_id==self.manufactured_company_id))
            wrh = result.scalar()
            if (not wrh) and wrh.amount < product.quantity: 
                raise HTTPException(status_code=404, detail=f"There is not enough {product.name} in warehouse")
            wrh.amount -= product.quantity
        await db.commit()

    async def check_if_payed_reservation(self, db: AsyncSession, **kwargs):
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
            raise HTTPException(status_code=404, detail="This reservstion confirmed")
        for product in self.products:
            result = await db.execute(select(CurrentFactoryWarehouse).filter(CurrentFactoryWarehouse.factory_id==self.manufactured_company_id, CurrentFactoryWarehouse.product_id==product.product_id))
            wrh = result.scalars().first()
            wrh.amount += product.quantity
        await db.delete(self)
        await db.commit()

    async def update_discount(self, discount: int, db: AsyncSession):
        if self.checked == True:
            raise HTTPException(status_code=400, detail=f"This reservation already chacked")
        for product in self.products:
            product.reservation_price = product.reservation_price * (100 / (100 - self.discount)) * (1 - discount / 100)
        self.total_payable = self.total_payable * (100 / (100 - self.discount)) * (1 - discount / 100)
        self.total_payable_with_nds = self.total_payable_with_nds * (100 / (100 - self.discount)) * (1 - discount / 100)
        self.discount = discount
        await db.commit()


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
        year = datetime.now().year
        month = datetime.now().month  
        num_days = calendar.monthrange(year, month)[1]
        start_date = date(year, month, 1)  
        end_date = date(year, month, num_days)
        product = await get_or_404(Products, kwargs['product_id'], db)
        amount = product.marketing_expenses * kwargs['compleated']
        result = await db.execute(select(cls).filter(cls.doctor_id==kwargs['doctor_id'], cls.product_id==kwargs['product_id'], cls.date>=start_date, cls.date<=end_date))
        month_bonus = result.scalars().first()
        if month_bonus is None:
            month_bonus = cls(doctor_id=kwargs['doctor_id'], product_id=kwargs['product_id'], product_quantity=kwargs['compleated'], amount=amount)
            db.add(month_bonus)
        else:
            month_bonus.amount += amount
            month_bonus.product_quantity += kwargs['compleated']


class HospitalFact(Base):
    __tablename__ = "hospital_fact"

    id = Column(Integer, primary_key=True)
    fact = Column(Integer)
    price = Column(Integer)
    discount_price = Column(Integer)
    date = Column(DateTime, default=datetime.now())
    hospital_id = Column(Integer, ForeignKey("hospital.id", ondelete="CASCADE"))
    hospital = relationship("Hospital", backref="hospital_fact", cascade="all, delete")
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
        result = await db.execute(select(cls).filter(cls.doctor_id==kwargs['doctor_id'], cls.pharmacy_id==kwargs['pharmacy_id'], cls.product_id==kwargs['product_id'], cls.date>=start_date, cls.date<=end_date))
        month_fact = result.scalars().first()
        if month_fact is None:
            month_fact = cls(doctor_id=kwargs['doctor_id'], pharmacy_id=kwargs['pharmacy_id'], product_id=kwargs['product_id'], fact=kwargs['compleated'], price=product.price, discount_price=product.discount_price)
            db.add(month_fact)
        else:
            month_fact.fact += kwargs['compleated']
        await Bonus.set_bonus(**kwargs, db=db)
