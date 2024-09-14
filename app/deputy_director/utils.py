from datetime import datetime
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import text
from models.users import EditablePlanMonths, UserProductPlan
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
    print(query)
    result = await db.execute(query, {'start_date': str(start_date), 'end_date': str(end_date)})
    fact = result.first()
    return fact[0] if fact[0] is not None else 0 

async def get_postupleniya_facts(doctor_id: int, product_id: int, start_date: datetime, end_date: datetime, db: AsyncSession):
    query = text(f"""SELECT sum(doctor_postupleniya_fact.fact), sum(doctor_postupleniya_fact.fact_price) FROM doctor_postupleniya_fact where doctor_postupleniya_fact.doctor_id={doctor_id} AND doctor_postupleniya_fact.product_id={product_id} 
        AND doctor_postupleniya_fact.date>=TO_TIMESTAMP(:start_date, 'YYYY-MM-DD HH24:MI:SS') AND doctor_postupleniya_fact.date<=TO_TIMESTAMP(:end_date, 'YYYY-MM-DD HH24:MI:SS')""")
    result = await db.execute(query, {'start_date': str(start_date), 'end_date': str(end_date)})
    fact = result.first()
    # print(f"Filter postupleniya: doctor_id: {doctor_id}, soni: {fact[0] if fact[0] is not None else 0}")
    return (fact[0] if fact[0] is not None else 0, fact[1] if fact[1] is not None else 0)

async def check_if_plan_is_editable(plan: UserProductPlan, db: AsyncSession):
    plan_date = plan.plan_month
    result = await db.execute(select(EditablePlanMonths).filter(EditablePlanMonths.month==plan_date.month)) 
    if result.scalar().status == False:
        raise HTTPException(status_code=400, detail=f"You can not edit plan in this month")
    return True
