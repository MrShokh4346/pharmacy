import calendar
from datetime import datetime
from app.models.database import get_or_404
from app.models.doctors import DoctorMonthlyPlan
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from app.models.users import Product


class DoctorFactService:
    @staticmethod
    async def set_fact(db: AsyncSession, **kwargs):
        year = datetime.now().year
        month = kwargs['visit_date'].month 
        num_days = calendar.monthrange(year, month)[1]
        start_date = datetime(year, month, 1)  
        end_date = datetime(year, month, num_days, 23, 59)
        product = await get_or_404(Product, kwargs['product_id'], db)
        result = await db.execute(select(DoctorMonthlyPlan).filter(DoctorMonthlyPlan.doctor_id==kwargs['doctor_id'], DoctorMonthlyPlan.pharmacy_id==kwargs['pharmacy_id'], DoctorMonthlyPlan.product_id==kwargs['product_id'], DoctorMonthlyPlan.date>=start_date, DoctorMonthlyPlan.date<=end_date))
        month_fact = result.scalars().first()
        if month_fact is None:
            month_fact = DoctorMonthlyPlan(date=kwargs['visit_date'], doctor_id=kwargs['doctor_id'], pharmacy_id=kwargs['pharmacy_id'], product_id=kwargs['product_id'], fact=kwargs['compleated'], price=product.price, discount_price=product.discount_price)
            db.add(month_fact)
        else:
            month_fact.fact += kwargs['compleated']

    @staticmethod
    async def set_fact_to_hospital(cls, db: AsyncSession, **kwargs):
        year = datetime.now().year
        month = kwargs['month_number'] 
        num_days = calendar.monthrange(year, month)[1]
        start_date = datetime(year, month, 1)  
        end_date = datetime(year, month, num_days, 23, 59)
        product = await get_or_404(Product, kwargs['product_id'], db)
        result = await db.execute(select(cls).filter(cls.doctor_id==kwargs['doctor_id'],  cls.product_id==kwargs['product_id'], cls.date>=start_date, cls.date<=end_date))
        month_fact = result.scalars().first()
        if month_fact is None:
            month_fact = cls(date=start_date, doctor_id=kwargs['doctor_id'], product_id=kwargs['product_id'], fact=kwargs['compleated'], price=product.price, discount_price=product.discount_price)
            db.add(month_fact)
        else:
            month_fact.fact += kwargs['compleated']
        # await Bonus.set_bonus(**kwargs, db=db)

