from datetime import datetime, timedelta, timezone, date 
from fastapi import Depends, FastAPI, HTTPException, status
from jose import JWTError, jwt
from .schemas import *
from fastapi import APIRouter
from models.users import *
from models.hospital import HospitalFact, Hospital, HospitalBonus
from models.doctors import DoctorFact, Doctor, Bonus, DoctorPostupleniyaFact
from models.pharmacy import PharmacyHotSale, Pharmacy
from models.database import get_db, get_or_404
from models.dependencies import *
from typing import Any
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from sqlalchemy.future import select
from sqlalchemy.orm import selectinload, joinedload
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import func, text
import calendar
from .utils import *
from common_depetencies import StartEndDates


router = FastAPI()


@router.post('/register-for-dd', response_model=UserOutSchema, description='using RegisterForDDSchema')
async def register_user_for_pm(user: RegisterForDDSchema, manager: Annotated[Users, Depends(get_current_user)], token: HTTPAuthorizationCredentials = Depends(auth_header), db: AsyncSession = Depends(get_db)) -> Any:
    if manager.status == 'deputy_director':
        await check_if_user_already_exists(username=user.username, db = db)
        if user.status == 'medical_representative':
            if not (user.region_manager_id and user.ffm_id and user.product_manager_id):
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="region_manager_id, ffm_id, product_manager_id should be declared"
                )
            new_user = Users(**user.dict(), deputy_director_id=manager.id, director_id=manager.director_id)
            await new_user.save(db=db)
        elif user.status == 'regional_manager':
            if not (user.ffm_id and user.product_manager_id):
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="ffm_id, product_manager_id should be declared"
                )
            new_user = Users(**user.dict(), deputy_director_id=manager.id, director_id=manager.director_id)
            await new_user.save(db=db)
        elif user.status == 'ff_manager':
            if not user.product_manager_id:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="product_manager_id should be declared"
                )
            new_user = Users(**user.dict(), deputy_director_id=manager.id, director_id=manager.director_id)
            await new_user.save(db=db)
        else:
            new_user = Users(**user.dict(), deputy_director_id=manager.id, director_id=manager.director_id)
            await new_user.save(db=db)
        return new_user
    raise HTTPException(status_code=403, detail="You are not a deputy director")


@router.post('/add-doctor-plan/{med_rep_id}', response_model=List[DoctorVisitPlanOutSchema])
async def add_doctor_visit_plan_to_mr(med_rep_id:int, plan: DoctorVisitPlanSchema,  db: AsyncSession = Depends(get_db)):
    visit = DoctorPlan(**plan.dict(), med_rep_id=med_rep_id)
    await visit.save(db)
    result = await db.execute(select(DoctorPlan).options(selectinload(DoctorPlan.doctor)).filter(DoctorPlan.med_rep_id==med_rep_id))
    return result.scalars().all()


@router.delete('/delete-doctor-plan/{plan_id}')
async def delete_doctor_visit_plan(plan_id:int, db: AsyncSession = Depends(get_db)):
    visit = await get_or_404(DoctorPlan, plan_id, db)
    query = f"delete from doctor_plan WHERE id={plan_id}"
    result = await db.execute(text(query))
    # await db.delete(visit)
    await db.commit()
    return {"msg":"Deleted"}


@router.post('/add-pharmacy-plan/{med_rep_id}', response_model=List[PharmacyVisitPlanOutSchema])
async def add_pharmacy_visit_plan_to_mr(med_rep_id:int, plan: PharmacyVisitPlanSchema,  db: AsyncSession = Depends(get_db)):
    visit = PharmacyPlan(**plan.dict(), med_rep_id=med_rep_id)
    await visit.save(db)
    result = await db.execute(select(PharmacyPlan).options(selectinload(PharmacyPlan.pharmacy)).filter(PharmacyPlan.med_rep_id==med_rep_id))
    return result.scalars().all()


@router.delete('/delete-pharmacy-plan/{plan_id}')
async def delete_pharmacy_visit_plan(plan_id:int, db: AsyncSession = Depends(get_db)):
    visit = await get_or_404(PharmacyPlan, plan_id, db)
    query = f"delete from pharmacy_plan WHERE id={plan_id}"
    result = await db.execute(text(query))
    # await db.delete(visit)
    await db.commit()
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
    query = f"delete from notification WHERE id={notofication_id}"
    result = await db.execute(text(query))
    # await db.delete(notification)
    await db.commit()
    return {"msg":"Deleted"}


