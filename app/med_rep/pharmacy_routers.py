from datetime import datetime, timedelta, timezone, date
from fastapi import Depends, FastAPI, HTTPException, status
from jose import JWTError, jwt
from .doctor_schemas import DoctorListSchema, DoctorAttachedProductSchema
from .pharmacy_schemas import *
from models.doctors import Doctor, DoctorAttachedProduct
from models.users import Products
from fastapi import APIRouter
from sqlalchemy.orm import Session
from models.pharmacy import *
from models.users import PharmacyPlan, Notification
from models.database import get_db
from models.dependencies import *
from fastapi.security import HTTPAuthorizationCredentials
from typing import List
from deputy_director.schemas import PharmacyVisitPlanOutSchema
from common.schemas import ProductOutSchema
from sqlalchemy import text
from deputy_director.schemas import NotificationOutSchema


router = APIRouter()


@router.get('/get-pharmacy-notifications/{pharmacy_id}', response_model=List[NotificationOutSchema])
async def get_doctor_notifications(pharmacy_id: int, db: Session = Depends(get_db)):
    notifications = db.query(Notification).filter(Notification.pharmacy_id==pharmacy_id).all()
    return notifications


@router.get('/get-all-pharmacy', response_model=List[PharmacyListSchema])
async def get_all_pharmacy(db: Session = Depends(get_db)):
    pharmacies = db.query(Pharmacy).all()
    return pharmacies


@router.get('/filter-pharmacy', response_model=List[PharmacyListSchema])
async def filter_pharmacies(doctor_id: int | None = None, product_id: int | None = None, region_id: int | None = None, db: Session = Depends(get_db)):
    query = filter_pharmacy(doctor_id, product_id, region_id)
    pharmacy = db.execute(text(query))
    print(pharmacy.__dict__)
    return pharmacy


@router.get('/get-pharmacy', response_model=List[PharmacyListSchema])
async def get_med_rep_related_pharmacy(user_id: int, db: Session = Depends(get_db)):
    user = get_user(user_id, db)
    pharmacies = db.query(Pharmacy).filter(Pharmacy.med_rep_id==user.id).all()
    return pharmacies
    

@router.post('/add-pharmacy', response_model=PharmacyOutSchema)
async def add_pharmacy(new_pharmacy: PharmacyAddSchema, user_id: int, db: Session = Depends(get_db)):
    user = get_user(user_id, db)
    pharmacy = Pharmacy(**new_pharmacy.dict(), med_rep_id=user.id, region_manager_id=user.region_manager_id, 
                        ffm_id=user.ffm_id, product_manager_id=user.product_manager_id, 
                        deputy_director_id=user.deputy_director_id, director_id=user.director_id)
    pharmacy.save(db)
    return pharmacy
    

@router.patch('/update-pharmacy/{id}', response_model=PharmacyOutSchema)
async def update_pharmacy(id: int, data: PharmacyUpdateSchema, db: Session = Depends(get_db)):
    pharmacy = db.query(Pharmacy).get(id)
    pharmacy.update(**data.dict(), db=db)
    return pharmacy


@router.post('/add-balance-in-stock')
async def add_balance_in_stock(balance: BalanceInStockSchema, db: Session = Depends(get_db)):
    IncomingBalanceInStock.save(**balance.dict(), db=db)
    return {"msg":"Done"}


@router.post('/checking-balance-in-stock')
async def checking_balance_in_stock(balance: CheckBalanceInStockSchema, db: Session = Depends(get_db)):
    CheckingBalanceInStock.save(**balance.dict(), db=db)
    return {"msg":"Done"}


@router.get('/get-balnce-in-stock/{pharmacy_id}', response_model=List[StockProduct])
async def get_balance_in_stock(pharmacy_id: int, from_date: str, to_date: str, db: Session = Depends(get_db)):
    from_date, to_date = datetime.strptime(from_date, '%Y-%m-%d'), datetime.strptime(to_date, '%Y-%m-%d')
    products = db.query(BalanceInStock).filter(BalanceInStock.date.between(from_date, to_date)).all()
    return products


@router.get('/get-pharmacy-visit-plan', response_model=List[PharmacyVisitPlanOutSchema])
async def get_pharmacy_visit_plan(user_id: int, db: Session = Depends(get_db)):
    user = get_user(user_id, db)
    plans = db.query(PharmacyPlan).filter(PharmacyPlan.med_rep_id==user.id).all()
    return plans 


@router.get('/filter-pharmacy-visit-plan-by-date', response_model=List[PharmacyVisitPlanOutSchema])
async def get_pharmacy_visit_plan(user_id: int, date: date, db: Session = Depends(get_db)):
    user = get_user(user_id, db)
    plans = db.query(PharmacyPlan).filter(PharmacyPlan.med_rep_id==user.id, PharmacyPlan.date==date).all()
    return plans 


@router.get('/get-pharmacy-visit-plan/{plan_id}', response_model=PharmacyVisitPlanOutSchema)
async def get_pharmacy_visit_plan_by_id(plan_id: int, db: Session = Depends(get_db)):
    plan = db.query(PharmacyPlan).get(plan_id)
    return plan 


@router.post('/reschedule-pharmacy-visit/{plan_id}', response_model=PharmacyVisitPlanOutSchema)
async def reschedule_doctor_visit_date(plan_id: int, date: RescheduleSchema, db: Session = Depends(get_db)):
    plan = db.query(PharmacyPlan).get(plan_id)
    plan.update(**date.dict(), db=db)
    return plan


