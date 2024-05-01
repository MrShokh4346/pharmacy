from pydantic import BaseModel


class RegionSchema(BaseModel):
    id: int
    name: str 


class UserOutSchema(BaseModel):
    id: int
    username: str
    full_name: str
    status: str


class DoctorCategorySchema(BaseModel):
    id: int
    name: str


class DoctorSpecialitySchema(BaseModel):
    id: int
    name: str


class MedicalOrganizationInSchema(BaseModel):
    address: str 
    latitude: str 
    longitude: str 
    med_rep_id: int 
    region_id: int 


class MedicalOrganizationOutSchema(MedicalOrganizationInSchema):
    id: int


class ProductInSchema(BaseModel):
    name: str 
    price: int 
    discount_price: int 
    man_company_id: int 


class ProductOutSchema(ProductInSchema):
    id: int 


class ManufacturedCompanySchema(BaseModel):
    id: int 
    name: str 

