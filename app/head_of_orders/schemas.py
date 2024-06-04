from pydantic import BaseModel, Field
from typing import Literal
from enum import Enum
from fastapi import FastAPI, Path
from common.schemas import ManufacturedCompanySchema, ProductOutSchema, RegionSchema
from datetime import date 
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


class WholesaleSchema(BaseModel):
    name: str 
    contact: str 
    region_id: int 


class WholesaleUpdateSchema(BaseModel):
    name: Optional[str] = None   
    contact: Optional[str] = None   
    region_id: Optional[int] = None   


    
class WholesaleProductsSchema(BaseModel):
    product: ProductOutSchema 
    quantity: int 


class WholesaleProductsListSchema(BaseModel):
    products: List[WholesaleProductsSchema]
 

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