@router.post('/add-user-product-plan', response_model=UserProductPlanOutSchema)
async def add_user_product_plan(plan: UserProductPlanInSchema, db: AsyncSession = Depends(get_db)):
    year = datetime.now().year
    day = datetime.now().day 
    num_days = calendar.monthrange(year, plan.month)[1]
    start_date = date(year, plan.month, 1)  
    end_date = date(year, plan.month, num_days)
    plan_date = date(year, plan.month, day)
    data = plan.dict()
    del data['month']
    result = await db.execute(select(UserProductPlan).filter(UserProductPlan.product_id==plan.product_id, UserProductPlan.plan_month>=start_date, UserProductPlan.plan_month<=end_date, UserProductPlan.med_rep_id==plan.med_rep_id))
    user_product = result.scalars().first()
    if user_product:
        raise HTTPException(status_code=404, detail='Plan already exists for this product in this month')
    plan = UserProductPlan(**data, current_amount=plan.amount, plan_month=plan_date)
    await plan.save(db)
    return plan 


@router.put('/update-user-product-plan/{plan_id}', response_model=UserProductPlanOutSchema)
async def add_user_product_plan(plan_id: int, amount: int, db: AsyncSession = Depends(get_db)):
    plan = await get_or_404(UserProductPlan, plan_id, db)
    await plan.update(amount, db)
    return plan 


@router.delete('/delete-user-product-plan/{plan_id}')
async def add_user_product_plan(plan_id: int, db: AsyncSession = Depends(get_db)):
    plan = await get_or_404(UserProductPlan, plan_id, db)
    query = f"delete from user_product_plan WHERE id={plan_id}"
    result = await db.execute(text(query))
    # await db.delete(plan)
    await db.commit()
    return {"msg":"Deleted"} 


@router.get('/get-user-products-plan/{med_rep_id}', response_model=List[UserProductPlanOutSchema])
async def add_user_products_plan(med_rep_id: int, month_number: int | None = None, db: AsyncSession = Depends(get_db)):
    query = select(UserProductPlan).filter(UserProductPlan.med_rep_id==med_rep_id)
    if month_number:
        year = datetime.now().year
        num_days = calendar.monthrange(year, month_number)[1]
        start_date = datetime(year, month_number, 1)
        end_date = datetime(year, month_number, num_days, 23, 59)
        query = query.filter(UserProductPlan.date>=start_date, UserProductPlan.date<=end_date)
    result = await db.execute(query)
    return result.scalars().all() 


