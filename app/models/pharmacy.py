from sqlalchemy import Boolean, Column, ForeignKey, Integer, String, Float, DateTime
from sqlalchemy.orm import relationship
from sqlalchemy.ext.asyncio import AsyncSession
from fastapi import Depends, FastAPI, HTTPException, status
from .doctors import Doctor, pharmacy_doctor, DoctorAttachedProduct
from datetime import date , datetime, timedelta
from .users import Products
from .warehouse import CurrentWholesaleWarehouse, CurrentFactoryWarehouse
from sqlalchemy.exc import IntegrityError
from sqlalchemy.future import select
from sqlalchemy.orm import selectinload
from .database import Base, get_db, get_or_404
from sqlalchemy import and_ , extract, func, or_


class IncomingStockProducts(Base):
    __tablename__ = "incoming_stock_products"

    id = Column(Integer, primary_key=True)
    quantity = Column(Integer)

    stock_id = Column(Integer, ForeignKey("incoming_balance_in_stock.id"))
    stock = relationship("IncomingBalanceInStock", backref="products")
    product_id = Column(Integer, ForeignKey("products.id"))
    product = relationship("Products", backref="incomingstockproducts")


class IncomingBalanceInStock(Base):
    __tablename__ = "incoming_balance_in_stock"

    id = Column(Integer, primary_key=True)
    # saler = Column(String)
    date = Column(DateTime, default=date.today())
    description = Column(String)

    wholesale_id = Column(Integer, ForeignKey("wholesale.id"))
    wholesale = relationship("Wholesale", backref='balanceinstock')
    factory_id = Column(Integer, ForeignKey("manufactured_company.id"))
    factory = relationship("ManufacturedCompany", backref='balanceinstock')
    pharmacy_id = Column(Integer, ForeignKey("pharmacy.id"))
    pharmacy = relationship("Pharmacy", backref='balanceinstock')

    @classmethod
    async def save(cls, db: AsyncSession, **kwargs):
        try:
            products = kwargs.pop('products')
            stock = cls(**kwargs)
            
            for product in products:
                wareh = None
                if kwargs.get('wholesale_id') is not None:
                    result = await db.execute(select(CurrentWholesaleWarehouse).filter(CurrentWholesaleWarehouse.product_id==product['product_id'], CurrentWholesaleWarehouse.wholesale_id==kwargs['wholesale_id']))
                    wareh = result.scalars().first()
                    if (not wareh) or (wareh.amount < product['quantity']):
                        raise HTTPException(status_code=404, detail='There is not enough product in wholesale warehouse')
                else:
                    result = await db.execute(select(CurrentFactoryWarehouse).filter(CurrentFactoryWarehouse.product_id==product['product_id'], CurrentFactoryWarehouse.factory_id==kwargs['factory_id']))
                    wareh = result.scalars().first()
                    if (not wareh) or (wareh.amount < product['quantity']):
                        raise HTTPException(status_code=404, detail='There is not enough product in warehouse')

                stock_product = IncomingStockProducts(**product)
                stock.products.append(stock_product)
                current = await CurrentBalanceInStock.add(pharmacy_id=kwargs['pharmacy_id'], product_id=product['product_id'], amount=product['quantity'], db=db)
                if wareh is not None:
                    wareh.amount -= product['quantity']
            db.add(stock)
            await db.commit()
        except IntegrityError as e:
            raise HTTPException(status_code=404, detail=str(e.orig).split('DETAIL:  ')[1].replace('.\n', ''))


class CurrentBalanceInStock(Base):
    __tablename__ = "current_balance_in_stock"

    id = Column(Integer, primary_key=True)
    amount = Column(Integer)

    product_id = Column(Integer, ForeignKey("products.id"))
    product = relationship("Products", backref="currntbalanceinstock")
    pharmacy_id = Column(Integer, ForeignKey("pharmacy.id"))
    pharmacy = relationship("Pharmacy", backref='currntbalanceinstock')

    @classmethod
    async def add(cls, pharmacy_id: int, product_id: int, amount: int, db: AsyncSession):
        result = await db.execute(select(cls).filter(cls.product_id==product_id, cls.pharmacy_id==pharmacy_id))
        current = result.scalars().first()
        if not current:
            current = cls(pharmacy_id=pharmacy_id, product_id=product_id, amount=amount)
            db.add(current)
        else:
            current.amount += amount
        return current


