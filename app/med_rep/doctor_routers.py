from datetime import datetime, timedelta, timezone, date
from sqlite3 import IntegrityError
from app.deputy_director.utils import check_if_plan_is_editable
from app.models.dependencies import get_doctor_or_404, get_user
from app.models.doctors import Bonus, BonusPayedAmounts, Distance, Doctor, DoctorFact, DoctorMonthlyPlan, DoctorPostupleniyaFact
from app.services.bonusService import BonusService
from app.services.doctorMonthlyPlanService import DoctorMonthlyPlanService
from fastapi import Depends, FastAPI, HTTPException, status
from jose import JWTError, jwt
from .doctor_schemas import *
from .pharmacy_schemas import PharmacyListSchema
from fastapi import APIRouter, Path
from sqlalchemy.ext.asyncio import AsyncSession
from models.users import Product, Users, DoctorPlan, Notification,UserProductPlan
from models.database import get_db, get_or_404
from fastapi.security import HTTPAuthorizationCredentials
from typing import List, Annotated
from deputy_director.schemas import DoctorVisitPlanOutSchema
from deputy_director.schemas import NotificationOutSchema, NotificationListSchema
from sqlalchemy import text
from sqlalchemy.future import select
from sqlalchemy.orm import selectinload
from sqlalchemy import cast, Date
import calendar
from common_depetencies import StartEndDates


router = APIRouter()


@router.get('/get-doctor-notifications/{doctor_id}', response_model=List[NotificationListSchema])
async def get_doctor_notifications(doctor_id: int, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(Notification).options(selectinload(Notification.doctor), selectinload(Notification.pharmacy), selectinload(Notification.wholesale)).filter(Notification.doctor_id==doctor_id))
    return result.scalars().all()


@router.get('/get-doctors', response_model=List[DoctorListSchema])
async def get_all_doctors(db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(Doctor).options(selectinload(Doctor.speciality)).filter(Doctor.deleted==False))
    return result.scalars().all()

#########################################################################################################################################################
@router.get('/get-all-doctors-with-plan', response_model=List[DoctorListWithPlanSchema])
async def get_all_doctors(db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(Doctor).options(selectinload(Doctor.speciality), selectinload(Doctor.doctormonthlyplan), selectinload(Doctor.postupleniya_fact)).filter(Doctor.deleted==False))
    # return result.scalars().all()
    objects = result.scalars().all()
    data = []
    for obj in objects:
        prd_list = []
        for plan in obj.doctormonthlyplan:
            result = await db.execute(select(DoctorPostupleniyaFact).filter(DoctorPostupleniyaFact.doctor_id==obj.id, DoctorPostupleniyaFact.product_id==plan.product_id))
            postupleniya = result.scalars().first()
            prd_list.append({**plan.__dict__, "postupleniya":postupleniya.fact if postupleniya else 0})
        data.append({
            "id": obj.id,
            "full_name": obj.full_name,
            "birth_date": obj.birth_date,
            "contact1": obj.contact1,
            "contact2": obj.contact2,
            "speciality": {**obj.speciality.__dict__},
            "medical_organization": {**obj.medical_organization.__dict__},
            "category": {**obj.category.__dict__},
            "doctormonthlyplan": prd_list
        })
    return data


@router.get('/get-doctors-by-med-rep/{med_rep_id}', response_model=List[DoctorListSchema])
async def get_all_doctors_by_med_rep(med_rep_id: int, db: AsyncSession = Depends(get_db)):
    med_rep = await get_user(med_rep_id, db)
    result = await db.execute(select(Doctor).options(selectinload(Doctor.speciality)).filter(Doctor.med_rep_id==med_rep.id, Doctor.deleted==False))
    return result.scalars().all()


@router.get('/filter-doctors', response_model=List[DoctorListSchema])
async def filter_doctors(
    category_id: Optional[int] = None, 
    speciality_id: Optional[int] = None, 
    region_id: Optional[int] = None, 
    db: AsyncSession = Depends(get_db)
):
    query = select(Doctor).options(selectinload(Doctor.speciality), selectinload(Doctor.medical_organization), selectinload(Doctor.category)).filter(Doctor.deleted==False)
    if category_id:
        query = query.filter(Doctor.category_id == category_id)
    if speciality_id:
        query = query.filter(Doctor.speciality_id == speciality_id)
    if region_id:
        query = query.filter(Doctor.region_id == region_id)
    result = await db.execute(query)
    return result.scalars().all()


@router.get('/get-doctor/{id}', response_model=DoctorOutSchema)
async def get_doctor_by_id(id: int, db: AsyncSession = Depends(get_db)):
    return await get_doctor_or_404(id, db)