@router.get('/get-med-rep-product-plan-by-month-id/{med_rep_id}')
async def get_user_product_plan_by_plan_id(filter_date: StartEndDates, med_rep_id: int, month_number: int | None = None, start_date: date | None = None, end_date: date | None = None, db: AsyncSession = Depends(get_db)):
    start_date = filter_date['start_date']
    end_date = filter_date['end_date']
    result1 = await db.execute(select(UserProductPlan).filter(UserProductPlan.plan_month>=start_date, UserProductPlan.plan_month<=end_date, UserProductPlan.med_rep_id==med_rep_id))
    user_plans = result1.scalars().all()
    user_plan_data = []
    fact = 0
    fact_price = 0
    for user_plan in user_plans:
        query = select(DoctorMonthlyPlan).join(Doctor).options(joinedload(DoctorMonthlyPlan.doctor)).filter(Doctor.med_rep_id == user_plan.med_rep_id, DoctorMonthlyPlan.product_id == user_plan.product_id, DoctorMonthlyPlan.date >= start_date, DoctorMonthlyPlan.date <= end_date)
        result = await db.execute(query)
        doctor_att = []
        doctor_plans = result.scalars().all()
        fact_p = 0 
        for doctor_plan in doctor_plans:
            result = await db.execute(select(Bonus).filter(Bonus.doctor_id==doctor_plan.doctor_id, Bonus.product_id==user_plan.product_id, Bonus.date >= start_date, Bonus.date <= end_date))
            bonus = result.scalars().first()
            fact_d = await get_visit_facts(doctor_plan.doctor_id, doctor_plan.product_id, start_date, end_date, db)
            fact_postupleniya = await get_postupleniya_facts(doctor_plan.doctor_id, doctor_plan.product_id, start_date, end_date, db)
            doctor_att.append({
                'monthly_plan' : doctor_plan.monthly_plan,
                'fact' : fact_d,
                'fact_postupleniya': fact_postupleniya[0],
                'doctor_name' : doctor_plan.doctor.full_name,
                'doctor_id' : doctor_plan.doctor.id,
                'bonus': bonus.amount if bonus else None
            })
            fact +=  fact_d
            fact_price += fact_d *  user_plan.product.price
            fact_p += fact_d 
        
        result = await db.execute(select(PharmacyHotSale).join(Pharmacy).filter(Pharmacy.med_rep_id == user_plan.med_rep_id, PharmacyHotSale.product_id==user_plan.product_id, PharmacyHotSale.date >= start_date, PharmacyHotSale.date <= end_date))
        hot_sales = [{"company_name": hot_sale.pharmacy.company_name, "company_id": hot_sale.pharmacy.id, "sale": hot_sale.amount} for hot_sale in result.scalars().all()]
        result = await db.execute(select(HospitalFact).join(Hospital).filter(Hospital.med_rep_id == user_plan.med_rep_id, HospitalFact.product_id==user_plan.product_id, HospitalFact.date >= start_date, HospitalFact.date <= end_date))
        hospital_facts = [{"hospital_name": hospital_fact.hospital.company_name, "hospital_id": hospital_fact.hospital.id, "fact": hospital_fact.fact, "hospital_fact_price": hospital_fact.fact * hospital_fact.price} for hospital_fact in result.scalars().all()]
        user_plan_data.append({
            "id": user_plan.id,
            "product": user_plan.product.name,
            "product_id": user_plan.product.id,
            "plan_amount": user_plan.amount,
            "plan_price" : user_plan.amount * user_plan.product.price,
            "date": user_plan.date,
            "doctor_plans": doctor_att,
            "vakant": user_plan.current_amount,
            "product_fact": fact_p,
            "pharmacy_hot_sale": hot_sales,
            "hospital_fact": hospital_facts
        })
    data = {
        'plan' : user_plan_data,
        'fact' : fact,
        'fact_price' : fact_price
    }
    return data


@router.get('/get-med-rep-product-plan-by-month')
async def get_user_product_plan_by_plan_id(filter_date:StartEndDates, month_number: int | None = None, start_date: date | None = None, end_date: date | None = None, db: AsyncSession = Depends(get_db)):
    start_date = filter_date['start_date']
    end_date = filter_date['end_date']
    result1 = await db.execute(select(UserProductPlan).filter(UserProductPlan.plan_month>=start_date, UserProductPlan.plan_month<=end_date))
    user_plans = result1.scalars().all()
    user_plan_data = []
    fact = 0
    fact_price = 0
    for user_plan in user_plans:
        query = select(DoctorMonthlyPlan).join(Doctor).options(joinedload(DoctorMonthlyPlan.doctor)).filter(Doctor.med_rep_id == user_plan.med_rep_id, DoctorMonthlyPlan.product_id == user_plan.product_id, DoctorMonthlyPlan.date >= start_date, DoctorMonthlyPlan.date <= end_date)
        result = await db.execute(query)
        doctor_att = []
        doctor_plans = result.scalars().all() 
        for doctor_plan in doctor_plans:
            result = await db.execute(select(DoctorFact).filter(DoctorFact.doctor_id==doctor_plan.doctor_id, DoctorFact.product_id==user_plan.product_id, DoctorFact.date >= start_date, DoctorFact.date <= end_date))
            fact_d = 0
            for f in result.scalars().all():
                fact_d += f.fact
            doctor_att.append({
                'monthly_plan' : doctor_plan.monthly_plan,
                'fact' : fact_d,
                'doctor_name' : doctor_plan.doctor.full_name,
                'doctor_id' : doctor_plan.doctor.id
            })
            fact +=  fact_d
            fact_price += fact_d *  user_plan.product.price
        user_plan_data.append({
            "id": user_plan.id,
            "product": user_plan.product.name,
            "product_id": user_plan.product.id,
            "plan_amount": user_plan.amount,
            "plan_price" : user_plan.amount * user_plan.product.price,
            "date": user_plan.date,
            "doctor_plans": doctor_att,
            "vakant": user_plan.current_amount
        })
    data = {
        'plan' : user_plan_data,
        'fact' : fact,
        'fact_price' : fact_price
    }
    return data