class CheckingStockProducts(Base):
    __tablename__ = "checking_stock_products"

    id = Column(Integer, primary_key=True)
    previous = Column(Integer)
    saled = Column(Integer)
    remainder = Column(Integer)

    stock_id = Column(Integer, ForeignKey("checking_balance_in_stock.id"))
    stock = relationship("CheckingBalanceInStock", backref="products")
    product_id = Column(Integer, ForeignKey("products.id"))
    product = relationship("Products", backref="checkingbalanceinstock")


class CheckingBalanceInStock(Base):
    __tablename__ = "checking_balance_in_stock"

    id = Column(Integer, primary_key=True)
    date = Column(DateTime, default=date.today())
    description = Column(String)

    pharmacy_id = Column(Integer, ForeignKey("pharmacy.id"))
    pharmacy = relationship("Pharmacy", backref='checkingbalanceinstock')

    @classmethod
    async def save(cls, db: AsyncSession, **kwargs):
        try:
            products = kwargs.pop('products')
            stock = cls(**kwargs)
            for product in products:
                result = await db.execute(select(CurrentBalanceInStock).filter(CurrentBalanceInStock.product_id==product['product_id'], CurrentBalanceInStock.pharmacy_id==kwargs['pharmacy_id']))
                current = result.scalars().first()
                if (not current) or (current.amount < product['remainder']) :
                    raise HTTPException(status_code=404, detail="There isn't enough product in stock")
                stock_product = CheckingStockProducts(**product, previous=current.amount, saled=current.amount-product['remainder'])
                stock.products.append(stock_product)
                if stock_product.saled > current.amount:
                    raise HTTPException(status_code=400, detail="There isn't enough product in stock")
                current.amount -= stock_product.saled
            db.add(stock)
            await db.commit()
            # for product in products:
                # await cls.fact(product_id=product['product_id'], pharmacy_id=current.pharmacy_id, db=db)
        except IntegrityError as e:
            raise HTTPException(status_code=404, detail=str(e.orig).split('DETAIL:  ')[1].replace('.\n', ''))

    @classmethod
    async def fact(cls, product_id: int, pharmacy_id: int, db: AsyncSession):
        current_year = datetime.now().year
        current_month = datetime.now().month

        sum_fact_result = await db.execute(
            select(func.sum(CheckingStockProducts.saled)).\
                join(cls, CheckingStockProducts.stock_id == cls.id).\
                filter(
                    CheckingStockProducts.product_id == product_id,
                    cls.pharmacy_id == pharmacy_id,
                    extract('year', cls.date) == current_year,
                    extract('month', cls.date) == current_month
                )
        )
        sum_fact = sum_fact_result.scalar() or 0  # Ensure sum_fact is an integer, default to 0 if None

        result = await db.execute(
            select(DoctorAttachedProduct).\
                join(Doctor, DoctorAttachedProduct.doctor_id == Doctor.id).\
                join(pharmacy_doctor, pharmacy_doctor.c.doctor_id == Doctor.id).\
                filter(
                    pharmacy_doctor.c.pharmacy_id == pharmacy_id,
                    DoctorAttachedProduct.product_id == product_id
                )
        )
        attached = result.scalars().first()  # Get the first result or None if no result
        if attached:
            attached.fact = sum_fact
            await db.commit()


class PharmacyAttachedProducts(Base):
    __tablename__ = "pharmacy_attached_products"

    id = Column(Integer, primary_key=True)
    monthly_plan = Column(Integer)
    product_id = Column(Integer, ForeignKey("products.id"))
    product = relationship("Products", backref="pharmacy_attached_product", lazy='selectin')
    pharmacy_id = Column(Integer, ForeignKey("pharmacy.id"))
    pharmacy = relationship("Pharmacy", back_populates="pharmacy_attached_product")


