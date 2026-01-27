from app.models.hospital import HospitalMonthlyPlan, HospitalPostupleniyaFact
from app.models.users import UserProductPlan
from sqlalchemy.exc import IntegrityError
from fastapi import HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from app.models.users import UserProductPlan
from sqlalchemy import text


class HospitalMonthlyPlanService:
    
    @staticmethod
    async def update(plan: HospitalMonthlyPlan, amount: int, db: AsyncSession):
        try:
            difference = plan.monthly_plan - amount
            plan.monthly_plan = amount
            result = await db.execute(select(UserProductPlan).filter(UserProductPlan.med_rep_id==plan.hospital.med_rep_id, UserProductPlan.product_id==plan.product_id))
            user_plan = result.scalar()
            user_plan.current_amount += difference
            if user_plan.current_amount < 0:
                raise HTTPException(status_code=404, detail="Med rep plan should be grater than 0 for tis product")
            if plan.monthly_plan == 0:
                result = await db.execute(select(HospitalPostupleniyaFact).filter(HospitalPostupleniyaFact.hospital_id==plan.hospital_id, HospitalPostupleniyaFact.product_id==plan.product_id))
                postupleniya = result.scalars().first()
                if postupleniya:
                    raise HTTPException(status_code=400, detail="There is postuplenuya fact whith this product in this hospital")
                query = f"delete from hospital_monthly_plan WHERE id={plan.id}"
                result = await db.execute(text(query))
            db.add(plan)
            await db.commit()
        except IntegrityError as e:
            raise HTTPException(status_code=404, detail=str(e.orig).split('DETAIL:  ')[1].replace('.\n', ''))
