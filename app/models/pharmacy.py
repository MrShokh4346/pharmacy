from sqlalchemy import Boolean, Column, ForeignKey, Integer, String
from sqlalchemy.orm import relationship
from .dependencies import get_password_hash, verify_password
from sqlalchemy.orm import Session
from fastapi import Depends, FastAPI, HTTPException, status
from .users import *
from .plan import *
from .doctors import *


from .database import Base, get_db


class Pharmacy(Base):
    __tablename__ = "pharmacy"

    id = Column(Integer, primary_key=True)
    company_name = Column(String)
    latitude = Column(String)
    longitude = Column(String)
    address = Column(String)
    bank_account_number = Column(String)
    inter_branch_turnover = Column(String)
    classification_of_economic_activities = Column(String)
    VAT_payer_code = Column(String)
    director = Column(String)
    
    med_rep = relationship("Users", cascade='all, delete', back_populates="mr_pharmacy")
    med_rep_id = Column(Integer, ForeignKey("users.id", ondelete='CASCADE'), nullable=False)
    region_manager = relationship("Users", cascade='all, delete', back_populates="rm_pharmacy")
    region_manager_id = Column(Integer, ForeignKey("users.id", ondelete='CASCADE'), nullable=False)
    ffm = relationship("Users", cascade='all, delete', back_populates="ffm_pharmacy")
    ffm_id = Column(Integer, ForeignKey("users.id", ondelete='CASCADE'), nullable=False)
    project_manager = relationship("Users", cascade='all, delete', back_populates="pm_pharmacy")
    project_manager_id = Column(Integer, ForeignKey("users.id", ondelete='CASCADE'), nullable=False)
    plan = relationship("Plan", cascade='all, delete', back_populates="pharmacy")
    region = relationship("Region", cascade='all, delete', back_populates="pharmacy")
    region_id = Column(Integer, ForeignKey("region.id", ondelete='CASCADE'), nullable=False) 
    doctor = relationship("Doctor", cascade='all, delete', back_populates="pharmacy")





    
    


