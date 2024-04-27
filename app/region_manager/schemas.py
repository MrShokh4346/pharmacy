from pydantic import BaseModel, Field
from typing import Literal
from enum import Enum
from fastapi import FastAPI, Path

class Status(str, Enum):
    medical_representative = "medical_representative"


class RegisterForRMSchema(BaseModel):
    password: str
    username: str
    full_name: str
    status: Status =  Path(..., title="User Role", description="The role of the user")
    region_id: int


class UserOutSchema(BaseModel):
    id: int
    username: str
    full_name: str
    status: str 
