from pydantic import BaseModel


class ExpenseCategoriesSchema(BaseModel):
    name: str
    office_id: int
    status: bool

class CategoriesGetSchema(ExpenseCategoriesSchema):
    id: int