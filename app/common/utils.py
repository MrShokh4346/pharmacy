from datetime import datetime
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import text

async def get_hot_sale(med_rep_id: int, product_id: int, start_date: datetime, end_date: datetime, db: AsyncSession):
    query = text(f"""SELECT sum(pharmacy_hot_sale.amount) FROM pharmacy_hot_sale INNER JOIN pharmacy ON pharmacy.id = pharmacy_hot_sale.pharmacy_id  
        where pharmacy.med_rep_id={med_rep_id} AND pharmacy_hot_sale.product_id={product_id} 
        AND pharmacy_hot_sale.date>=TO_DATE(:start_date, 'YYYY-MM-DD') AND pharmacy_hot_sale.date<=TO_DATE(:end_date, 'YYYY-MM-DD')""")
    result = await db.execute(query, {'start_date': str(start_date), 'end_date': str(end_date)})
    h_sale = result.first()
    return h_sale[0] if h_sale[0] is not None else 0 

async def get_visit_facts(med_rep_id: int, product_id: int, start_date: datetime, end_date: datetime, db: AsyncSession):
    query = text(f"""SELECT sum(doctor_fact.fact) FROM doctor_fact INNER JOIN doctor ON doctor.id = doctor_fact.doctor_id  
        where doctor.med_rep_id={med_rep_id} AND doctor_fact.product_id={product_id} 
        AND doctor_fact.date>=TO_DATE(:start_date, 'YYYY-MM-DD') AND doctor_fact.date<=TO_DATE(:end_date, 'YYYY-MM-DD')""")
    result = await db.execute(query, {'start_date': str(start_date), 'end_date': str(end_date)})
    fact = result.first()
    return fact[0] if fact[0] is not None else 0 

async def get_postupleniya_facts(med_rep_id: int, product_id: int, start_date: datetime, end_date: datetime, db: AsyncSession):
    query = text(f"""SELECT sum(doctor_postupleniya_fact.fact) FROM doctor_postupleniya_fact INNER JOIN doctor ON doctor.id = doctor_postupleniya_fact.doctor_id  
        where doctor.med_rep_id={med_rep_id} AND doctor_postupleniya_fact.product_id={product_id} 
        AND doctor_postupleniya_fact.date>=TO_DATE(:start_date, 'YYYY-MM-DD') AND doctor_postupleniya_fact.date<=TO_DATE(:end_date, 'YYYY-MM-DD')""")
    result = await db.execute(query, {'start_date': str(start_date), 'end_date': str(end_date)})
    fact = result.first()
    return fact[0] if fact[0] is not None else 0 
