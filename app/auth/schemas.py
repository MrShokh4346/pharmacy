from pydantic import BaseModel


class RegisterSchema(BaseModel):
    password: str
    username: str
    full_name: str
    status: str 
    boss_id: int | None = None


class UpdateUserSchema(RegisterSchema):
    username: str | None = None


class UserOutSchema(BaseModel):
    id: int
    username: str
    full_name: str
    status: str 

    # class Config:
    #     orm_mode = True


class LoginSchema(BaseModel):
    password: str
    username: str


class TokenSchema(BaseModel):
    access_token: str


