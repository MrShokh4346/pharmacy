from pydantic import BaseModel, Field, EmailStr
from typing import Literal, Optional
from enum import Enum
from fastapi import FastAPI, Path
from datetime import datetime


class Status(str, Enum):
    director = "director"
    ceo = "ceo"


class RegisterSchema(BaseModel):
    password: str
    username: str
    email: EmailStr
    full_name: str
    status: Status =  Path(..., title="User Role", description="The role of the user")


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


class LoginEmailSchema(BaseModel):
    email: EmailStr


class LoginEmailCodeSchema(BaseModel):
    email: EmailStr
    code: str


class UserLoginMonitoringSchema(BaseModel):
    login_date: datetime
    location: str
    latitude: Optional[str] = None
    longitude: Optional[str] = None
    user_id: int 


class UserLogoutMonitoringSchema(BaseModel):
    logout_date: datetime
    monitoring_id: int 


class EditablePlanMonthsSchema(BaseModel):
    id: int
    month: int
    status: bool 