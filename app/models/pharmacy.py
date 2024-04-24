from sqlalchemy import Boolean, Column, ForeignKey, Integer, String
from sqlalchemy.orm import relationship
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
    
    med_rep_id = Column(Integer, ForeignKey("users.id", ondelete='CASCADE'), nullable=False)
    med_rep = relationship("Users", cascade='all, delete', backref="mr_pharmacy", foreign_keys=[med_rep_id])
    region_manager_id = Column(Integer, ForeignKey("users.id", ondelete='CASCADE'), nullable=False)
    region_manager = relationship("Users", cascade='all, delete', backref="rm_pharmacy", foreign_keys=[region_manager_id])
    ffm_id = Column(Integer, ForeignKey("users.id", ondelete='CASCADE'), nullable=False)
    ffm = relationship("Users", cascade='all, delete', backref="ffm_pharmacy", foreign_keys=[ffm_id])
    project_manager_id = Column(Integer, ForeignKey("users.id", ondelete='CASCADE'), nullable=False)
    project_manager = relationship("Users", cascade='all, delete', backref="pm_pharmacy", foreign_keys=[project_manager_id])
    # plan = relationship("Plan", cascade='all, delete', backref="pharmacy")
    region = relationship("Region", cascade='all, delete', backref="pharmacy")
    region_id = Column(Integer, ForeignKey("region.id", ondelete='CASCADE'), nullable=False) 
    # doctor = relationship("Doctor", cascade='all, delete', backref="pharmacy")





    
    


