from datetime import datetime, timedelta, timezone
from fastapi import Depends, FastAPI, HTTPException, status
from jose import JWTError, jwt
from .schemas import *
from fastapi import APIRouter
from sqlalchemy.orm import Session
from models.database import get_db, get_or_404
from models.pharmacy import Pharmacy
from models.hospital import HospitalReservation
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

#######
@router.get('/get-all-reservations')
async def get_reservation(db: AsyncSession = Depends(get_db)):
    data = []
    result = await db.execute(select(Reservation).options(selectinload(Reservation.products)))
    # data.extend(result.scalars().all())
    for rs in result.scalars().all():
        data.append({
            "id":rs.id,
            "date":rs.date,
            "expire_date":rs.expire_date,
            "invoice_number": rs.invoice_number,
            "profit": rs.profit,
            "debt": rs.debt,
            "profit": rs.profit,
            "pharmacy":{
                "id":rs.pharmacy.id ,
                "company_name":rs.pharmacy.company_name,
                "manufactured_company": "Zuma",
                "inter_branch_turnover":rs.pharmacy.inter_branch_turnover,
                "promo":1000,
                "med_rep":{"full_name":rs.pharmacy.med_rep.full_name},
                "region":{"name":rs.pharmacy.region.name }
                },
            "discount":rs.discount,
            "total_payable_with_nds":rs.total_payable_with_nds,
            "checked":rs.checked
            })
    result = await db.execute(select(HospitalReservation).options(selectinload(HospitalReservation.products)))
    # data.extend(result.scalars().all())
    for rs in result.scalars().all():
        data.append({
            "id":rs.id,
            "date":rs.date,
            "expire_date":rs.expire_date,
            "invoice_number": rs.invoice_number,
            "profit": rs.profit,
            "debt": rs.debt,
            "profit": rs.profit,
            "hospital":{
                "id":rs.hospital.id ,
                "company_name":rs.hospital.company_name,
                "manufactured_company": "Zuma",
                "promo":1000,
                "inter_branch_turnover":rs.hospital.inter_branch_turnover,
                "med_rep":{"full_name":rs.hospital.med_rep.full_name},
                # "region":rs.hospital.region.name 
                },
            "discount":rs.discount,
            "total_payable_with_nds":rs.total_payable_with_nds,
            "checked":rs.checked
        })
    return data

    # {
    # "id":16,
    # "date":"2024-07-16T00:00:00",
    # "expire_date":"2024-07-26T11:46:03.586305",
    # "pharmacy":{
    #     "id":18,
    #     "company_name":"Мед Темур Фарм МЧЖ",
    #     "med_rep":{"id":60,"full_name":"Xalimova Anvara"},
    #     "region":{"id":6,"name":"Кашкадарьинская область"}
    #     },
    # "discount":5.0,
    # "total_payable_with_nds":4979520.0,
    # "checked":true
    # }


@router.post('/check-reservation/{reservation_id}')
async def get_reservation_products(reservation_id: int, obj: CheckSchema, db: AsyncSession = Depends(get_db)):
    reservation = await get_or_404(Reservation, reservation_id, db)
    await reservation.check_reservation(**obj.dict(), db=db)
    return {"msg":"Done"}


@router.post('/check-hospital-reservation/{reservation_id}')
async def get_hospital_reservation_products(reservation_id: int, obj: CheckSchema, db: AsyncSession = Depends(get_db)):
    reservation = await get_or_404(HospitalReservation, reservation_id, db)
    await reservation.check_reservation(**obj.dict(), db=db)
    return {"msg":"Done"}



@router.delete('/delete-reservation/{reservation_id}')
async def delete_reservation(reservation_id: int, db: AsyncSession = Depends(get_db)):
    reservation = await get_or_404(Reservation, reservation_id, db)
    await reservation.delete(db=db)
    return {"msg":"Done"}


@router.delete('/delete-hospital-reservation/{reservation_id}')
async def delete_reservation(reservation_id: int, db: AsyncSession = Depends(get_db)):
    reservation = await get_or_404(HospitalReservation, reservation_id, db)
    await reservation.delete(db=db)
    return {"msg":"Done"}


@router.post('/update-reservation-expire-date/{reservation_id}')
async def get_reservation_products(reservation_id: int, obj: ExpireDateSchema, db: AsyncSession = Depends(get_db)):
    reservation = await get_or_404(Reservation, reservation_id, db)
    await reservation.update_expire_date(date = obj.date, db=db)
    return {"msg":"Done"}


@router.post('/update-hospital-reservation-expire-date/{reservation_id}')
async def get_reservation_products(reservation_id: int, obj: ExpireDateSchema, db: AsyncSession = Depends(get_db)):
    reservation = await get_or_404(HospitalReservation, reservation_id, db)
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


@router.post('/update-hospital-reservation-discount/{reservation_id}')
async def get_hospital_reservation_products(reservation_id: int, discount: int, db: AsyncSession = Depends(get_db)):
    reservation = await get_or_404(HospitalReservation, reservation_id, db)
    await reservation.update_discount(discount = discount, db=db)
    return {"msg":"Done"}