class Debt(Base):
    __tablename__ = "debt"

    id = Column(Integer, primary_key=True)
    description = Column(String)
    amount = Column(Integer)
    payed = Column(Boolean, default=False) 
    date = Column(DateTime, default=date.today())
    pharmacy_id = Column(Integer, ForeignKey("pharmacy.id"))
    pharmacy = relationship("Pharmacy", backref="debts")

    async def save(self, db: AsyncSession):
        try:
            db.add(self)
            await db.commit()
            await db.refresh(self)
        except IntegrityError as e:
            raise HTTPException(status_code=404, detail=str(e.orig).split('DETAIL:  ')[1].replace('.\n', ''))

    async def update(self, db: AsyncSession, **kwargs):
        try:
            self.payed = kwargs.get('payed', self.payed)
            await db.commit()
            await db.refresh(self)
        except IntegrityError as e:
            raise HTTPException(status_code=404, detail=str(e.orig).split('DETAIL:  ')[1].replace('.\n', ''))

from datetime import date
class Reservation(Base):
    __tablename__ = "reservation"

    id = Column(Integer, primary_key=True)
    date = Column(DateTime, default=date.today())
    expire_date = Column(DateTime, default=(datetime.now() + timedelta(days=10)))
    discount = Column(Float)
    discountable = Column(Boolean)
    total_quantity = Column(Integer)
    total_amount = Column(Float)
    total_payable = Column(Float)
    pharmacy_id = Column(Integer, ForeignKey("pharmacy.id"))
    pharmacy = relationship("Pharmacy", backref="reservation", lazy='selectin')
    products = relationship("ReservationProducts", back_populates="reservation", lazy='selectin')
    manufactured_company_id = Column(Integer, ForeignKey("manufactured_company.id"))
    manufactured_company = relationship("ManufacturedCompany", backref="reservation", lazy='selectin')
    checked = Column(Boolean, default=False)

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
                result = await db.execute(select(CurrentFactoryWarehouse).filter(CurrentFactoryWarehouse.factory_id==kwargs['manufactured_company_id']))
                wrh = result.scalar()
                if (not wrh) or wrh.amount < product['quantity']: 
                    raise HTTPException(status_code=404, detail=f"There is not enough {prd.name} in warehouse")
                res_products.append(ReservationProducts(**product))
                total_quantity += product['quantity']
                total_amount += product['quantity'] * prd.price
            total_payable = total_amount - total_amount * kwargs['discount'] / 100 if kwargs['discountable'] == True else total_amount
            reservation = cls(**kwargs,
                                total_quantity = total_quantity,
                                total_amount = total_amount,
                                total_payable = total_payable)
            db.add(reservation)
            for p in res_products:
                reservation.products.append(p)
            await db.commit()
            return reservation
        except IntegrityError as e:
            raise HTTPException(status_code=404, detail=str(e.orig).split('DETAIL:  ')[1].replace('.\n', ''))
            
    async def check_reservation(self, check, db: AsyncSession):
        self.ckeck = check
        for product in self.products:
            result = await db.execute(select(CurrentFactoryWarehouse).filter(CurrentFactoryWarehouse.factory_id==self.manufactured_company_id))
            wrh = result.scalar()
            if (not wrh) and wrh.amount < product.quantity: 
                raise HTTPException(status_code=404, detail=f"There is not enough {product.name} in warehouse")
            wrh.amount -= product.quantity
        await db.commit()

    async def update_expire_date(self, date: date, db: AsyncSession):
        try:
            self.expire_date = date
            await db.commit()
        except IntegrityError as e:
            raise HTTPException(status_code=404, detail=str(e.orig).split('DETAIL:  ')[1].replace('.\n', ''))


class ReservationProducts(Base):
    __tablename__ = "reservation_products"

    id = Column(Integer, primary_key=True)
    quantity = Column(Integer)
    product_id = Column(Integer, ForeignKey("products.id"))
    product = relationship("Products", backref="reservaion_products", lazy='selectin')
    reservation_id = Column(Integer, ForeignKey("reservation.id"))
    reservation = relationship("Reservation", back_populates="products")


