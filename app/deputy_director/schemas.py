from pydantic import BaseModel, Field
from typing import Literal, Optional
from enum import Enum
from fastapi import FastAPI, Path
from typing import List 
from datetime import date, datetime
from med_rep.doctor_schemas import DoctorListSchema
from common.schemas import  ManufacturedCompanySchema, ProductCategorySchema
from common.schemas import RegionSchema, DoctorCategorySchema, DoctorSpecialitySchema, MedicalOrganizationOutSchema, ProductOutSchema


class Status(str, Enum):
    medical_representative = "medical_representative"
    regional_manager = "regional_manager"
    ff_manager = "ff_manager"
    product_manager = "product_manager"
    head_of_orders = "head_of_orders"
    wholesale_manager = "wholesale_manager"


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
    date: datetime
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
    date: datetime
    pharmacy_id: int 
    description: Optional[str] = None
    theme: Optional[str] = None 


class PharmacyOutSchema(BaseModel):
    id: int
    company_name: str 
    contact1: str 
    contact2: Optional[str] = None  
    latitude: str
    longitude: str  
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
    description2: Optional[str] = None 
    date: date 
    unread: bool
    doctor: Optional[DoctorListSchema] = None
    pharmacy: Optional[PharmacyOutSchema] = None
    wholesale: Optional[WholesaleSchema] = None


class NotificationListSchema(BaseModel):
    id: int 
    theme: Optional[str] = None 
    date: date 
    unread: bool
    doctor: Optional[DoctorListSchema] = None
    pharmacy: Optional[PharmacyOutSchema] = None
    wholesale: Optional[WholesaleSchema] = None


class ProductSchema(BaseModel):
    id: int 
    name: str 
    man_company: ManufacturedCompanySchema 
    category: ProductCategorySchema


class UserProductPlanInSchema(BaseModel):
    product_id: int 
    amount: int 
    month: int 
    med_rep_id: int


class UserProductPlanOutSchema(BaseModel):
    id: int 
    product: ProductSchema 
    amount: int 
    date: datetime 


class DoctorSchema(BaseModel):
    id: int 
    full_name: str 


class AttachProductsOutSchema(BaseModel):
    monthly_plan: int 
    fact: int 
    doctor: DoctorSchema


class ProductAttechSchema(BaseModel):
    id: int 
    name: str 


class UserProductPlanByIdSchema(BaseModel):
    product: ProductSchema 
    amount: int 
    date: datetime
    doctor_plans: List[DoctorSchema]
    vakant: int


class UserSchema(BaseModel):
    id: int
    username: str
    full_name: str
    status: str


class MedicalOrganizationSchema(BaseModel):
    id: int
    name: str
    address: str 


class AttachProductsSchema(BaseModel):
    id: int
    product: ProductOutSchema
    monthly_plan: int 
    fact: int 


class ReportSchema(BaseModel):
    id: int 
    full_name: str 
    contact1: str 
    contact2: Optional[str] = None   
    email: str 
    med_rep: UserSchema
    category: DoctorCategorySchema 
    speciality: DoctorSpecialitySchema 
    medical_organization: MedicalOrganizationSchema


class ProductExpensesSchema(BaseModel):
    id: int 
    name: str 
    price: int 
    discount_price: int 
    is_exist: Optional[bool] = None
    marketing_expenses: Optional[int] = None
    salary_expenses: Optional[int] = None 
    man_company: ManufacturedCompanySchema 
    category: ProductCategorySchema
