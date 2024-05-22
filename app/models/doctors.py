from sqlalchemy import Boolean, Column, ForeignKey, Integer, String, DateTime
from datetime import datetime
from sqlalchemy.orm import relationship
from sqlalchemy.orm import Session
from fastapi import Depends, FastAPI, HTTPException, status
from sqlalchemy import Table
from .database import Base, get_db


class Speciality(Base):
    __tablename__ = "speciality"

    id = Column(Integer, primary_key=True)
    name = Column(String)

    def save(self, db: Session):
        try:
            db.add(self)
            db.commit()
            db.refresh(self)
        except:
            raise AssertionError("Could not saved")


class DoctorCategory(Base):
    __tablename__ = "doctor_category"

    id = Column(Integer, primary_key=True)
    name = Column(String)

    def save(self, db: Session):
        try:
            db.add(self)
            db.commit()
            db.refresh(self)
        except:
            raise AssertionError("Could not saved")


class MedicalOrganization(Base):
    __tablename__ = "medical_organization"

    id = Column(Integer, primary_key=True)
    name = Column(String)
    address = Column(String)
    latitude = Column(String)
    longitude = Column(String)

    med_rep = relationship("Users",  backref="med_org")
    med_rep_id = Column(Integer, ForeignKey("users.id"))
    region = relationship("Region",  backref="med_org")
    region_id = Column(Integer, ForeignKey("region.id")) 

    def save(self, db: Session):
        try:
            db.add(self)
            db.commit()
            db.refresh(self)
        except:
            raise AssertionError("Could not saved")


class DoctorAttachedProduct(Base):
    __tablename__ = "doctor_attached_product"

    id = Column(Integer, primary_key=True)
    quantity = Column(Integer)
    monthly_plan = Column(Integer)

    product = relationship("Products",  backref="doctorattachedproduct")
    product_id = Column(Integer, ForeignKey("products.id"))
    doctor = relationship("Doctor",  backref="doctorattachedproduct")
    doctor_id = Column(Integer, ForeignKey("doctor.id"))

    def save(self, db: Session):
        try:
            db.add(self)
            db.commit()
            db.refresh(self)
        except:
            raise AssertionError("Could not saved")
            

class Bonus(Base):
    __tablename__ = "bonus"

    id = Column(Integer, primary_key=True)
    date = Column(DateTime, default=datetime.now())
    payed = Column(Boolean, default=False)
    description = Column(String)
    amount = Column(Integer)
    doctor_id = Column(Integer, ForeignKey("doctor.id"))
    doctor = relationship("Doctor", backref="bonus")

    def save(self, db: Session):
        try:
            db.add(self)
            db.commit()
            db.refresh(self)
        except:
            raise AssertionError("Could not saved")


class BonusProduct(Base):
    __tablename__ = "bonus_product"

    id = Column(Integer, primary_key=True)
    product_name = Column(String)
    monthly_plan = Column(Integer)
    bonus_id = Column(Integer, ForeignKey("bonus.id"))
    bonus = relationship("Bonus", backref="products", cascade="all, delete")


pharmacy_doctor = Table(
    "pharmacy_doctor",
    Base.metadata,
    Column("doctor_id", ForeignKey("doctor.id"), primary_key=True),
    Column("pharmacy_id", ForeignKey("pharmacy.id"), primary_key=True),
    Column("product_id", ForeignKey("products.id"), primary_key=True),
)

# class PharmacyDoctor(Base):
#     __tablename__ = "pharmacy_doctor"

#     doctor_id = Column(Integer, ForeignKey("doctor.id"), primary_key=True)
#     pharmacy_id = Column(Integer, ForeignKey("pharmacy.id"), primary_key=True)
#     product_id = Column(Integer, ForeignKey("products.id"), primary_key=True)

#     doctor = relationship("Doctor",  backref="ph_d")
#     pharmacy = relationship("Pharmacy",  backref="ph_d")
#     product = relationship("Products",  backref="ph_d")



class Doctor(Base):
    __tablename__ = "doctor"

    id = Column(Integer, primary_key=True)
    full_name = Column(String)
    contact1 = Column(String)
    contact2 = Column(String)
    email = Column(String)
    latitude = Column(String)
    longitude = Column(String)

    med_rep_id = Column(Integer, ForeignKey("users.id"))
    med_rep = relationship("Users",  backref="mr_doctor", foreign_keys=[med_rep_id])
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
    region = relationship("Region",  backref="doctor")
    region_id = Column(Integer, ForeignKey("region.id")) 
    pharmacy = relationship("Pharmacy",  secondary="pharmacy_doctor", backref="doctors")
    speciality = relationship("Speciality",  backref="doctor")
    speciality_id = Column(Integer, ForeignKey("speciality.id")) 
    category = relationship("DoctorCategory",  backref="doctor")
    category_id = Column(Integer, ForeignKey("doctor_category.id"))
    medical_organization = relationship("MedicalOrganization",  backref="doctor")
    medical_organization_id = Column(Integer, ForeignKey("medical_organization.id")) 

    def save(self, db: Session):
        try:
            db.add(self)
            db.commit()
            db.refresh(self)
        except:
            raise AssertionError("Could not saved")

    def update(self, db: Session, **kwargs):
        try:
            for key in list(kwargs.keys()):
                kwargs.pop(key) if kwargs[key]==None else None 
            self.full_name = kwargs.get('full_name', self.full_name)
            self.contact1 = kwargs.get('contact1', self.contact1)
            self.contact2 = kwargs.get('contact2', self.contact2)
            self.email = kwargs.get('email', self.email)
            self.latitude = kwargs.get('latitude', self.latitude)
            self.longitude = kwargs.get('longitude', self.longitude)
            self.bonus = kwargs.get('bonus', self.bonus)
            self.med_rep_id = kwargs.get('med_rep_id', self.med_rep_id)
            self.region_manager_id = kwargs.get('region_manager_id', self.region_manager_id)
            self.ffm_id = kwargs.get('ffm_id', self.ffm_id)
            self.product_manager_id = kwargs.get('product_manager_id', self.product_manager_id)
            self.deputy_director_id = kwargs.get('deputy_director_id', self.deputy_director_id)
            self.director_id = kwargs.get('director_id', self.director_id)
            self.plan_id = kwargs.get('plan_id', self.plan_id)
            self.region_id = kwargs.get('region_id', self.region_id)
            self.speciality_id = kwargs.get('speciality_id', self.speciality_id)
            self.category_id = kwargs.get('category_id', self.category_id)
            self.medical_organization_id = kwargs.get('medical_organization_id', self.medical_organization_id)
            db.add(self)
            db.commit()
            db.refresh(self)
        except:
            raise AssertionError("Could not updated")

    @classmethod
    def check_if_doctor_exists(cls, doctor_id: int, db: Session):
        doctor = db.query(cls).get(doctor_id)
        if doctor:
            return doctor
        else:
            raise HTTPException(
                status_code=400,
                detail="This doctor don't exists"
            )