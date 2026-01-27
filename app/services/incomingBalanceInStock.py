from app.models.pharmacy import CurrentBalanceInStock, IncomingBalanceInStock, IncomingStockProducts
from app.models.warehouse import CurrentFactoryWarehouse, CurrentWholesaleWarehouse
from sqlalchemy.exc import IntegrityError
from fastapi import HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select



class IncomingBalanceInStockService:
    @staticmethod
    async def save(db: AsyncSession, **kwargs):
        try:
            products = kwargs.pop('products')
            stock = IncomingBalanceInStock(**kwargs)
            
            for product in products:
                wareh = None
                if kwargs.get('wholesale_id') is not None:
                    result = await db.execute(select(CurrentWholesaleWarehouse).filter(CurrentWholesaleWarehouse.product_id==product['product_id'], CurrentWholesaleWarehouse.wholesale_id==kwargs['wholesale_id']))
                    wareh = result.scalars().first()
                    if (not wareh) or (wareh.amount < product['quantity']):
                        raise HTTPException(status_code=404, detail='There is not enough product in wholesale warehouse')
                else:
                    result = await db.execute(select(CurrentFactoryWarehouse).filter(CurrentFactoryWarehouse.product_id==product['product_id'], CurrentFactoryWarehouse.factory_id==kwargs['factory_id']))
                    wareh = result.scalars().first()
                    if (not wareh) or (wareh.amount < product['quantity']):
                        raise HTTPException(status_code=404, detail='There is not enough product in warehouse')

                stock_product = IncomingStockProducts(**product)
                stock.products.append(stock_product)
                current = await CurrentBalanceInStock.add(pharmacy_id=kwargs['pharmacy_id'], product_id=product['product_id'], amount=product['quantity'], db=db)
                if wareh is not None:
                    wareh.amount -= product['quantity']
            db.add(stock)
            await db.commit()
        except IntegrityError as e:
            raise HTTPException(status_code=404, detail=str(e.orig).split('DETAIL:  ')[1].replace('.\n', ''))
