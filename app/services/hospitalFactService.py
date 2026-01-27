import calendar
from datetime import datetime
from app.models.database import get_or_404
from app.models.hospital import HospitalBonus
from sqlalchemy.ext.asyncio import AsyncSession
from app.models.users import Product
from sqlalchemy.future import select


class HospitalBonusService:
    
    @staticmethod
    async def set_fact(db: AsyncSession, **kwargs):
        year = datetime.now().year
        month = datetime.now().month  
        num_days = calendar.monthrange(year, month)[1]
        start_date = datetime(year, month, 1)  
        end_date = datetime(year, month, num_days, 23, 59)
        product = await get_or_404(Product, kwargs['product_id'], db)
        result = await db.execute(select(HospitalBonus).filter(HospitalBonus.hospital_id==kwargs['hospital_id'], HospitalBonus.product_id==kwargs['product_id'], HospitalBonus.date>=start_date, HospitalBonus.date<=end_date))
        month_fact = result.scalars().first()
        if month_fact is None:
            month_fact = HospitalBonus(hospital_id=kwargs['hospital_id'], product_id=kwargs['product_id'], fact=kwargs['product_quantity'], price=product.price, discount_price=product.discount_price)
            db.add(month_fact)
        else:
            month_fact.fact += kwargs['product_quantity']
