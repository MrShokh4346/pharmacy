from pydantic import BaseModel
from typing import Optional
from datetime import datetime 


class RegionSchema(BaseModel):
    id: int
    name: str 


class RegionManager(BaseModel):
    username: str 
    full_name: str


class UserOutSchema(BaseModel):
    id: int
    username: str
    full_name: str
    status: str
    region_manager: Optional[RegionManager] = None
    region: Optional[RegionSchema] = None


class UserUpdateSchema(BaseModel):
    full_name: str
    username: str
    password: str 


class UserSchema(BaseModel):
    id: int
    username: str
    full_name: str
    status: str
    region_manager: Optional[RegionManager] = None
    region: Optional[RegionSchema] = None


class DoctorCategorySchema(BaseModel):
    id: int
    name: str


class ProductCategorySchema(BaseModel):
    id: int
    name: str


class DoctorSpecialitySchema(BaseModel):
    id: int
    name: str


class MedicalOrganizationInSchema(BaseModel):
    name: str
    address: str 
    latitude: str 
    longitude: str 
    region_id: int 



class MedicalOrganizationUpdateSchema(BaseModel):
    name: Optional[str] = None
    address: Optional[str] = None 
    latitude: Optional[str] = None 
    longitude: Optional[str] = None 
    region_id: Optional[int] = None 


class UserSchema(BaseModel):
    id: int
    username: str
    full_name: str
    status: str


class MedicalOrganizationOutSchema(BaseModel):
    id: int
    name: str
    address: str 
    latitude: str 
    longitude: str 
    region: RegionSchema


class ProductInSchema(BaseModel):
    name: str 
    price: int 
    discount_price: int 
    man_company_id: int 
    category_id: int


class ProductUpdateSchema(BaseModel):
    name: Optional[str] = None  
    price: Optional[int] = None  
    discount_price: Optional[int] = None  
    man_company_id: Optional[int] = None  
    category_id: Optional[int] = None
 

class ManufacturedCompanySchema(BaseModel):
    id: int 
    name: str 


class ProductOutSchema(BaseModel):
    id: int 
    name: str 
    price: int 
    discount_price: int 
    man_company: ManufacturedCompanySchema 
    category: ProductCategorySchema


class ExpenceCategoryInSchema(BaseModel):
    name: str


class ExpenceCategoryOutSchema(BaseModel):
    id: int 
    name: str


class ExpenceSchema(BaseModel):
    category_id: int 
    amount: int 
    description: str 


class ExpenceOutSchema(BaseModel):
    id: int
    category: ExpenceCategoryOutSchema 
    amount: int 
    description: str 
    date: datetime