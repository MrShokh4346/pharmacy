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
    latitude: str 
    longitude: str 
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
    latitude: str 
    longitude: str 
    category: DoctorCategorySchema 
    speciality: DoctorSpecialitySchema 
    medical_organization: MedOrgSchema
    # region: RegionSchema 
    

class DoctorUpdateSchema(BaseModel):
    full_name: Optional[str] = None  
    contact1: Optional[str] = None  
    contact2: Optional[str] = None  
    email: Optional[str] = None  
    latitude: Optional[str] = None  
    longitude: Optional[str] = None  
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
    medical_organization: Optional[MedOrgSchema] = None
    category: Optional[DoctorCategorySchema] = None
    

class AttachProductsSchema(BaseModel):
    doctor_id: int 
    product_id: int 
    monthly_plan: int 


class AttachProductsOutSchema(BaseModel):
    id: int
    product: ProductOutSchema
    monthly_plan: int 
    fact: int 


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
    # theme: Optional[str] = None
    # description: Optional[str] = None 
    status: bool 
    postpone: bool
    doctor: DoctorListSchema

    # @validator('date', pre=True, always=True)
    # def format_date(cls, value):
    #     if isinstance(value, datetime):
    #         return value.strftime('%Y-%m-%d %H:%M')
    #     return value

    # class Config:
    #     orm_mode = True