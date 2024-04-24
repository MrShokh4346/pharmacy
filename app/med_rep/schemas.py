from pydantic import BaseModel


# class Status(str, Enum):
#     medical_representative = "medical_representative"
#     regional_manager = "regional_manager"
#     ff_manager = "ff_manager"
#     product_manager = "product_manager"



# class RegisterSchema(BaseModel):
#     password: str
#     username: str
#     full_name: str
#     status: Status =  Path(..., title="User Role", description="The role of the user")


class PharmacySchema(BaseModel):
    company_name: str 
    latitude: str
    longitude: str 
    address: str 
    bank_account_number: str 
    inter_branch_turnover: str 
    classification_of_economic_activities: str 
    VAT_payer_code: str 
    director: str 
    region_id: int
    med_rep_id: int | None = None 
    region_manager_id: int | None = None 
