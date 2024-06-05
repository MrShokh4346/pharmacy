from pydantic import BaseModel


class RegionSchema(BaseModel):
    id: int
    name: str 


class UserOutSchema(BaseModel):
    id: int
    username: str
    full_name: str
    status: str
    region: RegionSchema


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
    med_rep_id: int 
    region_id: int 


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
    med_rep: UserSchema
    region: RegionSchema


class ProductInSchema(BaseModel):
    name: str 
    price: int 
    discount_price: int 
    man_company_id: int 
    category_id: int


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



