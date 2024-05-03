from pydantic import BaseModel
from typing import List, Optional
from common.schemas import RegionSchema, DoctorCategorySchema, DoctorSpecialitySchema, MedicalOrganizationOutSchema
from datetime import date
from enum import Enum


class PharmacyAddSchema(BaseModel):
    company_name: str 
    contact: str 
    latitude: str
    longitude: str 
    address: str 
    bank_account_number: str 
    inter_branch_turnover: str 
    classification_of_economic_activities: str 
    VAT_payer_code: str 
    pharmacy_director: str 
    region_id: int


class PharmacyOutSchema(BaseModel):
    id: int
    company_name: str 
    contact: str 
    latitude: str
    longitude: str 
    address: str 
    bank_account_number: str 
    inter_branch_turnover: str 
    classification_of_economic_activities: str 
    VAT_payer_code: str 
    pharmacy_director: str
    region: RegionSchema


class PharmacyUpdateSchema(BaseModel):
    company_name: Optional[str] = None  
    contact: Optional[str] = None   
    latitude: Optional[str] = None  
    longitude: Optional[str] = None   
    address: Optional[str] = None   
    bank_account_number: Optional[str] = None   
    inter_branch_turnover: Optional[str] = None   
    classification_of_economic_activities: Optional[str] = None   
    VAT_payer_code: Optional[str] = None   
    pharmacy_director: Optional[str] = None   
    region_id: Optional[int] = None  


class StockProduct(BaseModel):
    product_name: str 
    quantity: int 


class BalanceInStockSchema(BaseModel):
    products: List[StockProduct]
    date: date 
    pharmacy_id: int 


class RescheduleSchema(BaseModel):
    date: date 


class VisitInfoProductSchema(BaseModel):
    product_name: str 
    compleated: int 


class VisitInfoDoctorSchema(BaseModel):
    doctor_name: str
    doctor_speciality: str 
    products: List[VisitInfoProductSchema] 


class VisitInfoSchema(BaseModel):
    description: str 
    doctors: List[VisitInfoDoctorSchema]
