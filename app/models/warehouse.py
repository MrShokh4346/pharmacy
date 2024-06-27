from sqlalchemy import Boolean, Column, ForeignKey, Integer, String, Float, DateTime
from sqlalchemy.orm import relationship
from sqlalchemy.ext.asyncio import AsyncSession
from fastapi import Depends, FastAPI, HTTPException, status
from .doctors import Doctor, pharmacy_doctor
from datetime import date, datetime 
from .users import Products
from sqlalchemy.exc import IntegrityError
from sqlalchemy.future import select
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
    report_warehouse = relationship("CurrentWholesaleWarehouse", back_populates="wholesale", lazy='selectin')

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
            wh_product = ReportWholesaleWarehouse(**kwargs, wholesale_id=self.id)
            await wh_product.save(db=db, wholesale_id=self.id, **kwargs)
            current.amount -= kwargs['quantity']
            await db.commit()
        except IntegrityError as e:
            raise HTTPException(status_code=404, detail=str(e.orig).split('DETAIL:  ')[1].replace('.\n', ''))


class ReportWholesaleWarehouse(Base):
    __tablename__ = "report_wholesale_warehouse"

    id = Column(Integer, primary_key=True)
    quantity = Column(Integer)
    price = Column(Integer)
    date = Column(DateTime, default=date.today())
    factory_id = Column(Integer, ForeignKey("manufactured_company.id"))
    factory = relationship("ManufacturedCompany", backref="wholesale_report_warehouse", lazy='selectin')
    wholesale_id = Column(Integer, ForeignKey("wholesale.id"))
    wholesale = relationship("Wholesale", backref="wholesale_report_warehouse", lazy='selectin')
    product_id = Column(Integer, ForeignKey("products.id"))
    product = relationship("Products", backref="wholesale_report_warehouse", lazy='selectin')

    async def save(self, db: AsyncSession, **kwargs):
        try:
            db.add(self)
            await CurrentWholesaleWarehouse.add(product_id=kwargs['product_id'], wholesale_id=kwargs['wholesale_id'], amount=kwargs['quantity'], price=kwargs['price'], db=db)
            await db.commit()
        except IntegrityError as e:
            raise HTTPException(status_code=404, detail=str(e.orig).split('DETAIL:  ')[1].replace('.\n', ''))


class CurrentWholesaleWarehouse(Base):
    __tablename__ = "current_wholesale_warehouse"

    id = Column(Integer, primary_key=True)
    amount = Column(Integer)
    price = Column(Integer)
    wholesale_id = Column(Integer, ForeignKey("wholesale.id"))
    wholesale = relationship("Wholesale", back_populates="report_warehouse", lazy='selectin')
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


class WholesaleOutput(Base):
    __tablename__ = "wholesale_output"

    id = Column(Integer, primary_key=True)

    amount = Column(Integer)
    date = Column(DateTime, default=date.today())
    pharmacy = Column(String)
    product_id = Column(Integer, ForeignKey("products.id"))
    product = relationship("Products", backref="wholesale_output", lazy='selectin')
    wholesale_id = Column(Integer, ForeignKey("wholesale.id"))
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