@router.get('/get-doctor-bonus-by-med-rep-id/{med_rep_id}')
async def get_doctor_bonus_by_med_rep_id(filter_date:StartEndDates, med_rep_id: int, month_number: int | None = None, start_date: date | None = None, end_date: date | None = None,  db: AsyncSession = Depends(get_db)):
    start_date = filter_date['start_date']
    end_date = filter_date['end_date']
    user = await get_or_404(Users, med_rep_id, db)
    query = select(DoctorMonthlyPlan).join(Doctor).join(MedicalOrganization).options(joinedload(DoctorMonthlyPlan.doctor), joinedload(DoctorMonthlyPlan.product)).filter(Doctor.med_rep_id == user.id, DoctorMonthlyPlan.date >= start_date, DoctorMonthlyPlan.date <= end_date)
    result = await db.execute(query)
    doctor_att = []
    doctor_plans = result.scalars().all() 
    for doctor_plan in doctor_plans:
        fact_d = await get_visit_facts(doctor_plan.doctor_id, doctor_plan.product_id, start_date, end_date, db)
        result = await db.execute(select(Bonus).filter(Bonus.doctor_id==doctor_plan.doctor_id, Bonus.product_id==doctor_plan.product_id, Bonus.date >= start_date, Bonus.date <= end_date))
        bonus = result.scalars().first()
        fact_postupleniya = await get_postupleniya_facts(doctor_plan.doctor_id, doctor_plan.product_id, start_date, end_date, db)
        doctor_att.append({
            'monthly_plan' : doctor_plan.monthly_plan,
            'fact' : fact_d,
            'fact_postupleniya': fact_postupleniya[0],
            'doctor_name' : doctor_plan.doctor.full_name,
            'doctor_id' : doctor_plan.doctor.id,
            'product_name' : doctor_plan.product.name,
            'bonus_id' : bonus.id if bonus else None,
            'bonus_amount': bonus.amount if bonus else 0,
            'bonus_payed' : bonus.payed if bonus else 0,
            'pre_investment' : bonus.pre_investment if bonus else 0
        })
    return doctor_att


@router.get('/get-bonus-by-manufactory')
async def get_bonus_by_manufactory(filter_date:StartEndDates, month_number: int | None = None, start_date: date | None = None, end_date: date | None = None, db: AsyncSession = Depends(get_db)):
    start_date = filter_date['start_date']
    end_date = filter_date['end_date']
    result = await db.execute(select(ManufacturedCompany))
    man_comps = result.scalars().all()
    data = []
    for man_comp in man_comps:
        if man_comp.name == 'HEARTLY':
            break
        query = text(f"""SELECT SUM(doctor_postupleniya_fact.fact), SUM(doctor_postupleniya_fact.fact * doctor_postupleniya_fact.price), SUM(doctor_postupleniya_fact.fact * products.marketing_expenses) 
                    FROM doctor_postupleniya_fact INNER JOIN products ON products.id = doctor_postupleniya_fact.product_id 
                    WHERE products.man_company_id={man_comp.id} AND  doctor_postupleniya_fact.date>=TO_DATE(:start_date, 'YYYY-MM-DD') AND doctor_postupleniya_fact.date<=TO_DATE(:end_date, 'YYYY-MM-DD')
                    GROUP BY products.man_company_id""")
        result = await db.execute(query, {'start_date': str(start_date), 'end_date': str(end_date)})
        h_sale = result.first()

        query2 = text(f"""SELECT SUM(user_product_plan.amount), SUM(user_product_plan.amount * user_product_plan.price) FROM user_product_plan 
                    INNER JOIN products ON products.id = user_product_plan.product_id WHERE products.man_company_id={man_comp.id}
                    AND user_product_plan.date>=TO_DATE(:start_date, 'YYYY-MM-DD') AND user_product_plan.date<=TO_DATE(:end_date, 'YYYY-MM-DD')
                    GROUP BY products.man_company_id""")
        result = await db.execute(query2, {'start_date': str(start_date), 'end_date': str(end_date)})
        plan = result.first()

        data.append({
            "manufactured_company": man_comp.name,
            "plan": plan[0] if plan is not None else 0,
            "plan_price": plan[1] if plan is not None else 0,
            "saled_products_quantity": h_sale[0] if h_sale is not None else 0,
            "saled_products_price": h_sale[1] if h_sale is not None else 0, 
            "saled_products_pbonus_price": h_sale[2] if h_sale is not None else 0, 
        })
    return data


