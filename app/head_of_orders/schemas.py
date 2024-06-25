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
    total_payable: float
    checked: bool


class CheckSchema(BaseModel):
    check: bool 


class ExpireDateSchema(BaseModel):
    date: date

