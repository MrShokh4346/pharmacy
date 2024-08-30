from datetime import datetime, timedelta, timezone
from fastapi import Depends, FastAPI, HTTPException, status
from jose import JWTError, jwt
from .schemas import *
from fastapi import APIRouter
from models.users import *
from models.doctors import DoctorCategory, DoctorPostupleniyaFact
from models.pharmacy import PharmacyHotSale, Pharmacy
from models.dependencies import *
from models.database import get_db
from typing import Annotated, List
from fastapi.security import HTTPAuthorizationCredentials
from deputy_director.schemas import NotificationOutSchema, NotificationListSchema
from director.schemas import user_role_to_role_ids
from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from sqlalchemy.orm import selectinload
from .utils import *
from common_depetencies import StartEndDates


router = FastAPI()


@router.post('/add-product-category', response_model=List[ProductCategorySchema], description='using ProductCategorySchema')
async def add_doctor_category(name: str, db: AsyncSession = Depends(get_db)):
    category = ProductCategory(name=name)
    await category.save(db)
    result = await db.execute(select(ProductCategory))
    return result.scalars().all()


@router.put('/update-product-category/{category_id}', response_model=ProductCategorySchema)
async def update_product_category(category_id: int, name: str, db: AsyncSession = Depends(get_db)):
    category = await get_or_404(ProductCategory, category_id, db)
    await category.update(name=name, db=db)
    return category


@router.get('/get-product-category', response_model=List[ProductCategorySchema], description='using ProductCategorySchema')
async def get_doctor_category(db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(ProductCategory))
    return result.scalars().all()


@router.get("/get-regions", response_model=List[RegionSchema])
async def get_regions(db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(Region))
    return result.scalars().all()


@router.post("/add-region", response_model=List[RegionSchema])
async def add_region(name: str, db: AsyncSession = Depends(get_db)):
    region = Region(name = name)
    await region.save(db)
    result = await db.execute(select(Region))
    return result.scalars().all()


@router.put('/update-region/{region_id}', response_model=RegionSchema)
async def update_region(region_id: int, name: str, db: AsyncSession = Depends(get_db)):
    region = await get_or_404(Region, region_id, db)
    await region.update(name=name, db=db)
    return region


@router.post('/add-category', response_model=List[DoctorCategorySchema], description='using DoctorCategorySchema')
async def add_doctor_category(name: str, db: AsyncSession = Depends(get_db)):
    category = DoctorCategory(name=name)
    await category.save(db)
    result = await db.execute(select(DoctorCategory))
    return result.scalars().all()


@router.put('/update-category/{category_id}', response_model=DoctorCategorySchema)
async def update_doctor_category(category_id: int, name: str, db: AsyncSession = Depends(get_db)):
    category = await get_or_404(DoctorCategory, category_id, db)
    await category.update(name=name, db=db)
    return category


@router.get('/get-category', response_model=List[DoctorCategorySchema], description='using DoctorCategorySchema')
async def get_doctor_category(db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(DoctorCategory))
    return result.scalars().all()


@router.post('/add-speciality', response_model=List[DoctorSpecialitySchema], description='using DoctorSpecialitySchema')
async def add_doctor_speciality(name: str, db: AsyncSession = Depends(get_db)):
    speciality = Speciality(name=name)
    await speciality.save(db)
    result = await db.execute(select(Speciality))
    return result.scalars().all()


@router.put('/update-speciality/{speciality_id}', response_model=DoctorCategorySchema)
async def update_doctor_category(speciality_id: int, name: str, db: AsyncSession = Depends(get_db)):
    speciality = await get_or_404(Speciality, speciality_id, db)
    await speciality.update(name=name, db=db)
    return speciality


@router.get('/get-speciality', response_model=List[DoctorSpecialitySchema], description='using DoctorSpecialitySchema')
async def get_doctor_speciality(db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(Speciality))
    return result.scalars().all()


@router.post('/add-medical-organization', response_model=List[MedicalOrganizationOutSchema], description='using MedicalOrganizationInSchema')
async def add_medical_organization(organization: MedicalOrganizationInSchema, db: AsyncSession = Depends(get_db)):
    new_organization = MedicalOrganization(**organization.dict())
    await new_organization.save(db)
    result = await db.execute(select(MedicalOrganization).options(selectinload(MedicalOrganization.region)))
    return result.scalars().all()


@router.put('/update-medical-organization/{organization_id}', response_model=MedicalOrganizationOutSchema)
async def update_doctor_category(organization_id: int, organization: MedicalOrganizationUpdateSchema, db: AsyncSession = Depends(get_db)):
    org = await get_or_404(MedicalOrganization, organization_id, db)
    await org.update(**organization.dict(), db=db)
    return org


@router.get('/get-medical-organization', response_model=List[MedicalOrganizationOutSchema], description='using MedicalOrganizationOutSchema')
async def get_medical_organization(db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(MedicalOrganization).options(selectinload(MedicalOrganization.region)))
    return result.scalars().all()


