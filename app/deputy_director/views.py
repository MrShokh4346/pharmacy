from datetime import datetime, timedelta, timezone, date 
from fastapi import Depends, FastAPI, HTTPException, status
from jose import JWTError, jwt
from .schemas import *
from fastapi import APIRouter
from models.users import *
from models.doctors import DoctorFact, Doctor, Bonus
from models.database import get_db, get_or_404
from models.dependencies import *
from typing import Any
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from sqlalchemy.future import select
from sqlalchemy.orm import selectinload, joinedload
from sqlalchemy.ext.asyncio import AsyncSession
import calendar


router = FastAPI()


@router.post('/register-for-dd', response_model=UserOutSchema, description='using RegisterForDDSchema')
async def register_user_for_pm(user: RegisterForDDSchema, manager: Annotated[Users, Depends(get_current_user)], token: HTTPAuthorizationCredentials = Depends(auth_header), db: AsyncSession = Depends(get_db)) -> Any:
    if manager.status == 'deputy_director':
        await check_if_user_already_exists(username=user.username, db = db)
        if user.status == 'medical_representative':
            if not (user.region_manager_id and user.ffm_id and user.product_manager_id):
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="region_manager_id, ffm_id, product_manager_id should be declared"
                )
            new_user = Users(**user.dict(), deputy_director_id=manager.id, director_id=manager.director_id)
            await new_user.save(db=db)
        elif user.status == 'regional_manager':
            if not (user.ffm_id and user.product_manager_id):
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="ffm_id, product_manager_id should be declared"
                )
            new_user = Users(**user.dict(), deputy_director_id=manager.id, director_id=manager.director_id)
            await new_user.save(db=db)
        elif user.status == 'ff_manager':
            if not user.product_manager_id:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="product_manager_id should be declared"
                )
            new_user = Users(**user.dict(), deputy_director_id=manager.id, director_id=manager.director_id)
            await new_user.save(db=db)
        else:
            new_user = Users(**user.dict(), deputy_director_id=manager.id, director_id=manager.director_id)
            await new_user.save(db=db)
        return new_user
    raise HTTPException(status_code=403, detail="You are not a deputy director")


@router.post('/add-doctor-plan/{med_rep_id}', response_model=List[DoctorVisitPlanOutSchema])
async def add_doctor_visit_plan_to_mr(med_rep_id:int, plan: DoctorVisitPlanSchema,  db: AsyncSession = Depends(get_db)):
    visit = DoctorPlan(**plan.dict(), med_rep_id=med_rep_id)
    await visit.save(db)
    result = await db.execute(select(DoctorPlan).options(selectinload(DoctorPlan.doctor)).filter(DoctorPlan.med_rep_id==med_rep_id))
    return result.scalars().all()


@router.delete('/delete-doctor-plan/{plan_id}')
async def delete_doctor_visit_plan(plan_id:int, db: AsyncSession = Depends(get_db)):
    visit = await get_or_404(DoctorPlan, plan_id, db)
    await db.delete(visit)
    await db.commit()
    return {"msg":"Deleted"}


@router.post('/add-pharmacy-plan/{med_rep_id}', response_model=List[PharmacyVisitPlanOutSchema])
async def add_pharmacy_visit_plan_to_mr(med_rep_id:int, plan: PharmacyVisitPlanSchema,  db: AsyncSession = Depends(get_db)):
    visit = PharmacyPlan(**plan.dict(), med_rep_id=med_rep_id)
    await visit.save(db)
    result = await db.execute(select(PharmacyPlan).options(selectinload(PharmacyPlan.pharmacy)).filter(PharmacyPlan.med_rep_id==med_rep_id))
    return result.scalars().all()


@router.delete('/delete-pharmacy-plan/{plan_id}')
async def delete_pharmacy_visit_plan(plan_id:int, db: AsyncSession = Depends(get_db)):
    visit = await get_or_404(PharmacyPlan, plan_id, db)
    await db.delete(visit)
    await db.commit()
    return {"msg":"Deleted"}


@router.post('/post-notification', response_model=NotificationOutSchema)
async def post_notification(notif: NotificationSchema,  db: AsyncSession = Depends(get_db)):
    notification = await Notification.save(**notif.dict(), db=db)
    return notification 


@router.get('/notofications/{user_id}', response_model=List[NotificationListSchema])
async def notofications(user_id: int, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(Notification).options(selectinload(Notification.doctor), selectinload(Notification.pharmacy), selectinload(Notification.wholesale)).filter(Notification.med_rep_id==user_id))
    return result.scalars().all()


