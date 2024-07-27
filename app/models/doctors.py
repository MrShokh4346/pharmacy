from sqlalchemy import Boolean, Column, ForeignKey, Integer, String, DateTime
from datetime import datetime, date 
from sqlalchemy.orm import relationship
from sqlalchemy.ext.asyncio import AsyncSession
from fastapi import Depends, FastAPI, HTTPException, status
from sqlalchemy import Table
from .database import Base, get_db, get_or_404, check_exists
from sqlalchemy.orm import validates
from sqlalchemy.exc import IntegrityError
from sqlalchemy.future import select
from sqlalchemy.orm import lazyload
from sqlalchemy.schema import UniqueConstraint
from .users import UserProductPlan, Products
import calendar


class Speciality(Base):
    __tablename__ = "speciality"

    id = Column(Integer, primary_key=True)
    name = Column(String, unique=True)

    async def save(self, db: AsyncSession):
        try:
            db.add(self)
            await db.commit()
            await db.refresh(self)
        except IntegrityError as e:
            raise HTTPException(status_code=404, detail=str(e.orig).split('DETAIL:  ')[1].replace('.\n', ''))

    async def update(self, db: AsyncSession, **kwargs):
        try:
            self.name = kwargs.get('name', self.name)
            await db.commit()
            await db.refresh(self)
        except IntegrityError as e:
            raise HTTPException(status_code=404, detail=str(e.orig).split('DETAIL:  ')[1].replace('.\n', ''))


class DoctorCategory(Base):
    __tablename__ = "doctor_category"

    id = Column(Integer, primary_key=True)
    name = Column(String, unique=True)

    async def save(self, db: AsyncSession):
        try:
            db.add(self)
            await db.commit()
            await db.refresh(self)
        except IntegrityError as e:
            raise HTTPException(status_code=404, detail=str(e.orig).split('DETAIL:  ')[1].replace('.\n', ''))

    async def update(self, db: AsyncSession, **kwargs):
        try:
            self.name = kwargs.get('name', self.name)
            await db.commit()
            await db.refresh(self)
        except IntegrityError as e:
            raise HTTPException(status_code=404, detail=str(e.orig).split('DETAIL:  ')[1].replace('.\n', ''))


class MedicalOrganization(Base):
    __tablename__ = "medical_organization"

    id = Column(Integer, primary_key=True)
    name = Column(String, unique=True)
    address = Column(String)
    latitude = Column(String)
    longitude = Column(String)

    region = relationship("Region",  backref="med_org", lazy='selectin')
    region_id = Column(Integer, ForeignKey("region.id")) 

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
            self.address = kwargs.get('address', self.address)
            self.latitude = kwargs.get('latitude', self.latitude)
            self.longitude = kwargs.get('longitude', self.longitude)
            self.med_rep_id = kwargs.get('med_rep_id', self.med_rep_id)
            self.region_id = kwargs.get('region_id', self.region_id)
            await db.commit()
            await db.refresh(self)
        except IntegrityError as e:
            raise HTTPException(status_code=404, detail=str(e.orig).split('DETAIL:  ')[1].replace('.\n', ''))


class DoctorMonthlyPlan(Base):
    __tablename__ = "doctor_monthly_plan"

    id = Column(Integer, primary_key=True)
    monthly_plan = Column(Integer)
    date = Column(DateTime, default=datetime.now())
    product = relationship("Products",  backref="doctormonthlyplan", lazy="selectin")
    product_id = Column(Integer, ForeignKey("products.id"))
    price = Column(Integer)
    discount_price = Column(Integer)
    doctor = relationship("Doctor", cascade="all, delete",  backref="doctormonthlyplan", lazy="selectin")
    doctor_id = Column(Integer, ForeignKey("doctor.id", ondelete="CASCADE"))

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
            result = await db.execute(select(UserProductPlan).filter(UserProductPlan.med_rep_id==self.doctor.med_rep_id, UserProductPlan.product_id==self.product_id))
            user_plan = result.scalar()
            user_plan.current_amount += difference
            if user_plan.current_amount < 0:
                raise HTTPException(status_code=404, detail="Med rep plan should be grater than 0 for tis product")
            db.add(self)
            await db.commit()
            await db.refresh(self)
        except IntegrityError as e:
            raise HTTPException(status_code=404, detail=str(e.orig).split('DETAIL:  ')[1].replace('.\n', ''))


