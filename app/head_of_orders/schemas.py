from pydantic import BaseModel, Field
from typing import Literal, Annotated
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
    bonus: Optional[bool] = True 
    month_number: Annotated[int, Path(title="", gt=0, le=12)] 
    doctor_id: Optional[int] = None 
    product_id: int 


class PayReservtionSchema(BaseModel):
    objects: List[PayReservtionDoctors] 
    total: int
    description: Optional[str] = None 


class PayHospitalReservtion(BaseModel):
    amount: int 
    quantity: int
    bonus: Optional[bool] = True 
    month_number: Annotated[int, Path(title="", gt=0, le=12)] 
    product_id: int 


class PayHospitalReservtionSchema(BaseModel):
    objects: List[PayHospitalReservtion] 
    total: int
    description: Optional[str] = None 



class PayWholesaleReservtionDoctors(BaseModel):
    amount: int 
    quantity: int
    month_number: Annotated[int, Path(title="", gt=0, le=12)]
    doctor_id: int 
    product_id: int 


class PayWholesaleReservtionSchema(BaseModel):
    med_rep_id: int 
    pharmacy_id: int 
    total: Optional[int] = 0 
    objects: Optional[List[PayWholesaleReservtionDoctors]] = []
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

