from datetime import datetime
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import text
from models.users import EditablePlanMonths, UserProductPlan, Users
from models.pharmacy import ReservationPayedAmounts
from models.warehouse import WholesaleReservationPayedAmounts
from models.hospital import HospitalReservationPayedAmounts
from sqlalchemy.future import select
from fastapi import HTTPException

async def get_hot_sale(doctor_id: int, product_id: int, start_date: datetime, end_date: datetime, db: AsyncSession):
    query = text(f"""SELECT sum(pharmacy_hot_sale.amount) FROM pharmacy_hot_sale INNER JOIN pharmacy ON pharmacy.id = pharmacy_hot_sale.pharmacy_id  
        where pharmacy.med_rep_id={doctor_id} AND pharmacy_hot_sale.product_id={product_id} 
        AND pharmacy_hot_sale.date>=TO_TIMESTAMP(:start_date, 'YYYY-MM-DD HH24:MI:SS') AND pharmacy_hot_sale.date<=TO_TIMESTAMP(:end_date, 'YYYY-MM-DD HH24:MI:SS')""")
    result = await db.execute(query, {'start_date': str(start_date), 'end_date': str(end_date)})
    h_sale = result.first()
    return h_sale[0] if h_sale[0] is not None else 0 

async def get_visit_facts(doctor_id: int, product_id: int, start_date: datetime, end_date: datetime, db: AsyncSession):
    query = text(f"""SELECT sum(doctor_fact.fact) FROM doctor_fact where doctor_fact.doctor_id={doctor_id} AND doctor_fact.product_id={product_id} 
        AND doctor_fact.date>=TO_TIMESTAMP(:start_date, 'YYYY-MM-DD HH24:MI:SS') AND doctor_fact.date<=TO_TIMESTAMP(:end_date, 'YYYY-MM-DD HH24:MI:SS')""")
    result = await db.execute(query, {'start_date': str(start_date), 'end_date': str(end_date)})
    fact = result.first()
    return fact[0] if fact[0] is not None else 0 

async def get_postupleniya_facts(doctor_id: int, product_id: int, start_date: datetime, end_date: datetime, db: AsyncSession):
    query = text(f"""SELECT sum(doctor_postupleniya_fact.fact), sum(doctor_postupleniya_fact.fact_price) FROM doctor_postupleniya_fact where doctor_postupleniya_fact.doctor_id={doctor_id} AND doctor_postupleniya_fact.product_id={product_id} 
        AND doctor_postupleniya_fact.date>=TO_TIMESTAMP(:start_date, 'YYYY-MM-DD HH24:MI:SS') AND doctor_postupleniya_fact.date<=TO_TIMESTAMP(:end_date, 'YYYY-MM-DD HH24:MI:SS')""")
    result = await db.execute(query, {'start_date': str(start_date), 'end_date': str(end_date)})
    fact = result.first()
    return (fact[0] if fact[0] is not None else 0, fact[1] if fact[1] is not None else 0)

async def check_if_plan_is_editable(plan: UserProductPlan, db: AsyncSession):
    plan_date = plan.plan_month
    result = await db.execute(select(EditablePlanMonths).filter(EditablePlanMonths.month==plan_date.month)) 
    if result.scalar().status == False:
        raise HTTPException(status_code=400, detail=f"You cannot edit plan in this month")
    return True

async def check_if_month_is_addable(month: int, db: AsyncSession):
    result = await db.execute(select(EditablePlanMonths).filter(EditablePlanMonths.month==month)) 
    if result.scalar().status == False:
        raise HTTPException(status_code=400, detail=f"You cannot edit plan in this month")
    return True

async def calculate_postupleniya(pm_id, model, start_date, end_date, db):
    table = model.__tablename__
    query = text(f"""SELECT sum({table}.quantity), sum({table}.amount), users.id, users.full_name, users.product_manager_id FROM {table} INNER JOIN doctor on doctor.id={table}.doctor_id 
        INNER JOIN users on users.id=doctor.med_rep_id WHERE users.product_manager_id={pm_id}
        AND {table}.date>=TO_TIMESTAMP(:start_date, 'YYYY-MM-DD HH24:MI:SS') AND {table}.date<=TO_TIMESTAMP(:end_date, 'YYYY-MM-DD HH24:MI:SS') GROUP BY users.id""")
    result = await db.execute(query, {'start_date': str(start_date), 'end_date': str(end_date)})
    data = result.all()
    return data


async def get_pm_sales(pm: Users, start_date: datetime, end_date: datetime, db: AsyncSession):
    ph_sales = await calculate_postupleniya(pm.id, ReservationPayedAmounts, start_date, end_date, db)
    wh_sales = await calculate_postupleniya(pm.id, WholesaleReservationPayedAmounts, start_date, end_date, db)
    h_sales = await calculate_postupleniya(pm.id, HospitalReservationPayedAmounts, start_date, end_date, db)

    updated_list = []
    pm_sale_quantity = 0
    pm_sale_sum = 0

    for item1 in ph_sales:
        first_val_sum = item1[0] or 0  # Handle possible None
        second_val_sum = item1[1]      # Sum the second index

        for item2 in wh_sales:
            if item1[2] == item2[2]:
                first_val_sum += item2[0] or 0  # Handle None in item2
                second_val_sum += item2[1]
                break

        for item3 in h_sales:
            if item1[2] == item3[2]:
                first_val_sum += item3[0] or 0  # Handle None in item3
                second_val_sum += item3[1]
                break

        updated_list.append({
            "product_quantity": first_val_sum,
            "postupleniya_sum": second_val_sum,
            "med_rep_id": item1[2],
            "med_rep_name": item1[3],
            "pm_id": item1[4]
            })
        pm_sale_quantity += first_val_sum
        pm_sale_sum += second_val_sum

    data = {
        "id": pm.id,
        "product_manager": pm.full_name,
        "total_quantity": pm_sale_quantity,
        "total_sum": pm_sale_sum,
        "med_reps": updated_list
    }

    return data 