@router.post('/add-doctor', response_model=DoctorOutSchema)
async def add_doctor(doctor: DoctorInSchema, user_id: int, db: AsyncSession = Depends(get_db)):
    med_rep = await get_user(user_id, db)
    new_doctor = Doctor(**doctor.dict(),med_rep_id=med_rep.id, region_manager_id=med_rep.region_manager_id, ffm_id=med_rep.ffm_id, product_manager_id=med_rep.product_manager_id, deputy_director_id=med_rep.deputy_director_id, director_id=med_rep.director_id)
    await new_doctor.save(db=db)
    return new_doctor


@router.post('/attach-products')
async def attach_products_to_doctor(user_id: int, objects: AttachProductsListSchema, db: AsyncSession = Depends(get_db)):
    user = await get_or_404(Users, user_id, db)
    doctor_products = []
    doctor = await get_doctor_or_404(objects.items[0].doctor_id, db)
    year = datetime.now().year
    month = objects.month
    # month = datetime.now().month
    num_days = calendar.monthrange(year, month)[1]
    start_date = datetime(year, month, 1)  
    end_date = datetime(year, month, num_days, 23, 59)
    for obj in objects.items:
        result1 = await db.execute(select(DoctorMonthlyPlan).filter(DoctorMonthlyPlan.product_id==obj.product_id, DoctorMonthlyPlan.doctor_id==obj.doctor_id, DoctorMonthlyPlan.date>=start_date, DoctorMonthlyPlan.date<=end_date))
        doctor = result1.scalar()
        if doctor is not None:
            raise HTTPException(status_code=404, detail='This product already attached to doctor for this month')
        product = await get_or_404(Product, obj.product_id, db)
        doctor_products.append(DoctorMonthlyPlan(**obj.dict(), date=start_date, price=product.price, discount_price=product.discount_price))
        result = await db.execute(select(UserProductPlan).filter(UserProductPlan.product_id==obj.product_id, UserProductPlan.plan_month>=start_date, UserProductPlan.plan_month<=end_date, UserProductPlan.med_rep_id==user_id))
        user_product = result.scalars().first()
        if user_product is None:
            raise HTTPException(status_code=404, detail='You are trying to add product that is not exists in user plan in this month')
        if user_product.current_amount < obj.monthly_plan:
            raise HTTPException(status_code=404, detail='You are trying to add more doctor plan than user plan for this product')
        user_product.current_amount -= obj.monthly_plan
        await BonusService.set_bonus(doctor_id=obj.doctor_id, product_id=obj.product_id, compleated=0, db=db)
    db.add_all(doctor_products)
    try:
        await db.commit()
    except IntegrityError as e:
        raise HTTPException(status_code=404, detail=str(e.orig).split('DETAIL:  ')[1].replace('.\n', ''))
    return {"msg": "Done"}

##################################################################################################################################
@router.get('/doctor-attached-products/{doctor_id}')
async def get_doctor_attached_products(doctor_id: int, filter_date: StartEndDates, db: AsyncSession = Depends(get_db)):
    doctor = await get_doctor_or_404(doctor_id, db)
    start_date = filter_date['start_date']
    end_date = filter_date['end_date']
    result = await db.execute(select(DoctorMonthlyPlan).options(selectinload(DoctorMonthlyPlan.product)).filter(DoctorMonthlyPlan.doctor_id==doctor_id, DoctorMonthlyPlan.date>=start_date, DoctorMonthlyPlan.date<=end_date))
    data = []
    for obj in result.scalars().all():
        fact = 0
        result = await db.execute(select(DoctorFact).filter(DoctorFact.doctor_id==doctor_id, DoctorFact.product_id==obj.product.id, DoctorFact.date>=start_date, DoctorFact.date<=end_date))
        for f in result.scalars().all():
            fact += f.fact 
        data.append({
            "id":obj.id,
            "product":{
                    "id": obj.product.id,
                    "name": obj.product.name,
                    "price": obj.product.price,
                    "discount_price": obj.product.discount_price,
                    "man_company": {
                        "id": obj.product.man_company.id,
                        "name": obj.product.man_company.name
                    },
                    "category": {
                        "id": obj.product.category.id,
                        "name": obj.product.category.name
                    }
            },
            "monthly_plan":obj.monthly_plan,
            "fact":fact
        })
    return data


@router.put('/update-doctor-product-plan/{plan_id}', response_model=DoctorProductPlanOutSchema)
async def update_doctor_product_plan(plan_id: int, amount: int, db: AsyncSession = Depends(get_db)):
    plan = await get_or_404(DoctorMonthlyPlan, plan_id, db)
    await check_if_plan_is_editable(plan, db)
    await plan.update(amount, db)
    await DoctorMonthlyPlanService.update(plan=plan, amount=amount, db=db)
    return plan 


