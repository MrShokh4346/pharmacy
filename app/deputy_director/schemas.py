from pydantic import BaseModel, Field
from typing import Literal
from enum import Enum
from fastapi import FastAPI, Path
from typing import List 
from datetime import date
from med_rep.doctor_schemas import DoctorOutSchema
from med_rep.pharmacy_schemas import PharmacyOutSchema

class Status(str, Enum):
    medical_representative = "medical_representative"
    regional_manager = "regional_manager"
    ff_manager = "ff_manager"
    product_manager = "product_manager"


class RegisterForDDSchema(BaseModel):
    password: str
    username: str
    full_name: str
    status: Status =  Path(..., title="User Role", description="The role of the user")
    region_id: int
    region_manager_id: int | None = None
    ffm_id: int | None = None
    product_manager_id: int | None = None


class UserOutSchema(BaseModel):
    id: int
    username: str
    full_name: str
    status: str 


class DoctorVisitPlanSchema(BaseModel):
    date: date
    doctor_id: int 


class DoctorVisitPlanOutSchema(BaseModel):
    id: int    
    date: date
    doctor: DoctorOutSchema


class PharmacyVisitPlanSchema(BaseModel):
    date: date
    pharmacy_id: int 


class PharmacyVisitPlanOutSchema(BaseModel):
    id: int    
    date: date
    pharmacy: PharmacyOutSchema
