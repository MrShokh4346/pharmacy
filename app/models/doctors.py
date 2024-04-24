from sqlalchemy import Boolean, Column, ForeignKey, Integer, String, DateTime
from datetime import datetime
from sqlalchemy.orm import relationship
from sqlalchemy.orm import Session
from fastapi import Depends, FastAPI, HTTPException, status
from .users import *
from .pharmacy import *
from .doctors import *

from .database import Base, get_db


class Speciality(Base):
    __tablename__ = "speciality"

    id = Column(Integer, primary_key=True)
    name = Column(String)
    # doctor = relationship("Doctor", cascade='all, delete', backref="speciality")


class DoctorCategory(Base):
    __tablename__ = "doctor_category"

    id = Column(Integer, primary_key=True)
    name = Column(String)
    # doctor = relationship("Doctor", cascade='all, delete', backref="category")


class MedicalOrganization(Base):
    __tablename__ = "medical_organization"

    id = Column(Integer, primary_key=True)
    name = Column(String)
    address = Column(String)
    latitude = Column(String)
    longitude = Column(String)

    med_rep = relationship("Users", cascade='all, delete', backref="med_org")
    med_rep_id = Column(Integer, ForeignKey("users.id", ondelete='CASCADE'), nullable=False)
    region = relationship("Region", cascade='all, delete', backref="med_org")
    region_id = Column(Integer, ForeignKey("region.id", ondelete='CASCADE'), nullable=False) 
    # doctor = relationship("Doctor", cascade='all, delete', backref="medical_organization")
    # plan = relationship("Plan", cascade='all, delete', backref="medical_organization")


class DoctorAttachedProduct(Base):
    __tablename__ = "doctor_attached_product"

    id = Column(Integer, primary_key=True)
    quantity = Column(Integer)
    monthly_plan = Column(Integer)

    product = relationship("Products", cascade='all, delete', backref="doctorattachedproduct")
    product_id = Column(Integer, ForeignKey("products.id", ondelete='CASCADE'), nullable=False)
    doctor = relationship("Doctor", cascade='all, delete', backref="doctorattachedproduct")
    doctor_id = Column(Integer, ForeignKey("doctor.id", ondelete='CASCADE'), nullable=False)


class Doctor(Base):
    __tablename__ = "doctor"

    id = Column(Integer, primary_key=True)
    full_name = Column(String)
    contact = Column(String)
    latitude = Column(String)
    longitude = Column(String)
    bonus = Column(String)

    med_rep_id = Column(Integer, ForeignKey("users.id", ondelete='CASCADE'), nullable=False)
    med_rep = relationship("Users", cascade='all, delete', backref="mr_doctor", foreign_keys=[med_rep_id])
    region_manager_id = Column(Integer, ForeignKey("users.id", ondelete='CASCADE'), nullable=False)
    region_manager = relationship("Users", cascade='all, delete', backref="rm_doctor", foreign_keys=[region_manager_id])
    ffm_id = Column(Integer, ForeignKey("users.id", ondelete='CASCADE'), nullable=False)
    ffm = relationship("Users", cascade='all, delete', backref="ffm_doctor", foreign_keys=[ffm_id])
    project_manager_id = Column(Integer, ForeignKey("users.id", ondelete='CASCADE'), nullable=False)
    project_manager = relationship("Users", cascade='all, delete', backref="pm_doctor", foreign_keys=[project_manager_id])
    plan_id = Column(Integer, ForeignKey("plan.id", ondelete='CASCADE'), nullable=False)
    # plan = relationship("Plan", cascade='all, delete', backref="doctot")
    region = relationship("Region", cascade='all, delete', backref="doctor")
    region_id = Column(Integer, ForeignKey("region.id", ondelete='CASCADE'), nullable=False) 
    pharmacy = relationship("Pharmacy", cascade='all, delete', backref="doctor")
    pharmacy_id = Column(Integer, ForeignKey("pharmacy.id", ondelete='CASCADE'), nullable=False) 
    speciality = relationship("Speciality", cascade='all, delete', backref="doctor")
    speciality_id = Column(Integer, ForeignKey("speciality.id", ondelete='CASCADE'), nullable=False) 
    category = relationship("DoctorCategory", cascade='all, delete', backref="doctor")
    category_id = Column(Integer, ForeignKey("doctor_category.id", ondelete='CASCADE'), nullable=False)
    medical_organization = relationship("MedicalOrganization", cascade='all, delete', backref="doctor")
    medical_organization_id = Column(Integer, ForeignKey("medical_organization.id", ondelete='CASCADE'), nullable=False) 
    # doctorattachedproduct = relationship("DoctorAttachedProduct", cascade='all, delete', backref="doctor")


