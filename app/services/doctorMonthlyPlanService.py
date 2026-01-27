import calendar
from datetime import datetime
from app.models.doctors import DoctorMonthlyPlan, DoctorPostupleniyaFact
from app.models.users import UserProductPlan
from fastapi import HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from sqlalchemy import text
from sqlalchemy.exc import IntegrityError


class DoctorMonthlyPlanService:
    @staticmethod
    async def update(plan: DoctorMonthlyPlan, amount: int, db: AsyncSession):
        try:
            year = datetime.now().year
            month = plan.date.month  
            num_days = calendar.monthrange(year, month)[1]
            start_date = datetime(year, month, 1)  
            end_date = datetime(year, month, num_days, 23, 59)
            difference = plan.monthly_plan - amount
            plan.monthly_plan = amount
            result = await db.execute(select(UserProductPlan).filter(UserProductPlan.med_rep_id==plan.doctor.med_rep_id, UserProductPlan.product_id==plan.product_id, UserProductPlan.plan_month>=start_date, UserProductPlan.plan_month<=end_date))
            user_plan = result.scalars().first()
            user_plan.current_amount += difference
            if user_plan.current_amount < 0:
                raise HTTPException(status_code=404, detail="Med rep plan should be grater than 0 for tis product")
            if plan.monthly_plan == 0:
                result = await db.execute(select(DoctorPostupleniyaFact).filter(DoctorPostupleniyaFact.doctor_id==plan.doctor_id, DoctorPostupleniyaFact.product_id==plan.product_id))
                postupleniya = result.scalars().first()
                if postupleniya:
                    raise HTTPException(status_code=400, detail="There is postuplenuya fact whith this product in this doctor")
                query = f"delete from doctor_monthly_plan WHERE id={plan.id}"
                result = await db.execute(text(query))
            await db.commit()
        except IntegrityError as e:
            raise HTTPException(status_code=404, detail=str(e.orig).split('DETAIL:  ')[1].replace('.\n', ''))


    @staticmethod
    async def move_plan(db: AsyncSession, **kwargs):
        try:
            plan = kwargs['plan']
            if kwargs['remainder_amount'] > plan.monthly_plan:
                raise HTTPException(status_code=404, detail='Something went wrong')
            elif kwargs['remainder_amount'] == plan.monthly_plan:
                query = f"delete from doctor_monthly_plan WHERE id = {plan.id}"
            else:
                query = f"update doctor_monthly_plan set monthly_plan={kwargs['remainder_amount']} WHERE id = {plan.id}"
            total_quantity = 0
            for doctor in kwargs['doctors']:
                total_quantity += doctor['quantity']
                result = await db.execute(select(DoctorMonthlyPlan).filter(DoctorMonthlyPlan.doctor_id==doctor['doctor_id'], DoctorMonthlyPlan.product_id==doctor['quantity']))
                current_doctor = result.scalar()
                if current_doctor:
                    current_doctor.monthly_plan += doctor['quantity']
                else:
                    current_doctor = DoctorMonthlyPlan(
                        monthly_plan = doctor['quantity'],
                        product_id = plan.product_id,
                        price = plan.price,
                        discount_price = plan.discount_price,
                        doctor_id = doctor['doctor_id'],
                        date = plan.date
                    )
                    db.add(current_doctor)
            if total_quantity != plan.monthly_plan - kwargs['remainder_amount']:
                raise HTTPException(status_code=404, detail='Something went wrong')
            result = await db.execute(text(query))
            await db.commit()
        except IntegrityError as e:
            raise HTTPException(status_code=404, detail=str(e.orig).split('DETAIL:  ')[1].replace('.\n', ''))


