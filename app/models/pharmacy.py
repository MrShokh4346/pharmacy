from sqlalchemy import Boolean, Column, ForeignKey, Integer, String, Float, DateTime, Sequence
from sqlalchemy.orm import relationship
from sqlalchemy.ext.asyncio import AsyncSession
from fastapi import HTTPException
from datetime import datetime, timedelta
from sqlalchemy.exc import IntegrityError
from sqlalchemy import text, update
from db.db import Base


class IncomingStockProducts(Base):
    __tablename__ = "incoming_stock_products"
    __table_args__ = {'extend_existing': True}
    

    id = Column(Integer, primary_key=True)
    quantity = Column(Integer)

    stock_id = Column(Integer, ForeignKey("incoming_balance_in_stock.id", ondelete="CASCADE"))
    stock = relationship("app.models.pharmacy.IncomingBalanceInStock", cascade="all, delete", back_populates="products")
    product_id = Column(Integer, ForeignKey("products.id"))
    product = relationship("app.models.users.Product", backref="incomingstockproducts")


class IncomingBalanceInStock(Base):
    __tablename__ = "incoming_balance_in_stock"
    __table_args__ = {'extend_existing': True}
    

    id = Column(Integer, primary_key=True)
    date = Column(DateTime, default=datetime.now())
    description = Column(String)

    wholesale_id = Column(Integer, ForeignKey("wholesale.id"))
    wholesale = relationship("app.models.warehouse.Wholesale", backref='balanceinstock')
    factory_id = Column(Integer, ForeignKey("manufactured_company.id"))
    factory = relationship("app.models.users.ManufacturedCompany", backref='balanceinstock')
    pharmacy_id = Column(Integer, ForeignKey("pharmacy.id", ondelete="CASCADE"))
    pharmacy = relationship("app.models.pharmacy.Pharmacy", cascade="all, delete", backref='balanceinstock')
    products = relationship("app.models.pharmacy.IncomingStockProducts", cascade="all, delete", back_populates="stock", lazy='selectin')



class CurrentBalanceInStock(Base):
    __tablename__ = "current_balance_in_stock"
    __table_args__ = {'extend_existing': True}
    

    id = Column(Integer, primary_key=True)
    amount = Column(Integer)

    product_id = Column(Integer, ForeignKey("products.id"))
    product = relationship("app.models.users.Product", backref="currntbalanceinstock", lazy='selectin')
    pharmacy_id = Column(Integer, ForeignKey("pharmacy.id", ondelete="CASCADE"))
    pharmacy = relationship("app.models.pharmacy.Pharmacy", cascade="all, delete", back_populates='currntbalanceinstock', lazy='selectin')


class CheckingStockProducts(Base):
    __tablename__ = "checking_stock_products"
    __table_args__ = {'extend_existing': True}
    

    id = Column(Integer, primary_key=True)
    previous = Column(Integer)
    saled = Column(Integer)
    remainder = Column(Integer)
    chack = Column(Boolean, default=False)

    stock_id = Column(Integer, ForeignKey("checking_balance_in_stock.id", ondelete="CASCADE"))
    stock = relationship("app.models.pharmacy.CheckingBalanceInStock", cascade="all, delete", backref="products")
    product_id = Column(Integer, ForeignKey("products.id"))
    product = relationship("app.models.users.Product", backref="checkingbalanceinstock")


class CheckingBalanceInStock(Base):
    __tablename__ = "checking_balance_in_stock"
    __table_args__ = {'extend_existing': True}
    

    id = Column(Integer, primary_key=True)
    date = Column(DateTime, default=datetime.now())
    description = Column(String)

    pharmacy_id = Column(Integer, ForeignKey("pharmacy.id", ondelete="CASCADE"))
    pharmacy = relationship("app.models.pharmacy.Pharmacy", cascade="all, delete", backref='checkingbalanceinstock')


class Debt(Base):
    __tablename__ = "debt"
    __table_args__ = {'extend_existing': True}
    

    id = Column(Integer, primary_key=True)
    description = Column(String)
    amount = Column(Integer)
    payed = Column(Boolean, default=False) 
    date = Column(DateTime, default=datetime.now())
    pharmacy_id = Column(Integer, ForeignKey("pharmacy.id", ondelete="CASCADE"))
    pharmacy = relationship("app.models.pharmacy.Pharmacy", cascade="all, delete", backref="debts")

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


