from pydantic import BaseModel
from typing import List, Optional
from models.doctors import Speciality
from common.schemas import RegionSchema, DoctorCategorySchema, DoctorSpecialitySchema, MedicalOrganizationOutSchema, ProductOutSchema
from datetime import date
from enum import Enum


class DoctorInSchema(BaseModel):
    full_name: str 
    contact: str 
    latitude: str 
    longitude: str 
    category_id: int 
    speciality_id: int 
    # med_rep_id: int
    medical_organization_id: int
    region_id: int 


class DoctorOutSchema(BaseModel):
    id: int 
    full_name: str 
    contact: str 
    latitude: str 
    longitude: str 
    category: DoctorCategorySchema 
    speciality: DoctorSpecialitySchema 
    medical_organization: MedicalOrganizationOutSchema
    region: RegionSchema 
    

class DoctorUpdateSchema(BaseModel):
    full_name: Optional[str] = None  
    contact: Optional[str] = None  
    latitude: Optional[str] = None  
    longitude: Optional[str] = None  
    category_id: Optional[int] = None  
    speciality_id: Optional[int] = None  
    # med_rep_id: Optional[int] = None 
    medical_organization_id: Optional[int] = None 
    region_id: Optional[int] = None  


class SpecialitySchema(BaseModel):
    id: int
    name: str


class DoctorListSchema(BaseModel):
    id: int 
    full_name: str 
    speciality: SpecialitySchema
    

class AttachProductsSchema(BaseModel):
    doctor_id: int 
    product_id: int 
    quantity: int 
    monthly_plan: int 


class AttachProductsListSchema(BaseModel):
    items: List[AttachProductsSchema]


class FilterChoice(str, Enum):
    payed = "payed"
    debt = "debt"
    history = "history"


class BonusProductSchema(BaseModel):
    product_name: str 
    monthly_plan: int


class BonusSchema(BaseModel):
    date: date
    payed: bool 
    description: str 
    amount: int 
    doctor_id: int
    products: List[BonusProductSchema]


class BonusProductOutSchema(BonusProductSchema):
    id: int


class BonusOutSchema(BonusSchema):
    id: int
    products: List[BonusProductOutSchema]


class RescheduleSchema(BaseModel):
    date: date 


class VisitInfoProductSchema(BaseModel):
    product_name: str 
    compleated: int 


class VisitInfoSchema(BaseModel):
    description: str 
    products: List[VisitInfoProductSchema]


class DoctorAttachedProductSchema(BaseModel):
    product: ProductOutSchema
