from app.models.users import PharmacyPlan, PharmacyPlanAttachedProduct, Product, ProductExpenses, UserProductPlan
from sqlalchemy.exc import IntegrityError
from fastapi import HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select, update


class PharmacyPlanService:

    @staticmethod
    def attach(plan: PharmacyPlan, db: AsyncSession, **kwargs):
        try:
            PharmacyPlanAttachedProduct.delete(id=plan.id, db=db)
            plan.description = kwargs.get('description', plan.description)
            plan.status = True
            for doctor in kwargs['doctors']:
                doctor_copy = doctor.copy()
                del doctor_copy['products']
                for product in doctor['products']:
                        compleated = PharmacyPlanAttachedProduct(**product, **doctor_copy, plan_id=plan.id)
                        db.add(compleated)
            db.commit()
        except IntegrityError as e:
            raise HTTPException(status_code=404, detail=str(e.orig).split('DETAIL:  ')[1].replace('.\n', ''))
