import calendar
from datetime import datetime
from app.models.database import get_or_404
from app.models.doctors import Bonus, DoctorMonthlyPlan, DoctorPostupleniyaFact
from app.models.pharmacy import Reservation, ReservationPayedAmounts, ReservationProducts
from app.models.warehouse import CurrentFactoryWarehouse
from app.services.bonusService import BonusService
from app.services.currentBalanceInStock import CurrentBalanceInStockService
from app.services.doctorPostupleniyaFactService import DoctorPostupleniyaFactService
from app.services.remainderSumFromReservationService import RemainderSumFromReservationService
from sqlalchemy import text, update
from sqlalchemy.future import select
from sqlalchemy.exc import IntegrityError
from fastapi import HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from app.models.users import Product



class ReservationService:

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
                reservation_price = (price - price * kwargs['discount'] / 100) * 1.12
                res_products.append(ReservationProducts(**product, not_payed_quantity=product['quantity'], reservation_price=price, reservation_discount_price=prd.discount_price))
                total_quantity += product['quantity']
                total_amount += product['quantity'] * price
            total_payable = (total_amount - total_amount * kwargs['discount'] / 100) if kwargs['discountable'] == True else total_amount
            reservation = Reservation(**kwargs,
                                total_quantity = total_quantity,
                                total_amount = total_amount,
                                total_payable = total_payable,
                                total_payable_with_nds = (total_payable + total_payable * 0.12),
                                debt = (total_payable + total_payable * 0.12)
                                )
            db.add(reservation)
            for p in res_products:
                reservation.products.append(p)
            await db.commit()
            return reservation
        except IntegrityError as e:
            raise HTTPException(status_code=404, detail=str(e.orig).split('DETAIL:  ')[1].replace('.\n', ''))


    @staticmethod
    async def pay_reservation(reservation: Reservation, db: AsyncSession, **kwargs):
        try:
            query = text(f'SELECT product_id FROM reservation_products WHERE reservation_id={reservation.id}')
            result = await db.execute(query)
            product_ids = [row[0] for row in result.all()]
            current = sum([obj['amount'] * obj['quantity'] for obj in kwargs['objects']])
            
            if kwargs['total'] > 0:
                reservation.reailized_debt -= kwargs['total']
                if reservation.reailized_debt < 0:
                    reservation.reailized_debt = 0
                reservation.debt -= kwargs['total']
                reservation.profit += kwargs['total']
                remaind = reservation.profit - reservation.total_payable_with_nds

                if remaind > 0:
                    await RemainderSumFromReservationService.set_remainder(db=db, amonut=remaind, pharmacy_id=reservation.pharmacy_id, reservation_invoice_number=reservation.invoice_number)

            if reservation.profit < current:   
                raise HTTPException(status_code=400, detail=f"Total should be greater then sum of amounts")

            for obj in kwargs['objects']:
                if obj['product_id'] not in product_ids:
                    raise HTTPException(status_code=404, detail=f"No product found in this reservation with this id (product_id={obj['product_id']})")
                if obj['doctor_id'] is not None:
                    year = datetime.now().year
                    month_number = obj['month_number']
                    num_days = calendar.monthrange(year, month_number)[1]
                    start_date = datetime(year, month_number, 1)
                    end_date = datetime(year, month_number, num_days, 23, 59)
                    result = await db.execute(select(DoctorMonthlyPlan).filter(DoctorMonthlyPlan.doctor_id==obj['doctor_id'], DoctorMonthlyPlan.product_id==obj['product_id'], DoctorMonthlyPlan.date>=start_date, DoctorMonthlyPlan.date<=end_date))
                    doctor_monthly_plan = result.scalars().first()
                    if not doctor_monthly_plan:
                        raise HTTPException(status_code=404, detail=f"There is no doctor plan with this product (product_id={obj['product_id']}) in this doctor (doctor_id={obj['doctor_id']})")

                reservation.reailized_debt += obj['amount'] * obj['quantity']
                reservation = ReservationPayedAmounts(
                                        total_sum=kwargs['total'], 
                                        remainder_sum=kwargs['total'] - current, 
                                        amount=obj['amount'] * obj['quantity'], 
                                        quantity=obj['quantity'], 
                                        bonus=obj['bonus'], 
                                        description=kwargs['description'], 
                                        reservation_id=reservation.id, 
                                        product_id=obj['product_id'], 
                                        month_number=obj['month_number'],
                                        doctor_id=obj['doctor_id'])
                await reservation.save(db)
                await ReservationProducts.set_payed_quantity(
                                            quantity=obj['quantity'],
                                            reservation_id=reservation.reservation_id,
                                            product_id=obj['product_id'],
                                            db=db
                                            )
                if reservation.bonus == True:
                    await DoctorPostupleniyaFactService.set_fact(price=obj['amount'], fact_price=obj['amount'] * obj['quantity'], product_id=obj['product_id'], doctor_id=obj['doctor_id'], compleated=obj['quantity'], month_number=obj['month_number'], db=db)
                    await BonusService.set_bonus(product_id=obj['product_id'], doctor_id=obj['doctor_id'], compleated=obj['quantity'], month_number=obj['month_number'], db=db)
            await db.commit()
        except IntegrityError as e:
            raise HTTPException(status_code=404, detail=str(e.orig).split('DETAIL:  ')[1].replace('.\n', ''))


    @staticmethod
    async def check_reservation(reservation: Reservation, db: AsyncSession, **kwargs):
        if reservation.checked == True:
            raise HTTPException(status_code=400, detail=f"This reservation already chacked")
        reservation.checked = kwargs.get('checked')
        reservation.date_implementation = datetime.now()
        for product in reservation.products:
            result = await db.execute(select(CurrentFactoryWarehouse).filter(CurrentFactoryWarehouse.factory_id==reservation.manufactured_company_id, CurrentFactoryWarehouse.product_id==product.product_id))
            wrh = result.scalar()
            if (not wrh) or wrh.amount < product.quantity: 
                raise HTTPException(status_code=404, detail=f"There is not enough {product.product.name} in factrory warehouse")
            wrh.amount -= product.quantity
            await CurrentBalanceInStockService.add(reservation.pharmacy_id, product.product_id, product.quantity, db)
        await db.commit()


    @staticmethod
    async def return_product(reservation: Reservation, product_id: int, quantity: int, db: AsyncSession):
        try:
            result = await db.execute(select(ReservationProducts).filter(ReservationProducts.reservation_id==reservation.id, ReservationProducts.product_id==product_id))
            r_product = result.scalars().first()
            if r_product.not_payed_quantity < quantity:
                raise HTTPException(status_code=400, detail="You are trying to return more than not payed")
            await CurrentBalanceInStockService.minus(reservation.pharmacy_id, product_id, quantity, db)
            r_product.quantity -= quantity
            r_product.not_payed_quantity -= quantity
            if r_product.quantity < 0:
                raise HTTPException(status_code=400, detail="You are trying to return more than reserved")
            minus_price = quantity * r_product.product.price
            minus_price_with_discount = (minus_price - minus_price * reservation.discount / 100) if reservation.discountable == True else minus_price
            reservation.total_quantity -= quantity
            reservation.total_amount -= minus_price
            reservation.total_payable -= minus_price_with_discount
            reservation.returned_price += (minus_price_with_discount + minus_price_with_discount * 0.12)
            reservation.total_payable_with_nds -= (minus_price_with_discount + minus_price_with_discount * 0.12)
            reservation.debt -= (minus_price_with_discount + minus_price_with_discount * 0.12)
            await db.commit()
        except IntegrityError as e:
            raise HTTPException(status_code=400, detail="Something went wrong!")


    @staticmethod
    async def vozvrat(reservation: Reservation, product_id: int, quantity: int, db: AsyncSession):
        try:
            result = await db.execute(select(ReservationProducts).filter(ReservationProducts.reservation_id==reservation.id, ReservationProducts.product_id==product_id))
            r_product = result.scalars().first()
            await CurrentBalanceInStockService.minus(reservation.pharmacy_id, product_id, quantity, db)
            r_product.quantity -= quantity
            r_product.not_payed_quantity -= quantity
            if r_product.not_payed_quantity < 0:
                r_product.not_payed_quantity = 0
            if r_product.quantity < 0:
                raise HTTPException(status_code=400, detail="You are trying to return more than reserved")
            minus_price = quantity * r_product.product.price
            minus_price_with_discount = (minus_price - minus_price * reservation.discount / 100) if reservation.discountable == True else minus_price
            reservation.total_quantity -= quantity
            reservation.total_amount -= minus_price
            reservation.total_payable -= minus_price_with_discount
            # reservation.returned_price += (minus_price_with_discount + minus_price_with_discount * 0.12)
            reservation.total_payable_with_nds -= (minus_price_with_discount + minus_price_with_discount * 0.12)
            reservation.debt -= (minus_price_with_discount + minus_price_with_discount * 0.12)
            if reservation.debt > 0:
                reservation.profit += reservation.debt
                reservation.debt = 0
        except IntegrityError as e:
            raise HTTPException(status_code=400, detail="Something went wrong!")


    @staticmethod
    async def delete_postupleniya(self, db: AsyncSession):
        for res_product in self.payed_amounts:
            await DoctorPostupleniyaFactService.delete_postupleniya(doctor_id=res_product.doctor_id, product_id=res_product.product_id, month_number=res_product.month_number, quantity=res_product.quantity, amount=res_product.amount, db=db)
            if res_product.bonus == True:
                await BonusService.delete_bonus(doctor_id=res_product.doctor_id, product_id=res_product.product_id, month_number=res_product.month_number, quantity=res_product.quantity, db=db)
            await ReservationProducts.set_default_payed_quantity(reservation_id=self.id, product_id=res_product.product_id, db=db)
        await db.execute(update(Reservation).where(Reservation.id == self.id).values(profit=0, debt=self.total_payable_with_nds))
        query = f"delete from reservation_payed_amounts WHERE reservation_id={self.id}"
        result = await db.execute(text(query))
        await db.commit()

