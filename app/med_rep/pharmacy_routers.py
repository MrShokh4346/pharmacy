from datetime import datetime, timedelta, timezone, date
from fastapi import Depends, FastAPI, HTTPException, status
from jose import JWTError, jwt
from .doctor_schemas import DoctorListSchema, DoctorAttachedProductSchema
from .pharmacy_schemas import *
from models.doctors import Doctor
from models.users import Products
from fastapi import APIRouter
from sqlalchemy.ext.asyncio import AsyncSession
from models.pharmacy import *
from models.hospital import HospitalReservation
from models.users import PharmacyPlan, Notification
from models.database import get_db, get_or_404
from models.dependencies import *
from fastapi.security import HTTPAuthorizationCredentials
from typing import List
from deputy_director.schemas import PharmacyVisitPlanOutSchema, PharmacyVisitPlanListSchema
from common.schemas import ProductOutSchema
from sqlalchemy import text
from deputy_director.schemas import NotificationOutSchema, NotificationListSchema
from sqlalchemy.future import select
from sqlalchemy.orm import selectinload
from sqlalchemy import cast, Date
import calendar


router = APIRouter()


@router.get('/get-pharmacy-notifications/{pharmacy_id}', response_model=List[NotificationListSchema])
async def get_doctor_notifications(pharmacy_id: int, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(Notification).options(selectinload(Notification.doctor), selectinload(Notification.pharmacy), selectinload(Notification.wholesale)).filter(Notification.pharmacy_id==pharmacy_id))
    return result.scalars().all()


@router.get('/get-all-pharmacy', response_model=List[PharmacyListSchema])
async def get_all_pharmacy(db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(Pharmacy))
    return result.scalars().all()


@router.get('/get-pharmacy/{pharmacy_id}', response_model=PharmacyOutSchema)
async def get_pharmacy_by_id(pharmacy_id: int, db: AsyncSession = Depends(get_db)):
    result = await get_or_404(Pharmacy, pharmacy_id, db)
    return result


@router.get('/filter-pharmacy', response_model=List[PharmacyListSchema])
async def filter_pharmacies(med_rep_id: int | None = None, doctor_id: int | None = None, product_id: int | None = None, region_id: int | None = None, db: AsyncSession = Depends(get_db)):
    query = select(Pharmacy).options(selectinload(Pharmacy.doctors))
    if med_rep_id:
        query = query.filter(Pharmacy.med_rep_id == med_rep_id)
    if doctor_id:
        query = query.filter(Pharmacy.doctors.any(Doctor.id == doctor_id))
    if region_id:
        query = query.filter(Pharmacy.region_id == region_id)
    result = await db.execute(query)
    return result.scalars().all()


@router.get('/get-pharmacy', response_model=List[PharmacyListSchema])
async def get_med_rep_related_pharmacy(user_id: int, db: AsyncSession = Depends(get_db)):
    user = await get_user(user_id, db)
    result = await db.execute(select(Pharmacy).filter(Pharmacy.med_rep_id==user.id))
    return result.scalars().all()
    

@router.post('/add-pharmacy', response_model=PharmacyOutSchema)
async def add_pharmacy(new_pharmacy: PharmacyAddSchema, user_id: int, db: AsyncSession = Depends(get_db)):
    user = await get_user(user_id, db)
    pharmacy = Pharmacy(**new_pharmacy.dict(), med_rep_id=user.id, region_manager_id=user.region_manager_id, 
                        ffm_id=user.ffm_id, product_manager_id=user.product_manager_id, 
                        deputy_director_id=user.deputy_director_id, director_id=user.director_id)
    await pharmacy.save(db)
    return pharmacy
    

@router.patch('/update-pharmacy/{pharmacy_id}', response_model=PharmacyOutSchema)
async def update_pharmacy(pharmacy_id: int, data: PharmacyUpdateSchema, db: AsyncSession = Depends(get_db)):
    pharmacy = await get_or_404(Pharmacy, pharmacy_id, db)
    await pharmacy.update(**data.dict(), db=db)
    return pharmacy


@router.post('/add-balance-in-stock')
async def add_balance_in_stock(balance: BalanceInStockSchema, db: AsyncSession = Depends(get_db)):
    await IncomingBalanceInStock.save(**balance.dict(), db=db)
    return {"msg":"Done"}


@router.post('/checking-balance-in-stock')
async def checking_balance_in_stock(balance: CheckBalanceInStockSchema, db: AsyncSession = Depends(get_db)):
    await CheckingBalanceInStock.save(**balance.dict(), db=db)
    return {"msg":"Done"}


@router.get('/get-balnce-in-stock/{pharmacy_id}', response_model=List[StockOutSchema])
async def get_balance_in_stock(pharmacy_id: int, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(CurrentBalanceInStock).options(selectinload(CurrentBalanceInStock.product)).filter(CurrentBalanceInStock.pharmacy_id==pharmacy_id, CurrentBalanceInStock.amount > 0))
    return result.scalars().all()


