from pydantic import BaseModel, Field
from typing import Literal, Optional
from enum import Enum
from fastapi import FastAPI, Path
from typing import List 
from datetime import date, datetime
from med_rep.doctor_schemas import DoctorListSchema


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
    description: Optional[str] = None
    theme: Optional[str] = None 


class DoctorOutSchema(BaseModel):
    id: int 
    full_name: str 
    contact1: str 
    contact2: Optional[str] = None   
    email: str 


class DoctorVisitPlanOutSchema(BaseModel):
    id: int    
    date: datetime
    theme: Optional[str] = None
    description: Optional[str] = None 
    status: bool 
    postpone: bool
    doctor: DoctorListSchema


class PharmacyVisitPlanSchema(BaseModel):
    date: date
    pharmacy_id: int 
    description: Optional[str] = None
    theme: Optional[str] = None 


class PharmacyOutSchema(BaseModel):
    id: int
    company_name: str 
    contact1: str 
    contact2: Optional[str] = None   
    email: str 
    brand_name: str | None = None
    pharmacy_director: str


class PharmacyVisitPlanListSchema(BaseModel):
    id: int    
    date: datetime
    status: bool 
    postpone: bool 
    pharmacy: PharmacyOutSchema


class PharmacyVisitPlanOutSchema(BaseModel):
    id: int    
    date: datetime
    theme: Optional[str] = None
    description: Optional[str] = None 
    status: bool 
    postpone: bool 
    pharmacy: PharmacyOutSchema


class NotificationSchema(BaseModel):
    author: str 
    theme: Optional[str] = None 
    description: Optional[str] = None 
    med_rep_id: int
    pharmacy_id: Optional[int] = None
    doctor_id: Optional[int] = None
    wholesale_id: Optional[int] = None


class WholesaleSchema(BaseModel):
    id: int 
    name: str 
    contact: str 


class NotificationOutSchema(BaseModel):
    id: int 
    author: str 
    theme: Optional[str] = None 
    description: Optional[str] = None 
    date: date 
    unread: bool
    doctor: Optional[DoctorListSchema] = None
    pharmacy: Optional[PharmacyOutSchema] = None
    wholesale: Optional[WholesaleSchema] = None


class NotificationListSchema(BaseModel):
    id: int 
    # author: str 
    theme: Optional[str] = None 
    # description: Optional[str] = None 
    date: date 
    unread: bool
    doctor: Optional[DoctorListSchema] = None
    pharmacy: Optional[PharmacyOutSchema] = None
    wholesale: Optional[WholesaleSchema] = None

