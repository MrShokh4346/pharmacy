from datetime import datetime, timedelta, timezone, date
from fastapi import Depends, FastAPI, HTTPException, status
from jose import JWTError, jwt
from .doctor_schemas import *
from .pharmacy_schemas import PharmacyListSchema
from fastapi import APIRouter
from sqlalchemy.ext.asyncio import AsyncSession
from models.doctors import *
from models.users import Users, DoctorPlan, Notification, DoctorVisitInfo
from models.database import get_db, get_or_404
from models.dependencies import *
from fastapi.security import HTTPAuthorizationCredentials
from typing import List, Annotated
from deputy_director.schemas import DoctorVisitPlanOutSchema
from deputy_director.schemas import NotificationOutSchema, NotificationListSchema
from sqlalchemy import text
from sqlalchemy.future import select
from sqlalchemy.orm import selectinload
from sqlalchemy import cast, Date


router = APIRouter()


@router.get('/get-doctor-notifications/{doctor_id}', response_model=List[NotificationListSchema])
async def get_doctor_notifications(doctor_id: int, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(Notification).options(selectinload(Notification.doctor), selectinload(Notification.pharmacy), selectinload(Notification.wholesale)).filter(Notification.doctor_id==doctor_id))
    return result.scalars().all()


@router.get('/get-doctors', response_model=List[DoctorListSchema])
async def get_all_doctors(db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(Doctor).options(selectinload(Doctor.speciality)))
    return result.scalars().all()


@router.get('/get-doctors-by-med-rep/{med_rep_id}', response_model=List[DoctorListSchema])
async def get_all_doctors_by_med_rep(med_rep_id: int, db: AsyncSession = Depends(get_db)):
    med_rep = await get_user(med_rep_id, db)
    result = await db.execute(select(Doctor).options(selectinload(Doctor.speciality)).filter(Doctor.med_rep_id==med_rep.id))
    return result.scalars().all()


@router.get('/filter-doctors', response_model=List[DoctorListSchema])
async def filter_doctors(
    category_id: Optional[int] = None, 
    speciality_id: Optional[int] = None, 
    region_id: Optional[int] = None, 
    product_id: Optional[int] = None,
    db: AsyncSession = Depends(get_db)
):
    query = select(Doctor).options(selectinload(Doctor.speciality), selectinload(Doctor.medical_organization), selectinload(Doctor.category))
    if category_id:
        query = query.filter(Doctor.category_id == category_id)
    if speciality_id:
        query = query.filter(Doctor.speciality_id == speciality_id)
    if region_id:
        query = query.filter(Doctor.region_id == region_id)
    if product_id:
        query = query.filter(Doctor.doctorattachedproduct.any(DoctorAttachedProduct.product_id == product_id))
    result = await db.execute(query)
    return result.scalars().all()


@router.get('/get-doctor/{id}', response_model=DoctorOutSchema)
async def get_doctor_by_id(id: int, db: AsyncSession = Depends(get_db)):
    return await get_or_404(Doctor, id, db)


@router.post('/add-doctor', response_model=DoctorOutSchema)
async def add_doctor(doctor: DoctorInSchema, user_id: int, db: AsyncSession = Depends(get_db)):
    med_rep = await get_user(user_id, db)
    new_doctor = Doctor(**doctor.dict(), region_manager_id=med_rep.region_manager_id, ffm_id=med_rep.ffm_id, product_manager_id=med_rep.product_manager_id, deputy_director_id=med_rep.deputy_director_id, director_id=med_rep.director_id)
    await new_doctor.save(db=db)
    return new_doctor


@router.post('/attach-products')
async def attach_products_to_doctor(objects: AttachProductsListSchema, db: AsyncSession = Depends(get_db)):
    products = [DoctorAttachedProduct(**obj.dict()) for obj in objects.items]
    db.add_all(products)
    try:
        await db.commit()
    except IntegrityError as e:
        raise HTTPException(status_code=404, detail=str(e.orig).split('DETAIL:  ')[1].replace('.\n', ''))
    return {"msg": "Done"}


@router.get('/doctor-attached-products/{doctor_id}', response_model=List[AttachProductsOutSchema])
async def get_doctor_attached_products(doctor_id: int, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(DoctorAttachedProduct).options(selectinload(DoctorAttachedProduct.product)).filter(DoctorAttachedProduct.doctor_id==doctor_id))
    return result.scalars().all()


@router.patch('/update-doctor/{id}', response_model=DoctorOutSchema)
async def update_doctor(id: int, data: DoctorUpdateSchema, db: AsyncSession = Depends(get_db)):
    doctor = await get_or_404(Doctor, id, db)
    await doctor.update(**data.dict(), db=db)
    return doctor


