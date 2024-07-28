from sqlalchemy import Boolean, Column, ForeignKey, Integer, String, Float, DateTime, Sequence, text
from sqlalchemy.orm import relationship
from sqlalchemy.ext.asyncio import AsyncSession
from fastapi import Depends, FastAPI, HTTPException, status
from .doctors import Doctor, pharmacy_doctor
from datetime import date, datetime, timedelta 
from .users import Products
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import selectinload
from sqlalchemy.future import select
from .database import Base, get_db, get_or_404


class ReportFactoryWerehouse(Base):
    __tablename__ = "report_factory_warehouse"

    id = Column(Integer, primary_key=True)
    date = Column(DateTime, default=date.today())
    quantity = Column(Integer)
    factory_id = Column(Integer, ForeignKey("manufactured_company.id"))
    factory = relationship("ManufacturedCompany", backref="factory_report_werehouse", lazy='selectin')
    product_id = Column(Integer, ForeignKey("products.id"))
    product = relationship("Products", backref="factory_report_werehouse", lazy='selectin')

    @classmethod
    async def save(cls, db: AsyncSession, **kwargs):
        try:
            report = cls(**kwargs)
            current = await CurrentFactoryWarehouse.add(product_id=kwargs['product_id'], factory_id=kwargs['factory_id'], amount=kwargs['quantity'], db=db)
            db.add(report)
            await db.commit()
            return report
        except IntegrityError as e:
            raise HTTPException(status_code=404, detail=str(e.orig).split('DETAIL:  ')[1].replace('.\n', ''))


class CurrentFactoryWarehouse(Base):
    __tablename__ = "current_factory_warehouse"

    id = Column(Integer, primary_key=True)
    amount = Column(Integer)
    factory_id = Column(Integer, ForeignKey("manufactured_company.id"))
    factory = relationship("ManufacturedCompany", backref="current_werehouse", lazy='selectin')
    product_id = Column(Integer, ForeignKey("products.id"))
    product = relationship("Products", backref="factory_current_werehouse", lazy='selectin')

    @classmethod
    async def add(cls, db: AsyncSession, **kwargs):
        result = await db.execute(select(cls).filter(cls.product_id==kwargs['product_id'], cls.factory_id==kwargs['factory_id']))
        current = result.scalars().first()
        if not current:
            current = cls(product_id=kwargs['product_id'], factory_id=kwargs['factory_id'], amount=kwargs['amount'])
            db.add(current)
        else:
            current.amount += kwargs['amount']
        return current


class Wholesale(Base):
    __tablename__ = "wholesale"

    id = Column(Integer, primary_key=True)
    name = Column(String)
    contact = Column(String)
    region_id = Column(Integer, ForeignKey("region.id")) 
    region = relationship("Region", backref="wholesales", lazy='selectin')
    report_warehouse = relationship("CurrentWholesaleWarehouse", cascade="all, delete", back_populates="wholesale", lazy='selectin')

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
            self.name = kwargs.get('name', self.name)
            self.contact = kwargs.get('contact', self.contact)
            self.region_id = kwargs.get('region_id', self.region_id)
            db.add(self)
            await db.commit()
            await db.refresh(self)
        except IntegrityError as e:
            raise HTTPException(status_code=404, detail=str(e.orig).split('DETAIL:  ')[1].replace('.\n', ''))

    async def add(self, db: AsyncSession, **kwargs):
        try:
            result = await db.execute(select(CurrentFactoryWarehouse).filter(CurrentFactoryWarehouse.product_id==kwargs['product_id'], CurrentFactoryWarehouse.factory_id==kwargs['factory_id']))
            current = result.scalars().first()
            if (not current) or (current.amount < kwargs['quantity']):
                raise HTTPException(status_code=400, detail="There isn't enough product in factory warehouse")
            # wh_product = ReportWholesaleWarehouse(**kwargs, wholesale_id=self.id)
            # await wh_product.save(db=db, wholesale_id=self.id, **kwargs)
            current.amount -= kwargs['quantity']
            await db.commit()
        except IntegrityError as e:
            raise HTTPException(status_code=404, detail=str(e.orig).split('DETAIL:  ')[1].replace('.\n', ''))


# class ReportWholesaleWarehouse(Base):
#     __tablename__ = "report_wholesale_warehouse"

#     id = Column(Integer, primary_key=True)
#     quantity = Column(Integer)
#     price = Column(Integer)
#     date = Column(DateTime, default=date.today())
#     factory_id = Column(Integer, ForeignKey("manufactured_company.id"), nullable=True)
#     factory = relationship("ManufacturedCompany", backref="wholesale_report_warehouse", lazy='selectin')
#     wholesale_id = Column(Integer, ForeignKey("wholesale.id"), nullable=True)
#     wholesale = relationship("Wholesale", backref="wholesale_report_warehouse", lazy='selectin')
#     product_id = Column(Integer, ForeignKey("products.id"))
#     product = relationship("Products", backref="wholesale_report_warehouse", lazy='selectin')

