from datetime import datetime, timedelta, timezone
from fastapi import Depends, FastAPI, HTTPException, status
from jose import JWTError, jwt
from models.hospital import *
from fastapi import APIRouter
from sqlalchemy.orm import Session
from models.database import get_db
from models.dependencies import *
from fastapi.security import HTTPAuthorizationCredentials
from typing import List
from .hospital_schemas import *
from deputy_director.schemas import NotificationOutSchema


router = APIRouter()


@router.post('/create-hospital', response_model=HospitalOutSchema)
async def create_hospital(obj: HospitalSchema, db: AsyncSession = Depends(get_db)):
    user = await get_or_404(Users, obj.med_rep_id, db)
    hospital = Hospital(**obj.dict(), region_id=user.region_id)
    await hospital.save(db)
    return hospital


@router.patch('/update-hospital/{hospital_id}', response_model=HospitalOutSchema)
async def update_pharmacy(hospital_id: int, data: HospitalUpdateSchema, db: AsyncSession = Depends(get_db)):
    hospital = await get_or_404(Hospital, hospital_id, db)
    await hospital.update(**data.dict(), db=db)
    return hospital


@router.get('/get-hospitals', response_model=List[HospitalOutSchema])
async def get_hospitals(med_rep_id: int | None = None, db: AsyncSession = Depends(get_db)):
    query = select(Hospital)
    if med_rep_id:
        query = query.filter(Hospital.med_rep_id==med_rep_id)
    hospitals = await db.execute(query)
    return hospitals.scalars().all()


@router.get('/get-hospital-by-id/{hospital_id}', response_model=HospitalOutSchema)
async def get_hospitals(hospital_id: int, db: AsyncSession = Depends(get_db)):
    hospital = await get_or_404(Hospital, hospital_id, db)
    return hospital


@router.post('/attach-products-to-hospital/{hospital_id}')
async def attach_products_to_hospital(hospital_id: int, user_id: int, objects: AttachProductsListSchema, db: AsyncSession = Depends(get_db)):
    user = await get_or_404(Users, user_id, db)
    hospital_products = []
    year = datetime.now().year
    # month = datetime.now().month
    month = objects.month
    num_days = calendar.monthrange(year, month)[1]
    start_date = datetime(year, month, 1)  
    end_date = datetime(year, month, num_days, 23, 59)
    for obj in objects.items:
        result1 = await db.execute(select(HospitalMonthlyPlan).filter(HospitalMonthlyPlan.product_id==obj.product_id, HospitalMonthlyPlan.hospital_id==hospital_id, HospitalMonthlyPlan.date>=start_date, HospitalMonthlyPlan.date<=end_date))
        hospital_plan = result1.scalar()
        if hospital_plan is not None:
            raise HTTPException(status_code=404, detail='This product already attached to hospital plan for this month')
        product = await get_or_404(Products, obj.product_id, db)
        hospital_products.append(HospitalMonthlyPlan(**obj.dict(), date=start_date, hospital_id=hospital_id, price=product.price, discount_price=product.discount_price))
        result = await db.execute(select(UserProductPlan).filter(UserProductPlan.product_id==obj.product_id, UserProductPlan.plan_month>=start_date, UserProductPlan.plan_month<=end_date, UserProductPlan.med_rep_id==user_id))
        user_product = result.scalars().first()
        if user_product is None:
            raise HTTPException(status_code=404, detail='You are trying to add product that is not exists in user plan in this month')
        if user_product.current_amount < obj.monthly_plan:
            raise HTTPException(status_code=404, detail='You are trying to add more doctor plan than user plan for this product')
        user_product.current_amount -= obj.monthly_plan
    db.add_all(hospital_products)
    try:
        await db.commit()
    except IntegrityError as e:
        raise HTTPException(status_code=404, detail=str(e.orig).split('DETAIL:  ')[1].replace('.\n', ''))
    return {"msg": "Done"}


@router.put('/update-hospital-product-plan/{plan_id}', response_model=HospitalProductPlanOutSchema)
async def update_doctor_product_plan(plan_id: int, amount: int, db: AsyncSession = Depends(get_db)):
    plan = await get_or_404(HospitalMonthlyPlan, plan_id, db)
    await plan.update(amount, db)
    return plan 