@router.get('/get-pharmacy-visit-plan', response_model=List[PharmacyVisitPlanListSchema])
async def get_pharmacy_visit_plan(user_id: int, db: AsyncSession = Depends(get_db)):
    user = await get_user(user_id, db)
    result = await db.execute(select(PharmacyPlan).options(selectinload(PharmacyPlan.pharmacy)).filter(PharmacyPlan.med_rep_id==user.id))
    return result.scalars().all()


@router.get('/filter-pharmacy-visit-plan-by-date', response_model=List[PharmacyVisitPlanListSchema])
async def get_pharmacy_visit_plan(user_id: int, date: date, db: AsyncSession = Depends(get_db)):
    user = await get_user(user_id, db)
    result = await db.execute(select(PharmacyPlan).options(selectinload(PharmacyPlan.pharmacy)).filter(PharmacyPlan.med_rep_id == user.id, cast(PharmacyPlan.date, Date) == date))
    return result.scalars().all()


@router.get('/filter-pharmacy-visit-plan-by-date-interval', response_model=List[PharmacyVisitPlanListSchema])
async def get_pharmacy_visit_plan(user_id: int, from_date: date, to_date: date, db: AsyncSession = Depends(get_db)):
    user = await get_user(user_id, db)
    result = await db.execute(select(PharmacyPlan).options(selectinload(PharmacyPlan.pharmacy)).filter(PharmacyPlan.med_rep_id == user.id, cast(PharmacyPlan.date, Date) >= from_date, cast(PharmacyPlan.date, Date) <= to_date))
    return result.scalars().all()


@router.get('/get-pharmacy-visit-plan/{plan_id}', response_model=PharmacyVisitPlanOutSchema)
async def get_pharmacy_visit_plan_by_id(plan_id: int, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(PharmacyPlan).options(selectinload(PharmacyPlan.pharmacy)).where(PharmacyPlan.id==plan_id))
    plan = result.scalars().first()
    if not plan:
        raise HTTPException(status_code=404, detail="Plan not found")
    return plan


@router.post('/reschedule-pharmacy-visit/{plan_id}', response_model=PharmacyVisitPlanOutSchema, description='date format: (%Y-%m-%d %H:%M)')
async def reschedule_pharmacy_visit_date(plan_id: int, date: RescheduleSchema, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(PharmacyPlan).options(selectinload(PharmacyPlan.pharmacy)).where(PharmacyPlan.id == plan_id))
    plan = result.scalars().first()
    if not plan:
        raise HTTPException(status_code=404, detail="Plan not found")
    await plan.update(**date.dict(), db=db)
    return plan


@router.post('/pharmacy-visit-info/{visit_id}')
async def pharmacy_visit_info(visit_id: int, visit: VisitInfoSchema, db: AsyncSession = Depends(get_db)):
    plan = await get_or_404(PharmacyPlan, visit_id, db)
    await plan.update(description=visit.description, status=True, db=db)
    if visit.doctors is not None:
        fact = await PharmacyFact.save(**visit.dict(), visit_date=plan.date, pharmacy_id=plan.pharmacy_id, db=db)
    return {"msg":"Done"}


@router.get('/pharmacy-visit-report', response_model=List[PharmacyFactSchema])
async def pharmacy_visit_report(month_number: int, db: AsyncSession = Depends(get_db)):
    year = datetime.now().year
    num_days = calendar.monthrange(year, month_number)[1]
    start_date = datetime(year, month_number, 1)
    end_date = datetime(year, month_number, num_days, 23, 59)
    fact = await db.execute(select(PharmacyFact).filter(PharmacyFact.date >= start_date, PharmacyFact.date <= end_date))
    return fact.scalars().all()


@router.get('/pharmacy-visit-report-by-pharmacy-id/{pharmacy_id}', response_model=List[PharmacyFactSchema])
async def pharmacy_visit_report_by_pharmacy_id(pharmacy_id: int, db: AsyncSession = Depends(get_db)):
    fact = await db.execute(select(PharmacyFact).filter(PharmacyFact.pharmacy_id==pharmacy_id))
    return fact.scalars().all()


@router.post('/attach-doctor-to-pharmacy')
async def attach_doctor_to_pharmacy(att: AttachDoctorToPharmacySchema, db: AsyncSession = Depends(get_db)):
    pharmacy = await get_or_404(Pharmacy, att.dict().get('pharmacy_id'), db)
    await pharmacy.attach_doctor(**att.dict(), db=db)
    return {"msg":"Done"}


@router.get('/search-mr-doctors', response_model=List[DoctorListSchema])
async def search_for_med_rep_attached_doctors(search: str, user_id: int, db: AsyncSession = Depends(get_db)):
    user = await get_user(user_id, db)
    result = await db.execute(select(Doctor).filter(Doctor.full_name.like(f"%{search}%"), Doctor.med_rep_id==user.id, Doctor.deleted == False))
    return result.scalars().all()


