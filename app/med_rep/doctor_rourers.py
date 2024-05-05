from datetime import datetime, timedelta, timezone
from fastapi import Depends, FastAPI, HTTPException, status
from jose import JWTError, jwt
from .doctor_schemas import *
from fastapi import APIRouter
from sqlalchemy.orm import Session
from models.doctors import *
from models.users import Users, DoctorPlan
from models.database import get_db
from models.dependencies import *
from fastapi.security import HTTPAuthorizationCredentials
from typing import List, Annotated
from deputy_director.schemas import DoctorVisitPlanOutSchema


router = APIRouter()


@router.get('/get-doctors', response_model=List[DoctorListSchema])
async def get_all_doctors(db: Session = Depends(get_db)):
    doctors = db.query(Doctor).all()
    return doctors


@router.get('/get-doctor/{id}', response_model=DoctorOutSchema)
async def get_doctor_by_id(id:int, db: Session = Depends(get_db)):
    doctor = db.query(Doctor).get(id)
    return doctor


@router.post('/add-doctor', response_model=DoctorOutSchema)
async def add_doctor(doctor: DoctorInSchema, med_rep: Annotated[Users, Depends(get_current_user)], token: HTTPAuthorizationCredentials = Depends(auth_header), db: Session = Depends(get_db)):
    check_if_med_rep(med_rep)
    new_doctor = Doctor(**doctor.dict(), region_manager_id=med_rep.region_manager_id, ffm_id=med_rep.ffm_id, product_manager_id=med_rep.product_manager_id, deputy_director_id=med_rep.deputy_director_id, director_id=med_rep.director_id)
    new_doctor.save(db=db)
    return new_doctor


@router.post('/attach-products')
async def attach_products_to_doctor(objects: AttachProductsListSchema, db: Session = Depends(get_db)):
    for obj in objects.items:
        product = DoctorAttachedProduct(**obj.dict())
        db.add(product)
    db.commit()
    return {"msg":"Done"}   


@router.patch('/update-doctor/{id}', response_model=DoctorOutSchema)
async def update_doctor(id: int, data: DoctorUpdateSchema, db: Session = Depends(get_db)):
    doctor = db.query(Doctor).get(id)
    doctor.update(**data.dict(), db=db)
    return doctor
   

@router.post('/add-bonus', response_model=List[BonusOutSchema])
async def add_bonus_to_doctor(data: BonusSchema, db: Session = Depends(get_db)):
    data = data.dict()
    products = data.pop('products')
    bonus = Bonus(**data)
    bonus.save(db)
    for product in products:
        attached_product = BonusProduct(**product, bonus_id=bonus.id)
        db.add(attached_product)
    db.commit()
    bonuses = db.query(Bonus).filter(Bonus.doctor_id==data['doctor_id']).order_by(Bonus.id.desc()).all()
    return bonuses


@router.delete('/delete-bonus/{bonus_id}')
async def delete_product_by_id_form_bonus(bonus_id:int, db: Session = Depends(get_db)):
    bonus = db.query(Bonus).get(bonus_id)
    db.delete(bonus)
    db.commit()
    return {"msg":"Deleted"}


@router.get('/get-bonus/{id}', response_model=List[BonusOutSchema])
async def get_bonus_by_doctor_id(id: int, filter_bonus: FilterChoice, from_date: str, to_date: str, db: Session = Depends(get_db)):
    fr_date, to_date = datetime.strptime(from_date, '%Y-%m-%d'), datetime.strptime(to_date, '%Y-%m-%d')
    if filter_bonus == 'payed': 
        bonuses = db.query(Bonus).filter(Bonus.doctor_id==id, Bonus.payed==True, Bonus.date.between(fr_date, to_date)).order_by(Bonus.id.desc()).all() if (fr_date and to_date) else db.query(Bonus).filter(Bonus.doctor_id==id, Bonus.payed==True).order_by(Bonus.id.desc()).all()
        return bonuses
    elif filter_bonus == 'debt': 
        bonuses = db.query(Bonus).filter(Bonus.doctor_id==id, Bonus.payed==False, Bonus.date.between(fr_date, to_date)).order_by(Bonus.id.desc()).all() if (fr_date and to_date) else db.query(Bonus).filter(Bonus.doctor_id==id, Bonus.payed==False).order_by(Bonus.id.desc()).all()
        return bonuses
    else:
        bonuses = db.query(Bonus).filter(Bonus.doctor_id==id, Bonus.date.between(fr_date, to_date)).order_by(Bonus.id.desc()).all() if (fr_date and to_date) else db.query(Bonus).filter(Bonus.doctor_id==id).order_by(Bonus.id.desc()).all()
        return bonuses


@router.get('/get-doctor-visit-plan', response_model=List[DoctorVisitPlanOutSchema])
async def get_doctor_visit_plan(user: Annotated[Users, Depends(get_current_user)], token: HTTPAuthorizationCredentials = Depends(auth_header), db: Session = Depends(get_db)):
    check_if_med_rep(user)
    plans = db.query(DoctorPlan).filter(DoctorPlan.med_rep_id==user.id).all()
    return plans 


@router.get('/get-doctor-visit-plan/{plan_id}', response_model=DoctorVisitPlanOutSchema)
async def get_doctor_visit_plan_by_id(plan_id: int, user: Annotated[Users, Depends(get_current_user)], token: HTTPAuthorizationCredentials = Depends(auth_header), db: Session = Depends(get_db)):
    plan = db.query(DoctorPlan).get(plan_id)
    return plan 


@router.post('/reschedule-doctor-visit/{plan_id}', response_model=DoctorVisitPlanOutSchema)
async def reschedule_doctor_visit_date(plan_id: int, date: RescheduleSchema, token: HTTPAuthorizationCredentials = Depends(auth_header), db: Session = Depends(get_db)):
    plan = db.query(DoctorPlan).get(plan_id)
    plan.update(**date.dict(), db=db)
    return plan


@router.post('/doctor-visit-info/{visit_id}')
async def doctor_visit_info(visit_id: int, visit: VisitInfoSchema, db: Session = Depends(get_db)):
    plan = db.query(DoctorPlan).get(visit_id)
    plan.attach(**visit.dict(), db=db)
    return {"msg":"Done"}