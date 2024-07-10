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


class DoctorAttachedProduct(Base):
    __tablename__ = "doctor_attached_product"

    id = Column(Integer, primary_key=True)
    monthly_plan = Column(Integer)
    fact = Column(Integer, default=0)

    product = relationship("Products",  backref="doctorattachedproduct", lazy='selectin')
    product_id = Column(Integer, ForeignKey("products.id"))
    doctor = relationship("Doctor",  back_populates="doctor_attached_products")
    doctor_id = Column(Integer, ForeignKey("doctor.id"))

    async def save(self, db: AsyncSession):
        try:
            db.add(self)
            await db.commit()
            await db.refresh(self)
        except:
            raise HTTPException(status_code=404, detail=str(e.orig).split('DETAIL:  ')[1].replace('.\n', ''))
            
    async def update(self, monthly_plan: int, user_id: int, db: AsyncSession):
        self.monthly_plan = monthly_plan 
        year = datetime.now().year
        month = datetime.now().month
        num_days = calendar.monthrange(year, month)[1]
        start_date = date(year, month, 1)  
        end_date = date(year, month, num_days)
        result = await db.execute(select(UserProductPlan).filter(UserProductPlan.product_id==self.product_id, UserProductPlan.plan_month>=start_date, UserProductPlan.plan_month<=end_date, UserProductPlan.med_rep_id==user_id))
        user_product = result.scalars().first()
        if user_product is None:
            raise HTTPException(status_code=404, detail='You are trying to add product that is not exists in user plan')
        if user_product.current_amount < monthly_plan:
            raise HTTPException(status_code=404, detail='You are trying to add more doctor plan than user plan for this product')
        user_product.current_amount -= monthly_plan
        await db.commit()



class DoctorMonthlyPlan(Base):
    __tablename__ = "doctor_monthly_plan"

    id = Column(Integer, primary_key=True)
    monthly_plan = Column(Integer)
    date = Column(DateTime, default=datetime.now())
    product = relationship("Products",  backref="doctormonthlyplan")
    product_id = Column(Integer, ForeignKey("products.id"))
    price = Column(Integer)
    discount_price = Column(Integer)
    doctor = relationship("Doctor",  backref="doctormonthlyplan")
    doctor_id = Column(Integer, ForeignKey("doctor.id"))

    async def save(self, db: AsyncSession):
        try:
            db.add(self)
            await db.commit()
            await db.refresh(self)
        except:
            raise HTTPException(status_code=404, detail=str(e.orig).split('DETAIL:  ')[1].replace('.\n', ''))


class DoctorFact(Base):
    __tablename__ = "doctor_fact"

    id = Column(Integer, primary_key=True)
    fact = Column(Integer)
    price = Column(Integer)
    discount_price = Column(Integer)
    date = Column(DateTime, default=datetime.now())
    doctor_id = Column(Integer, ForeignKey("doctor.id"))
    doctor = relationship("Doctor", backref="fact")
    pharmacy_id = Column(Integer, ForeignKey("pharmacy.id"))
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
        await Bonus.set_bonus(**kwargs, db=db)


class Bonus(Base):
    __tablename__ = "bonus"

    id = Column(Integer, primary_key=True)
    date = Column(DateTime, default=datetime.now())
    amount = Column(Integer)
    payed = Column(Integer, default=0)
    product_quantity = Column(Integer)
    doctor_id = Column(Integer, ForeignKey("doctor.id"))
    doctor = relationship("Doctor", backref="bonus")
    product = relationship("Products",  backref="bonus", lazy='selectin')
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


# class BonusProduct(Base):
#     __tablename__ = "bonus_product"

#     id = Column(Integer, primary_key=True)
#     quantity = Column(Integer)
#     bonus_id = Column(Integer, ForeignKey("bonus.id", ondelete="CASCADE"))
#     bonus = relationship("Bonus", back_populates="products", cascade="all, delete")
#     product = relationship("Products",  backref="bonusproduct", lazy='selectin')
#     product_id = Column(Integer, ForeignKey("products.id"))


# class BonusPayed(Base):
#     __tablename__ = "bonus_payed"

#     id = Column(Integer, primary_key=True)
#     date = Column(DateTime, default=datetime.now())
#     payed = Column(Integer)
#     bonus_id = Column(Integer, ForeignKey("bonus.id", ondelete="CASCADE"))
#     bonus = relationship("Bonus", back_populates="pated_bonus", cascade="all, delete")

#     async def save(self, db: AsyncSession):
#         try:
#             db.add(self)
#             await db.commit()
#             await db.refresh(self)
#         except IntegrityError as e:
#             raise HTTPException(status_code=404, detail=str(e.orig).split('DETAIL:  ')[1].replace('.\n', ''))



pharmacy_doctor = Table(
    "pharmacy_doctor",
    Base.metadata,
    Column("doctor_id", ForeignKey("doctor.id"), primary_key=True),
    Column("pharmacy_id", ForeignKey("pharmacy.id"), primary_key=True),
    # Column("product_id", ForeignKey("products.id"), primary_key=True)
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
    pharmacy = relationship("Pharmacy",  secondary="pharmacy_doctor", back_populates="doctors")
    speciality = relationship("Speciality",  backref="doctor", lazy='selectin')
    speciality_id = Column(Integer, ForeignKey("speciality.id")) 
    category = relationship("DoctorCategory",  backref="doctor", lazy='selectin')
    category_id = Column(Integer, ForeignKey("doctor_category.id"))
    medical_organization = relationship("MedicalOrganization",  backref="doctor", lazy='selectin')
    medical_organization_id = Column(Integer, ForeignKey("medical_organization.id")) 
    doctor_attached_products = relationship("DoctorAttachedProduct",  back_populates="doctor")


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




# lst = [{'name':'doctor',
#             'pharmacy':['pharmacy1', 'pharmacy2']},
#             {'name':'doctor2',
#                 'pharmacy':['pharmacy1', 'pharmacy2']},
#        {'name':'doctor3',
#                 'pharmacy':['pharmacy1', 'pharmacy2']}]