@router.delete('/delete-notofications/{notofication_id}')
async def delete_notofications(notofication_id: int, db: AsyncSession = Depends(get_db)):
    notification = await get_or_404(Notification, notofication_id, db)
    await db.delete(notification)
    await db.commit()
    return {"msg":"Deleted"}


@router.post('/add-user-product-plan', response_model=UserProductPlanOutSchema)
async def add_user_product_plan(plan: UserProductPlanInSchema, db: AsyncSession = Depends(get_db)):
    year = datetime.now().year
    day = datetime.now().day 
    num_days = calendar.monthrange(year, plan.month)[1]
    start_date = date(year, plan.month, 1)  
    end_date = date(year, plan.month, num_days)
    plan_date = date(year, plan.month, day)
    data = plan.dict()
    del data['month']
    result = await db.execute(select(UserProductPlan).filter(UserProductPlan.product_id==plan.product_id, UserProductPlan.plan_month>=start_date, UserProductPlan.plan_month<=end_date, UserProductPlan.med_rep_id==plan.med_rep_id))
    user_product = result.scalars().first()
    if user_product:
        raise HTTPException(status_code=404, detail='Plan already exists for this product in this month')
    plan = UserProductPlan(**data, current_amount=plan.amount, plan_month=plan_date)
    await plan.save(db)
    return plan 


@router.put('/update-user-product-plan/{plan_id}', response_model=UserProductPlanOutSchema)
async def add_user_product_plan(plan_id: int, amount: int, db: AsyncSession = Depends(get_db)):
    plan = await get_or_404(UserProductPlan, plan_id, db)
    await plan.update(amount, db)
    return plan 


@router.delete('/delete-user-product-plan/{plan_id}')
async def add_user_product_plan(plan_id: int, db: AsyncSession = Depends(get_db)):
    plan = await get_or_404(UserProductPlan, plan_id, db)
    await db.delete(plan)
    await db.commit()
    return {"msg":"Deleted"} 


@router.get('/get-user-products-plan/{med_rep_id}', response_model=List[UserProductPlanOutSchema])
async def add_user_products_plan(med_rep_id: int, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(UserProductPlan).filter(UserProductPlan.med_rep_id==med_rep_id))
    return result.scalars().all() 


@router.get('/get-med-rep-product-plan-by-month-id/{med_rep_id}')
async def get_user_product_plan_by_plan_id(med_rep_id: int, month_number: int | None = None, start_date: date | None = None, end_date: date | None = None, db: AsyncSession = Depends(get_db)):
    if month_number:
        year = datetime.now().year
        num_days = calendar.monthrange(year, month_number)[1]
        start_date = date(year, month_number, 1)
        end_date = date(year, month_number, num_days)
    result1 = await db.execute(select(UserProductPlan).filter(UserProductPlan.plan_month>=start_date, UserProductPlan.plan_month<=end_date, UserProductPlan.med_rep_id==med_rep_id))
    user_plans = result1.scalars().all()
    user_plan_data = []
    fact = 0
    fact_price = 0
    for user_plan in user_plans:
        query = select(DoctorMonthlyPlan).join(Doctor).options(joinedload(DoctorMonthlyPlan.doctor)).filter(Doctor.med_rep_id == user_plan.med_rep_id, DoctorMonthlyPlan.product_id == user_plan.product_id, DoctorMonthlyPlan.date >= start_date, DoctorMonthlyPlan.date <= end_date)
        result = await db.execute(query)
        doctor_att = []
        doctor_plans = result.scalars().all() 
        for doctor_plan in doctor_plans:
            result = await db.execute(select(DoctorFact).filter(DoctorFact.doctor_id==doctor_plan.doctor_id, DoctorFact.product_id==user_plan.product_id, DoctorFact.date >= start_date, DoctorFact.date <= end_date))
            fact_d = 0
            for f in result.scalars().all():
                fact_d += f.fact
            doctor_att.append({
                'monthly_plan' : doctor_plan.monthly_plan,
                'fact' : fact_d,
                'doctor_name' : doctor_plan.doctor.full_name,
                'doctor_id' : doctor_plan.doctor.id
            })
            fact +=  fact_d
            fact_price += fact_d *  user_plan.product.price
        user_plan_data.append({
            "id": user_plan.id,
            "product": user_plan.product.name,
            "product_id": user_plan.product.id,
            "plan_amount": user_plan.amount,
            "plan_price" : user_plan.amount * user_plan.product.price,
            "date": user_plan.date,
            "doctor_plans": doctor_att,
            "vakant": user_plan.current_amount
        })
    data = {
        'plan' : user_plan_data,
        'fact' : fact,
        'fact_price' : fact_price
    }
    return data