#     async def save(self, db: AsyncSession, **kwargs):
#         try:
#             db.add(self)
#             await CurrentWholesaleWarehouse.add(product_id=kwargs['product_id'], wholesale_id=kwargs['wholesale_id'], amount=kwargs['quantity'], price=kwargs['price'], db=db)
#             await db.commit()
#         except IntegrityError as e:
#             raise HTTPException(status_code=404, detail=str(e.orig).split('DETAIL:  ')[1].replace('.\n', ''))


class CurrentWholesaleWarehouse(Base):
    __tablename__ = "current_wholesale_warehouse"

    id = Column(Integer, primary_key=True)
    amount = Column(Integer)
    price = Column(Integer)
    wholesale_id = Column(Integer, ForeignKey("wholesale.id", ondelete="CASCADE"))
    wholesale = relationship("Wholesale", cascade="all, delete",  back_populates="report_warehouse", lazy='selectin')
    product_id = Column(Integer, ForeignKey("products.id"))
    product = relationship("Products", backref="wholesale_current_warehouse", lazy='selectin')

    @classmethod
    async def add(cls, db: AsyncSession, **kwargs):
        result = await db.execute(select(cls).filter(cls.product_id==kwargs['product_id'], cls.wholesale_id==kwargs['wholesale_id']))
        current = result.scalars().first()
        if not current:
            current = cls(product_id=kwargs['product_id'], wholesale_id=kwargs['wholesale_id'], amount=kwargs['amount'], price = kwargs['price'])
            db.add(current)
        else:
            current.amount += kwargs['amount']
            current.price = kwargs['price']
        return current


class WholesaleReservationPayedAmounts(Base):
    __tablename__ = "wholesale_reservation_payed_amounts"

    id = Column(Integer, primary_key=True)
    amount = Column(Integer)
    description = Column(String)
    date = Column(DateTime, default=date.today())
    product_id = Column(Integer, ForeignKey("products.id", ondelete="CASCADE"))
    product = relationship("Products", cascade="all, delete", backref="wholesale_payed_amounts", lazy='selectin')
    doctor_id = Column(Integer, ForeignKey("doctor.id", ondelete="CASCADE"))
    doctor = relationship("Doctor", backref="wholesale_payed_amounts", lazy='selectin')
    pharmacy_id = Column(Integer, ForeignKey("pharmacy.id", ondelete="CASCADE"))
    pharmacy = relationship("Pharmacy", backref="wholesale_payed_amounts", cascade="all, delete", lazy='selectin')
    med_rep_id = Column(Integer, ForeignKey("users.id"))
    med_rep = relationship("Users", backref="wholesale_payed_amounts", lazy='selectin')
    reservation_id = Column(Integer, ForeignKey("wholesale_reservation.id", ondelete="CASCADE"))
    reservation = relationship("WholesaleReservation", cascade="all, delete", backref="wholesale_payed_amounts")
   
    async def save(self, db: AsyncSession):
        try:
            db.add(self)
            # await db.commit()
            # await db.refresh(self)
        except IntegrityError as e:
            raise HTTPException(status_code=404, detail=str(e.orig).split('DETAIL:  ')[1].replace('.\n', ''))


invoice_number_seq = Sequence('invoice_number_seq')