@router.get('/get-fact')
async def get_fact(filter_date: StartEndDates, med_rep_id: int | None = None, region_id: int | None = None, product_id: int | None = None, db: AsyncSession = Depends(get_db)):
    start_date = filter_date['start_date']
    end_date = filter_date['end_date']
    query = select(DoctorMonthlyPlan).join(Doctor).join(MedicalOrganization).options(joinedload(DoctorMonthlyPlan.doctor), joinedload(DoctorMonthlyPlan.product)).filter(DoctorMonthlyPlan.date >= start_date, DoctorMonthlyPlan.date <= end_date)
    if med_rep_id:
        query = query.filter(Doctor.med_rep_id == med_rep_id)
    if region_id:
        query = query.filter(MedicalOrganization.region_id == region_id)
    if product_id:
        query = query.filter(DoctorMonthlyPlan.product_id == product_id)
    result = await db.execute(query)
    doctor_att = []
    doctor_plans = result.scalars().all() 
    for doctor_plan in doctor_plans:
        fact_postupleniya = await get_postupleniya_facts(doctor_plan.doctor_id, doctor_plan.product_id, start_date, end_date, db)
        fact_d = await get_visit_facts(doctor_plan.doctor_id, doctor_plan.product_id, start_date, end_date, db)
        result = await db.execute(select(Bonus).filter(Bonus.doctor_id==doctor_plan.doctor_id, Bonus.product_id==doctor_plan.product_id, Bonus.date >= start_date, Bonus.date <= end_date))
        bonus = result.scalars().first()
        doctor_att.append({
            'monthly_plan' : doctor_plan.monthly_plan,
            'med_rep': doctor_plan.doctor.med_rep.full_name,
            'region': doctor_plan.doctor.medical_organization.region.name,
            'plan_price' : doctor_plan.monthly_plan * doctor_plan.price ,
            'fact' : fact_d,
            'fact_price' : fact_d * doctor_plan.product.marketing_expenses,
            'fact_postupleniya' : fact_postupleniya[0],
            "fact_postupleniya_price": fact_postupleniya[1],
            'doctor_name' : doctor_plan.doctor.full_name,
            'speciality' : doctor_plan.doctor.speciality.name,
            'medical_organization_name' : doctor_plan.doctor.medical_organization.name,
            'doctor_id' : doctor_plan.doctor.id,
            'product_name' : doctor_plan.product.name,
            'bonus_id' : bonus.id if bonus else None,
            'bonus_amount': bonus.amount if bonus else 0,
            'bonus_payed' : bonus.payed if bonus else 0,
            'bonus_remainder' : bonus.amount - bonus.payed if bonus else 0,
            'pre_investment' : bonus.pre_investment if bonus else 0

        })
    return doctor_att


@router.get('/get-user-current-month-product-plan/{med_rep_id}', response_model=List[UserProductPlanOutSchema])
async def get_user_current_month_plan(med_rep_id: int, db: AsyncSession = Depends(get_db)):
    year = datetime.now().year
    month = datetime.now().month
    num_days = calendar.monthrange(year, month)[1]
    start_date = datetime(year, month, 1)
    end_date = datetime(year, month, num_days, 23, 59)
    result = await db.execute(select(UserProductPlan).filter(UserProductPlan.med_rep_id==med_rep_id, UserProductPlan.plan_month >= start_date, UserProductPlan.plan_month <= end_date))
    return result.scalars().all() 


@router.get('/get-proccess-report', response_model=List[ReportSchema])
async def get_proccess_report(db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(Doctor).filter(Doctor.deleted==False))
    return result.scalars().all()


@router.get('/get-proccess-report-ecxel')
async def get_proccess_report(month: int, db: AsyncSession = Depends(get_db)):
    return await write_proccess_to_excel(month, db)


@router.get('/set-product-expenses/{product_id}', response_model=ProductExpensesSchema)
async def set_product_expenses(product_id: int, marketing_expenses: int | None = None, salary_expenses: int | None = None, db: AsyncSession = Depends(get_db)):
    product = await get_or_404(Products, product_id, db)
    await product.set_expenses(marketing_expenses=marketing_expenses, salary_expenses=salary_expenses, db=db)
    return product


@router.get('/get-products', response_model=List[ProductExpensesSchema])
async def get_medcine(db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(Products).options(selectinload(Products.man_company), selectinload(Products.category)))
    return result.scalars().all()


