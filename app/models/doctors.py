from sqlalchemy import Boolean, Column, ForeignKey, Integer, String, DateTime
from datetime import datetime 
from sqlalchemy.orm import relationship
from sqlalchemy.ext.asyncio import AsyncSession
from fastapi import HTTPException
from sqlalchemy import Table
from sqlalchemy.exc import IntegrityError
from sqlalchemy.future import select
# from .users import UserProductPlan, Product
from sqlalchemy import text
import calendar
from .database import  get_or_404
from db.db import Base


class Distance(Base):
    __tablename__ = "distance"
    __table_args__ = {'extend_existing': True}
    

    id = Column(Integer, primary_key=True)
    distance = Column(Integer)


class Speciality(Base):
    __tablename__ = "speciality"
    __table_args__ = {'extend_existing': True}
    

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
    __table_args__ = {'extend_existing': True}
    

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
    __table_args__ = {'extend_existing': True}
    

    id = Column(Integer, primary_key=True)
    name = Column(String, unique=True)
    address = Column(String)
    latitude = Column(String)
    longitude = Column(String)

    region = relationship("app.models.users.Region",  backref="med_org", lazy='selectin')
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
            self.region_id = kwargs.get('region_id', self.region_id)
            await db.commit()
            await db.refresh(self)
        except IntegrityError as e:
            raise HTTPException(status_code=404, detail=str(e.orig).split('DETAIL:  ')[1].replace('.\n', ''))


class DoctorMonthlyPlan(Base):
    __tablename__ = "doctor_monthly_plan"
    __table_args__ = {'extend_existing': True}
    

    id = Column(Integer, primary_key=True)
    monthly_plan = Column(Integer)
    date = Column(DateTime, default=datetime.now(), index=True)
    product = relationship("app.models.users.Product",  backref="doctormonthlyplan", lazy="selectin")
    product_id = Column(Integer, ForeignKey("products.id"), index=True)
    price = Column(Integer)
    discount_price = Column(Integer)
    doctor = relationship("app.models.doctors.Doctor", cascade="all, delete",  back_populates="doctormonthlyplan", lazy="selectin")
    doctor_id = Column(Integer, ForeignKey("doctor.id", ondelete="CASCADE"), index=True)

    async def save(self, db: AsyncSession):
        try:
            db.add(self)
            await db.commit()
            await db.refresh(self)
        except IntegrityError as e:
            raise HTTPException(status_code=404, detail=str(e.orig).split('DETAIL:  ')[1].replace('.\n', ''))


class DoctorFact(Base):
    __tablename__ = "doctor_fact"
    __table_args__ = {'extend_existing': True}
    

    id = Column(Integer, primary_key=True)
    fact = Column(Integer)
    price = Column(Integer)
    discount_price = Column(Integer)
    date = Column(DateTime, default=datetime.now(), index=True)
    doctor_id = Column(Integer, ForeignKey("doctor.id", ondelete="CASCADE"), index=True)
    doctor = relationship("app.models.doctors.Doctor", cascade="all, delete", backref="fact")
    pharmacy_id = Column(Integer, ForeignKey("pharmacy.id"), nullable=True)
    pharmacy = relationship("app.models.pharmacy.Pharmacy", backref="doctorfact")
    product = relationship("app.models.users.Product",  backref="doctorfact")
    product_id = Column(Integer, ForeignKey("products.id"), index=True)


class BonusPayedAmounts(Base):
    __tablename__ = "bonus_payed_amounts"
    __table_args__ = {'extend_existing': True}
    

    id = Column(Integer, primary_key=True)
    amount = Column(Integer)
    description = Column(String)
    date = Column(DateTime, default=datetime.now())
    bonus_id = Column(Integer, ForeignKey("bonus.id", ondelete="CASCADE"))
    bonus = relationship("app.models.doctors.Bonus", cascade="all, delete", backref="bonus_payed_amounts")


