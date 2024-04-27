from pydantic import BaseModel


class RegionSchema(BaseModel):
    id: int
    name: str 


class UserOutSchema(BaseModel):
    id: int
    username: str
    full_name: str
    status: str