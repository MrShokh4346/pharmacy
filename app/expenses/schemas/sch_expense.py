from pydantic import BaseModel


class ExpenseSchema(BaseModel):
    who_added : str
    categories_id : int
    office_id : int
    amount : int
    description : str
    status : bool

class ExpenseGetSchema(ExpenseSchema):
    id : int