@router.get("/get-users", response_model=List[UserOutSchema])
async def get_users(user: Annotated[Users, Depends(get_current_user)], token: HTTPAuthorizationCredentials = Depends(auth_header), db: AsyncSession = Depends(get_db)):
    query = select(Users).options(selectinload(Users.region), selectinload(Users.region_manager))
    if user.status == 'director':
        query = query.filter(Users.director_id == user.id)
    elif user.status == 'deputy_director':
        query = query.filter(Users.deputy_director_id == user.id)
    elif user.status == 'product_manager':
        query = query.filter(Users.product_manager_id == user.id)
    elif user.status == 'ff_manager':
        query = query.filter(Users.ffm_id == user.id)
    elif user.status == 'regional_manager':
        query = query.filter(Users.region_manager_id == user.id)
    else:
        return []
    result = await db.execute(query)
    return result.scalars().all()


@router.get("/get-users-by-username", response_model=List[UserOutSchema])
async def get_users_by_username(username: str,  db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(Users).filter(Users.username == username))
    user = result.scalar()
    query = select(Users).options(selectinload(Users.region), selectinload(Users.region_manager))
    if (user) and (user.status == 'director'):
        query = query.filter(Users.director_id == user.id)
    elif (user) and (user.status == 'deputy_director'):
        query = query.filter(Users.deputy_director_id == user.id)
    elif (user) and (user.status == 'product_manager'):
        query = query.filter(Users.product_manager_id == user.id)
    elif (user) and (user.status == 'ff_manager'):
        query = query.filter(Users.ffm_id == user.id)
    elif (user) and (user.status == 'regional_manager'):
        query = query.filter(Users.region_manager_id == user.id)
    else:
        return []
    result = await db.execute(query)
    return result.scalars().all()


@router.get("/get-medical-representatives")
async def get_medical_representatives(filter_date: StartEndDates, db: AsyncSession = Depends(get_db)):
    start_date = filter_date['start_date']
    end_date = filter_date['end_date']
    result = await db.execute(select(Users).options(selectinload(Users.region), selectinload(Users.region_manager)).filter(Users.status == 'medical_representative'))
    data = []
    for user in result.scalars().all():
        result1 = await db.execute(select(UserProductPlan).filter(UserProductPlan.med_rep_id==user.id, UserProductPlan.plan_month>=start_date, UserProductPlan.plan_month<=end_date))
        user_plans = result1.scalars().all()
        user_plan_data = []
        for user_plan in user_plans:
            hot_sales = await get_hot_sale(user_plan.med_rep_id, user_plan.product_id, start_date, end_date, db)
            fact = await get_visit_facts(user_plan.med_rep_id, user_plan.product_id, start_date, end_date, db)
            fact_postupleniya = await get_postupleniya_facts(user_plan.med_rep_id, user_plan.product_id, start_date, end_date, db)
            user_plan_data.append({
                "id": user_plan.id,
                "product": user_plan.product.name,
                "product_id": user_plan.product.id,
                "plan_amount": user_plan.amount - user_plan.current_amount,
                "plan_price" : (user_plan.amount - user_plan.current_amount) * user_plan.product.price,
                "plan_bonus" : (user_plan.amount - user_plan.current_amount) * user_plan.product.marketing_expenses, 
                "hot_sales": hot_sales,
                "hot_sales_price": hot_sales * user_plan.product.price,
                "fact": fact,
                "fact_price": fact *  user_plan.product.price,
                "fact_postupleniya": fact_postupleniya[0],
                "fact_postupleniya_price": fact_postupleniya[1],
                "vakant": user_plan.current_amount,
                "vakant_price": user_plan.current_amount * user_plan.product.price,
            })
        med_rep = {
            'id': user.id,
            'full_name': user.full_name,
            'username': user.username,
            'status': user.status,
            'plan' : user_plan_data
        }
        data.append(med_rep)
    return data


@router.get('/get-all_plan_sum')
async def get_all_plan_sum(month_number: int | None = None, start_date: date | None = None, end_date: date | None = None, db: AsyncSession = Depends(get_db)):
    if start_date is None or end_date is None:
        if month_number is None:
            month_number = datetime.now().month 
        year = datetime.now().year
        num_days = calendar.monthrange(year, month_number)[1]
        start_date = datetime(year, month_number, 1)  
        end_date = datetime(year, month_number, num_days, 23, 59)
    query = text(f"""SELECT sum(user_product_plan.amount*user_product_plan.price), sum(user_product_plan.amount) from user_product_plan 
                where user_product_plan.date>=TO_DATE(:start_date, 'YYYY-MM-DD') AND user_product_plan.date<=TO_DATE(:end_date, 'YYYY-MM-DD')""")
    result = await db.execute(query, {'start_date': str(start_date), 'end_date': str(end_date)})
    plan_sum = result.first()
    data_dict = {
            "plan_sum": plan_sum[0] if plan_sum else 0,
            "plan": plan_sum[1] if plan_sum else 0,
            }
    return data_dict


