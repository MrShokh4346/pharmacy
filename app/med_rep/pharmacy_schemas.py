from pydantic import BaseModel
from typing import List, Optional
from common.schemas import RegionSchema, DoctorCategorySchema, DoctorSpecialitySchema, MedicalOrganizationOutSchema, ProductOutSchema
from datetime import date, datetime
from enum import Enum


class PharmacyAddSchema(BaseModel):
    company_name: str 
    contact1: str 
    contact2: Optional[str] = None   
    email: str 
    latitude: str
    longitude: str 
    address: str 
    brand_name: str
    bank_account_number: str 
    inter_branch_turnover: str 
    classification_of_economic_activities: str 
    VAT_payer_code: str 
    pharmacy_director: str 
    region_id: int


class PharmacyListSchema(BaseModel):
    id: Optional[int] 
    company_name: str 
    brand_name: str | None = None
    pharmacy_director: str


class PharmacyOutSchema(BaseModel):
    id: int
    company_name: str 
    contact1: str 
    contact2: Optional[str] = None   
    email: str 
    brand_name: str | None = None
    latitude: str
    longitude: str 
    address: str 
    bank_account_number: str 
    inter_branch_turnover: str 
    classification_of_economic_activities: str 
    VAT_payer_code: str 
    pharmacy_director: str
    region: Optional[RegionSchema]


class PharmacyUpdateSchema(BaseModel):
    company_name: Optional[str] = None  
    contact1: Optional[str] = None   
    contact2: Optional[str] = None   
    email: Optional[str] = None   
    brand_name: Optional[str] = None   
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
    product_id: int 
    quantity: int 

class StockOutSchema(BaseModel):
    id: int 
    amount: int 
    product: ProductOutSchema


class BalanceInStockSchema(BaseModel):
    products: List[StockProduct]
    pharmacy_id: int 
    saler: str 
    description: Optional[str] 


class CheckStockProduct(BaseModel):
    product_id: int 
    remainder: int 


class CheckBalanceInStockSchema(BaseModel):
    products: List[CheckStockProduct]
    pharmacy_id: int 
    description: Optional[str] 


class RescheduleSchema(BaseModel):
    date: str 
    postpone: bool 
    description: str 
    theme: str 


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


class DebtSchema(BaseModel):
    description: str 
    amount: int 


class DebtUpdateSchema(BaseModel):
    payed: bool 


class DebtOutSchema(DebtSchema):
    id: int 
    date: datetime 
    payed: bool 


class FactoryWarehouseSchema(BaseModel):
    quantity: int 
    product_id: int 


class FactoryWarehouseOutSchema(BaseModel):
    quantity: int 
    product: ProductOutSchema 


class ReservationProductSchema(BaseModel):
    product_name: str 
    price: float
    discount_price: float
    quantity: int


class ReservationSchema(BaseModel):
    company: str
    discount: int
    total_quantity: int 
    total_amount: float 
    total_payable: float 
    products: List[ReservationProductSchema]


class ReservationOutSchema(ReservationSchema):
    id: int
    date: datetime 


class AttachDoctorToPharmacySchema(BaseModel):
    doctor_id: int 
    pharmacy_id: int 
    product_id: int 