class WholesaleReservation(Base):
    __tablename__ = "wholesale_reservation"

    id = Column(Integer, primary_key=True)
    date = Column(DateTime, default=date.today())
    date_implementation = Column(DateTime)
    expire_date = Column(DateTime, default=(datetime.now() + timedelta(days=10)))
    discount = Column(Float, default=0)
    discountable = Column(Boolean)
    total_quantity = Column(Integer)
    total_amount = Column(Float)
    total_payable = Column(Float)
    total_payable_with_nds = Column(Float)
    invoice_number = Column(Integer, invoice_number_seq, server_default=invoice_number_seq.next_value())
    profit = Column(Integer, default=0)
    debt = Column(Integer)
    med_rep_id = Column(Integer, ForeignKey("users.id"))    
    med_rep = relationship("Users",  backref="wholesale_reservation")
    wholesale_id = Column(Integer, ForeignKey("wholesale.id", ondelete="CASCADE"))
    wholesale = relationship("Wholesale", backref="wholesale_reservation", cascade="all, delete", lazy='selectin')
    products = relationship("WholesaleReservationProducts", cascade="all, delete", back_populates="wholesale_reservation", lazy='selectin')
    manufactured_company_id = Column(Integer, ForeignKey("manufactured_company.id"))
    manufactured_company = relationship("ManufacturedCompany", backref="wholesale_reservation", lazy='selectin')
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
                result = await db.execute(select(CurrentFactoryWarehouse).filter(CurrentFactoryWarehouse.factory_id==kwargs['manufactured_company_id'], CurrentFactoryWarehouse.product_id==product['product_id']))
                wrh = result.scalar()
                if (not wrh) or wrh.amount < product['quantity']: 
                    raise HTTPException(status_code=404, detail=f"There is not enough {prd.name} in factory warehouse")
                res_products.append(WholesaleReservationProducts(**product))
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
            raise HTTPException(status_code=400, detail=f"This reservation already chacked")
        self.checked = kwargs.get('checked')
        self.date_implementation = datetime.now()
        for product in self.products:
            result = await db.execute(select(CurrentFactoryWarehouse).filter(CurrentFactoryWarehouse.factory_id==self.manufactured_company_id, CurrentFactoryWarehouse.product_id==product.product_id))
            wrh = result.scalar()
            if (not wrh) or wrh.amount < product.quantity: 
                raise HTTPException(status_code=404, detail=f"There is not enough {product.product.name} in warehouse")
            wrh.amount -= product.quantity
            await CurrentWholesaleWarehouse.add(product_id=product.product_id, wholesale_id=self.wholesale_id, amount=product.quantity, price=product.price, db=db)
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
        # await db.delete(self)
        query = f"delete from wholesale_reservation WHERE id={self.id}"  
        result = await db.execute(text(query))
        await db.commit()

    async def update_discount(self, discount: int, db: AsyncSession):
        if self.checked == True:
            raise HTTPException(status_code=400, detail=f"This reservation already chacked")
        for product in self.products:
            product.price = product.price * (100 / (100 - self.discount)) * (1 - discount / 100)
        self.total_payable = self.total_payable * (100 / (100 - self.discount)) * (1 - discount / 100)
        self.total_payable_with_nds = self.total_payable_with_nds * (100 / (100 - self.discount)) * (1 - discount / 100)
        self.discount = discount
        await db.commit()

    async def pay_reservation(self, db: AsyncSession, **kwargs):
        try:
            query = text(f'SELECT product_id FROM wholesale_reservation_products WHERE reservation_id={self.id}')
            result = await db.execute(query)
            product_ids = [row[0] for row in result.all()]
            for obj in kwargs['objects']:
                if obj['product_id'] not in product_ids:
                    raise HTTPException(status_code=404, detail=f"No product found in this reservation with this id (product_id={obj['product_id']})")
                self.debt -= obj['amount']
                self.profit += obj['amount']
                reservation = WholesaleReservationPayedAmounts(
                                        amount=obj['amount'], 
                                        description=kwargs['description'], 
                                        reservation_id=self.id, 
                                        product_id=obj['product_id'], 
                                        doctor_id=obj['doctor_id'],
                                        pharmacy_id=kwargs['pharmacy_id'],
                                        med_rep_id=kwargs['med_rep_id']
                                        )
                await reservation.save(db)
                if self.debt < 0:
                    raise HTTPException(status_code=400, detail=f"This reservation already chacked")
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


class WholesaleReservationProducts(Base):
    __tablename__ = "wholesale_reservation_products"

    id = Column(Integer, primary_key=True)
    quantity = Column(Integer)
    product_id = Column(Integer, ForeignKey("products.id"))
    price = Column(Integer)
    # reservation_discount_price = Column(Integer)
    product = relationship("Products", backref="wholesale_reservaion_products", lazy='selectin')
    reservation_id = Column(Integer, ForeignKey("wholesale_reservation.id", ondelete="CASCADE"))
    wholesale_reservation = relationship("WholesaleReservation", cascade="all, delete", back_populates="products")


class WholesaleOutput(Base):
    __tablename__ = "wholesale_output"

    id = Column(Integer, primary_key=True)

    amount = Column(Integer)
    date = Column(DateTime, default=date.today())
    pharmacy = Column(String)
    product_id = Column(Integer, ForeignKey("products.id"))
    product = relationship("Products", backref="wholesale_output", lazy='selectin')
    wholesale_id = Column(Integer, ForeignKey("wholesale.id"), nullable=True)
    wholesale = relationship("Wholesale", backref="warehouse_output", lazy='selectin')

    async def save(self, wholesale_id: int, db: AsyncSession):
        try:
            result = await db.execute(select(CurrentWholesaleWarehouse).filter(CurrentWholesaleWarehouse.wholesale_id==wholesale_id))
            current = result.scalars().first()
            if (not current) or (current.amount < self.amount):
                raise HTTPException(status_code=404, detail='THere is not enough product in wholesale warehouse')
            current.amount -= self.amount
            db.add(self)
            await db.commit()
            await db.refresh(self)
        except IntegrityError as e:
            raise HTTPException(status_code=404, detail=str(e.orig).split('DETAIL:  ')[1].replace('.\n', ''))