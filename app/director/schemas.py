from pydantic import BaseModel, Field, EmailStr
from typing import Literal
from enum import Enum
from fastapi import FastAPI, Path

user_role_to_role_ids = {
    "medical_representative" : "med_rep_id",
    "regional_manager" : "region_manager_id",
    "ff_manager" : "ffm_id",
    "product_manager" : "product_manager_id",
    "deputy_director" : "deputy_director_id",
    "director" : "director_id"
}

class Status(str, Enum):
    medical_representative = "medical_representative"
    regional_manager = "regional_manager"
    ff_manager = "ff_manager"
    product_manager = "product_manager"
    deputy_director = "deputy_director"


class RegisterForDSchema(BaseModel):
    password: str
    username: str
    email: EmailStr
    full_name: str
    status: Status =  Path(..., title="User Role", description="The role of the user")
    region_id: int
    region_manager_id: int | None = None
    ffm_id: int | None = None
    product_manager_id: int | None = None
    deputy_director_id: int | None = None


class UserOutSchema(BaseModel):
    id: int
    username: str
    full_name: str
    status: str 