class ReservationPayedAmounts(Base):
    __tablename__ = "reservation_payed_amounts"
    __table_args__ = {'extend_existing': True}
    

    id = Column(Integer, primary_key=True)
    amount = Column(Integer)
    total_sum = Column(Integer)
    remainder_sum = Column(Integer)
    bonus = Column(Boolean, default=True)
    quantity = Column(Integer)
    description = Column(String)
    month_number=Column(Integer)
    date = Column(DateTime, default=datetime.now())
    product_id = Column(Integer, ForeignKey("products.id", ondelete="CASCADE"))
    product = relationship("app.models.users.Product", cascade="all, delete", backref="reservation_payed_amounts", lazy='selectin')
    doctor_id = Column(Integer, ForeignKey("doctor.id", ondelete="CASCADE"))
    doctor = relationship("app.models.doctors.Doctor", backref="reservation_payed_amounts", lazy='selectin')
    reservation_id = Column(Integer, ForeignKey("reservation.id", ondelete="CASCADE"))
    reservation = relationship("app.models.pharmacy.Reservation", cascade="all, delete", back_populates="payed_amounts", lazy='selectin')
   
    async def save(self, db: AsyncSession):
        try:
            db.add(self)
            # await db.commit()
            # await db.refresh(self)
        except IntegrityError as e:
            raise HTTPException(status_code=404, detail=str(e.orig).split('DETAIL:  ')[1].replace('.\n', ''))


invoice_number_seq = Sequence('invoice_number_seq')


class Reservation(Base):
    __tablename__ = "reservation"
    __table_args__ = {'extend_existing': True}
    

    id = Column(Integer, primary_key=True)
    date = Column(DateTime, default=datetime.now(), index=True)
    date_implementation = Column(DateTime, default=datetime.now())
    expire_date = Column(DateTime, default=(datetime.now() + timedelta(days=30)))
    discount = Column(Float)
    discountable = Column(Boolean)
    bonus = Column(Boolean, default=True)
    description = Column(String)
    reailized_debt = Column(Integer, default=0)
    returned_price = Column(Float, default=0)
    total_quantity = Column(Integer)
    total_amount = Column(Float)
    total_payable = Column(Float)
    total_payable_with_nds = Column(Float)
    invoice_number = Column(Integer, invoice_number_seq, unique=True, server_default=invoice_number_seq.next_value())
    profit = Column(Integer, default=0)
    debt = Column(Integer)
    med_rep_id = Column(Integer, ForeignKey("users.id"), index=True)    
    med_rep = relationship("app.models.users.Users",  backref="reservation")
    prosrochenniy_debt = Column(Boolean, default=False)
    pharmacy_id = Column(Integer, ForeignKey("pharmacy.id", ondelete="CASCADE"), index=True)
    pharmacy = relationship("app.models.pharmacy.Pharmacy", backref="reservation", cascade="all, delete", lazy='selectin')
    products = relationship("app.models.pharmacy.ReservationProducts", cascade="all, delete", back_populates="reservation", lazy='selectin')
    payed_amounts = relationship("app.models.pharmacy.ReservationPayedAmounts", cascade="all, delete", back_populates="reservation", lazy='selectin')
    manufactured_company_id = Column(Integer, ForeignKey("manufactured_company.id"), index=True)
    manufactured_company = relationship("app.models.users.ManufacturedCompany", backref="reservation", lazy='selectin')
    checked = Column(Boolean, default=False)

    async def update_date_implementation(self, date, db: AsyncSession):
        try:
            self.date_implementation = date
            await db.commit()
        except IntegrityError as e:
            raise HTTPException(status_code=404, detail=str(e.orig).split('DETAIL:  ')[1].replace('.\n', ''))

    async def delete(self, db: AsyncSession):
        if self.checked == True:
            raise HTTPException(status_code=404, detail="This reservstion confirmed")
        query = f"delete from reservation WHERE id={self.id}"  
        result = await db.execute(text(query))
        await db.commit()

    async def update_discount(self, discount: float, db: AsyncSession):
        for product in self.products:
            product.reservation_price = (product.reservation_price * (100 / (100 - self.discount)) * (1 - discount / 100))
        self.total_payable = (self.total_payable * (100 / (100 - self.discount)) * (1 - discount / 100))
        self.total_payable_with_nds = (self.total_payable_with_nds * (100 / (100 - self.discount)) * (1 - discount / 100))
        self.debt = (self.debt * (100 / (100 - self.discount)) * (1 - discount / 100))
        self.discount = discount
        await db.commit()

    async def edit_invoice_number(self, invoice_number: int, db: AsyncSession):
        try:
            self.invoice_number = invoice_number
            await db.commit()
            await db.refresh(self)
        except IntegrityError as e:
            raise HTTPException(status_code=404, detail=str(e.orig).split('DETAIL:  ')[1].replace('.\n', ''))


