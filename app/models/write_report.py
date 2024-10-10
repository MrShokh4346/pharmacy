import xlsxwriter
from fastapi.responses import FileResponse
from sqlalchemy.future import select
from sqlalchemy.orm import selectinload
import calendar
from datetime import datetime, timedelta, timezone, date
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import func 
from jose import JWTError, jwt
from dotenv.main import load_dotenv
from fastapi import Request, Depends, HTTPException
from .users import Users, Products, Region, UserProductPlan, ManufacturedCompany, Products
from .doctors import DoctorCategory, Speciality, MedicalOrganization, Doctor, DoctorMonthlyPlan, DoctorFact
from .pharmacy import Reservation
from .hospital import HospitalReservation
from .warehouse import WholesaleReservation
from typing import Annotated
from .database import get_db
from fastapi.security import HTTPBearer
from openpyxl import Workbook, load_workbook
import shutil
from sqlalchemy import text 
import os 


class Excel:
    product_manager = 1
    medical_representative = 2
    doctor = 3
    doctor_contact = 4
    speciality = 5
    medical_organization = 6
    region = 7
    # number = 8
    category = 8
    # pharmacy = 10
    # pharmacy_contact = 11
    # wholesale = 12
    plan_product_template = []
    plan_products = {}
    sum_plan: 0 
    fact_product_template = []
    fact_products = {}
    sum_fact: 0 
    done_persent: 0
    count: 0
    start_row = 7
    doctor_count = 1
    manufacturer_colors = ['#61E143', '#7D94DF', '#FDEF3D', '#FEBD3C', '#3BFFC2']

    # {
    #     {'zavod': 'some',
    #     'products': [1,2,4]}
    # }

    def __init__(self, products: list) -> None:
        count = 9
        for zavod in products:
            tmp = {'start_marge': 0, 'end_marge': 0, 'products': {}}
            tmp['start_marge'] = count
            tmp['end_marge'] = count + len(zavod['products']) - 1 
            tmp['color'] = self.manufacturer_colors[products.index(zavod)]
            for product in zavod['products']:
                tmp['name'] =  zavod['zavod']
                tmp['products'][product['id']] = count
                self.plan_products[product['id']] = count
                count += 1
            self.plan_product_template.append(tmp)
        self.sum_plan = count
        count += 1
        for zavod in products:
            tmp = {'start_marge': 0, 'end_marge': 0, 'products': {}}
            tmp['start_marge'] = count
            tmp['end_marge'] = count + len(zavod['products']) - 1 
            tmp['color'] = self.manufacturer_colors[products.index(zavod)]
            for product in zavod['products']:
                tmp['name'] =  zavod['zavod']
                tmp['products'][product['id']] = count
                self.fact_products[product['id']] = count
                count += 1
            self.fact_product_template.append(tmp)
        self.sum_fact = count
        self.done_persent = count


def get_format(workbook, color='white', rotation=0):
    format = workbook.add_format(
        {
            "bold": 1,
            "border": 1,
            "align": "center",
            "valign": "vcenter",
            'rotation': rotation,
            "fg_color": color,
        }
    )
    return format


async def begining_template(excel, workbook, worksheet):

    column_format = get_format(workbook)

    merge_format =  get_format(workbook, '#4F95E3')
    pm_merge_format =  get_format(workbook, '#4F95E3', 90)

    worksheet.set_column(excel.product_manager, excel.product_manager, 5, column_format)
    worksheet.merge_range(excel.start_row - 4, excel.product_manager, excel.start_row - 1, excel.product_manager, "Продукт Менеджер", pm_merge_format)
    
    worksheet.set_column(excel.medical_representative, excel.medical_representative, 25, column_format)
    worksheet.merge_range(excel.start_row - 4, excel.medical_representative, excel.start_row - 1, excel.medical_representative, "РМ/МП", merge_format)
    
    worksheet.set_column(excel.doctor, excel.doctor, 25, column_format)
    worksheet.merge_range(excel.start_row - 4, excel.doctor, excel.start_row - 1, excel.doctor, "ФИО Врача", merge_format)
    
    worksheet.set_column(excel.doctor_contact, excel.doctor_contact, 20, column_format)
    worksheet.merge_range(excel.start_row - 4, excel.doctor_contact, excel.start_row - 1, excel.doctor_contact, "Контакт врача", merge_format)
    
    worksheet.set_column(excel.speciality, excel.speciality, 20, column_format)
    worksheet.merge_range(excel.start_row - 4, excel.speciality, excel.start_row - 1, excel.speciality, "Специальность", merge_format)

    worksheet.set_column(excel.medical_organization, excel.medical_organization, 25, column_format)
    worksheet.merge_range(excel.start_row - 4, excel.medical_organization, excel.start_row - 1, excel.medical_organization, "ЛПУ", merge_format)
    
    worksheet.set_column(excel.region, excel.region, 25, column_format)
    worksheet.merge_range(excel.start_row - 4, excel.region, excel.start_row - 1, excel.region, "Регион", merge_format)
    
    worksheet.set_column(excel.doctor, excel.doctor, 10, column_format)
    worksheet.merge_range(excel.start_row - 4, excel.category, excel.start_row - 2, excel.category, "Категория врача", merge_format)
    worksheet.write(excel.start_row - 1, excel.category, "(VIP, A, B)", merge_format)
    

