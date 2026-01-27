from app.models.database import get_or_404
from app.models.users import Product, UserProductPlan
from sqlalchemy.exc import IntegrityError
from fastapi import HTTPException
from sqlalchemy.ext.asyncio import AsyncSession


class UserProductPlanService:

    @staticmethod
    async def save(plan: UserProductPlan, db: AsyncSession):
        try:
            product = await get_or_404(Product, plan.product_id, db)
            plan.price = product.price
            plan.discount_price = product.discount_price
            db.add(plan)
            await db.commit()
            await db.refresh(plan)
        except IntegrityError as e:
            raise HTTPException(status_code=404, detail=str(e.orig).split('DETAIL:  ')[1].replace('.\n', ''))