@router.get('/get-doctor-pharmacies-list/{doctor_id}', response_model=List[PharmacyListSchema])
async def get_doctor_attached_pharmacies_list(doctor_id: int, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(Doctor).options(selectinload(Doctor.pharmacy)).where(Doctor.id == doctor_id))
    doctor = result.scalars().first()
    if not doctor:
        raise HTTPException(status_code=404, detail="Doctor not found")
    return doctor.pharmacy


@router.post('/add-bonus', response_model=List[BonusOutSchema])
async def add_bonus_to_doctor(data: BonusSchema, db: AsyncSession = Depends(get_db)):
    data_dict = data.dict()
    products = data_dict.pop('products')
    bonus = Bonus(**data_dict)
    await bonus.save(db)
    bonus_products = [BonusProduct(**product, bonus_id=bonus.id) for product in products]
    db.add_all(bonus_products)
    await db.commit()
    result = await db.execute(select(Bonus).options(selectinload(Bonus.products)).filter(Bonus.doctor_id == data_dict['doctor_id']).order_by(Bonus.id.desc()))
    return result.scalars().all()


@router.delete('/delete-bonus/{bonus_id}')
async def delete_product_by_id_form_bonus(bonus_id:int, db: AsyncSession = Depends(get_db)):
    bonus = await get_or_404(Bonus, bonus_id, db)
    await db.delete(bonus)
    await db.commit()
    return {"msg":"Deleted"}


@router.get('/get-bonus/{doctor_id}', response_model=List[BonusOutSchema])
async def get_bonus_by_doctor_id(doctor_id: int, filter_bonus: FilterChoice, from_date: str, to_date: str, db: AsyncSession = Depends(get_db)):
    fr_date = datetime.strptime(from_date, '%Y-%m-%d') if from_date else None
    to_date = datetime.strptime(to_date, '%Y-%m-%d') if to_date else None

    query = select(Bonus).options(selectinload(Bonus.products)).filter(Bonus.doctor_id == doctor_id)
    if filter_bonus == 'payed':
        query = query.filter(Bonus.payed == True)
    elif filter_bonus == 'debt':
        query = query.filter(Bonus.payed == False)
    
    if fr_date and to_date:
        query = query.filter(Bonus.date.between(fr_date, to_date))

    result = await db.execute(query.order_by(Bonus.id.desc()))
    return result.scalars().all()


@router.get('/get-doctor-visit-plan', response_model=List[DoctorVisitPlanListSchema])
async def get_doctor_visit_plan(user_id: int, db: AsyncSession = Depends(get_db)):
    user = await get_user(user_id, db)
    result = await db.execute(select(DoctorPlan).options(selectinload(DoctorPlan.doctor)).filter(DoctorPlan.med_rep_id == user.id))
    return result.scalars().all()


@router.get('/filter-doctor-visit-plan-by-date', response_model=List[DoctorVisitPlanListSchema])
async def filter_doctor_visit_plan_by_date(user_id: int, date: date, db: AsyncSession = Depends(get_db)):
    user = await get_user(user_id, db)
    result = await db.execute(select(DoctorPlan).options(selectinload(DoctorPlan.doctor)).filter(DoctorPlan.med_rep_id == user.id, cast(DoctorPlan.date, Date) == date))
    return result.scalars().all()


@router.get('/get-doctor-visit-plan/{plan_id}', response_model=DoctorVisitPlanOutSchema)
async def get_doctor_visit_plan_by_id(plan_id: int, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(DoctorPlan).options(selectinload(DoctorPlan.doctor)).where(DoctorPlan.id == plan_id))
    plan = result.scalars().first()
    if not plan:
        raise HTTPException(status_code=404, detail="Plan not found")
    return plan


@router.post('/reschedule-doctor-visit/{plan_id}', response_model=DoctorVisitPlanOutSchema, description='date format: (%Y-%m-%d %H:%M)')
async def reschedule_doctor_visit_date(plan_id: int, date: RescheduleSchema, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(DoctorPlan).options(selectinload(DoctorPlan.doctor)).where(DoctorPlan.id == plan_id))
    plan = result.scalars().first()
    if not plan:
        raise HTTPException(status_code=404, detail="Plan not found")
    await plan.update(**date.dict(), db=db)
    return plan


@router.post('/doctor-visit-info')
async def doctor_visit_info(plan_id: int, visit: VisitInfoSchema, db: AsyncSession = Depends(get_db)):
    plan = await get_or_404(DoctorPlan, plan_id, db) 
    await plan.update(description=visit.dict().get('description'), status=True, db=db)
    await DoctorVisitInfo.save(**visit.dict(), doctor_id=plan.doctor_id, db=db)
    return {"msg":"Done"}