class ReservationProducts(Base):
    __tablename__ = "reservation_products"
    __table_args__ = {'extend_existing': True}
    

    id = Column(Integer, primary_key=True)
    quantity = Column(Integer)
    not_payed_quantity = Column(Integer)
    product_id = Column(Integer, ForeignKey("products.id"))
    reservation_price = Column(Float)
    reservation_discount_price = Column(Integer)
    product = relationship("app.models.users.Product", backref="reservaion_products", lazy='selectin')
    reservation_id = Column(Integer, ForeignKey("reservation.id", ondelete="CASCADE"))
    reservation = relationship("app.models.pharmacy.Reservation", cascade="all, delete", back_populates="products", lazy='selectin')

    @classmethod
    async def set_payed_quantity(cls, db: AsyncSession, **kwargs):
        try:
            query = f"update reservation_products set not_payed_quantity=not_payed_quantity-{kwargs['quantity']} WHERE reservation_id={kwargs['reservation_id']} AND product_id={kwargs['product_id']} returning not_payed_quantity"  
            result = await db.execute(text(query))
            quantity = result.scalar()
            if quantity < 0:
                raise HTTPException(status_code=400, detail="Quantity couldn't be lower then 0")
        except:
            raise HTTPException(status_code=400, detail="Quantity couldn't be lower then 0")

    @classmethod
    async def set_default_payed_quantity(cls, db: AsyncSession, **kwargs):
        query = f"update reservation_products set not_payed_quantity=quantity WHERE reservation_id={kwargs['reservation_id']} AND product_id={kwargs['product_id']} returning not_payed_quantity"  
        result = await db.execute(text(query))
        quantity = result.scalar()
        if quantity < 0:
            raise HTTPException(status_code=400, detail="Quantity couldn't be lower then 0")

    async def update(self, db: AsyncSession, **kwargs):
        try:
            difference = kwargs['quantity'] - self.quantity
            self.quantity = kwargs['quantity']
            self.not_payed_quantity = kwargs['quantity']
            discount = self.reservation.discount
            difference_sum = ((difference * self.product.price * 1.12) * (100 - discount)/100)
            self.reservation.total_quantity += difference
            self.reservation.total_amount += difference * self.product.price
            self.reservation.total_payable += ((difference * self.product.price) * (100 - discount)/100)
            self.reservation.total_payable_with_nds += difference_sum
            self.reservation.debt += difference_sum
            await db.commit()
        except IntegrityError as e:
            raise HTTPException(status_code=404, detail=str(e.orig).split('DETAIL:  ')[1].replace('.\n', ''))

    async def delete(self, db: AsyncSession, **kwargs):
        try:
            query = f"delete from reservation_products WHERE id={self.id}"
            discount = self.reservation.discount
            difference_sum = ((self.quantity * self.product.price * 1.12) * (100 - discount)/100)
            self.reservation.total_quantity -= self.quantity
            self.reservation.total_amount -= self.quantity * self.product.price
            self.reservation.total_payable -= ((self.quantity * self.product.price) * (100 - discount)/100)
            self.reservation.total_payable_with_nds -= difference_sum
            self.reservation.debt -= difference_sum
            result = await db.execute(text(query))
            await db.commit()
        except IntegrityError as e:
            raise HTTPException(status_code=404, detail=str(e.orig).split('DETAIL:  ')[1].replace('.\n', ''))


