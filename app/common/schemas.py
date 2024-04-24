from pydantic import BaseModel


class RegionSchema(BaseModel):
    id: int
    name: str 