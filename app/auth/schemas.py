from pydantic import BaseModel, Field
from typing import Literal, Optional
from enum import Enum
from fastapi import FastAPI, Path


class Status(str, Enum):
    medical_representative = "medical_representative"
    regional_manager = "regional_manager"
    ff_manager = "ff_manager"
    product_manager = "product_manager"
    deputy_director = "deputy_director"
    director = "director"


class RegisterSchema(BaseModel):
    password: str
    username: str
    full_name: str
    # status: Status =  Path(..., title="User Role", description="The role of the user")


class UpdateUserSchema(RegisterSchema):
    username: str | None = None


class UserOutSchema(BaseModel):
    id: int
    username: str
    full_name: str

    # class Config:
    #     orm_mode = True


class LoginSchema(BaseModel):
    password: str
    username: str


class TokenSchema(BaseModel):
    id: int
    access_token: str
    status: str
    region_id: Optional[int]

