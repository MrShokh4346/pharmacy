from app.services.bonusService import BonusService
from app.services.doctorPostupleniyaFactService import DoctorPostupleniyaFactService
from sqlalchemy import Boolean, Column, ForeignKey, Integer, String, Float, DateTime, Sequence, text
from sqlalchemy.orm import relationship
from sqlalchemy.ext.asyncio import AsyncSession
from fastapi import Depends, FastAPI, HTTPException, status
from .doctors import DoctorPostupleniyaFact, Bonus
from datetime import date, datetime, timedelta 
from .users import Product
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import selectinload
from sqlalchemy.future import select
from .database import  get_db, get_or_404
from db.db import Base


class ReportFactoryWerehouse(Base):
    __tablename__ = "report_factory_warehouse"
    

    id = Column(Integer, primary_key=True)
    date = Column(DateTime, default=datetime.now())
    quantity = Column(Integer)
    factory_id = Column(Integer, ForeignKey("manufactured_company.id"))
    factory = relationship("ManufacturedCompany", backref="factory_report_werehouse", lazy='selectin')
    product_id = Column(Integer, ForeignKey("products.id"))
    product = relationship("Product", backref="factory_report_werehouse", lazy='selectin')

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
    product = relationship("Product", backref="factory_current_werehouse", lazy='selectin')

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
#     date = Column(DateTime, default=datetime.now())
#     factory_id = Column(Integer, ForeignKey("manufactured_company.id"), nullable=True)
#     factory = relationship("ManufacturedCompany", backref="wholesale_report_warehouse", lazy='selectin')
#     wholesale_id = Column(Integer, ForeignKey("wholesale.id"), nullable=True)
#     wholesale = relationship("Wholesale", backref="wholesale_report_warehouse", lazy='selectin')
#     product_id = Column(Integer, ForeignKey("products.id"))
#     product = relationship("Product", backref="wholesale_report_warehouse", lazy='selectin')

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
    product = relationship("Product", backref="wholesale_current_warehouse", lazy='selectin')

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
    amount = Column(Integer, default=0)
    total_sum = Column(Integer)
    remainder_sum = Column(Integer, default=0)
    nds_sum = Column(Integer , default=0)
    fot_sum = Column(Integer , default=0)
    promo_sum = Column(Integer , default=0)
    skidka_sum = Column(Integer , default=0)
    pure_proceeds = Column(Integer , default=0)
    quantity = Column(Integer)
    description = Column(String)
    payed = Column(Boolean, default=False)
    date = Column(DateTime, default=datetime.now())
    product_id = Column(Integer, ForeignKey("products.id", ondelete="CASCADE"))
    product = relationship("Product", cascade="all, delete", backref="wholesale_payed_amounts", lazy='selectin')
    doctor_id = Column(Integer, ForeignKey("doctor.id", ondelete="CASCADE"))
    doctor = relationship("Doctor", backref="wholesale_payed_amounts", lazy='selectin')
    pharmacy_id = Column(Integer, ForeignKey("pharmacy.id", ondelete="CASCADE"))
    pharmacy = relationship("Pharmacy", backref="wholesale_payed_amounts", cascade="all, delete", lazy='selectin')
    med_rep_id = Column(Integer, ForeignKey("users.id"))
    med_rep = relationship("Users", backref="wholesale_payed_amounts", lazy='selectin')
    reservation_id = Column(Integer, ForeignKey("wholesale_reservation.id", ondelete="CASCADE"))
    reservation = relationship("WholesaleReservation", cascade="all, delete", back_populates="wholesale_payed_amounts", lazy='selectin')
   
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
    date = Column(DateTime, default=datetime.now(), index=True)
    date_implementation = Column(DateTime)
    expire_date = Column(DateTime, default=(datetime.now() + timedelta(days=60)))
    discount = Column(Float, default=0)
    discountable = Column(Boolean)
    bonus = Column(Boolean, default=True)
    total_quantity = Column(Integer)
    total_amount = Column(Float)
    total_payable = Column(Float)
    total_payable_with_nds = Column(Float)
    invoice_number = Column(Integer, invoice_number_seq, unique=True, server_default=invoice_number_seq.next_value())
    profit = Column(Integer, default=0)
    debt = Column(Integer)
    reailized_debt = Column(Integer, default=0)
    prosrochenniy_debt = Column(Boolean, default=False)
    med_rep_id = Column(Integer, ForeignKey("users.id"), index=True)    
    med_rep = relationship("Users",  backref="wholesale_reservation")
    wholesale_id = Column(Integer, ForeignKey("wholesale.id", ondelete="CASCADE"), index=True)
    wholesale = relationship("Wholesale", backref="wholesale_reservation", cascade="all, delete", lazy='selectin')
    products = relationship("WholesaleReservationProducts", cascade="all, delete", back_populates="wholesale_reservation", lazy='selectin')
    manufactured_company_id = Column(Integer, ForeignKey("manufactured_company.id"), index=True)
    manufactured_company = relationship("ManufacturedCompany", backref="wholesale_reservation", lazy='selectin')
    wholesale_payed_amounts = relationship("WholesaleReservationPayedAmounts", cascade="all, delete", back_populates="reservation", lazy='selectin')
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
                prd = await get_or_404(Product, product['product_id'], db)
                price = product['price'] if product['price'] else prd.price
                result = await db.execute(select(CurrentFactoryWarehouse).filter(CurrentFactoryWarehouse.factory_id==kwargs['manufactured_company_id'], CurrentFactoryWarehouse.product_id==product['product_id']))
                wrh = result.scalar()
                if (not wrh) or wrh.amount < product['quantity']: 
                    raise HTTPException(status_code=404, detail=f"There is not enough {prd.name} in factory warehouse")
                reservation_price = ((price - price * kwargs['discount'] / 100) * 1.12)
                res_products.append(WholesaleReservationProducts(
                                    quantity = product['quantity'],
                                    product_id = product['product_id'],
                                    reservation_price=price, 
                                    not_payed_quantity=product['quantity'])
                                    )
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

    async def update_date_implementation(self, date, db: AsyncSession):
        try:
            self.date_implementation = date
            await db.commit()
        except IntegrityError as e:
            raise HTTPException(status_code=404, detail=str(e.orig).split('DETAIL:  ')[1].replace('.\n', ''))

    async def delete(self, db: AsyncSession):
        if self.checked == True:
            raise HTTPException(status_code=404, detail="This reservstion confirmed")
        query = f"delete from wholesale_reservation WHERE id={self.id}"  
        result = await db.execute(text(query))
        await db.commit()

    async def update_discount(self, discount: float, db: AsyncSession):
        # if self.checked == True:
        #     raise HTTPException(status_code=400, detail=f"This reservation already chacked")
        for product in self.products:
            product.price = (product.price * (100 / (100 - self.discount)) * (1 - discount / 100))
        self.total_payable =( self.total_payable * (100 / (100 - self.discount)) * (1 - discount / 100))
        self.total_payable_with_nds = (self.total_payable_with_nds * (100 / (100 - self.discount)) * (1 - discount / 100))
        self.debt = (self.debt * (100 / (100 - self.discount)) * (1 - discount / 100))
        self.discount = discount
        await db.commit()

    async def pay_reservation(self, db: AsyncSession, **kwargs):
        try:
            query = text(f'SELECT product_id FROM wholesale_reservation_products WHERE reservation_id={self.id}')
            result = await db.execute(query)
            product_ids = [row[0] for row in result.all()]
            current = sum([obj['amount'] * obj['quantity'] for obj in kwargs['objects']])
            
            # agar pul tulansa pulni uzini saqlaydi, hechqaysi obyektga bog'lamasdan, historyda faqat tulangan summa ko'rinishi uchun
            remaind = None
            if kwargs['total'] > 0:
                remaind = kwargs['total'] - self.reailized_debt
                self.reailized_debt -= kwargs['total']
                if self.reailized_debt < 0:
                    self.reailized_debt = 0
                self.debt -= kwargs['total']
                if self.debt < 0:
                    self.debt = 0
                self.profit += kwargs['total']
                if remaind > 0:
                    for prd in self.wholesale_payed_amounts:
                        prd.remainder_sum = remaind
                reservation = WholesaleReservationPayedAmounts(
                        total_sum=kwargs['total'], 
                        amount=kwargs['total'],
                        description=kwargs['description'], 
                        reservation_id=self.id, 
                        payed=True
                        )
                await reservation.save(db)
            
            for obj in kwargs['objects']:
                if obj['product_id'] not in product_ids:
                    raise HTTPException(status_code=404, detail=f"No product found in this reservation with this id (product_id={obj['product_id']})")
                self.reailized_debt += obj['amount'] * obj['quantity']

                result = await db.execute(select(Product).filter(Product.id==obj['product_id']))
                product = result.scalar()
                nds_sum = obj['amount'] - obj['amount']/1.12 
                skidka_sum = product.price - obj['amount']/1.12 
                    
                # agar pul kiritmasdan dorilarni kiritsa doctorga fact va bonus yozadi
                reservation = WholesaleReservationPayedAmounts(
                                        amount=obj['amount'] * obj['quantity'],
                                        quantity=obj['quantity'], 
                                        description=kwargs['description'], 
                                        reservation_id=self.id, 
                                        product_id=obj['product_id'], 
                                        doctor_id=obj['doctor_id'],
                                        pharmacy_id=kwargs['pharmacy_id'],
                                        med_rep_id=kwargs['med_rep_id']
                                        )
                await reservation.save(db)
                await WholesaleReservationProducts.set_payed_quantity(
                            quantity=obj['quantity'],
                            reservation_id=reservation.reservation_id,
                            product_id=obj['product_id'],
                            db=db
                            )   
                if self.bonus == True:
                    await DoctorPostupleniyaFactService.set_fact(price=obj['amount'], fact_price=obj['amount'] * obj['quantity'], product_id=obj['product_id'], doctor_id=obj['doctor_id'], compleated=obj['quantity'], month_number=obj['month_number'], db=db)
                    await BonusService.set_bonus(product_id=obj['product_id'], doctor_id=obj['doctor_id'], compleated=obj['quantity'], month_number=obj['month_number'], db=db)
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
    not_payed_quantity = Column(Integer)
    product_id = Column(Integer, ForeignKey("products.id"))
    reservation_price = Column(Float)
    # reservation_discount_price = Column(Integer)
    product = relationship("Product", backref="wholesale_reservaion_products", lazy='selectin')
    reservation_id = Column(Integer, ForeignKey("wholesale_reservation.id", ondelete="CASCADE"))
    wholesale_reservation = relationship("WholesaleReservation", cascade="all, delete", back_populates="products")

    @classmethod
    async def set_payed_quantity(cls, db: AsyncSession, **kwargs):
        query = f"update wholesale_reservation_products set not_payed_quantity=not_payed_quantity-{kwargs['quantity']} WHERE reservation_id={kwargs['reservation_id']} AND product_id={kwargs['product_id']} returning not_payed_quantity"  
        result = await db.execute(text(query))
        quantity = result.scalar()
        if quantity < 0:
            raise HTTPException(status_code=400, detail="Quantity couldn't be lower then 0")


class WholesaleOutput(Base):
    __tablename__ = "wholesale_output"
    

    id = Column(Integer, primary_key=True)

    amount = Column(Integer)
    date = Column(DateTime, default=datetime.now())
    pharmacy = Column(String)
    product_id = Column(Integer, ForeignKey("products.id"))
    product = relationship("Product", backref="wholesale_output", lazy='selectin')
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