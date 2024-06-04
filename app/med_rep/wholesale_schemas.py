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