@router.get('/get-med-rep-product-plan-by-month')
async def get_user_product_plan_by_plan_id(month_number: int | None = None, start_date: date | None = None, end_date: date | None = None, db: AsyncSession = Depends(get_db)):
    if month_number:
        year = datetime.now().year
        num_days = calendar.monthrange(year, month_number)[1]
        start_date = date(year, month_number, 1)
        end_date = date(year, month_number, num_days)
    result1 = await db.execute(select(UserProductPlan).filter(UserProductPlan.plan_month>=start_date, UserProductPlan.plan_month<=end_date))
    user_plans = result1.scalars().all()
    user_plan_data = []
    fact = 0
    fact_price = 0
    for user_plan in user_plans:
        query = select(DoctorMonthlyPlan).join(Doctor).options(joinedload(DoctorMonthlyPlan.doctor)).filter(Doctor.med_rep_id == user_plan.med_rep_id, DoctorMonthlyPlan.product_id == user_plan.product_id, DoctorMonthlyPlan.date >= start_date, DoctorMonthlyPlan.date <= end_date)
        result = await db.execute(query)
        doctor_att = []
        doctor_plans = result.scalars().all() 
        for doctor_plan in doctor_plans:
            result = await db.execute(select(DoctorFact).filter(DoctorFact.doctor_id==doctor_plan.doctor_id, DoctorFact.product_id==user_plan.product_id, DoctorFact.date >= start_date, DoctorFact.date <= end_date))
            fact_d = 0
            for f in result.scalars().all():
                fact_d += f.fact
            doctor_att.append({
                'monthly_plan' : doctor_plan.monthly_plan,
                'fact' : fact_d,
                'doctor_name' : doctor_plan.doctor.full_name,
                'doctor_id' : doctor_plan.doctor.id
            })
            fact +=  fact_d
            fact_price += fact_d *  user_plan.product.price
        user_plan_data.append({
            "id": user_plan.id,
            "product": user_plan.product.name,
            "product_id": user_plan.product.id,
            "plan_amount": user_plan.amount,
            "plan_price" : user_plan.amount * user_plan.product.price,
            "date": user_plan.date,
            "doctor_plans": doctor_att,
            "vakant": user_plan.current_amount
        })
    data = {
        'plan' : user_plan_data,
        'fact' : fact,
        'fact_price' : fact_price
    }
    return data


@router.get('/get-doctor-bonus-by-med-rep-id/{med_rep_id}')
async def get_doctor_bonus_by_med_rep_id(med_rep_id: int, month_number: int,  db: AsyncSession = Depends(get_db)):
    year = datetime.now().year
    num_days = calendar.monthrange(year, month_number)[1]
    start_date = date(year, month_number, 1)
    end_date = date(year, month_number, num_days)
    user = await get_or_404(Users, med_rep_id, db)
    query = select(DoctorMonthlyPlan).join(Doctor).join(MedicalOrganization).options(joinedload(DoctorMonthlyPlan.doctor), joinedload(DoctorMonthlyPlan.product)).filter(Doctor.med_rep_id == user.id, DoctorMonthlyPlan.date >= start_date, DoctorMonthlyPlan.date <= end_date)
    result = await db.execute(query)
    doctor_att = []
    doctor_plans = result.scalars().all() 
    for doctor_plan in doctor_plans:
        result = await db.execute(select(DoctorFact).filter(DoctorFact.doctor_id==doctor_plan.doctor_id, DoctorFact.product_id==doctor_plan.product_id, DoctorFact.date >= start_date, DoctorFact.date <= end_date))
        fact_d = 0
        for f in result.scalars().all():
            fact_d += f.fact
        result = await db.execute(select(Bonus).filter(Bonus.doctor_id==doctor_plan.doctor_id, Bonus.product_id==doctor_plan.product_id, Bonus.date >= start_date, Bonus.date <= end_date))
        bonus = result.scalars().first()
        doctor_att.append({
            'monthly_plan' : doctor_plan.monthly_plan,
            'fact' : fact_d,
            'doctor_name' : doctor_plan.doctor.full_name,
            'doctor_id' : doctor_plan.doctor.id,
            'product_name' : doctor_plan.product.name,
            'bonus_id' : bonus.id if bonus else None,
            'bonus_amount': bonus.amount if bonus else 0,
            'bonus_payed' : bonus.payed if bonus else 0
        })
    return doctor_att


