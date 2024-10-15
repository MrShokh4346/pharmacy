from datetime import datetime
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import text
from models.users import EditablePlanMonths, UserProductPlan, Users
from models.pharmacy import ReservationPayedAmounts, Reservation
from models.warehouse import WholesaleReservationPayedAmounts, WholesaleReservation
from models.hospital import HospitalReservationPayedAmounts, HospitalReservation
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


async def calculate_postupleniya(pm_id, model, start_date, end_date, db, med_rep_id=None, region_id=None):
    table = model.__tablename__                                                
    query = f"""SELECT sum({table}.total_payable_with_nds), users.id, users.full_name, users.product_manager_id FROM {table} 
        INNER JOIN users on users.id={table}.med_rep_id  WHERE users.product_manager_id={pm_id}"""
    if med_rep_id:
        query += f" AND users.id={med_rep_id}"
    if region_id:
        query += f" AND users.region_id ={region_id}"

    query += f""" AND {table}.date>=TO_TIMESTAMP(:start_date, 'YYYY-MM-DD HH24:MI:SS') AND {table}.date<=TO_TIMESTAMP(:end_date, 'YYYY-MM-DD HH24:MI:SS') GROUP BY users.id"""
    query = text(query)
    result = await db.execute(query, {'start_date': str(start_date), 'end_date': str(end_date)})
    data = result.all()
    return data


def merge_data(data_list, combined_data):
    for tup in data_list:
        key = tup[1]  
        combined_data[key][0] += tup[0]
        combined_data[key][1] = tup[1]
        combined_data[key][2] = tup[2]  
        combined_data[key][3] = tup[3]
    return combined_data


async def get_pm_sales(pm: Users, start_date: datetime, end_date: datetime, db: AsyncSession):
    ph_sales = await calculate_postupleniya(pm.id, Reservation, start_date, end_date, db)
    wh_sales = await calculate_postupleniya(pm.id, WholesaleReservation, start_date, end_date, db)
    h_sales = await calculate_postupleniya(pm.id, HospitalReservation, start_date, end_date, db)

    combined_data = defaultdict(lambda: [0, 0, '', 0])

    combined_data = merge_data(ph_sales, combined_data)
    combined_data = merge_data(wh_sales, combined_data)
    combined_data = merge_data(h_sales, combined_data)

    updated_list = []
    amount = 0

    for value in combined_data.values():
        updated_list.append({
            "sum": value[0],
            "med_rep_id": value[1],
            "med_rep_name": value[2]
            })
        amount += value[0]

    data = {
        "id": pm.id,
        "product_manager": pm.full_name,
        "total_sum": amount,
        "med_reps": updated_list
    }

    return data 


async def get_sum_reservations(
            start_date,
            end_date,
            db,
            med_rep_id=None,
            product_manager_id=None,
            pharmacy_id=None,
            hospital_id=None,
            wholesale_id=None,
            region_id=None,
            man_company_id=None
            ):
  
    tables = [Reservation, WholesaleReservation, HospitalReservation]

    data = {
        "umumiy_savdo": 0,
        "tushum": 0,
        "qarz": 0,
        "nds_summa": 0,
        "skidka": 0,
        "zavod_narxi": 0,
        "fot_sum": 0,
        "promo_sum": 0
    }

    for table in tables: 
        subquery = "" 
        if pharmacy_id:
            if not getattr(table, 'pharmacy_id', False):
                continue
            subquery += f" r.pharmacy_id = {pharmacy_id} AND"
        if hospital_id:
            if not getattr(table, 'hospital_id', False):
                continue
            subquery += f" r.hospital_id = {hospital_id} AND"
        if wholesale_id:
            if not getattr(table, 'wholesale_id', False):
                continue
            subquery += f" r.wholesale_id = {wholesale_id} AND"
        if med_rep_id:
            subquery += f" r.med_rep_id = {med_rep_id} AND"
        if region_id:
            subquery += f" u.region_id = {region_id} AND"
        if man_company_id:
            subquery += f" r.manufactured_company_id = {man_company_id} AND"
        if product_manager_id:
            subquery += f" u.product_manager_id = {product_manager_id} AND"

        query = f"""
            SELECT 
                SUM(r.total_payable_with_nds) AS umumiy_savdo,  
                SUM(r.profit) AS tushum,                        
                SUM(r.debt) AS qarz,                           
                SUM(r.total_payable_with_nds - r.total_payable) AS nds_summa, 
                SUM(r.total_amount - r.total_payable) AS skidka,             
                SUM(r.total_amount) AS zavod_narxi,       
                SUM(rp.quantity * p.salary_expenses) AS fot_sum,      
                SUM(rp.quantity * p.marketing_expenses) AS promo_sum   
            FROM 
                {table.__tablename__} r
            JOIN 
                {table.__tablename__}_products rp ON r.id = rp.reservation_id
            JOIN 
                products p ON rp.product_id = p.id
            JOIN 
                users u ON r.med_rep_id = u.id
            WHERE
                {subquery}
                r.date>=TO_TIMESTAMP(:start_date, 'YYYY-MM-DD HH24:MI:SS') AND r.date<=TO_TIMESTAMP(:end_date, 'YYYY-MM-DD HH24:MI:SS')
            GROUP BY 
                r.id;
        """
        query = text(query)
        result = await db.execute(query, {'start_date': str(start_date), 'end_date': str(end_date)})
        res = result.first()
        if res:
            data["umumiy_savdo"] += res[0]
            data["tushum"] += res[1]
            data["qarz"] += res[2]
            data["nds_summa"] += res[3]
            data["skidka"] += res[4]
            data["zavod_narxi"] += res[5]
            data["fot_sum"] += res[6]
            data["promo_sum"] += res[7]
    return data 


async def get_sale_by_doctor(db, doctor_id=None, product_id=None):
    tables = [ReservationpayedAmounts, WholesaleReservationpayedAmounts, HospitalReservationpayedAmounts]

    for table in tables: 
        subquery = "" 
        if doctor_id:
            subquery += f" rp.doctor_id = {doctor_id} AND"
        if product_id:
            subquery += f" rp.product_id = {product_id} AND"

        query = f"""
            SELECT 
                SUM(rp.amount) AS amount,  
                SUM(rp.nds_summa) AS nds_summa, 
                SUM(rp.skidka_sum) AS skidka,             
                SUM(rp.pure_proceeds) AS zavod_narxi,       
                SUM(rp.fot_sum) AS fot_sum,      
                SUM(rp.promo_sum) AS promo_sum   
            FROM 
                {table.__tablename__} rp
            JOIN 
                {table.__tablename__[:-14]} r ON r.id = rp.reservation_id
            JOIN 
                products p ON rp.product_id = p.id
            JOIN 
                users u ON r.med_rep_id = u.id
            WHERE
                {subquery}
                r.date>=TO_TIMESTAMP(:start_date, 'YYYY-MM-DD HH24:MI:SS') AND r.date<=TO_TIMESTAMP(:end_date, 'YYYY-MM-DD HH24:MI:SS')
            GROUP BY 
                r.id;
        """
        query = text(query)
        result = await db.execute(query, {'start_date': str(start_date), 'end_date': str(end_date)})
        res = result.first()
