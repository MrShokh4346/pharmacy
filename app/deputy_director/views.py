from datetime import datetime, timedelta, timezone
from fastapi import Depends, FastAPI, HTTPException, status
from jose import JWTError, jwt
from .schemas import *
from fastapi import APIRouter
from models.users import *
from models.doctors import DoctorAttachedProduct, Doctor
from models.database import get_db
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
    plan = UserProductPlan(**plan.dict(), current_amount=plan.amount)
    await plan.save(db)
    return plan 


@router.get('/get-user-products-plan/{med_rep_id}', response_model=List[UserProductPlanOutSchema])
async def add_user_products_plan(med_rep_id: int, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(UserProductPlan).filter(UserProductPlan.med_rep_id==med_rep_id))
    return result.scalars().all() 


@router.get('/get-med-rep-product-plan-by-month-id/{med_rep_id}')
async def add_user_product_plan_by_plan_id(med_rep_id: int, month_number: int, db: AsyncSession = Depends(get_db)):
    year = datetime.now().year
    num_days = calendar.monthrange(year, month_number)[1]
    start_date = date(year, month_number, 1)
    end_date = date(year, month_number, num_days)

    result1 = await db.execute(select(UserProductPlan).filter(UserProductPlan.date >= start_date, UserProductPlan.date <= end_date, UserProductPlan.med_rep_id==med_rep_id))
    user_plans = result1.scalars().all()
    user_plan_data = []
    for user_plan in user_plans:
        # result = await db.execute(
        #             select(DoctorAttachedProduct).options(selectinload(DoctorAttachedProduct.doctor)).\
        #                 join(Doctor, DoctorAttachedProduct.doctor_id == Doctor.id).\
        #                 filter(
        #                     DoctorAttachedProduct.product_id==user_plan.product_id,
        #                     Doctor.med_rep_id == user_plan.med_rep_id
        #                 )
        #             )

        query = select(DoctorAttachedProduct).join(Doctor).options(
                            joinedload(DoctorAttachedProduct.doctor)
                        ).where(Doctor.med_rep_id == user_plan.med_rep_id).where(DoctorAttachedProduct.product_id == user_plan.product_id)
        result = await db.execute(query)
        doctor_att = []
        doctor_plans = result.scalars().all() 
        for doctor_plan in doctor_plans:
            doctor_att.append({
                'monthly_plan' : doctor_plan.monthly_plan,
                'fact' : doctor_plan.fact,
                'doctor_name' : doctor_plan.doctor.full_name
            })

        user_plan_data.append({
            "id": user_plan.id,
            "product": user_plan.product.name,
            "amount": user_plan.amount,
            "date": user_plan.date,
            "doctor_plans": doctor_att,
            "vakant": user_plan.current_amount
        })
    return user_plan_data


@router.get('/get-proccess-report', response_model=List[ReportSchema])
async def get_proccess_report(db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(Doctor).options(selectinload(Doctor.doctor_attached_products)).filter(Doctor.deleted==False))
    return result.scalars().all()