class DoctorPostupleniyaFact(Base):
    __tablename__ = 'doctor_postupleniya_fact'
    __table_args__ = {'extend_existing': True}
    

    id = Column(Integer, primary_key=True)
    fact = Column(Integer)
    fact_price = Column(Integer, default=0)
    price = Column(Integer)
    discount_price = Column(Integer)
    date = Column(DateTime, default=datetime.now(), index=True)
    doctor_id = Column(Integer, ForeignKey("doctor.id", ondelete="CASCADE"), index=True)
    doctor = relationship("app.models.doctors.Doctor", cascade="all, delete", back_populates="postupleniya_fact")
    # pharmacy_id = Column(Integer, ForeignKey("pharmacy.id"), nullable=True)
    # pharmacy = relationship("Pharmacy", backref="doctorfact")
    product = relationship("app.models.users.Product",  backref="postupleniya_fact")
    product_id = Column(Integer, ForeignKey("products.id"), index=True)


class Bonus(Base):
    __tablename__ = "bonus"
    __table_args__ = {'extend_existing': True}
    

    id = Column(Integer, primary_key=True)
    date = Column(DateTime, default=datetime.now())
    amount = Column(Integer)
    payed = Column(Integer, default=0)
    product_quantity = Column(Integer)
    pre_investment = Column(Integer, default=0)
    doctor_id = Column(Integer, ForeignKey("doctor.id", ondelete="CASCADE"), index=True)
    doctor = relationship("app.models.doctors.Doctor", cascade="all, delete", backref="bonus")
    product = relationship("app.models.users.Product",  backref="bonus", lazy='selectin')
    product_id = Column(Integer, ForeignKey("products.id"), index=True)


pharmacy_doctor = Table(
    "pharmacy_doctor",
    Base.metadata,
    Column("doctor_id", ForeignKey("doctor.id", ondelete="CASCADE"), primary_key=True),
    Column("pharmacy_id", ForeignKey("pharmacy.id", ondelete="CASCADE"), primary_key=True),
    extend_existing=True
)


class Doctor(Base):
    __tablename__ = "doctor"
    __table_args__ = {'extend_existing': True}
    

    id = Column(Integer, primary_key=True)
    full_name = Column(String)
    contact1 = Column(String)
    contact2 = Column(String)
    email = Column(String)
    latitude = Column(String)
    longitude = Column(String)
    deleted = Column(Boolean, default=False)
    birth_date = Column(DateTime)

    med_rep_id = Column(Integer, ForeignKey("users.id"), index=True)
    med_rep = relationship("app.models.users.Users",  backref="mr_doctor", foreign_keys=[med_rep_id], lazy='selectin')
    region_manager_id = Column(Integer, ForeignKey("users.id"), index=True)
    region_manager = relationship("app.models.users.Users",  backref="rm_doctor", foreign_keys=[region_manager_id])
    ffm_id = Column(Integer, ForeignKey("users.id"), index=True)
    ffm = relationship("app.models.users.Users",  backref="ffm_doctor", foreign_keys=[ffm_id])
    product_manager_id = Column(Integer, ForeignKey("users.id"), index=True)
    product_manager = relationship("app.models.users.Users",  backref="pm_doctor", foreign_keys=[product_manager_id])
    deputy_director_id = Column(Integer, ForeignKey("users.id"), index=True)   
    deputy_director = relationship("app.models.users.Users",   foreign_keys=[deputy_director_id])
    director_id = Column(Integer, ForeignKey("users.id"), index=True)    
    director = relationship("app.models.users.Users",   foreign_keys=[director_id])
    region = relationship("app.models.users.Region",  backref="doctor", lazy='selectin')
    region_id = Column(Integer, ForeignKey("region.id"), index=True) 
    pharmacy = relationship("app.models.pharmacy.Pharmacy",  secondary="pharmacy_doctor", cascade="all, delete", back_populates="doctors")
    speciality = relationship("app.models.doctors.Speciality",  backref="doctor", lazy='selectin')
    speciality_id = Column(Integer, ForeignKey("speciality.id"), index=True) 
    category = relationship("app.models.doctors.DoctorCategory",  backref="doctor", lazy='selectin')
    category_id = Column(Integer, ForeignKey("doctor_category.id"), index=True)
    medical_organization = relationship("app.models.doctors.MedicalOrganization",  backref="doctor", lazy='selectin')
    medical_organization_id = Column(Integer, ForeignKey("medical_organization.id"), index=True) 
    doctormonthlyplan = relationship("app.models.doctors.DoctorMonthlyPlan", cascade="all, delete",  back_populates="doctor")
    postupleniya_fact = relationship("app.models.doctors.DoctorPostupleniyaFact", cascade="all, delete", back_populates="doctor")


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