async def get_product_name_and_price(id, product_list):
    product = [prd for prd in product_list if prd['id'] == id]
    return product[0]['name'], product[0]['price'] 


async def plan_products_template(excel, workbook, worksheet, products_list):

    merge_format = get_format(workbook, 'gray')
    column_format = get_format(workbook)
    
    for zavod in excel.plan_product_template:
        manufacturer_format = get_format(workbook, zavod['color'])
        product_format = get_format(workbook, zavod['color'], 90)
        worksheet.merge_range(excel.start_row - 4, zavod['start_marge'], excel.start_row - 4, zavod['end_marge'], zavod['name'], manufacturer_format)
        for key, value in zavod['products'].items():
            product_name, product_price = await get_product_name_and_price(key, products_list)
            worksheet.set_column(value, value, 3, column_format)
            worksheet.write(excel.start_row - 3, value, product_name, product_format)
            worksheet.write(excel.start_row - 2, value, product_price, product_format)

    worksheet.merge_range(excel.start_row - 4, excel.sum_plan, excel.start_row - 1, excel.sum_plan, "СУММА", merge_format)
    worksheet.merge_range(excel.start_row - 1, excel.category + 1, excel.start_row - 1, excel.sum_plan - 1, f"План продаж", merge_format)


async def fact_products_template(excel, workbook, worksheet, products_list):

    merge_format = get_format(workbook, 'gray')
    column_format = get_format(workbook)


    for zavod in excel.fact_product_template:
        manufacturer_format = get_format(workbook, zavod['color'])
        product_format = get_format(workbook, zavod['color'], 90)
        worksheet.merge_range(excel.start_row - 4, zavod['start_marge'], excel.start_row - 4, zavod['end_marge'], zavod['name'], manufacturer_format)
        for key, value in zavod['products'].items():
            product_name, product_price = await get_product_name_and_price(key, products_list)
            worksheet.set_column(value, value, 3, column_format)
            worksheet.write(excel.start_row - 3, value, product_name, product_format)
            worksheet.write(excel.start_row - 2, value, product_price, product_format)

    worksheet.merge_range(excel.start_row - 4, excel.sum_fact, excel.start_row - 1, excel.sum_fact, "СУММА", merge_format)
    worksheet.merge_range(excel.start_row - 1, excel.sum_plan + 1, excel.start_row - 1, excel.sum_fact - 1, f"Фактическая реализация", merge_format)


async def write_doctors(row, user, excel, format, worksheet, start_date, end_date, db):
    doctor_fact_products = {}
    med_rep_total_paln_sum = 0
    med_rep_total_fact_sum = 0
    result = await db.execute(select(Doctor).filter(Doctor.med_rep_id == user.id))
    for doctor in result.scalars().all():
        worksheet.write(row, excel.doctor, doctor.full_name, format)
        worksheet.write(row, excel.doctor_contact, doctor.contact1, format)
        worksheet.write(row, excel.speciality, doctor.speciality.name, format)
        worksheet.write(row, excel.medical_organization, doctor.medical_organization.name, format)
        worksheet.write(row, excel.region, doctor.medical_organization.region.name, format)
        worksheet.write(row, excel.category, doctor.category.name, format)

        result = await db.execute(select(DoctorMonthlyPlan).filter(DoctorMonthlyPlan.doctor_id == doctor.id, DoctorMonthlyPlan.date>=start_date, DoctorMonthlyPlan.date<=end_date))
        doctor_total_paln_sum = 0
        for product_plan in result.scalars().all():
            if excel.plan_products.get(product_plan.product_id):
                worksheet.write(row, excel.plan_products[product_plan.product_id], product_plan.monthly_plan, format)

                # planni minimal 5 % skidka va nds biln hisoblaydi
                plan_sum = product_plan.monthly_plan * product_plan.price * 1.12 * 0.95 
                doctor_total_paln_sum += plan_sum
        med_rep_total_paln_sum += doctor_total_paln_sum
        worksheet.write(row, excel.sum_plan, doctor_total_paln_sum, format)

        query = f'select sum(fact) as fact, product_id, price from doctor_fact where doctor_id={doctor.id} group by doctor_id, product_id, price;'
        result = await db.execute(text(query))

        doctor_total_fact_sum = 0
        for fact in result.all():

            if excel.fact_products.get(fact.product_id):

                worksheet.write(row, excel.fact_products[fact.product_id], fact.fact, format)

                # planni minimal 5 % skidka va nds biln hisoblaydi
                fact_sum = fact.fact * fact.price * 1.12 * 0.95
                doctor_total_fact_sum += fact_sum
                if doctor_fact_products.get(fact.product_id) is not None:
                    doctor_fact_products[fact.product_id] += fact.fact
                else:
                    doctor_fact_products[fact.product_id] = fact.fact
        med_rep_total_fact_sum += doctor_total_fact_sum
        worksheet.write(row, excel.sum_fact, doctor_total_fact_sum, format)
        row += 1
    doctor_fact_products['med_rep_total_paln_sum'] = med_rep_total_paln_sum
    doctor_fact_products['med_rep_total_fact_sum'] = med_rep_total_fact_sum
    return doctor_fact_products, row - 1