class PharmacyFact(Base):
    __tablename__ = "pharmacy_fact"

    id = Column(Integer, primary_key=True)
    quantity = Column(Integer)
    date = Column(DateTime, default=datetime.now())
    monthly_plan = Column(Integer)

    doctor_id = Column(Integer, ForeignKey("doctor.id"))
    doctor = relationship("Doctor", backref="fact", lazy='selectin')
    product_id = Column(Integer, ForeignKey("products.id"))
    product = relationship("Products", backref="fact", lazy='selectin')
    pharmacy_id = Column(Integer, ForeignKey("pharmacy.id"))
    pharmacy = relationship("Pharmacy", backref="fact", lazy='selectin')

    @classmethod
    async def save(cls, db: AsyncSession, **kwargs):
        try:
            for doctor in kwargs['doctors']:
                for product in doctor['products']:
                    result = await db.execute(select(DoctorAttachedProduct).filter(DoctorAttachedProduct.doctor_id == doctor['doctor_id'], DoctorAttachedProduct.product_id == product['product_id']))
                    prod = result.scalars().first()
                    if not prod:
                        raise HTTPException(status_code=404, detail=f"This product(id={product['product_id']}) is not attached to this doctor(id={doctor['doctor_id']})")
                    result = await db.execute(select(CurrentBalanceInStock).filter(CurrentBalanceInStock.pharmacy_id==kwargs['pharmacy_id'], CurrentBalanceInStock.product_id==product['product_id']))
                    current_stock = result.scalar()
                    if (not current_stock) or (current_stock.amount < product['compleated']):
                        raise HTTPException(status_code=404, detail=f"There is nt enough product(id={product['product_id']}) in this pharmacy(id={kwargs['pharmacy_id']})")
                    current_stock.amount -= product['compleated']
                    prod.fact =  product['compleated']
                    p_fact = cls(pharmacy_id = kwargs['pharmacy_id'], doctor_id = doctor['doctor_id'], product_id = product['product_id'], quantity = product['compleated'], monthly_plan=prod.monthly_plan) 
                    db.add(p_fact)
            await db.commit()
        except IntegrityError as e:
            raise HTTPException(status_code=404, detail=str(e.orig).split('DETAIL:  ')[1].replace('.\n', ''))


