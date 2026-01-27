from app.models.pharmacy import CheckingBalanceInStock, CheckingStockProducts, CurrentBalanceInStock
from fastapi import HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from sqlalchemy.exc import IntegrityError


class CheckingBalanceInStockService:
    @staticmethod
    async def save(db: AsyncSession, **kwargs):
        try:
            products = kwargs.pop('products')
            stock = CheckingBalanceInStock(**kwargs)
            for product in products:
                result = await db.execute(select(CurrentBalanceInStock).filter(CurrentBalanceInStock.product_id==product['product_id'], CurrentBalanceInStock.pharmacy_id==kwargs['pharmacy_id']))
                current = result.scalars().first()
                if (not current) or (current.amount < product['remainder']) :
                    raise HTTPException(status_code=404, detail="There isn't enough product in stock")
                saled_product_amount = current.amount-product['remainder']
                stock_product = CheckingStockProducts(**product, previous=current.amount, saled=saled_product_amount)
                stock.products.append(stock_product)
                if stock_product.saled > current.amount:
                    raise HTTPException(status_code=400, detail="There isn't enough product in stock")
                current.amount -= saled_product_amount
            db.add(stock)
            await db.commit()
        except IntegrityError as e:
            raise HTTPException(status_code=404, detail=str(e.orig).split('DETAIL:  ')[1].replace('.\n', ''))
