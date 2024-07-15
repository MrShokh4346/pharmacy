from pydantic import BaseModel, validator
from typing import List, Optional
from models.doctors import Speciality
from common.schemas import RegionSchema, DoctorCategorySchema, DoctorSpecialitySchema, MedicalOrganizationOutSchema, ProductOutSchema
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
    discount: Optional[int] = 0
    products: List[HospitalReservationProductSchema]


class ReservationOutSchema(BaseModel):
    id: int
    date: datetime 
    expire_date: datetime 
    discount: float
    total_quantity: float
    total_amount: float
    total_payable: float
    total_payable_with_nds: float
    confirmed: bool
    payed: bool


class CheckSchema(BaseModel):
    confirmed: bool 


class CheckPayedSchema(BaseModel):
    payed: bool