class DoctorFact(Base):
    __tablename__ = "doctor_fact"

    id = Column(Integer, primary_key=True)
    fact = Column(Integer)
    price = Column(Integer)
    discount_price = Column(Integer)
    date = Column(DateTime, default=datetime.now())
    doctor_id = Column(Integer, ForeignKey("doctor.id", ondelete="CASCADE"))
    doctor = relationship("Doctor", cascade="all, delete", backref="fact")
    pharmacy_id = Column(Integer, ForeignKey("pharmacy.id"), nullable=True)
    pharmacy = relationship("Pharmacy", backref="doctorfact")
    product = relationship("Products",  backref="doctorfact")
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
        # await Bonus.set_bonus(**kwargs, db=db)


class BonusPayedAmounts(Base):
    __tablename__ = "bonus_payed_amounts"

    id = Column(Integer, primary_key=True)
    amount = Column(Integer)
    description = Column(String)
    date = Column(DateTime, default=date.today())
    bonus_id = Column(Integer, ForeignKey("bonus.id", ondelete="CASCADE"))
    bonus = relationship("Bonus", cascade="all, delete", backref="bonus_payed_amounts")


class DoctorPostupleniyaFact(Base):
    __tablename__ = 'doctor_postupleniya_fact'

    id = Column(Integer, primary_key=True)
    fact = Column(Integer)
    price = Column(Integer)
    discount_price = Column(Integer)
    date = Column(DateTime, default=datetime.now())
    doctor_id = Column(Integer, ForeignKey("doctor.id", ondelete="CASCADE"))
    doctor = relationship("Doctor", cascade="all, delete", backref="postupleniya_fact")
    # pharmacy_id = Column(Integer, ForeignKey("pharmacy.id"), nullable=True)
    # pharmacy = relationship("Pharmacy", backref="doctorfact")
    product = relationship("Products",  backref="postupleniya_fact")
    product_id = Column(Integer, ForeignKey("products.id"))

    @classmethod
    async def set_fact(cls, db: AsyncSession, **kwargs):
        year = datetime.now().year
        month = datetime.now().month  
        num_days = calendar.monthrange(year, month)[1]
        start_date = date(year, month, 1)  
        end_date = date(year, month, num_days)
        product = await get_or_404(Products, kwargs['product_id'], db)
        result = await db.execute(select(cls).filter(cls.doctor_id==kwargs['doctor_id'], cls.product_id==kwargs['product_id'], cls.date>=start_date, cls.date<=end_date))
        month_fact = result.scalars().first()
        if month_fact is None:
            month_fact = cls(doctor_id=kwargs['doctor_id'], product_id=kwargs['product_id'], fact=kwargs['compleated'], price=product.price, discount_price=product.discount_price)
            db.add(month_fact)
        else:
            month_fact.fact += kwargs['compleated']
        # await Bonus.set_bonus(**kwargs, db=db)


class Bonus(Base):
    __tablename__ = "bonus"

    id = Column(Integer, primary_key=True)
    date = Column(DateTime, default=datetime.now())
    amount = Column(Integer)
    payed = Column(Integer, default=0)
    product_quantity = Column(Integer)
    pre_investment = Column(Integer, default=0)
    doctor_id = Column(Integer, ForeignKey("doctor.id", ondelete="CASCADE"))
    doctor = relationship("Doctor", cascade="all, delete", backref="bonus")
    product = relationship("Products",  backref="bonus", lazy='selectin')
    product_id = Column(Integer, ForeignKey("products.id"))

    async def paying_bonus(self, amount: int, description: str, db: AsyncSession):
        payed = BonusPayedAmounts(amount=amount, description=description, bonus_id=self.id)
        db.add(payed)
        self.payed += amount
        difference = self.payed - self.amount
        if difference > 0:
            self.pre_investment = difference
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
            if month_bonus.pre_investment >= amount:
                month_bonus.pre_investment -= amount
            else:
                month_bonus.pre_investment = 0 


