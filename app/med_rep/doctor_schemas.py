from pydantic import BaseModel, validator
from typing import List, Optional
from models.doctors import Speciality
from common.schemas import RegionSchema, DoctorCategorySchema, DoctorSpecialitySchema, MedicalOrganizationOutSchema, ProductOutSchema
from datetime import date, datetime
from enum import Enum


class DoctorInSchema(BaseModel):
    full_name: str 
    contact1: str 
    contact2: Optional[str] = None   
    email: str 
    category_id: int 
    speciality_id: int 
    # med_rep_id: int
    medical_organization_id: int
    # region_id: int 


class MedOrgSchema(BaseModel):
    id: int 
    name: str


class DoctorOutSchema(BaseModel):
    id: int 
    full_name: str 
    contact1: str 
    contact2: Optional[str] = None   
    email: str 
    category: DoctorCategorySchema 
    speciality: DoctorSpecialitySchema 
    medical_organization: MedicalOrganizationOutSchema
    # region: RegionSchema 
    

class DoctorUpdateSchema(BaseModel):
    full_name: Optional[str] = None  
    contact1: Optional[str] = None  
    contact2: Optional[str] = None  
    email: Optional[str] = None  
    category_id: Optional[int] = None  
    speciality_id: Optional[int] = None  
    # med_rep_id: Optional[int] = None 
    medical_organization_id: Optional[int] = None 
    # region_id: Optional[int] = None  


class SpecialitySchema(BaseModel):
    id: int
    name: str


class DoctorListSchema(BaseModel):
    id: int 
    full_name: str 
    speciality: Optional[SpecialitySchema] = None
    medical_organization: Optional[MedicalOrganizationOutSchema] = None
    category: Optional[DoctorCategorySchema] = None
    

class AttachProductsSchema(BaseModel):
    doctor_id: int 
    product_id: int 
    monthly_plan: int 


class AttachProductsOutSchema(BaseModel):
    id: int
    product: ProductOutSchema
    monthly_plan: int 


class AttachProductsListSchema(BaseModel):
    items: List[AttachProductsSchema]
    month: int


class FilterChoice(str, Enum):
    payed = "payed"
    debt = "debt"
    history = "history"


class BonusProductSchema(BaseModel):
    product_id: int 
    quantity: int


class BonusSchema(BaseModel):
    description: str 
    doctor_id: int
    products: List[BonusProductSchema]


class BonusOutSchema(BaseModel):
    id: int
    date: datetime
    amount: int 
    payed: int 
    product_quantity: int 
    product: ProductOutSchema


class RescheduleSchema(BaseModel):
    date: str 
    postpone: bool 
    description: str 
    theme: str 


class VisitInfoProductSchema(BaseModel):
    product_id: int 
    recept: int 


class VisitInfoSchema(BaseModel):
    description: str 
    products: List[VisitInfoProductSchema]


class DoctorAttachedProductSchema(BaseModel):
    product: ProductOutSchema


class DoctorVisitPlanListSchema(BaseModel):
    id: int    
    date: datetime
    status: bool 
    postpone: bool
    doctor: DoctorListSchema
