import calendar
from datetime import datetime
from app.models.doctors import Bonus, DoctorMonthlyPlan, DoctorPostupleniyaFact
from app.models.pharmacy import Reservation, ReservationPayedAmounts, ReservationProducts
from app.services.remainderSumFromReservationService import RemainderSumFromReservationService
from sqlalchemy import text
from sqlalchemy.future import select
from sqlalchemy.exc import IntegrityError
from fastapi import HTTPException
from sqlalchemy.ext.asyncio import AsyncSession


class ReservationService:
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
                    await DoctorPostupleniyaFact.set_fact(price=obj['amount'], fact_price=obj['amount'] * obj['quantity'], product_id=obj['product_id'], doctor_id=obj['doctor_id'], compleated=obj['quantity'], month_number=obj['month_number'], db=db)
                    await Bonus.set_bonus(product_id=obj['product_id'], doctor_id=obj['doctor_id'], compleated=obj['quantity'], month_number=obj['month_number'], db=db)
            await db.commit()
        except IntegrityError as e:
            raise HTTPException(status_code=404, detail=str(e.orig).split('DETAIL:  ')[1].replace('.\n', ''))