@router.get("/get-med-reps", response_model=List[UserByIdSchema])
async def get_med_rep(db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(Users).options(selectinload(Users.product_manager)).filter(Users.status == 'medical_representative'))
    return result.scalars().all()
    

@router.post('/add-manufactured-company', response_model=List[ManufacturedCompanySchema])
async def add_manufactured_company(name: str, db: AsyncSession = Depends(get_db)):
    comp = ManufacturedCompany(name=name)
    await comp.save(db)
    result = await db.execute(select(ManufacturedCompany))
    return result.scalars().all()


@router.put('/update-manufactured-company/{company_id}', response_model=DoctorCategorySchema)
async def update_doctor_category(company_id: int, name: str, db: AsyncSession = Depends(get_db)):
    company = await get_or_404(ManufacturedCompany, company_id, db)
    await company.update(name=name, db=db)
    return company


@router.get('/get-manufactured-company', response_model=List[ManufacturedCompanySchema])
async def get_manufactured_company(db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(ManufacturedCompany))
    return result.scalars().all()


@router.post('/add-product', response_model=List[ProductOutSchema])
async def add_medcine(product: ProductInSchema, db: AsyncSession = Depends(get_db)):
    product = Products(**product.dict())
    await product.save(db)
    result = await db.execute(select(Products).options(selectinload(Products.man_company), selectinload(Products.category)))
    return result.scalars().all()


@router.put('/update-product/{product_id}', response_model=ProductOutSchema)
async def update_doctor_category(product_id: int, obj: ProductUpdateSchema, db: AsyncSession = Depends(get_db)):
    product = await get_or_404(Products, product_id, db)
    await product.update(**obj.dict(), db=db)
    return product
    

@router.get('/get-product', response_model=List[ProductOutSchema])
async def get_medcine(db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(Products).options(selectinload(Products.man_company), selectinload(Products.category)))
    return result.scalars().all()


@router.get('/search-product', response_model=List[ProductOutSchema])
async def search_medcine(search: str, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(Products).options(selectinload(Products.man_company), selectinload(Products.category)).filter(Products.name.like(f"%{search}%")))
    return result.scalars().all()


@router.get('/filter-product', response_model=List[ProductOutSchema])
async def filter_products(category_id: int | None = None, man_company_id: int | None = None, db: AsyncSession = Depends(get_db)):
    query = select(Products).options(selectinload(Products.man_company), selectinload(Products.category))
    if category_id:
        query = query.filter(Products.category_id==category_id)
    if man_company_id:
        query = query.filter(Products.man_company_id==man_company_id)
    result = await db.execute(query)
    return result.scalars().all()


@router.get('/get-notofication/{notofication_id}', response_model=NotificationOutSchema)
async def get_notification_by_id(notofication_id: int, db: AsyncSession = Depends(get_db)):
    return await get_or_404(Notification, notofication_id, db)


@router.get('/get-notifications', response_model=List[NotificationListSchema])
async def notifications(user_id: int, user_status: str, db: AsyncSession = Depends(get_db)):
    if user_status in user_role_to_role_ids.keys():
        result = await db.execute(select(Notification).options(selectinload(Notification.doctor), selectinload(Notification.pharmacy), selectinload(Notification.wholesale)).filter(text(f"{user_role_to_role_ids[user_status]}={user_id}")))
        return result.scalars().all()
    raise HTTPException(status_code=400, detail="User status incorrect")


@router.put('/update-user/{user_id}', response_model=UserSchema)
async def update_user(user_id: int, crd: UserUpdateSchema, db: AsyncSession = Depends(get_db)):
    user = await get_or_404(Users, user_id, db)
    await user.update(**crd.dict(), db=db)
    return user


@router.post('/post-expense-category', response_model=ExpenceCategoryOutSchema)
async def post_expence_category(data: ExpenceCategoryInSchema, db: AsyncSession = Depends(get_db)):
    category = ExpenseCategory(**data.dict())
    await category.save(db)
    return category


@router.get('/get-expenxe-categories', response_model=List[ExpenceCategoryOutSchema])
async def get_expenxe_categories(db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(ExpenseCategory))
    return result.scalars().all()


@router.post('/post-expense', response_model=ExpenceOutSchema)
async def post_expence(data: ExpenceSchema, db: AsyncSession = Depends(get_db)):
    expence = Expense(**data.dict())
    await expence.save(db)
    return expence


@router.get('/get-expenxe', response_model=List[ExpenceOutSchema])
async def get_expenxes(db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(Expense))
    return result.scalars().all()


@router.get('/get-med-rep-by-id/{med_rep_id}', response_model=UserByIdSchema)
async def get_med_rep_by_id(med_rep_id: int, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(Users).options(selectinload(Users.product_manager)).where(Users.id==med_rep_id))
    user = result.scalars().first()
    if not user:
        raise HTTPException(status_code=400, detail=f"User not found")
    return user 