class PharmacyHotSale(Base):
    __tablename__ = "pharmacy_hot_sale"
    __table_args__ = {'extend_existing': True}
    

    id = Column(Integer, primary_key=True)
    amount = Column(Integer)
    date = Column(DateTime, default=datetime.now(), index=True)

    product_id = Column(Integer, ForeignKey("products.id"), index=True)
    product = relationship("app.models.users.Product", backref="hot_sale_products", lazy='selectin')
    pharmacy_id = Column(Integer, ForeignKey("pharmacy.id", ondelete="CASCADE"), index=True)
    pharmacy = relationship("app.models.pharmacy.Pharmacy", backref="hot_sale", cascade="all, delete", lazy='selectin')

    @classmethod
    async def save(cls, db: AsyncSession, **kwargs):
        try:
            hot_sale = cls(**kwargs)
            db.add(hot_sale)
        except IntegrityError as e:
            raise HTTPException(status_code=404, detail=str(e.orig).split('DETAIL:  ')[1].replace('.\n', ''))


class PharmacyFact(Base):
    __tablename__ = "pharmacy_fact"
    __table_args__ = {'extend_existing': True}
    

    id = Column(Integer, primary_key=True)
    quantity = Column(Integer)
    date = Column(DateTime, default=datetime.now())
    monthly_plan = Column(Integer)

    doctor_id = Column(Integer, ForeignKey("doctor.id", ondelete="CASCADE"), nullable=True)
    doctor = relationship("app.models.doctors.Doctor", backref="pharmacyfact", lazy='selectin')
    product_id = Column(Integer, ForeignKey("products.id"))
    product = relationship("app.models.users.Product", backref="pharmacyfact", lazy='selectin')
    pharmacy_id = Column(Integer, ForeignKey("pharmacy.id", ondelete="CASCADE"))
    pharmacy = relationship("app.models.pharmacy.Pharmacy", backref="pharmacyfact", cascade="all, delete", lazy='selectin')


class Pharmacy(Base):
    __tablename__ = "pharmacy"
    __table_args__ = {'extend_existing': True}
    

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
    med_rep = relationship("app.models.users.Users", backref="mr_pharmacy", foreign_keys=[med_rep_id], lazy='selectin')
    region_manager_id = Column(Integer, ForeignKey("users.id"))
    region_manager = relationship("app.models.users.Users", backref="rm_pharmacy", foreign_keys=[region_manager_id])
    ffm_id = Column(Integer, ForeignKey("users.id"))
    ffm = relationship("app.models.users.Users", backref="ffm_pharmacy", foreign_keys=[ffm_id])
    product_manager_id = Column(Integer, ForeignKey("users.id"))
    product_manager = relationship("app.models.users.Users", backref="pm_pharmacy", foreign_keys=[product_manager_id])
    deputy_director_id = Column(Integer, ForeignKey("users.id"))   
    deputy_director = relationship("app.models.users.Users",  foreign_keys=[deputy_director_id])
    director_id = Column(Integer, ForeignKey("users.id"))    
    director = relationship("app.models.users.Users",  foreign_keys=[director_id])
    region = relationship("app.models.users.Region", backref="pharmacy", lazy='selectin')
    region_id = Column(Integer, ForeignKey("region.id")) 
    doctors = relationship("app.models.doctors.Doctor",  secondary="pharmacy_doctor", passive_deletes=True, back_populates="pharmacy")
    currntbalanceinstock = relationship("app.models.pharmacy.CurrentBalanceInStock", cascade="all, delete", back_populates='pharmacy', lazy='selectin')

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


    async def set_discount(self, discount: float, db: AsyncSession):
        try:
            self.discount = discount
            await db.commit()
            await db.refresh(self)
        except IntegrityError as e:
            raise HTTPException(status_code=404, detail=str(e.orig).split('DETAIL:  ')[1].replace('.\n', ''))


