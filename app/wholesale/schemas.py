from pydantic import BaseModel, Field
from typing import Literal, Annotated
from enum import Enum
from fastapi import FastAPI, Path
from common.schemas import ManufacturedCompanySchema, ProductOutSchema, RegionSchema, ProductCategorySchema
from datetime import date 
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