@router.get('/get-pharmacy-doctors-list/{pharmacy_id}', response_model=List[DoctorListSchema])
async def get_pharmacy_attached_doctors(pharmacy_id: int, db: AsyncSession = Depends(get_db)):
    pharmacy = await get_or_404(Pharmacy, pharmacy_id, db)
    result = await db.execute(select(Doctor).\
            join(pharmacy_doctor, pharmacy_doctor.c.doctor_id == Doctor.id).filter(
                    pharmacy_doctor.c.pharmacy_id == pharmacy_id,
                    Doctor.deleted == False))
    doctors = result.scalars().all()
    return doctors


@router.post('/add-debt/{pharmacy_id}', response_model=List[DebtOutSchema])
async def add_debt(pharmacy_id: int, debt: DebtSchema, db: AsyncSession = Depends(get_db)):
    debt = Debt(**debt.dict(), pharmacy_id=pharmacy_id)
    await debt.save(db)
    result = await db.execute(select(Debt).filter(Debt.pharmacy_id==pharmacy_id))
    return result.scalars().all()


@router.put('/update-debt-status/{debt_id}', response_model=DebtOutSchema)
async def update_debt_status(debt_id: int, st: DebtUpdateSchema, db: AsyncSession = Depends(get_db)):
    debt = await get_or_404(Debt, debt_id, db)
    await debt.update(**st.dict(), db=db)
    return debt


@router.get('/get-debt/{pharmacy_id}', response_model=List[DebtOutSchema])
async def get_debt(pharmacy_id: int, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(Debt).filter(Debt.pharmacy_id==pharmacy_id))
    debt = result.scalars().all()
    if debt:
        return debt
    return []


@router.post('/reservation/{pharmacy_id}', response_model=ReservationOutSchema)
async def reservation(pharmacy_id: int, res: ReservationSchema, db: AsyncSession = Depends(get_db)):
    pharmacy = await get_or_404(Pharmacy, pharmacy_id, db)
    reservation = await Reservation.save(**res.dict(), db=db, pharmacy_id=pharmacy_id, discount=pharmacy.discount)
    return reservation


@router.get('/get-reservation-history/{reservation_id}', response_model=List[ReservationHistorySchema])
async def get_reservation_history(reservation_id: int, db: AsyncSession = Depends(get_db)):
    history = await db.execute(select(ReservationPayedAmounts).filter(ReservationPayedAmounts.reservation_id==reservation_id))
    return history.scalars().all()


# @router.get('/get-reservations/{pharmacy_id}', response_model=List[ReservationListSchema])
# async def get_reservation(pharmacy_id: int, db: AsyncSession = Depends(get_db)):
#     result = await db.execute(select(Reservation).options(selectinload(Reservation.products)).filter(Reservation.pharmacy_id==pharmacy_id))
#     return result.scalars().all()


@router.get('/get-reservation/{reservation_id}', response_model=ReservationOutWithProductsSchema)
async def get_report(reservation_id: int, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(Reservation).where(Reservation.id==reservation_id))
    res = result.scalar()
    if res is None:
        raise HTTPException(status_code=404, detail="Reservation no found")
    return res


@router.get('/get-report/{reservation_id}')
async def get_report(reservation_id: int, db: AsyncSession = Depends(get_db)):
    return await write_excel(reservation_id, db)


@router.get('/get-hospital-report/{reservation_id}')
async def get_report(reservation_id: int, db: AsyncSession = Depends(get_db)):
    return await write_excel_hospital(reservation_id, db)


@router.post('/reply-notification/{notification_id}', response_model=NotificationOutSchema)
async def reply_notification(notification_id: int, reply: ReplyNotification, db: AsyncSession = Depends(get_db)):
    notification = await get_or_404(Notification, notification_id, db)
    await notification.reply(**reply.dict(), db=db)
    return notification


@router.get('/get-pharmacy-hot-sales/{pharmacy_id}', response_model=List[PharmacyHotSaleSchema])
async def get_pharmacy_hot_sales(pharmacy_id: int, month: int | None = None, db: AsyncSession = Depends(get_db)):
    year = datetime.now().year
    month = datetime.now().month if month is None else month 
    num_days = calendar.monthrange(year, month)[1]
    start_date = datetime(year, month_number, 1)  
    end_date = datetime(year, month, num_days, 23, 59)
    result = await db.execute(select(PharmacyHotSale).filter(PharmacyHotSale.pharmacy_id==pharmacy_id))
    return result.scalars().all()


@router.get('/get-pharmacy-warehouse', response_model=List[PharmacyWarehouseSchema])
async def get_pharmacy_warehouse(db: AsyncSession = Depends(get_db)):
    # pharmacies = await Pharmacy.get_warehouse(db)
    pharmacy_warehouse = await db.execute(select(Pharmacy))
    return pharmacy_warehouse.scalars().all()