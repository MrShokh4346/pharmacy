from pydantic import BaseModel


class OfficeSchema(BaseModel):

    name : str
    status : bool


class OfficeGetSchema(OfficeSchema):

    id: int