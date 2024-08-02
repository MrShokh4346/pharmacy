from datetime import datetime, timedelta, timezone
from fastapi import Depends, FastAPI, HTTPException, status
from jose import JWTError, jwt
from .schemas import *
from fastapi import APIRouter
from sqlalchemy.orm import Session
from models.database import get_db, get_or_404
from models.pharmacy import Pharmacy, ReservationPayedAmounts, ReservationProducts
from models.hospital import HospitalReservation
from models.warehouse import ReportFactoryWerehouse, CurrentFactoryWarehouse, Wholesale, WholesaleReservation, WholesaleReservationPayedAmounts, WholesaleReservationProducts
from models.dependencies import *
from typing import Any, List
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from sqlalchemy.orm import selectinload
from sqlalchemy import update, text 


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


@router.get('/get-all-reservations')
async def get_reservation(db: AsyncSession = Depends(get_db)):
    data = []
    result = await db.execute(select(Reservation).options(selectinload(Reservation.products), selectinload(Reservation.manufactured_company)))
    for rs in result.scalars().all():
        promo = 0
        for pr in rs.products:
            promo += pr.product.marketing_expenses * pr.quantity
        data.append({
            "id":rs.id,
            "date":rs.date,
            "expire_date":rs.expire_date,
            "date_implementation": rs.date_implementation,
            "invoice_number": rs.invoice_number,
            "profit": rs.profit,
            "debt": rs.debt,
            "profit": rs.profit,
            "pharmacy":{
                "id":rs.pharmacy.id ,
                "company_name":rs.pharmacy.company_name,
                "manufactured_company": rs.manufactured_company.name,
                "inter_branch_turnover":rs.pharmacy.inter_branch_turnover,
                "promo":promo,
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
        promo = 0
        for pr in rs.products:
            promo += pr.product.marketing_expenses * pr.quantity
        data.append({
            "id":rs.id,
            "date":rs.date,
            "expire_date":rs.expire_date,
            "date_implementation": rs.date_implementation,
            "invoice_number": rs.invoice_number,
            "profit": rs.profit,
            "debt": rs.debt,
            "profit": rs.profit,
            "hospital":{
                "id":rs.hospital.id ,
                "company_name":rs.hospital.company_name,
                "manufactured_company": rs.manufactured_company.name,
                "promo":promo,
                "inter_branch_turnover":rs.hospital.inter_branch_turnover,
                "med_rep":{"full_name":rs.hospital.med_rep.full_name},
                "region":{"name": rs.hospital.region.name} 
                },
            "discount":rs.discount,
            "total_payable_with_nds":rs.total_payable_with_nds,
            "checked":rs.checked
        })
    result = await db.execute(select(WholesaleReservation).options(selectinload(WholesaleReservation.products)))
    for rs in result.scalars().all():
        promo = 0
        for pr in rs.products:
            promo += pr.product.marketing_expenses * pr.quantity
        data.append({
            "id":rs.id,
            "date":rs.date,
            "expire_date":rs.expire_date,
            "date_implementation": rs.date_implementation,
            "invoice_number": rs.invoice_number,
            "profit": rs.profit,
            "debt": rs.debt,
            "profit": rs.profit,
            "wholesale":{
                "id":rs.wholesale.id ,
                "company_name":rs.wholesale.name,
                "promo":promo,
                "region":{"name":rs.wholesale.region.name }
                },
            "discount":rs.discount,
            "total_payable_with_nds":rs.total_payable_with_nds,
            "checked":rs.checked
            })
    return data


@router.post('/check-reservation/{reservation_id}')
async def check_reservation_products(reservation_id: int, obj: CheckSchema, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(Reservation).where(Reservation.id==reservation_id))
    reservation = result.scalars().first()
    if reservation is None:
        raise HTTPException(status_code=400, detail='Reservation not found')
    await reservation.check_reservation(**obj.dict(), db=db)
    return {"msg":"Done"}


@router.post('/check-hospital-reservation/{reservation_id}')
async def check_hospital_reservation_products(reservation_id: int, obj: CheckSchema, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(HospitalReservation).where(HospitalReservation.id==reservation_id))
    reservation = result.scalars().first()
    if reservation is None:
        raise HTTPException(status_code=400, detail='Reservation not found')
    await reservation.check_reservation(**obj.dict(), db=db)
    return {"msg":"Done"}


@router.post('/check-wholesale-reservation/{reservation_id}')
async def check_wholesale_reservation_products(reservation_id: int, obj: CheckSchema, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(WholesaleReservation).where(WholesaleReservation.id==reservation_id))
    reservation = result.scalars().first()
    if reservation is None:
        raise HTTPException(status_code=400, detail='Reservation not found')
    await reservation.check_reservation(**obj.dict(), db=db)
    return {"msg":"Done"}


@router.delete('/delete-reservation/{reservation_id}')
async def delete_reservation(reservation_id: int, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(Reservation).where(Reservation.id==reservation_id))
    reservation = result.scalars().first()
    if reservation is None:
        raise HTTPException(status_code=400, detail='Reservation not found')
    await reservation.delete(db=db)
    return {"msg":"Done"}


@router.delete('/delete-hospital-reservation/{reservation_id}')
async def delete_reservation(reservation_id: int, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(HospitalReservation).where(HospitalReservation.id==reservation_id))
    reservation = result.scalars().first()
    if reservation is None:
        raise HTTPException(status_code=400, detail='Reservation not found')
    await reservation.delete(db=db)
    return {"msg":"Done"}


@router.delete('/delete-wholesale-reservation/{reservation_id}')
async def delete_reservation(reservation_id: int, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(WholesaleReservation).where(WholesaleReservation.id==reservation_id))
    reservation = result.scalars().first()
    if reservation is None:
        raise HTTPException(status_code=400, detail='Reservation not found')
    await reservation.delete(db=db)
    return {"msg":"Done"}


@router.post('/update-reservation-expire-date/{reservation_id}')
async def get_reservation_products(reservation_id: int, obj: ExpireDateSchema, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(Reservation).where(Reservation.id==reservation_id))
    reservation = result.scalars().first()
    if reservation is None:
        raise HTTPException(status_code=400, detail='Reservation not found')
    await reservation.update_date_implementation(date = obj.date, db=db)
    return {"msg":"Done"}


@router.post('/update-hospital-reservation-expire-date/{reservation_id}')
async def get_reservation_products(reservation_id: int, obj: ExpireDateSchema, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(HospitalReservation).where(HospitalReservation.id==reservation_id))
    reservation = result.scalars().first()
    if reservation is None:
        raise HTTPException(status_code=400, detail='Reservation not found')
    await reservation.update_date_implementation(date = obj.date, db=db)
    return {"msg":"Done"}


@router.post('/update-wholesale-reservation-expire-date/{reservation_id}')
async def get_reservation_products(reservation_id: int, obj: ExpireDateSchema, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(WholesaleReservation).where(WholesaleReservation.id==reservation_id))
    reservation = result.scalars().first()
    if reservation is None:
        raise HTTPException(status_code=400, detail='Reservation not found')
    await reservation.update_date_implementation(date = obj.date, db=db)
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
    result = await db.execute(select(Reservation).where(Reservation.id==reservation_id))
    reservation = result.scalars().first()
    if reservation is None:
        raise HTTPException(status_code=400, detail='Reservation not found')
    await reservation.update_discount(discount = discount, db=db)
    return {"msg":"Done"}


@router.post('/update-hospital-reservation-discount/{reservation_id}')
async def get_reservation_products(reservation_id: int, discount: int, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(HospitalReservation).where(HospitalReservation.id==reservation_id))
    reservation = result.scalars().first()
    if reservation is None:
        raise HTTPException(status_code=400, detail='Reservation not found')
    await reservation.update_discount(discount = discount, db=db)
    return {"msg":"Done"}


@router.post('/update-wholesale-reservation-discount/{reservation_id}')
async def get_wholesale_reservation_products(reservation_id: int, discount: int, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(WholesaleReservation).where(WholesaleReservation.id==reservation_id))
    reservation = result.scalars().first()
    await reservation.update_discount(discount = discount, db=db)
    return {"msg":"Done"}


@router.post('/pay-reservation/{reservation_id}', response_model=ReservationOutSchema)
async def pay_pharmacy_reservation(reservation_id: int, obj: PayReservtionSchema, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(Reservation).where(Reservation.id==reservation_id))
    reservation = result.scalars().first()
    if not reservation:
        raise HTTPException(status_code=400, detail=f"Reservation not found")
    await reservation.pay_reservation(**obj.dict(), db=db)
    return reservation


@router.post('/pay-hospital-reservation/{reservation_id}', response_model=ReservationOutSchema)
async def pay_pharmacy_hospital_reservation(reservation_id: int, obj: PayHospitalReservtionSchema, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(HospitalReservation).where(HospitalReservation.id==reservation_id))
    reservation = result.scalars().first()
    if not reservation:
        raise HTTPException(status_code=400, detail=f"Reservation not found")
    await reservation.pay_reservation(**obj.dict(), db=db)
    return reservation


@router.post('/pay-wholesale-reservation/{reservation_id}', response_model=ReservationOutSchema)
async def pay_wholesale_pharmacy_reservation(reservation_id: int, obj: PayWholesaleReservtionSchema, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(WholesaleReservation).where(WholesaleReservation.id==reservation_id))
    reservation = result.scalars().first()
    if not reservation:
        raise HTTPException(status_code=400, detail=f"WholesaleReservation not found")
    await reservation.pay_reservation(**obj.dict(), db=db)
    return reservation


@router.get('/get-pharmacy-reservation-payed-remiainder/{reservation_id}')
async def get_pharmacy_reservation_payed_remiainder(reservation_id: int, db: AsyncSession = Depends(get_db)):
    data = {}
    result = await db.execute(select(ReservationPayedAmounts).filter(ReservationPayedAmounts.reservation_id==reservation_id).order_by(ReservationPayedAmounts.id.desc()))
    obj = result.scalars().first()
    result = await db.execute(select(ReservationProducts).filter(ReservationProducts.reservation_id==reservation_id))
    data = {
        "remiainder_sum": obj.remainder_sum if obj else 0 ,
        "reservation_unpayed_products": [{'product_id':prd.product_id, 'quantity': prd.not_payed_quantity} for prd in result.scalars().all()]
    }
    return data 


@router.get('/get-wholesale-reservation-payed-remiainder/{reservation_id}')
async def get_wholesale_reservation_payed_remiainder(reservation_id: int, db: AsyncSession = Depends(get_db)):
    data = {}
    result = await db.execute(select(WholesaleReservationPayedAmounts).filter(WholesaleReservationPayedAmounts.reservation_id==reservation_id).order_by(WholesaleReservationPayedAmounts.id.desc()))
    obj = result.scalars().first()
    result = await db.execute(select(WholesaleReservationProducts).filter(WholesaleReservationProducts.reservation_id==reservation_id))
    data = {
        "remiainder_sum": obj.remainder_sum if obj else 0 ,
        "reservation_unpayed_products": [{'product_id':prd.product_id, 'quantity': prd.not_payed_quantity} for prd in result.scalars().all()]
    }
    return data 


@router.put('/edit-pharmacy-reservation-invoice-number/{reservation_id}', response_model=ReservationOutSchema)
async def edit_pharmacy_reservation_invoice_number(reservation_id: int, invoice_number: int, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(Reservation).where(Reservation.id==reservation_id))
    reservation = result.scalars().first()
    if not reservation:
        raise HTTPException(status_code=400, detail=f"Reservation not found")
    await reservation.edit_invoice_number(invoice_number, db)
    return reservation


@router.put('/edit-hospital-reservation-invoice-number/{reservation_id}', response_model=ReservationOutSchema)
async def edit_hospital_reservation_invoice_number(reservation_id: int, invoice_number: int, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(HospitalReservation).where(HospitalReservation.id==reservation_id))
    reservation = result.scalars().first()
    if not reservation:
        raise HTTPException(status_code=400, detail=f"HospitalReservation not found")
    await reservation.edit_invoice_number(invoice_number, db)
    return reservation


@router.put('/edit-wholesale-reservation-invoice-number/{reservation_id}', response_model=ReservationOutSchema)
async def edit_wholesale_reservation_invoice_number(reservation_id: int, invoice_number: int, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(WholesaleReservation).where(WholesaleReservation.id==reservation_id))
    reservation = result.scalars().first()
    if not reservation:
        raise HTTPException(status_code=400, detail=f"WholesaleReservation not found")
    await reservation.edit_invoice_number(invoice_number, db)
    return reservation