@router.post('/move-doctor-plan/{plan_id}')
async def move_doctor_plan(plan_id: int, remainder_amount: int, doctors: DoctorPlanMoveShema, db: AsyncSession = Depends(get_db)):
    plan = await get_or_404(DoctorMonthlyPlan, plan_id, db)
    await DoctorMonthlyPlanService.move_plan(**doctors.dict(), remainder_amount=remainder_amount, plan=plan, db=db)
    return {'msg': 'Success'} 


@router.patch('/update-doctor/{id}', response_model=DoctorOutSchema)
async def update_doctor(id: int, data: DoctorUpdateSchema, db: AsyncSession = Depends(get_db)):
    doctor = await get_doctor_or_404(id, db)
    await doctor.update(**data.dict(), db=db)
    return doctor


@router.delete('/delete-doctor/{doctor_id}')
async def delete_doctor(doctor_id: int, db: AsyncSession = Depends(get_db)):
    doctor = await get_doctor_or_404(doctor_id, db)
    await doctor.delete(db)
    return {"msg":"Done"}


@router.get('/get-doctor-pharmacies-list/{doctor_id}', response_model=List[PharmacyListSchema])
async def get_doctor_attached_pharmacies_list(doctor_id: int, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(Doctor).options(selectinload(Doctor.pharmacy)).where(Doctor.id == doctor_id, Doctor.deleted==False))
    doctor = result.scalars().first()
    if not doctor:
        raise HTTPException(status_code=404, detail="Doctor not found")
    return doctor.pharmacy


@router.post('/paying-bonus/{bonus_id}', response_model=BonusOutSchema)
async def paying_bonus(bonus_id: int, amount: int, description: str | None = None, db: AsyncSession = Depends(get_db)):
    if amount < 0:
        raise HTTPException(status_code=400, detail="Amount should be greater  then 0")
    bonus = await get_or_404(Bonus, bonus_id, db)
    await bonus.paying_bonus(amount, description, db)    
    return bonus


@router.delete('/delete-bonus/{bonus_id}')
async def delete_product_by_id_form_bonus(bonus_id:int, db: AsyncSession = Depends(get_db)):
    bonus = await get_or_404(Bonus, bonus_id, db)
    query = f"delete from bonus WHERE id={bonus.id}"  
    result = await db.execute(text(query))
    # await db.delete(bonus)
    # await db.commit()
    return {"msg":"Deleted"}


@router.get('/get-bonus/{doctor_id}', response_model=List[BonusOutSchema])
async def get_bonus_by_doctor_id(doctor_id: int, filter_date: StartEndDates, db: AsyncSession = Depends(get_db)):
    start_date = filter_date['start_date']
    end_date = filter_date['end_date']
    doctor = await get_doctor_or_404(doctor_id, db)
    result = await db.execute(select(Bonus).options(selectinload(Bonus.product)).filter(Bonus.doctor_id == doctor_id, Bonus.date >= start_date, Bonus.date <= end_date))
    return result.scalars().all()


@router.get('/get-bonus-history/{bonus_id}', response_model=List[BonusHistory])
async def get_bonus_history(bonus_id: int, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(BonusPayedAmounts).filter(BonusPayedAmounts.bonus_id==bonus_id))
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


@router.get('/filter-doctor-visit-plan-by-date-interval', response_model=List[DoctorVisitPlanListSchema])
async def filter_doctor_visit_plan_by_date(user_id: int, filter_date: StartEndDates, db: AsyncSession = Depends(get_db)):
    start_date = filter_date['start_date']
    end_date = filter_date['end_date']
    user = await get_user(user_id, db)
    result = await db.execute(select(DoctorPlan).options(selectinload(DoctorPlan.doctor)).filter(DoctorPlan.med_rep_id == user.id, cast(DoctorPlan.date, Date) >= start_date, cast(DoctorPlan.date, Date) <= end_date))
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
    result = await db.execute(select(Distance))
    distance = result.scalars().first()
    if distance.distance < visit.distance:
        raise HTTPException(status_code=400, detail="You are far from doctor")
    await plan.update(description=visit.dict().get('description'), status=True, db=db)
    # await DoctorVisitInfo.save(**visit.dict(), doctor_id=plan.doctor_id, db=db)
    return {"msg":"Done"}


@router.post('/set-distance')
async def set_distance(distance: int, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(Distance))
    dst = result.scalars().first()
    if dst is None:
        dst = Distance(distance=distance)
        db.add(dst)
    else:
        dst.distance = distance
    await db.commit()
    return {"msg":"Done"}
