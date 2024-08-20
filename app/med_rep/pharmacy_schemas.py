from pydantic import BaseModel
from typing import List, Optional, Annotated
from common.schemas import RegionSchema, DoctorCategorySchema, DoctorSpecialitySchema, MedicalOrganizationOutSchema, ProductOutSchema, ManufacturedCompanySchema
from datetime import date, datetime
from enum import Enum
from fastapi import Path


class PharmacyAddSchema(BaseModel):
    company_name: str 
    contact1: str 
    contact2: Optional[str] = None   
    email: str 
    latitude: str
    longitude: str 
    address: str 
    brand_name: str
    bank_account_number: Optional[str] = None 
    inter_branch_turnover: str 
    classification_of_economic_activities: Optional[str] = None 
    VAT_payer_code: Optional[str] = None 
    pharmacy_director: str 
    region_id: int


class UserOutSchema(BaseModel):
    id: int
    username: str
    full_name: str
    status: str


class PharmacyListSchema(BaseModel):
    id: Optional[int] 
    company_name: str 
    brand_name: str | None = None
    pharmacy_director: str
    inter_branch_turnover: str
    latitude: str 
    longitude: str
    discount: float 
    region: RegionSchema
    med_rep: UserOutSchema


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
    bank_account_number: Optional[str] = None 
    inter_branch_turnover: str 
    classification_of_economic_activities: Optional[str] = None 
    VAT_payer_code: Optional[str] = None 
    pharmacy_director: str
    region: Optional[RegionSchema]
    med_rep: UserOutSchema


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
    doctors: Optional[List[VisitInfoDoctorSchema]] = None 


class DoctorSchema(BaseModel):
    id: int
    full_name: str


class ProductSchema(BaseModel):
    id: int
    name: str
    man_company: ManufacturedCompanySchema 


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
    quantity: Annotated[int, Path(title="", ge=0)]


class ReservationSchema(BaseModel):
    manufactured_company_id: int
    invoice_number: Optional[int] = None
    discountable: bool 
    products: List[ReservationProductSchema]


class ReservationProductOutSchema(BaseModel):
    product: Optional[ProductOutSchema] 
    quantity: int


class ReservationOutWithProductsSchema(BaseModel):
    id: Optional[int]
    date: datetime 
    expire_date: datetime 
    discount: float
    total_quantity: float
    total_amount: float
    total_payable: float
    total_payable_with_nds: float
    products: List[ReservationProductOutSchema]
    checked: bool
    invoice_number: Optional[int] = None 
    profit: Optional[int] = None 
    debt: Optional[int] = None 



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
    id: Optional[int]
    date: datetime 
    expire_date: datetime 
    discount: float
    total_quantity: float
    total_amount: float
    total_payable: float
    total_payable_with_nds: float
    checked: bool
    invoice_number: Optional[int] = None 
    profit: Optional[int] = None 
    debt: Optional[int] = None 


class AttachDoctorToPharmacySchema(BaseModel):
    doctor_id: int 
    pharmacy_id: int 


class ReplyNotification(BaseModel):
    description2: str 
    unread: bool 


class PharmacyHotSaleSchema(BaseModel):
    id: int 
    amount: int 
    date: date 
    product: ProductSchema


class ReservationHistorySchema(BaseModel):
    amount: int 
    description: Optional[str] = None
    date: date 
    product: ProductSchema
    doctor: DoctorSchema