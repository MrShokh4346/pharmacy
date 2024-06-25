from pydantic import BaseModel
from typing import List, Optional
from common.schemas import RegionSchema, DoctorCategorySchema, DoctorSpecialitySchema, MedicalOrganizationOutSchema, ProductOutSchema
from datetime import date, datetime
from enum import Enum


class WholesaleProductsSchema(BaseModel):
    product_name: str 
    price: int 
    quantity: int 


class WholesaleProductsListSchema(BaseModel):
    products: List[WholesaleProductsSchema]


class WholesaleOutSchema(BaseModel):
    id: int 
    name: str 
    contact: str 
    region: RegionSchema 


class WholesaleProductListSchema(BaseModel):
    id: int 
    wholesale: WholesaleOutSchema 
    product: ProductOutSchema
    amount: int


class ManufacturedCompanySchema(BaseModel):
    id: int 
    name: str 


class FactoryWarehouseOutSchema(BaseModel):
    id: int 
    factory: ManufacturedCompanySchema 
    product: ProductOutSchema
    amount: int


class PharmacySchema(BaseModel):
    id: int
    company_name: str


class IncomingBalanceInStockProductSchema(BaseModel):
    product: ProductOutSchema
    quantity: int 


class WholesaleReportSchema(BaseModel):
    date: date 
    wholesale: WholesaleOutSchema
    pharmacy: PharmacySchema
    products: List[IncomingBalanceInStockProductSchema]


class WholesaleOutputSchema(BaseModel):
    product_id: int 
    amount: int 
    pharmacy: str 
    