async def write_med_rep(row, user, excel, format, worksheet, start_date, end_date, db):
    result = await db.execute(select(UserProductPlan).filter(UserProductPlan.med_rep_id==user.id, UserProductPlan.plan_month>=start_date, UserProductPlan.plan_month<=end_date))

    worksheet.write(row, excel.medical_representative, user.full_name, format)
    worksheet.write(row, excel.region, user.region.name, format)

    for product_plan in result.scalars().all():
        if excel.plan_products.get(product_plan.product_id):
            worksheet.write(row, excel.plan_products[product_plan.product_id], product_plan.amount, format)
    row += 1
    user_fact, end_row = await write_doctors(row, user, excel, format, worksheet, start_date, end_date, db)

    for key, value in user_fact.items():
        if excel.fact_products.get(key):
            worksheet.write(row - 1, excel.fact_products[key], value, format)
    worksheet.write(row - 1, excel.sum_plan, user_fact['med_rep_total_paln_sum'], format)
    worksheet.write(row - 1, excel.sum_fact, user_fact['med_rep_total_fact_sum'], format)

    # print(user.full_name, ': ', row, end_row)

    return end_row



async def write_product_manager(row, pm, excel, format, workbook, worksheet, start_date, end_date, db):
    pm_format = get_format(workbook, 'white', 90)
    merge_row = row
    end_row = None

    result = await db.execute(select(Users).options(selectinload(Users.region)).filter(Users.status=="medical_representative", Users.product_manager_id==pm.id))
    for user in result.scalars().all():

        end_row = await write_med_rep(row, user, excel, format, worksheet, start_date, end_date, db)
        row = end_row + 1

    if end_row is None:
        end_row = row

    worksheet.merge_range(merge_row, excel.product_manager, end_row, excel.product_manager, pm.full_name, pm_format)
    # print('\t', pm.full_name, ": ", merge_row, end_row)
    return end_row



async def write_proccess_to_excel(excel, workbook, worksheet, month, db):
    year = datetime.now().year
    month = datetime.now().month if month is None else month
    num_days = calendar.monthrange(year, month)[1]
    start_date = datetime(year, month, 1)  
    end_date = datetime(year, month, num_days, 23, 59)

    format = get_format(workbook, 'white')
    row = excel.start_row

    result = await db.execute(select(Users).options(selectinload(Users.region)).filter(Users.status=="product_manager"))
    med_rep_start_row = excel.start_row
    for pm in result.scalars().all():
        
        end_row = await write_product_manager(row, pm, excel, format, workbook, worksheet, start_date, end_date, db)
        row = end_row + 1
    


async def products(db: AsyncSession):
    zavodlar = await db.execute(select(ManufacturedCompany))
    PRODUCTS = []
    FACTORIES = []
    for zavod in zavodlar.scalars().all():
        result = await db.execute(select(Products).filter(Products.man_company_id==zavod.id))
        objects = result.scalars().all()
        prs = lambda objects: [{'id': c.id, 'name': c.name, 'price': c.price} for c in objects]
        prs = prs(objects)
        if len(prs) > 0:
            PRODUCTS.extend(prs)
            FACTORIES.append({
                    'zavod': zavod.name,
                    'products': prs
                })
    return FACTORIES, PRODUCTS


async def write_to_excel(month: int, db: AsyncSession):

    z, p = await products(db)
    excel = Excel(z)
    date = datetime.now()

    source_excel_file = f"app/report/Report_{date.strftime('%Y-%m-%d %H:%M')}.xlsx"
    filename = 'Report.xlsx'

    if os.path.exists(source_excel_file):
        os.remove(source_excel_file)

    workbook = xlsxwriter.Workbook(source_excel_file)
    worksheet = workbook.add_worksheet()

    await begining_template(excel, workbook, worksheet)
    await plan_products_template(excel, workbook, worksheet, p)
    await fact_products_template(excel, workbook, worksheet, p)
    await write_proccess_to_excel(excel, workbook, worksheet, month, db)

    workbook.close()


    return FileResponse(filename=filename, path=source_excel_file)
