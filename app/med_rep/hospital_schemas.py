from pydantic import BaseModel, validator
from typing import List, Optional
from models.doctors import Speciality
from common.schemas import RegionSchema, DoctorCategorySchema, ManufacturedCompanySchema, DoctorSpecialitySchema, MedicalOrganizationOutSchema, ProductOutSchema
from datetime import date, datetime
from enum import Enum


class UserSchema(BaseModel):
    id: int
    full_name: str 
    username: str 
    status: str


class HospitalSchema(BaseModel):
    company_name: str 
    company_address: str 
    inter_branch_turnover: str 
    bank_account_number: str 
    director: str 
    purchasing_manager: str 
    contact: str 
    med_rep_id: int 


class HospitalUpdateSchema(BaseModel):
    company_name: Optional[str] = None 
    company_address: Optional[str] = None 
    inter_branch_turnover: Optional[str] = None 
    bank_account_number: Optional[str] = None 
    director: Optional[str] = None 
    purchasing_manager: Optional[str] = None 
    contact: Optional[str] = None 


class HospitalOutSchema(BaseModel):
    id: int 
    company_name: str 
    company_address: str 
    inter_branch_turnover: str 
    bank_account_number: str 
    director: str 
    purchasing_manager: str 
    contact: str 
    med_rep: UserSchema


class HospitalReservationProductSchema(BaseModel):
    product_id: int 
    quantity: int


class HospitalReservationSchema(BaseModel):
    manufactured_company_id: int
    invoice_number: str
    discount: Optional[int] = 0
    products: List[HospitalReservationProductSchema]


class ProductSchema(BaseModel):
    id: int 
    name: str 
    price: int 
    man_company: ManufacturedCompanySchema 


class ReservationProductOutSchema(BaseModel):
    id: int 
    quantity: int 
    product: ProductSchema


class HospitalReservationOutSchema(BaseModel):
    id: int
    date: datetime 
    expire_date: datetime 
    discount: float
    total_quantity: float
    total_amount: float
    total_payable: float
    total_payable_with_nds: float
    products: List[ReservationProductOutSchema]
    checked: bool
    payed: bool
    invoice_number: Optional[str] = None 
    profit: Optional[int] = None 
    debt: Optional[int] = None 


class PayReservtionSchema(BaseModel):
    amount: int 
    description: Optional[str] = None 


class CheckSchema(BaseModel):
    checked: bool 


class CheckPayedSchema(BaseModel):
    payed: bool


class ExpireDateSchema(BaseModel):
    date: date


class BonusOutSchema(BaseModel):
    id: int
    date: datetime
    amount: int 
    payed: int 
    product_quantity: int 
    product: ProductSchema


class AttachProductsSchema(BaseModel):
    product_id: int 
    monthly_plan: int 


class AttachProductsOutSchema(BaseModel):
    id: int
    product: ProductOutSchema
    monthly_plan: int 


class AttachProductsListSchema(BaseModel):
    items: List[AttachProductsSchema]
    month: int


class HospitalProductPlanOutSchema(BaseModel):
    id: int 
    product: ProductSchema 
    monthly_plan: int 
    date: datetime 


class HospitalAttachedProducts(BaseModel):
    id: int 
    monthly_plan: int 
    date: datetime
    product: ProductSchema