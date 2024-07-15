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
    hospital = Hospital(**obj.dict())
    await hospital.save(db)
    return hospital


@router.get('/get-hospitals', response_model=List[HospitalOutSchema])
async def get_hospitals(db: AsyncSession = Depends(get_db)):
    hospitals = await db.execute(select(Hospital))
    return hospitals.scalars().all()


@router.post('/hospital-reservation/{hospital_id}', response_model=ReservationOutSchema)
async def hospital_reservation(hospital_id: int, res: HospitalReservationSchema, db: AsyncSession = Depends(get_db)):
    hospital = await get_or_404(Hospital, hospital_id, db)
    reservation = await HospitalReservation.save(**res.dict(), db=db, hospital_id=hospital_id)
    return reservation


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


