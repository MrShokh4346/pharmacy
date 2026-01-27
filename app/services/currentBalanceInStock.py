from app.models.pharmacy import CurrentBalanceInStock
from fastapi import HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select



class CurrentBalanceInStockService:
    @staticmethod
    async def add(pharmacy_id: int, product_id: int, amount: int, db: AsyncSession):
        result = await db.execute(select(CurrentBalanceInStock).filter(CurrentBalanceInStock.product_id==product_id, CurrentBalanceInStock.pharmacy_id==pharmacy_id))
        current = result.scalars().first()
        if not current:
            current = CurrentBalanceInStock(pharmacy_id=pharmacy_id, product_id=product_id, amount=amount)
            db.add(current)
        else:
            current.amount += amount
        return current

    @staticmethod
    async def minus(pharmacy_id: int, product_id: int, amount: int, db: AsyncSession):
        result = await db.execute(select(CurrentBalanceInStock).filter(CurrentBalanceInStock.product_id==product_id, CurrentBalanceInStock.pharmacy_id==pharmacy_id))
        current = result.scalars().first()
        if not current or current.amount < amount:
            raise HTTPException(status_code=404, detail='There is not enough product in pharmacy warehouse')
        else:
            current.amount -= amount
        return current