@router.get('/hospital-attached-products/{hospital_id}', response_model=List[HospitalAttachedProducts])
async def get_hospital_attached_products(hospital_id: int, month: int | None = None, db: AsyncSession = Depends(get_db)):
    doctor = await get_or_404(Hospital, hospital_id, db)
    year = datetime.now().year
    month = datetime.now().month if month is None else month 
    num_days = calendar.monthrange(year, month)[1]
    start_date = datetime(year, month, 1)  
    end_date = datetime(year, month, num_days, 23, 59)
    result = await db.execute(select(HospitalMonthlyPlan).options(selectinload(HospitalMonthlyPlan.product)).filter(HospitalMonthlyPlan.hospital_id==hospital_id, HospitalMonthlyPlan.date>=start_date, HospitalMonthlyPlan.date<=end_date))
    data = []
    for plan in result.scalars().all():
        result1 = await db.execute(select(HospitalFact).filter(HospitalFact.hospital_id==hospital_id, HospitalFact.product_id==plan.product_id, HospitalFact.date>=start_date, HospitalFact.date<=end_date))
        fact = result1.scalars().first()
        data.append({
            **plan.__dict__, 
            "fact": fact.fact if fact else 0
        })
    return data


@router.post('/hospital-reservation/{hospital_id}')
async def hospital_reservation(hospital_id: int, res: HospitalReservationSchema, db: AsyncSession = Depends(get_db)):
    hospital = await get_or_404(Hospital, hospital_id, db)
    reservation = await HospitalReservation.save(**res.dict(), db=db, hospital_id=hospital_id)
    return {"msg":"Done"}


@router.get('/get-hospital-reservation-history/{reservation_id}', response_model=List[ReservationHistorySchema])
async def get_hospital_reservation_history(reservation_id: int, db: AsyncSession = Depends(get_db)):
    history = await db.execute(select(HospitalReservationPayedAmounts).filter(HospitalReservationPayedAmounts.reservation_id==reservation_id))
    return history.scalars().all()


@router.post('/check-hospital-reservation/{hospital_reservation_id}')
async def check_hospital_reservation(hospital_reservation_id: int, obj: CheckSchema, db: AsyncSession = Depends(get_db)):
    reservation = await get_or_404(HospitalReservation, hospital_reservation_id, db)
    await reservation.check_reservation(**obj.dict(), db=db)
    return {"msg":"Done"}


@router.post('/check-if-payed-hospital-reservation/{hospital_reservation_id}')
async def check_if_payed_hospital_reservation(hospital_reservation_id: int, obj: CheckPayedSchema, db: AsyncSession = Depends(get_db)):
    reservation = await get_or_404(HospitalReservation, hospital_reservation_id, db)
    await reservation.check_if_payed_reservation(**obj.dict(), db=db)
    return {"msg":"Done"}


# @router.delete('/delete-hospital-reservation/{reservation_id}')
# async def delete_hospital_reservation(reservation_id: int, db: AsyncSession = Depends(get_db)):
#     reservation = await get_or_404(HospitalReservation, reservation_id, db)
#     await reservation.delete(db=db)
#     return {"msg":"Done"}


@router.post('/update-reservation-expire-date/{reservation_id}')
async def get_reservation_products(reservation_id: int, obj: ExpireDateSchema, db: AsyncSession = Depends(get_db)):
    reservation = await get_or_404(HospitalReservation, reservation_id, db)
    await reservation.update_expire_date(date = obj.date, db=db)
    return {"msg":"Done"}


@router.post('/set-discount-to-hospital-reservation/{reservation_id}')
async def set_discount_to_pharmacy(reservation_id: int, discount: float,  db: AsyncSession = Depends(get_db)):
    reservation = await get_or_404(HospitalReservation, reservation_id, db)
    await reservation.update_discount(discount, db)
    return {"msg":"Done"}


@router.get('/get-hospital-reservation/{reservation_id}', response_model=HospitalReservationOutSchema)
async def get_hospital_reservation(reservation_id: int, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(HospitalReservation).filter(HospitalReservation.id==reservation_id))
    res = result.scalar()
    if res is None:
        raise HTTPException(status_code=404, detail="Reservation no found")
    return res


@router.post('/paying-hospital-bonus/{bonus_id}', response_model=BonusOutSchema)
async def paying_bonus(bonus_id: int, amount: int, db: AsyncSession = Depends(get_db)):
    bonus = await get_or_404(HospitalBonus, bonus_id, db)
    await bonus.paying_bonus(amount, db)    
    return bonus


@router.get('/get-hospital-bonus/{hospital_id}', response_model=List[BonusOutSchema])
async def get_bonus_by_doctor_id(hospital_id: int, month: int, db: AsyncSession = Depends(get_db)):
    year = datetime.now().year
    month = datetime.now().month if month is None else month 
    num_days = calendar.monthrange(year, month)[1]
    start_date = datetime(year, month, 1)  
    end_date = datetime(year, month, num_days, 23, 59)
    result = await db.execute(select(HospitalBonus).options(selectinload(HospitalBonus.product)).filter(HospitalBonus.hospital_id == hospital_id, HospitalBonus.date >= start_date, HospitalBonus.date <= end_date))
    return result.scalars().all()



