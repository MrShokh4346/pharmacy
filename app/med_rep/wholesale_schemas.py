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


class WholesaleSchema(BaseModel):
    name: str 
    contact: str 
    region_id: int 


class WholesaleUpdateSchema(BaseModel):
    name: Optional[str] = None   
    contact: Optional[str] = None   
    region_id: Optional[int] = None    


class WholesaleOutSchema(BaseModel):
    id: int 
    name: str 
    contact: str 
    region: RegionSchema 
    products: List[WholesaleProductsSchema]
