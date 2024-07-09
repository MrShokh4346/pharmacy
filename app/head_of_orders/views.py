from datetime import datetime, timedelta, timezone
from fastapi import Depends, FastAPI, HTTPException, status
from jose import JWTError, jwt
from .schemas import *
from fastapi import APIRouter
from sqlalchemy.orm import Session
from models.database import get_db, get_or_404
from models.pharmacy import Pharmacy
from models.warehouse import ReportFactoryWerehouse, CurrentFactoryWarehouse, Wholesale
from models.dependencies import *
from typing import Any, List
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from sqlalchemy.orm import selectinload
from sqlalchemy import update


router = FastAPI()


@router.post('/add-factory-warehouse')
async def add_to_factory_warehouse(obj: FactoryWarehouseInSchema, db: AsyncSession = Depends(get_db)):
    report = await ReportFactoryWerehouse.save(**obj.dict(), db=db)
    return {"msg":'Done'}


@router.get('/get-current-factory-warehouse/{factory_id}', response_model=List[FactoryWarehouseOutSchema])
async def get_current_factory_warehouse(factory_id: int, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(CurrentFactoryWarehouse).filter(CurrentFactoryWarehouse.factory_id==factory_id))
    return result.scalars().all()


@router.get('/get-all-current-factory-warehouse', response_model=List[FactoryWarehouseOutSchema])
async def get_current_factory_warehouse(db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(CurrentFactoryWarehouse))
    return result.scalars().all()


@router.get('/get-factory-warehouse/{id}', response_model=FactoryWarehouseIncomeOutSchema)
async def get_factory_warehouse(id: int, db: AsyncSession = Depends(get_db)):
    return await get_or_404(ReportFactoryWerehouse, id, db) 


@router.get('/get-factory-warehouse-incomes/{factory_id}', response_model=List[FactoryWarehouseIncomeOutSchema])
async def get_factory_warehouse(factory_id: int, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(ReportFactoryWerehouse).filter(ReportFactoryWerehouse.factory_id==factory_id))  
    return result.scalars().all()


@router.get('/get-reservations/{pharmacy_id}', response_model=List[ReservationListSchema])
async def get_reservation(pharmacy_id: int, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(Reservation).options(selectinload(Reservation.products)).filter(Reservation.pharmacy_id==pharmacy_id))
    return result.scalars().all()


@router.get('/get-all-reservations', response_model=List[ReservationListSchema])
async def get_reservation(db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(Reservation).options(selectinload(Reservation.products)))
    return result.scalars().all()


@router.post('/check-reservation/{reservation_id}')
async def get_reservation_products(reservation_id: int, obj: CheckSchema, db: AsyncSession = Depends(get_db)):
    reservation = await get_or_404(Reservation, reservation_id, db)
    await reservation.check_reservation(**obj.dict(), db=db)
    return {"msg":"Done"}


@router.delete('/delete-reservation/{reservation_id}')
async def delete_reservation(reservation_id: int, db: AsyncSession = Depends(get_db)):
    reservation = await get_or_404(Reservation, reservation_id, db)
    await reservation.delete(db=db)
    return {"msg":"Done"}


@router.post('/update-reservation-expire-date/{reservation_id}')
async def get_reservation_products(reservation_id: int, obj: ExpireDateSchema, db: AsyncSession = Depends(get_db)):
    reservation = await get_or_404(Reservation, reservation_id, db)
    await reservation.update_expire_date(date = obj.date, db=db)
    return {"msg":"Done"}


@router.post('/set-discount-to-pharmacy/{pharmacy_id}')
async def set_discount_to_pharmacy(pharmacy_id: int, discount: float,  db: AsyncSession = Depends(get_db)):
    pharmacy = await get_or_404(Pharmacy, pharmacy_id, db)
    await pharmacy.set_discount(discount, db)
    return {"msg":"Done"}


@router.post('/set-discount-to-all-pharmacies')
async def set_discount_to_all_pharmacies(discount: float,  db: AsyncSession = Depends(get_db)):
    await db.execute(update(Pharmacy).values(discount=discount))
    await db.commit()
    return {"msg":"Done"}


@router.post('/update-reservation-discount/{reservation_id}')
async def get_reservation_products(reservation_id: int, discount: int, db: AsyncSession = Depends(get_db)):
    reservation = await get_or_404(Reservation, reservation_id, db)
    await reservation.update_discount(discount = discount, db=db)
    return {"msg":"Done"}
