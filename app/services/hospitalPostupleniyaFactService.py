import calendar
from datetime import datetime
from app.models.database import get_or_404
from sqlalchemy.ext.asyncio import AsyncSession
from app.models.users import Product
from sqlalchemy.future import select


class HospitalPostupleniyaFactService:
    
    @staticmethod
    async def set_fact(cls, db: AsyncSession, **kwargs):
        year = datetime.now().year
        num_days = calendar.monthrange(year, kwargs['month_number'])[1]
        start_date = datetime(year, kwargs['month_number'], 1)  
        end_date = datetime(year, kwargs['month_number'], num_days, 23, 59)
        product = await get_or_404(Product, kwargs['product_id'], db)
        result = await db.execute(select(cls).filter(cls.hospital_id==kwargs['hospital_id'], cls.product_id==kwargs['product_id'], cls.date>=start_date, cls.date<=end_date))
        month_fact = result.scalars().first()
        if month_fact is None:
            month_fact = cls(fact_price = kwargs['fact_price'], hospital_id=kwargs['hospital_id'], product_id=kwargs['product_id'], fact=kwargs['compleated'], price=product.price, discount_price=product.discount_price)
            db.add(month_fact)
        else:
            month_fact.fact += kwargs['compleated']
            month_fact.fact_price += kwargs['fact_price']
