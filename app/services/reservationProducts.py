from app.models.database import get_or_404
from app.models.pharmacy import Reservation, ReservationProducts
from fastapi import HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from sqlalchemy.exc import IntegrityError
from app.models.users import Product


class ReservationProductsService:
    @staticmethod
    async def add(db: AsyncSession, **kwargs):
        try:
            discount = kwargs['discount']
            del kwargs['discount']
            product = await get_or_404(Product, kwargs['product_id'], db)
            reservation_price = (product.price - product.price * discount / 100) * 1.12
            res_product = ReservationProducts(**kwargs, not_payed_quantity=kwargs['quantity'], reservation_price=reservation_price)
            db.add(res_product)
            result = await db.execute(select(Reservation).filter(Reservation.id==kwargs['reservation_id']))
            reservation = result.scalar()
            difference_sum = ((kwargs['quantity'] * product.price * 1.12) * (100 - discount)/100)
            reservation.total_quantity += kwargs['quantity']
            reservation.total_amount += kwargs['quantity'] * product.price
            reservation.total_payable += ((kwargs['quantity'] * product.price) * (100 - discount)/100)
            reservation.total_payable_with_nds += difference_sum
            reservation.debt += difference_sum
            await db.commit()
        except IntegrityError as e:
            raise HTTPException(status_code=404, detail=str(e.orig).split('DETAIL:  ')[1].replace('.\n', ''))
