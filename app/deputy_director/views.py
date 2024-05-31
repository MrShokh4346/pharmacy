from datetime import datetime, timedelta, timezone
from fastapi import Depends, FastAPI, HTTPException, status
from jose import JWTError, jwt
from .schemas import *
from fastapi import APIRouter
from sqlalchemy.orm import Session
from models.users import *
from models.database import get_db
from models.dependencies import *
from typing import Any
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from sqlalchemy.future import select
from sqlalchemy.orm import selectinload
from sqlalchemy.ext.asyncio import AsyncSession


router = FastAPI()


@router.post('/register-for-dd', response_model=UserOutSchema, description='using RegisterForDDSchema')
async def register_user_for_pm(user: RegisterForDDSchema, manager: Annotated[Users, Depends(get_current_user)], token: HTTPAuthorizationCredentials = Depends(auth_header), db: Session = Depends(get_db)) -> Any:
    if manager.status == 'deputy_director':
        check_if_user_already_exists(username=user.username, db = db)
        if user.status == 'medical_representative':
            if not (user.region_manager_id and user.ffm_id and user.product_manager_id):
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="region_manager_id, ffm_id, product_manager_id should be declared"
                )
            new_user = Users(**user.dict(), deputy_director_id=manager.id, director_id=manager.director_id)
            new_user.save(db=db)
        elif user.status == 'regional_manager':
            if not (user.ffm_id and user.product_manager_id):
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="ffm_id, product_manager_id should be declared"
                )
            new_user = Users(**user.dict(), deputy_director_id=manager.id, director_id=manager.director_id)
            new_user.save(db=db)
        elif user.status == 'ff_manager':
            if not user.product_manager_id:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="product_manager_id should be declared"
                )
            new_user = Users(**user.dict(), deputy_director_id=manager.id, director_id=manager.director_id)
            new_user.save(db=db)
        else:
            new_user = Users(**user.dict(), deputy_director_id=manager.id, director_id=manager.director_id)
            new_user.save(db=db)
        return new_user
    raise HTTPException(status_code=403, detail="You are not a deputy director")


@router.post('/add-doctor-plan/{med_rep_id}', response_model=List[DoctorVisitPlanOutSchema])
async def add_doctor_visit_plan_to_mr(med_rep_id:int, plan: DoctorVisitPlanSchema,  db: Session = Depends(get_db)):
    visit = DoctorPlan(**plan.dict(), med_rep_id=med_rep_id)
    visit.save(db)
    visits = db.query(DoctorPlan).filter(DoctorPlan.med_rep_id==med_rep_id).order_by(DoctorPlan.id.desc()).all()
    return visits


@router.delete('/delete-doctor-plan/{plan_id}')
async def delete_doctor_visit_plan(plan_id:int, db: Session = Depends(get_db)):
    visit = db.query(DoctorPlan).get(plan_id)
    db.delete(visit)
    db.commit()
    return {"msg":"Deleted"}


@router.post('/add-pharmacy-plan/{med_rep_id}', response_model=List[PharmacyVisitPlanOutSchema])
async def add_pharmacy_visit_plan_to_mr(med_rep_id:int, plan: PharmacyVisitPlanSchema,  db: Session = Depends(get_db)):
    visit = PharmacyPlan(**plan.dict(), med_rep_id=med_rep_id)
    visit.save(db)
    visits = db.query(PharmacyPlan).filter(PharmacyPlan.med_rep_id==med_rep_id).order_by(PharmacyPlan.id.desc()).all()
    return visits


@router.delete('/delete-pharmacy-plan/{plan_id}')
async def delete_pharmacy_visit_plan(plan_id:int, db: Session = Depends(get_db)):
    visit = db.query(PharmacyPlan).get(plan_id)
    db.delete(visit)
    db.commit()
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

