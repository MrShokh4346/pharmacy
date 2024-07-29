from pydantic import BaseModel, Field
from typing import Literal
from enum import Enum
from fastapi import FastAPI, Path
from common.schemas import ManufacturedCompanySchema, ProductOutSchema, RegionSchema
from datetime import date , datetime
from typing import List, Optional



class FactoryWarehouseInSchema(BaseModel):
    factory_id: int 
    product_id: int 
    quantity: int 


class FactoryWarehouseOutSchema(BaseModel):
    factory: ManufacturedCompanySchema 
    product: ProductOutSchema 
    amount: int 


class FactoryWarehouseIncomeOutSchema(BaseModel):
    id: int 
    factory: ManufacturedCompanySchema 
    product: ProductOutSchema 
    quantity: int 
    date: date


class ReservationProductOutSchema(BaseModel):
    product: Optional[ProductOutSchema] 
    quantity: int


class MedRepSchema(BaseModel):
    id: int
    full_name: str 


class PharmacyReservationSchema(BaseModel):
    id: int
    company_name: str 
    med_rep: MedRepSchema
    region: RegionSchema


class ReservationListSchema(BaseModel):
    id: int
    date: datetime 
    expire_date: datetime 
    # products: List[ReservationProductOutSchema] 
    # manufactured_company: ManufacturedCompanySchema
    pharmacy: PharmacyReservationSchema
    discount: float
    # total_quantity: float
    # total_amount: float
    total_payable_with_nds: float
    checked: bool


class CheckSchema(BaseModel):
    checked: bool 


class ExpireDateSchema(BaseModel):
    date: date


class PayReservtionDoctors(BaseModel):
    amount: int 
    quantity: int
    doctor_id: int 
    product_id: int 


class PayReservtionSchema(BaseModel):
    objects: List[PayReservtionDoctors] 
    description: Optional[str] = None 


class PayWholesaleReservtionDoctors(BaseModel):
    amount: int 
    doctor_id: int 
    product_id: int 


class PayWholesaleReservtionSchema(BaseModel):
    med_rep_id: int 
    pharmacy_id: int 
    objects: List[PayWholesaleReservtionDoctors] 
    description: Optional[str] = None 



class ReservationOutSchema(BaseModel):
    id: Optional[int]
    date: datetime 
    expire_date: datetime 
    discount: Optional[float] = None
    total_quantity: float
    total_amount: float
    total_payable: float
    total_payable_with_nds: float
    checked: bool
    invoice_number: Optional[int] = None 
    profit: Optional[int] = None 
    debt: Optional[int] = None 

