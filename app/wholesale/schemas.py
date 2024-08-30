from pydantic import BaseModel, Field
from typing import Literal, Annotated
from enum import Enum
from fastapi import FastAPI, Path
from common.schemas import ManufacturedCompanySchema, ProductOutSchema, RegionSchema, ProductCategorySchema
from datetime import date , datetime
from typing import List, Optional


class ProductSchema(BaseModel):
    id: int 
    name: str 
    man_company: ManufacturedCompanySchema 
    category: ProductCategorySchema


class WholesaleSchema(BaseModel):
    name: str 
    contact: str 
    region_id: int 


class WholesaleUpdateSchema(BaseModel):
    name: Optional[str] = None   
    contact: Optional[str] = None   
    region_id: Optional[int] = None   

    
class WholesaleProductsSchema(BaseModel):
    product: ProductSchema 
    amount: int 
    price: Optional[int]


class WholesaleProductsInSchema(BaseModel):
    product_id: int 
    quantity: Annotated[int, Path(title="", ge=0)]
    factory_id: int
    price: int
 

class WholesaleOutSchema(BaseModel):
    id: int 
    name: str 
    contact: str 
    region: RegionSchema 
    report_warehouse: List[WholesaleProductsSchema]


class WholesaleListSchema(BaseModel):
    id: int 
    name: str 
    contact: str 
    region: RegionSchema 


class WholesaleWarehouseIncomeOutSchema(BaseModel):
    id: int 
    factory: ManufacturedCompanySchema 
    product: ProductSchema 
    quantity: int 
    date: date
    price: Optional[int]


class WholesaleOutputSchema(BaseModel):
    product_id: int 
    amount: int 
    pharmacy: str 
    wholesale_id: int 


class WholesaleOutputOutSchema(BaseModel):
    id: int 
    amount: int 
    date: date 
    pharmacy: str 
    product: ProductOutSchema
    wholesale: WholesaleListSchema


class ReturnProductSchema(BaseModel):
    pharmacy_id: int 
    product_id: int 
    amount: int 


class WholesaleReservationProductSchema(BaseModel):
    product_id: int 
    quantity: Annotated[int, Path(title="", ge=0)]
    price: Annotated[int, Path(title="", ge=0)] 


class WholesaleReservationSchema(BaseModel):
    manufactured_company_id: int
    invoice_number: Optional[int] = None
    med_rep_id: int
    discount: int 
    products: List[WholesaleReservationProductSchema]


class ReservationProductOutSchema(BaseModel):
    id: int 
    quantity: int 
    product: ProductSchema


class ReservationSchema(BaseModel):
    id: Optional[int]
    date: datetime 
    expire_date: datetime 
    discount: Optional[int] = None
    total_quantity: float
    total_amount: float
    total_payable: float
    total_payable_with_nds: float
    products: Optional[List[ReservationProductOutSchema]] = None
    checked: bool
    invoice_number: Optional[int] = None 
    profit: Optional[float] = None 
    debt: Optional[float] = None 


class ReservationOutSchema(BaseModel):
    id: Optional[int]
    date: datetime 
    expire_date: datetime 
    discount: Optional[int] = None
    total_quantity: float
    total_amount: float
    total_payable: float
    total_payable_with_nds: float
    checked: bool
    invoice_number: Optional[int] = None 
    profit: Optional[float] = None 
    debt: Optional[float] = None 



class DoctorSchema(BaseModel):
    id: int
    full_name: str


class ReservationHistorySchema(BaseModel):
    amount: int 
    description: Optional[str] = None
    date: date 
    product: Optional[ProductSchema] = None
    doctor: Optional[DoctorSchema] = None