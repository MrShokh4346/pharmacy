from datetime import datetime
from app.models.database import get_or_404
from app.models.doctors import Bonus, DoctorFact, DoctorPostupleniyaFact
from app.models.hospital import HospitalReservation, HospitalReservationPayedAmounts, HospitalReservationProducts
from app.models.warehouse import CurrentFactoryWarehouse
from sqlalchemy.exc import IntegrityError
from fastapi import HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from app.models.users import Product


class HospitalReservationService:
    
    @staticmethod
    async def save(db: AsyncSession, **kwargs):
        try:
            total_quantity = 0
            total_amount = 0
            total_payable = 0
            res_products = []
            products = kwargs.pop('products')
            for product in products:
                prd = await get_or_404(Product, product['product_id'], db)
                price = product['price'] if product['price'] else prd.price
                del product['price']
                result = await db.execute(select(CurrentFactoryWarehouse).filter(CurrentFactoryWarehouse.factory_id==kwargs['manufactured_company_id'], CurrentFactoryWarehouse.product_id==product['product_id']))
                wrh = result.scalar()
                if (not wrh) or wrh.amount < product['quantity']: 
                    raise HTTPException(status_code=404, detail=f"There is not enough {prd.name} in factory warehouse")
                res_products.append(HospitalReservationProducts(**product, reservation_price=price, reservation_discount_price=prd.discount_price))
                total_quantity += product['quantity']
                total_amount += product['quantity'] * price
            total_payable = (total_amount - total_amount * kwargs['discount'] / 100)
            reservation = HospitalReservation(**kwargs,
                                total_quantity = total_quantity,
                                total_amount = total_amount,
                                total_payable = total_payable,
                                total_payable_with_nds = (total_payable + total_payable * 0.12),
                                debt = (total_payable + total_payable * 0.12)
                                )
            db.add(reservation)
            for p in res_products:
                p.reservation_id=reservation.id
                reservation.products.append(p)
            await db.commit()
            return reservation
        except IntegrityError as e:
            raise HTTPException(status_code=404, detail=str(e.orig).split('DETAIL:  ')[1].replace('.\n', ''))
    

    @staticmethod
    async def check_reservation(reservation: HospitalReservation, db: AsyncSession, **kwargs):
        if reservation.checked == True:
            raise HTTPException(status_code=400, detail=f"This reservation already checked")
        reservation.checked = kwargs.get('checked')
        reservation.date_implementation = datetime.now()
        for product in reservation.products:
            result = await db.execute(select(CurrentFactoryWarehouse).filter(CurrentFactoryWarehouse.factory_id==reservation.manufactured_company_id, CurrentFactoryWarehouse.product_id==product.product_id))
            wrh = result.scalar()
            if (not wrh) or wrh.amount < product.quantity: 
                raise HTTPException(status_code=404, detail=f"There is not enough {product.product.name} in warehouse")
            wrh.amount -= product.quantity
        await db.commit()

    @staticmethod
    async def pay_reservation(reservation: HospitalReservation, db: AsyncSession, **kwargs):
        try:
            reservation.debt -= kwargs['amount']
            reservation.profit += kwargs['amount']
            reservation = HospitalReservationPayedAmounts(quantity=reservation.total_quantity, doctor_id=kwargs['doctor_id'], bonus_discount=kwargs['bonus_discount'], amount=kwargs['amount'], description=kwargs['description'], reservation_id=reservation.id)
            await reservation.save(db)
            if reservation.debt < 0:
                raise HTTPException(status_code=400, detail=f"Something went wrong")
            for prd in reservation.products:
                product_price = (prd.product.price * 1.12) * (100 - reservation.discount)/100
                fact_price = prd.quantity * product_price
                bonus_sum = fact_price * kwargs['bonus_discount']/100
                await DoctorFact.set_fact_to_hospital(month_number=kwargs['month_number'], doctor_id=kwargs['doctor_id'], product_id=prd.product.id, compleated=prd.quantity, db=db)
                await DoctorPostupleniyaFact.set_fact(price=product_price, fact_price=fact_price, product_id=prd.product.id, doctor_id=kwargs['doctor_id'], compleated=prd.quantity, month_number=kwargs['month_number'], db=db)
                if reservation.bonus == True:
                    await Bonus.set_bonus_to_hospital(bonus_sum=bonus_sum, product_id=prd.product.id, doctor_id=kwargs['doctor_id'], compleated=prd.quantity, month_number=kwargs['month_number'], db=db)
            await db.commit()
        except IntegrityError as e:
            raise HTTPException(status_code=404, detail=str(e.orig).split('DETAIL:  ')[1].replace('.\n', ''))
