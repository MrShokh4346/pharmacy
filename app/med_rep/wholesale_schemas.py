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


class UserOutSchema(BaseModel):
    id: int
    username: str
    full_name: str


class PharmacySchema(BaseModel):
    id: int
    company_name: str
    inter_branch_turnover: str 
    med_rep: UserOutSchema


class IncomingBalanceInStockProductSchema(BaseModel):
    product: ProductOutSchema
    quantity: int 
    current_amount: int | None = None


class WholesaleReportSchema(BaseModel):
    date: date 
    wholesale: WholesaleOutSchema
    pharmacy: PharmacySchema
    products: List[IncomingBalanceInStockProductSchema]


class DoctorOutSchema(BaseModel):
    id: int 
    full_name: str 
    email: str 
    speciality: DoctorSpecialitySchema 


class PharmacyWSchema(BaseModel):
    id: int
    company_name: str
    inter_branch_turnover: str 
    


class WholesaleReservationPayedAmountsSchema(BaseModel):
    id : int  
    amount : int 
    description : Optional[str] = None 
    date : datetime  
    product : ProductOutSchema 
    doctor : DoctorOutSchema  
    pharmacy : PharmacyWSchema   
    med_rep : UserOutSchema  