@router.get('/get-total-plan-fact')
async def get_total_plan_fact(
                            med_rep_id: int | None = None, 
                            product_id: int | None = None, 
                            start_date: date | None = None,
                            end_date: date | None = None,
                            month_number : int | None = None,
                            manufactured_company_id : int | None = None,
                            region_id : int | None = None,
                            db: AsyncSession = Depends(get_db)):
    if month_number:
        year = datetime.now().year
        num_days = calendar.monthrange(year, month_number)[1]
        start_date = datetime(year, month_number, 1)
        end_date = datetime(year, month_number, num_days, 23, 59)
    if start_date is None or end_date is None:
        raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="month_number or start_date / end_date should be exists"
                )
    query = select(Users).filter(Users.status=='medical_representative')
    if med_rep_id:
        query = query.filter(Users.id == med_rep_id)
    if region_id:
        query = query.filter(Users.region_id == region_id)
    result = await db.execute(query)
    users = result.scalars().all()
    data = []
    for user in users:
        user_products = []
        query = f"SELECT user_product_plan.product_id, products.name, user_product_plan.med_rep_id, sum(user_product_plan.amount) AS sum_1, \
        sum(user_product_plan.amount * user_product_plan.price::NUMERIC) AS plan_price \
        FROM user_product_plan INNER JOIN products ON products.id = user_product_plan.product_id \
        WHERE user_product_plan.med_rep_id={user.id} AND user_product_plan.date>=TO_DATE(:start_date, 'YYYY-MM-DD') AND user_product_plan.date<=TO_DATE(:end_date, 'YYYY-MM-DD')"
        if product_id:
            query += f" AND user_product_plan.product_id={product_id}::INT"
        if manufactured_company_id:
            query += f" AND products.man_company_id={manufactured_company_id}::INT"
        query += " GROUP BY user_product_plan.product_id, user_product_plan.med_rep_id, products.id"
        query = text(query)
        result = await db.execute(query, {'start_date': str(start_date), 'end_date': str(end_date)})
        plan = result.all()
        for prod in plan:
            query = f"""SELECT sum(doctor_fact.fact) AS fact, sum(doctor_fact.fact * doctor_fact.price) FROM doctor_fact 
                    INNER JOIN doctor ON doctor.id = doctor_fact.doctor_id  
                    where doctor.med_rep_id={user.id} AND doctor_fact.product_id={prod[0]}
                    AND doctor_fact.date>=TO_DATE(:start_date, 'YYYY-MM-DD') AND doctor_fact.date<=TO_DATE(:end_date, 'YYYY-MM-DD')"""
            query = text(query)
            result = await db.execute(query, {'start_date': str(start_date), 'end_date': str(end_date)})
            fact = result.all()
            user_products.append({
                "product_id": prod[0],
                "product_name" : prod[1],
                "plan": prod[3],
                "plan_price": float(prod[4]) ,
                "fact": fact[0][0],
                "fact_price": fact[0][1] 
            })
        data.append({
            "id": user.id,
            "full_name":user.full_name,
            "username": user.username,
            "status": user.status,
            "plan": user_products
        })
    return data


@router.get('/get-profit')
async def get_profit(start_date: date, end_date: date, db: AsyncSession = Depends(get_db)): 
    query = text(f"SELECT sum(pharmacy_fact.quantity) AS fact, sum(pharmacy_fact.quantity * products.salary_expenses) AS salary_expense, sum(pharmacy_fact.quantity * products.marketing_expenses) AS marketing_expense, products.name, region.name FROM pharmacy_fact \
    INNER JOIN products on products.id = pharmacy_fact.product_id INNER JOIN pharmacy on pharmacy.id = pharmacy_fact.pharmacy_id INNER JOIN region on region.id = pharmacy.region_id WHERE pharmacy_fact.date>=TO_DATE(:start_date, 'YYYY-MM-DD') AND pharmacy_fact.date<=TO_DATE(:end_date, 'YYYY-MM-DD') \
     GROUP BY products.id, region.id")
    result = await db.execute(query, {'start_date': str(start_date), 'end_date': str(end_date)})
    facts = result.all()
    data = [{"fact":fact[0], "salary_expense":fact[1], "marketing_expense":fact[2], "product_name":fact[3], "region":fact[4]} for fact in facts]
    return data