@router.post('/pharmacy-visit-info/{visit_id}')
async def doctor_visit_info(visit_id: int, visit: VisitInfoSchema, db: Session = Depends(get_db)):
    plan = db.query(PharmacyPlan).get(visit_id)
    plan.attach(**visit.dict(), db=db)
    return {"msg":"Done"}


@router.get('/get-pharmacy-doctors-list/{pharmacy_id}', response_model=List[DoctorListSchema])
async def get_phatmacy_attached_doctors_list(pharmacy_id: int, db: Session = Depends(get_db)):
    pharmacy = db.query(Pharmacy).get(pharmacy_id)
    return pharmacy.doctors


@router.post('/attach-doctor-to-pharmacy/{pharmacy_id}')
async def attach_doctor_to_pharmacy(att: AttachDoctorToPharmacySchema, db: Session = Depends(get_db)):
    pharmacy = db.query(Pharmacy).get(pharmacy_id)
    pharmacy.attach_doctor(**att.dict(), db=db)
    return {"msg":"Done"}


@router.get('/search-pharmacy-doctors', response_model=List[DoctorListSchema])
async def search_for_pharmacy_attached_doctors(search: str, user_id: int, db: Session = Depends(get_db)):
    user = get_user(user_id, db)
    doctors = db.query(Doctor).filter(Doctor.full_name.like(f"%{search}%"), Doctor.med_rep_id==user.id).all()
    return doctors


@router.get('/search-mr-doctors/{pharmacy_id}', response_model=List[DoctorListSchema])
async def search_for_med_rep_attached_doctors(pharmacy_id: int, search: str, db: Session = Depends(get_db)):
    pharmacy = db.query(Pharmacy).filter(Pharmacy.id==pharmacy_id, Pharmacy.doctors.any(Doctor.full_name.like(f"%{search}%"))).all()
    return pharmacy[0].doctors

        
@router.get('/get-doctor-attached-products/{doctor_id}', response_model=List[DoctorAttachedProductSchema])
async def seatch_for_doctor_attached_products(doctor_id: int, search: str, db: Session = Depends(get_db)):
    products = db.query(DoctorAttachedProduct).filter(DoctorAttachedProduct.doctor_id==doctor_id).all()
    return products 


@router.post('/add-debt/{pharmacy_id}', response_model=List[DebtOutSchema])
async def add_debt(pharmacy_id: int, debt: DebtSchema, db: Session = Depends(get_db)):
    debt = Debt(**debt.dict(), pharmacy_id=pharmacy_id)
    debt.save(db)
    debts = db.query(Debt).filter(Debt.pharmacy_id==pharmacy_id).all()
    return debts


@router.put('/update-debt-status/{debt_id}', response_model=DebtOutSchema)
async def update_debt_status(debt_id: int, st: DebtUpdateSchema, db: Session = Depends(get_db)):
    debt = db.query(Debt).get(debt_id)
    debt.update(**st.dict(), db=db)
    return debt


@router.get('/get-debt/{pharmacy_id}', response_model=List[DebtOutSchema])
async def get_debt(pharmacy_id: int, db: Session = Depends(get_db)):
    debts = db.query(Debt).filter(Debt.pharmacy_id==pharmacy_id).all()
    return debts


@router.get('/search-from-warehouse', response_model=List[FactoryWarehouseOutSchema])
async def search_from_factory_warehouse(search: str, db: Session = Depends(get_db)):
    products = db.query(FactoryWarehouse).filter(FactoryWarehouse.product.has(Products.name.like(f"%{search}%"))).all()
    return products


@router.post('/reservation', response_model=ReservationOutSchema)
async def reservation(res: ReservationSchema, db: Session = Depends(get_db)):
    reservation = Reservation.save(**res.dict(), db=db)
    return reservation


@router.get('/get-reservations', response_model=ReservationOutSchema)
async def get_reservation(db: Session = Depends(get_db)):
    reservations = db.query(Reservation).all()
    return reservations


@router.get('/get-report/{reservation_id}')
async def get_report(reservation_id: int, db: Session = Depends(get_db)):
    return write_excel(reservation_id, db)


@router.post('/add-wholesale', response_model=WholesaleOutSchema)
async def wholesale(wholesale: WholesaleSchema, db: Session = Depends(get_db)):
    wholesale = Wholesale(**wholesale.dict())
    wholesale.save(db)
    return wholesale


@router.patch('/update-wholesale/{wholesale_id}', response_model=WholesaleOutSchema)
async def update_wholesale(wholesale_id: int, data: WholesaleUpdateSchema, db: Session = Depends(get_db)):
    wholesale = db.query(Wholesale).get(wholesale_id)
    wholesale.update(**data.dict(), db=db)
    return wholesale


@router.post('/wholesale-attach-product/{wholesale_id}')
async def wholesale_attach_product(wholesale_id: int, product: WholesaleProductsListSchema, db: Session = Depends(get_db)):
    wholesale = db.query(Wholesale).get(wholesale_id)
    wholesale.attach(**product.dict(), db=db)
    return {"msg":"Done"}


@router.get('/search-wholesale-products', response_model=List[WholesaleOutSchema])
async def search_for_med_rep_attached_doctors(region_id: int, search: str, db: Session = Depends(get_db)):
    wholesale = db.query(Wholesale).filter(Wholesale.region_id==region_id, Wholesale.products.any(Products.name.like(f"%{search}%"))).all()
    return wholesale
