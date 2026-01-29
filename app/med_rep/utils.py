from app.models.users import EditablePlanMonths
from app.models.doctors import DoctorMonthlyPlan
from sqlalchemy.future import select
from sqlalchemy.ext.asyncio import AsyncSession
from fastapi import HTTPException


async def check_if_plan_is_editable(plan: DoctorMonthlyPlan, db: AsyncSession):
    plan_date = plan.date
    result = await db.execute(select(EditablePlanMonths).filter(EditablePlanMonths.month==plan_date.month)) 
    if result.scalar().status == False:
        raise HTTPException(status_code=400, detail=f"You can not edit plan in this month")
    return True