pharmacy_doctor = Table(
    "pharmacy_doctor",
    Base.metadata,
    Column("doctor_id", ForeignKey("doctor.id", ondelete="CASCADE"), primary_key=True),
    Column("pharmacy_id", ForeignKey("pharmacy.id", ondelete="CASCADE"), primary_key=True),
)


class Doctor(Base):
    __tablename__ = "doctor"

    id = Column(Integer, primary_key=True)
    full_name = Column(String)
    contact1 = Column(String)
    contact2 = Column(String)
    email = Column(String)
    latitude = Column(String)
    longitude = Column(String)
    deleted = Column(Boolean, default=False)
    birth_date = Column(DateTime)

    med_rep_id = Column(Integer, ForeignKey("users.id"))
    med_rep = relationship("Users",  backref="mr_doctor", foreign_keys=[med_rep_id], lazy='selectin')
    region_manager_id = Column(Integer, ForeignKey("users.id"))
    region_manager = relationship("Users",  backref="rm_doctor", foreign_keys=[region_manager_id])
    ffm_id = Column(Integer, ForeignKey("users.id"))
    ffm = relationship("Users",  backref="ffm_doctor", foreign_keys=[ffm_id])
    product_manager_id = Column(Integer, ForeignKey("users.id"))
    product_manager = relationship("Users",  backref="pm_doctor", foreign_keys=[product_manager_id])
    deputy_director_id = Column(Integer, ForeignKey("users.id"))   
    deputy_director = relationship("Users",   foreign_keys=[deputy_director_id])
    director_id = Column(Integer, ForeignKey("users.id"))    
    director = relationship("Users",   foreign_keys=[director_id])
    region = relationship("Region",  backref="doctor", lazy='selectin')
    region_id = Column(Integer, ForeignKey("region.id")) 
    pharmacy = relationship("Pharmacy",  secondary="pharmacy_doctor", cascade="all, delete", back_populates="doctors")
    speciality = relationship("Speciality",  backref="doctor", lazy='selectin')
    speciality_id = Column(Integer, ForeignKey("speciality.id")) 
    category = relationship("DoctorCategory",  backref="doctor", lazy='selectin')
    category_id = Column(Integer, ForeignKey("doctor_category.id"))
    medical_organization = relationship("MedicalOrganization",  backref="doctor", lazy='selectin')
    medical_organization_id = Column(Integer, ForeignKey("medical_organization.id")) 

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
            self.full_name = kwargs.get('full_name', self.full_name)
            self.contact1 = kwargs.get('contact1', self.contact1)
            self.contact2 = kwargs.get('contact2', self.contact2)
            self.email = kwargs.get('email', self.email)
            self.latitude = kwargs.get('latitude', self.latitude)
            self.longitude = kwargs.get('longitude', self.longitude)
            self.birth_date = kwargs.get('birth_date', self.birth_date)
            self.med_rep_id = kwargs.get('med_rep_id', self.med_rep_id)
            self.region_manager_id = kwargs.get('region_manager_id', self.region_manager_id)
            self.ffm_id = kwargs.get('ffm_id', self.ffm_id)
            self.product_manager_id = kwargs.get('product_manager_id', self.product_manager_id)
            self.deputy_director_id = kwargs.get('deputy_director_id', self.deputy_director_id)
            self.director_id = kwargs.get('director_id', self.director_id)
            self.region_id = kwargs.get('region_id', self.region_id)
            self.speciality_id = kwargs.get('speciality_id', self.speciality_id)
            self.category_id = kwargs.get('category_id', self.category_id)
            self.medical_organization_id = kwargs.get('medical_organization_id', self.medical_organization_id)
            db.add(self)
            await db.commit()
            await db.refresh(self)
        except IntegrityError as e:
            raise HTTPException(status_code=404, detail=str(e.orig).split('DETAIL:  ')[1].replace('.\n', ''))

    async def delete(self, db: AsyncSession):
        try:
            self.deleted = True
            await db.commit()
            await db.refresh(self)
        except IntegrityError as e:
            raise HTTPException(status_code=404, detail=str(e.orig).split('DETAIL:  ')[1].replace('.\n', ''))

