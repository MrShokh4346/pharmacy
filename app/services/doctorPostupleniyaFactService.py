import calendar
from datetime import datetime
from app.models.database import get_or_404
from app.models.doctors import DoctorPostupleniyaFact
from fastapi import HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from app.models.users import Product


class DoctorPostupleniyaFactService:
    @staticmethod
    async def set_fact(db: AsyncSession, **kwargs):
        year = datetime.now().year
        # month = datetime.now().month  
        num_days = calendar.monthrange(year, kwargs['month_number'])[1]
        start_date = datetime(year, kwargs['month_number'], 1)  
        end_date = datetime(year, kwargs['month_number'], num_days, 23, 59)
        product = await get_or_404(Product, kwargs['product_id'], db)
        result = await db.execute(select(DoctorPostupleniyaFact).filter(DoctorPostupleniyaFact.doctor_id==kwargs['doctor_id'], DoctorPostupleniyaFact.product_id==kwargs['product_id'], DoctorPostupleniyaFact.date>=start_date, DoctorPostupleniyaFact.date<=end_date))
        doctor_postupleniya = result.scalars().first()
        if doctor_postupleniya is None:
            doctor_postupleniya = DoctorPostupleniyaFact(date=start_date, fact_price=kwargs['fact_price'], doctor_id=kwargs['doctor_id'], product_id=kwargs['product_id'], fact=kwargs['compleated'], price=kwargs['price'])
            db.add(doctor_postupleniya)
        else:
            doctor_postupleniya.fact += kwargs['compleated']
            doctor_postupleniya.fact_price += kwargs['fact_price']


    @staticmethod
    async def delete_postupleniya(db: AsyncSession, **kwargs):
        year = datetime.now().year
        num_days = calendar.monthrange(year, kwargs['month_number'])[1]
        start_date = datetime(year, kwargs['month_number'], 1)  
        end_date = datetime(year, kwargs['month_number'], num_days, 23, 59)
        result = await db.execute(select(DoctorPostupleniyaFact).filter(DoctorPostupleniyaFact.doctor_id==kwargs['doctor_id'], DoctorPostupleniyaFact.product_id==kwargs['product_id'], DoctorPostupleniyaFact.date>=start_date, DoctorPostupleniyaFact.date<=end_date))
        doctor_postupleniya = result.scalars().first()
        if doctor_postupleniya is None:
            raise HTTPException(status_code=404, detail=f"Doctor postupleniya not found (doctor_id={kwargs['doctor_id']}), (product_id={kwargs['product_id']})")
        elif doctor_postupleniya.fact < kwargs['quantity']:
            raise HTTPException(status_code=404, detail=f"There is not enough amount fact in doctor postupleniya (doctor_id={kwargs['doctor_id']}), (product_id={kwargs['product_id']}), (doctor_postupleniya={doctor_postupleniya.fact}), (postupleniya={kwargs['quantity']})")
        else:
            doctor_postupleniya.fact -= kwargs['quantity']
            doctor_postupleniya.fact_price -= kwargs['amount']
