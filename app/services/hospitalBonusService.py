from app.models.database import get_or_404
from app.models.hospital import HospitalBonus
from sqlalchemy.ext.asyncio import AsyncSession
from app.models.users import Product


class HospitalBonusService:
    
    @staticmethod
    async def set_bonus(cls, db: AsyncSession, **kwargs):
        product = await get_or_404(Product, kwargs['product_id'], db)
        month_bonus = HospitalBonus(hospital_id=kwargs['hospital_id'], product_id=kwargs['product_id'], product_quantity=kwargs['product_quantity'], amount=kwargs['bonus_sum'])
        db.add(month_bonus)