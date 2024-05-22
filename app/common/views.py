from datetime import datetime, timedelta, timezone
from fastapi import Depends, FastAPI, HTTPException, status
from jose import JWTError, jwt
from .schemas import *
from fastapi import APIRouter
from sqlalchemy.orm import Session
from models.users import *
from models.dependencies import *
from models.database import get_db
from typing import Annotated, List
from fastapi.security import HTTPAuthorizationCredentials
from deputy_director.schemas import NotificationOutSchema
from director.schemas import user_role_to_role_ids
from sqlalchemy import text


router = FastAPI()


@router.post('/add-product-category', response_model=List[ProductCategorySchema], description='using ProductCategorySchema')
async def add_doctor_category(name: str, db: Session = Depends(get_db)):
    category = ProductCategory(name=name)
    category.save(db)
    categories = db.query(ProductCategory).all()
    return categories


@router.get('/get-product-category', response_model=List[ProductCategorySchema], description='using ProductCategorySchema')
async def get_doctor_category(db: Session = Depends(get_db)):
    categories = db.query(ProductCategory).all()
    return categories


@router.get("/get-regions", response_model=List[RegionSchema])
async def get_regions(db: Session = Depends(get_db)):
    regions = db.query(Region).all()
    return regions


@router.post("/add-region", response_model=List[RegionSchema])
async def add_region(name: str, token: HTTPAuthorizationCredentials = Depends(auth_header), db: Session = Depends(get_db)):
    region = Region(name = name)
    region.save(db)
    regions = db.query(Region).all()
    return regions


@router.post('/add-category', response_model=List[DoctorCategorySchema], description='using DoctorCategorySchema')
async def add_doctor_category(name: str, db: Session = Depends(get_db)):
    category = DoctorCategory(name=name)
    category.save(db)
    categories = db.query(DoctorCategory).all()
    return categories


@router.get('/get-category', response_model=List[DoctorCategorySchema], description='using DoctorCategorySchema')
async def get_doctor_category(db: Session = Depends(get_db)):
    categories = db.query(DoctorCategory).all()
    return categories


@router.post('/add-speciality', response_model=List[DoctorSpecialitySchema], description='using DoctorSpecialitySchema')
async def add_doctor_speciality(name: str, db: Session = Depends(get_db)):
    speciality = Speciality(name=name)
    speciality.save(db)
    specialities = db.query(Speciality).all()
    return specialities


@router.get('/get-speciality', response_model=List[DoctorSpecialitySchema], description='using DoctorSpecialitySchema')
async def get_doctor_speciality(db: Session = Depends(get_db)):
    specialities = db.query(Speciality).all()
    return specialities


@router.post('/add-medical-organization', response_model=List[MedicalOrganizationOutSchema], description='using MedicalOrganizationInSchema')
async def add_medical_organization(organization: MedicalOrganizationInSchema, db: Session = Depends(get_db)):
    new_organization = MedicalOrganization(**organization.dict())
    new_organization.save(db)
    organizations = db.query(MedicalOrganization).all()
    return organizations


@router.get('/get-medical-organization', response_model=List[MedicalOrganizationOutSchema], description='using MedicalOrganizationOutSchema')
async def get_medical_organization(db: Session = Depends(get_db)):
    organizations = db.query(MedicalOrganization).all()
    return organizations


@router.get("/get-users", response_model=List[UserOutSchema])
async def get_users(user: Annotated[Users, Depends(get_current_user)], token: HTTPAuthorizationCredentials = Depends(auth_header), db: Session = Depends(get_db)):
    if user.status == 'director':
        users = db.query(Users).filter(Users.director_id == user.id).all()
    elif user.status == 'deputy_director':
        users = db.query(Users).filter(Users.deputy_director_id == user.id).all()
    elif user.status == 'product_manager':
        users = db.query(Users).filter(Users.product_manager_id == user.id).all()
    elif user.status == 'ff_manager':
        users = db.query(Users).filter(Users.ffm_id == user.id).all()
    elif user.status == 'regional_manager':
        users = db.query(Users).filter(Users.region_manager_id == user.id).all()
    else:
        return []
    return users


@router.get("/get-users-by-username", response_model=List[UserOutSchema])
async def get_users_by_username(username: str,  db: Session = Depends(get_db)):
    user = db.query(Users).filter(Users.username == username).first()
    if (user) and (user.status == 'director'):
        users = db.query(Users).filter(Users.director_id == user.id).all()
    elif (user) and (user.status == 'deputy_director'):
        users = db.query(Users).filter(Users.deputy_director_id == user.id).all()
    elif (user) and (user.status == 'product_manager'):
        users = db.query(Users).filter(Users.product_manager_id == user.id).all()
    elif (user) and (user.status == 'ff_manager'):
        users = db.query(Users).filter(Users.ffm_id == user.id).all()
    elif (user) and (user.status == 'regional_manager'):
        users = db.query(Users).filter(Users.region_manager_id == user.id).all()
    else:
        return []
    return users


@router.post('/add-manufactured-company', response_model=List[ManufacturedCompanySchema])
async def add_manufactured_company(name: str, db: Session = Depends(get_db)):
    comp = ManufacturedCompany(name=name)
    comp.save(db)
    comps = db.query(ManufacturedCompany).all()
    return comps


@router.get('/get-manufactured-company', response_model=List[ManufacturedCompanySchema])
async def get_manufactured_company(db: Session = Depends(get_db)):
    comps = db.query(ManufacturedCompany).all()
    return comps


@router.post('/add-product', response_model=List[ProductOutSchema])
async def add_medcine(product: ProductInSchema, db: Session = Depends(get_db)):
    product = Products(**product.dict())
    product.save(db)
    products = db.query(Products).all()
    return products 
    

@router.get('/get-product', response_model=List[ProductOutSchema])
async def get_medcine(db: Session = Depends(get_db)):
    products = db.query(Products).all()
    return products 


@router.get('/search-product', response_model=List[ProductOutSchema])
async def search_medcine(search: str, db: Session = Depends(get_db)):
    products = db.query(Products).filter(Products.name.like(f"%{search}%")).all()
    return products 


@router.get('/filter-product-by-category', response_model=List[ProductOutSchema])
async def filter_products_by_category_id(category_id: str, db: Session = Depends(get_db)):
    products = db.query(Products).filter(Products.category_id==category_id).all()
    return products


@router.get('/filter-product-by-manufacturer', response_model=List[ProductOutSchema])
async def filter_products_by_manufactured_company_id(man_company_id: str, db: Session = Depends(get_db)):
    products = db.query(Products).filter(Products.man_company_id==man_company_id).all()
    return products


@router.get('/get-notofication/{notofication_id}', response_model=NotificationOutSchema)
async def get_notification_by_id(notofication_id: int, db: Session = Depends(get_db)):
    notification = db.query(Notification).get(notofication_id)
    return notification


@router.get('/get-notifications', response_model=List[NotificationOutSchema])
async def notifications(user_id: int, user_status: str, db: Session = Depends(get_db)):
    if user_status in user_role_to_role_ids.keys():
        notifications = db.query(Notification).filter(text(f"{user_role_to_role_ids[user_status]}={user_id}")).all()
        return notifications
    raise HTTPException(status_code=400, detail="User status incorrect")