class Pharmacy(Base):
    __tablename__ = "pharmacy"

    id = Column(Integer, primary_key=True)
    company_name = Column(String)
    contact1 = Column(String)
    contact2 = Column(String)
    email = Column(String)
    latitude = Column(String)
    longitude = Column(String)
    address = Column(String)
    bank_account_number = Column(String)
    inter_branch_turnover = Column(String)
    classification_of_economic_activities = Column(String)
    VAT_payer_code = Column(String)
    pharmacy_director = Column(String)
    discount = Column(Float, default=0)
    brand_name = Column(String, nullable=True)
    
    med_rep_id = Column(Integer, ForeignKey("users.id"))
    med_rep = relationship("Users", backref="mr_pharmacy", foreign_keys=[med_rep_id])
    region_manager_id = Column(Integer, ForeignKey("users.id"))
    region_manager = relationship("Users", backref="rm_pharmacy", foreign_keys=[region_manager_id])
    ffm_id = Column(Integer, ForeignKey("users.id"))
    ffm = relationship("Users", backref="ffm_pharmacy", foreign_keys=[ffm_id])
    product_manager_id = Column(Integer, ForeignKey("users.id"))
    product_manager = relationship("Users", backref="pm_pharmacy", foreign_keys=[product_manager_id])
    deputy_director_id = Column(Integer, ForeignKey("users.id"))   
    deputy_director = relationship("Users",  foreign_keys=[deputy_director_id])
    director_id = Column(Integer, ForeignKey("users.id"))    
    director = relationship("Users",  foreign_keys=[director_id])
    region = relationship("Region", backref="pharmacy", lazy='selectin')
    region_id = Column(Integer, ForeignKey("region.id")) 
    doctors = relationship("Doctor",  secondary="pharmacy_doctor", back_populates="pharmacy")
    pharmacy_attached_product = relationship("PharmacyAttachedProducts", back_populates="pharmacy")

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
            self.contact1 = kwargs.get('contact1', self.contact1)
            self.contact2 = kwargs.get('contact2', self.contact2)
            self.email = kwargs.get('email', self.email)
            self.brand_name = kwargs.get('brand_name', self.brand_name)
            self.address = kwargs.get('address', self.address)
            self.latitude = kwargs.get('latitude', self.latitude)
            self.longitude = kwargs.get('longitude', self.longitude)
            self.bank_account_number = kwargs.get('bank_account_number', self.bank_account_number)
            self.inter_branch_turnover = kwargs.get('inter_branch_turnover', self.inter_branch_turnover)
            self.classification_of_economic_activities = kwargs.get('classification_of_economic_activities', self.classification_of_economic_activities)
            self.VAT_payer_code = kwargs.get('VAT_payer_code', self.VAT_payer_code)
            self.pharmacy_director = kwargs.get('pharmacy_director', self.pharmacy_director)
            self.med_rep_id = kwargs.get('med_rep_id', self.med_rep_id)
            self.region_manager_id = kwargs.get('region_manager_id', self.region_manager_id)
            self.ffm_id = kwargs.get('ffm_id', self.ffm_id)
            self.product_manager_id = kwargs.get('product_manager_id', self.product_manager_id)
            self.deputy_director_id = kwargs.get('deputy_director_id', self.deputy_director_id)
            self.director_id = kwargs.get('director_id', self.director_id)
            self.region_id = kwargs.get('region_id', self.region_id)
            db.add(self)
            await db.commit()
            await db.refresh(self)
        except IntegrityError as e:
            raise HTTPException(status_code=404, detail=str(e.orig).split('DETAIL:  ')[1].replace('.\n', ''))

    async def attach_doctor(self, db: AsyncSession, **kwargs):
        try:
            # doctor_product_result = await db.execute(select(DoctorAttachedProduct).filter(DoctorAttachedProduct.doctor_id==kwargs.get('doctor_id'), DoctorAttachedProduct.product_id==kwargs.get('product_id')))
            # doctor_product = doctor_product_result.scalar()
            # if not doctor_product:
            #     raise HTTPException(status_code=400, detail="This product not attached to a doctor")
            
            # result = await db.execute(select(pharmacy_doctor).filter(
            #         and_(or_(pharmacy_doctor.c.doctor_id == kwargs.get('doctor_id'),
            #             pharmacy_doctor.c.product_id == kwargs.get('product_id')),
            #             pharmacy_doctor.c.pharmacy_id == kwargs.get('pharmacy_id')
            #             )))
            # doc =  result.scalar()
            
            # if not doc:
            # association_entry = pharmacy_doctor.insert().values(
            #     doctor_id=kwargs.get('doctor_id'),
            #     pharmacy_id=self.id,
            #     product_id=kwargs.get('product_id')
            # )
            # await db.execute(association_entry)
            doctor = await db.get(Doctor, kwargs.get('doctor_id'))
            if (not doctor) or (doctor.deleted == True):
                raise HTTPException(status_code=404, detail=f"Doctor not found")
            # await self.doctors.append(doctor)
            association_entry = pharmacy_doctor.insert().values(
                doctor_id=kwargs.get('doctor_id'),
                pharmacy_id=self.id,
            )
            await db.commit()
            # else:
                # raise HTTPException(status_code=400, detail="This doctor already attached")
        except IntegrityError as e:
            raise HTTPException(status_code=404, detail=str(e.orig).split('DETAIL:  ')[1].replace('.\n', ''))

    async def set_discount(self, discount: float, db: AsyncSession):
        try:
            self.discount = discount
            await db.commit()
            await db.refresh(self)
        except IntegrityError as e:
            raise HTTPException(status_code=404, detail=str(e.orig).split('DETAIL:  ')[1].replace('.\n', ''))
