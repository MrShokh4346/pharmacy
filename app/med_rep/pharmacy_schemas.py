from pydantic import BaseModel
from typing import List, Optional
from common.schemas import RegionSchema, DoctorCategorySchema, DoctorSpecialitySchema, MedicalOrganizationOutSchema, ProductOutSchema, ManufacturedCompanySchema
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
    discount: float
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
    wholesale_id: Optional[int] = None
    factory_id: Optional[int] = None
    # saler: str 
    description: Optional[str] = None 


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
    product_id: int 
    compleated: int 


class VisitInfoDoctorSchema(BaseModel):
    doctor_id: int
    products: List[VisitInfoProductSchema] 


class VisitInfoSchema(BaseModel):
    description: str 
    doctors: List[VisitInfoDoctorSchema]


class DoctorSchema(BaseModel):
    id: int
    full_name: str


class ProductSchema(BaseModel):
    id: int
    name: str


class PharmacySchema(BaseModel):
    id: int
    company_name: str


class PharmacyFactSchema(BaseModel):
    id: int 
    quantity: int 
    date: datetime 
    monthly_plan: int
    doctor: DoctorSchema
    product: ProductSchema
    pharmacy: PharmacySchema


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
    product_id: int 
    quantity: int


class ReservationSchema(BaseModel):
    manufactured_company_id: int
    discountable: bool 
    products: List[ReservationProductSchema]


class ReservationProductOutSchema(BaseModel):
    product: Optional[ProductOutSchema] 
    quantity: int


class ReservationListSchema(BaseModel):
    id: int
    date: datetime 
    expire_date: datetime 
    products: List[ReservationProductOutSchema] 
    manufactured_company: ManufacturedCompanySchema
    discount: int
    total_quantity: float
    total_amount: float
    total_payable: float
    checked: bool


class ReservationOutSchema(BaseModel):
    id: int
    date: datetime 
    expire_date: datetime 
    # products: List[ReservationProductOutSchema] 
    # manufactured_company: ManufacturedCompanySchema
    discount: float
    total_quantity: float
    total_amount: float
    total_payable: float
    checked: bool



class AttachDoctorToPharmacySchema(BaseModel):
    doctor_id: int 
    pharmacy_id: int 
    # product_id: int 


class ReplyNotification(BaseModel):
    description2: str 
    unread: bool 