@router.get('/get-fact')
async def get_fact(month_number: int, med_rep_id: int | None = None, region_id: int | None = None, product_id: int | None = None, db: AsyncSession = Depends(get_db)):
    year = datetime.now().year
    num_days = calendar.monthrange(year, month_number)[1]
    start_date = date(year, month_number, 1)
    end_date = date(year, month_number, num_days)
    query = select(DoctorMonthlyPlan).join(Doctor).join(MedicalOrganization).options(joinedload(DoctorMonthlyPlan.doctor), joinedload(DoctorMonthlyPlan.product)).filter(DoctorMonthlyPlan.date >= start_date, DoctorMonthlyPlan.date <= end_date)
    if med_rep_id:
        query = query.filter(Doctor.med_rep_id == med_rep_id)
    if region_id:
        query = query.filter(MedicalOrganization.region_id == region_id)
    if product_id:
        query = query.filter(DoctorMonthlyPlan.product_id == product_id)
    result = await db.execute(query)
    doctor_att = []
    doctor_plans = result.scalars().all() 
    for doctor_plan in doctor_plans:
        result = await db.execute(select(DoctorFact).filter(DoctorFact.doctor_id==doctor_plan.doctor_id, DoctorFact.product_id==doctor_plan.product_id, DoctorFact.date >= start_date, DoctorFact.date <= end_date))
        fact_d = 0
        for f in result.scalars().all():
            fact_d += f.fact
        result = await db.execute(select(Bonus).filter(Bonus.doctor_id==doctor_plan.doctor_id, Bonus.product_id==doctor_plan.product_id, Bonus.date >= start_date, Bonus.date <= end_date))
        bonus = result.scalars().first()
        doctor_att.append({
            'monthly_plan' : doctor_plan.monthly_plan,
            'plan_price' : doctor_plan.monthly_plan * doctor_plan.price * 0.92,
            'fact' : fact_d,
            'fact_price' : fact_d * doctor_plan.price * 0.92,
            'doctor_name' : doctor_plan.doctor.full_name,
            'doctor_id' : doctor_plan.doctor.id,
            'product_name' : doctor_plan.product.name,
            'bonus_id' : bonus.id if bonus else None,
            'bonus_amount': bonus.amount if bonus else 0,
            'bonus_payed' : bonus.payed if bonus else 0
        })
    return doctor_att


@router.get('/get-user-current-month-product-plan/{med_rep_id}', response_model=List[UserProductPlanOutSchema])
async def get_user_current_month_plan(med_rep_id: int, db: AsyncSession = Depends(get_db)):
    year = datetime.now().year
    month = datetime.now().month
    num_days = calendar.monthrange(year, month)[1]
    start_date = date(year, month, 1)
    end_date = date(year, month, num_days)
    result = await db.execute(select(UserProductPlan).filter(UserProductPlan.med_rep_id==med_rep_id, UserProductPlan.plan_month >= start_date, UserProductPlan.plan_month <= end_date))
    return result.scalars().all() 


@router.get('/get-proccess-report', response_model=List[ReportSchema])
async def get_proccess_report(db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(Doctor).options(selectinload(Doctor.doctor_attached_products)).filter(Doctor.deleted==False))
    return result.scalars().all()


@router.get('/get-proccess-report-ecxel')
async def get_proccess_report(month: int, db: AsyncSession = Depends(get_db)):
    return await write_proccess_to_excel(month, db)


@router.get('/set-product-expenses/{product_id}', response_model=ProductExpensesSchema)
async def set_product_expenses(product_id: int, marketing_expenses: int | None = None, salary_expenses: int | None = None, db: AsyncSession = Depends(get_db)):
    product = await get_or_404(Products, product_id, db)
    await product.update(marketing_expenses=marketing_expenses, salary_expenses=salary_expenses, db=db)
    return product


@router.get('/get-products', response_model=List[ProductExpensesSchema])
async def get_medcine(db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(Products).options(selectinload(Products.man_company), selectinload(Products.category)))
    return result.scalars().all()
