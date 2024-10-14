from datetime import datetime
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import text
from models.users import EditablePlanMonths, UserProductPlan, Users
from models.pharmacy import ReservationPayedAmounts
from models.warehouse import WholesaleReservationPayedAmounts
from models.hospital import HospitalReservationPayedAmounts
from sqlalchemy.future import select
from fastapi import HTTPException
from collections import defaultdict


async def get_hot_sale(doctor_id: int, product_id: int, start_date: datetime, end_date: datetime, db: AsyncSession):
    query = text(f"""SELECT sum(pharmacy_hot_sale.amount) FROM pharmacy_hot_sale INNER JOIN pharmacy ON pharmacy.id = pharmacy_hot_sale.pharmacy_id  
        where pharmacy.med_rep_id={doctor_id} AND pharmacy_hot_sale.product_id={product_id} 
        AND pharmacy_hot_sale.date>=TO_TIMESTAMP(:start_date, 'YYYY-MM-DD HH24:MI:SS') AND pharmacy_hot_sale.date<=TO_TIMESTAMP(:end_date, 'YYYY-MM-DD HH24:MI:SS')""")
    result = await db.execute(query, {'start_date': str(start_date), 'end_date': str(end_date)})
    h_sale = result.first()
    return h_sale[0] if h_sale[0] is  not None else 0 

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
    table = model.__tablename__         #0                  #1              #2          #3                  #4                          #5                  #6                      #7                      #8                      #9                                      
    query = text(f"""SELECT sum({table}.quantity), sum({table}.amount), users.id, users.full_name, users.product_manager_id, sum({table}.nds_sum), sum({table}.fot_sum), sum({table}.promo_sum), sum({table}.skidka_sum), sum({table}.pure_proceeds) FROM {table} INNER JOIN doctor on doctor.id={table}.doctor_id 
        INNER JOIN users on users.id=doctor.med_rep_id WHERE users.product_manager_id={pm_id}
        AND {table}.date>=TO_TIMESTAMP(:start_date, 'YYYY-MM-DD HH24:MI:SS') AND {table}.date<=TO_TIMESTAMP(:end_date, 'YYYY-MM-DD HH24:MI:SS') GROUP BY users.id""")
    result = await db.execute(query, {'start_date': str(start_date), 'end_date': str(end_date)})
    data = result.all()
    return data


def merge_data(data_list, combined_data):
    quantities = 0
    amounts = 0 
    for tup in data_list:
        key = tup[2]  # Using name as the key
        quantities += tup[0] if tup[0] is not None else 0
        amounts += tup[1] 
        combined_data[key][0] += tup[0] if tup[0] is not None else 0
        combined_data[key][1] += tup[1]
        combined_data[key][2] = tup[2]  # Assuming we take the last occurrence of this value
        combined_data[key][3] = tup[3]
        combined_data[key][4] = tup[4] 
        combined_data[key][5] += tup[5] 
        combined_data[key][6] += tup[6] 
        combined_data[key][7] += tup[7] 
        combined_data[key][8] += tup[8] 
        combined_data[key][9] += tup[9] 
    return combined_data



async def get_pm_sales(pm: Users, start_date: datetime, end_date: datetime, db: AsyncSession):
    ph_sales = await calculate_postupleniya(pm.id, ReservationPayedAmounts, start_date, end_date, db)
    wh_sales = await calculate_postupleniya(pm.id, WholesaleReservationPayedAmounts, start_date, end_date, db)
    h_sales = await calculate_postupleniya(pm.id, HospitalReservationPayedAmounts, start_date, end_date, db)

    pm_sale_quantity = 0
    pm_sale_sum = 0
    nds_sum = 0
    fot_sum = 0
    promo_sum = 0
    skidka_sum = 0
    pure_proceeds = 0

    combined_data = defaultdict(lambda: [0, 0, 0, '', 0, 0, 0, 0, 0, 0])

    # Merge all the lists
    combined_data = merge_data(ph_sales, combined_data)
    combined_data = merge_data(wh_sales, combined_data)
    combined_data = merge_data(h_sales, combined_data)

    updated_list = []

    for value in combined_data.values():
        updated_list.append({
            "product_quantity": value[0],
            "postupleniya_sum": value[1],
            "med_rep_id": value[2],
            "med_rep_name": value[3],
            "pm_id": value[4]
            })
        pm_sale_quantity += value[0]
        pm_sale_sum += value[1]
        nds_sum += value[5]
        fot_sum += value[6]
        promo_sum += value[7]
        skidka_sum += value[8]
        pure_proceeds += value[9]

    data = {
        "id": pm.id,
        "product_manager": pm.full_name,
        "total_quantity": pm_sale_quantity,
        "total_sum": pm_sale_sum,
        "med_reps": updated_list
    }

    return data, (pm_sale_sum, nds_sum, fot_sum, promo_sum, skidka_sum, pure_proceeds) 



