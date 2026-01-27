import calendar
from datetime import datetime
from app.models.database import get_or_404
from app.models.pharmacy import CheckingStockProducts, Pharmacy, PharmacyFact, PharmacyHotSale
from app.services.doctorFactService import DoctorFactService
from sqlalchemy.exc import IntegrityError
from fastapi import HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from app.models.doctors import  pharmacy_doctor, DoctorMonthlyPlan
from app.models.users import UserProductPlan


class PharmacyFactService:
    @staticmethod
    async def save(db: AsyncSession, **kwargs):
        try:
            year = datetime.now().year
            month = kwargs['visit_date'].month  
            num_days = calendar.monthrange(year, month)[1]
            start_date = datetime(year, month, 1)  
            end_date = datetime(year, month, num_days, 23, 59)
            product_dict = dict()
            for doctor in kwargs['doctors']:
                result = await db.execute(select(pharmacy_doctor).filter(
                            pharmacy_doctor.c.doctor_id == doctor.get('doctor_id'),
                            pharmacy_doctor.c.pharmacy_id == kwargs.get('pharmacy_id')
                            ))
                doc =  result.scalar()
                if doc is None:
                    raise HTTPException(status_code=404, detail=f"This doctor(id={doctor['doctor_id']}) is not attached to this pharmacy(id={kwargs.get('pharmacy_id')})")
                for product in doctor['products']:
                    result = await db.execute(select(DoctorMonthlyPlan).filter(DoctorMonthlyPlan.doctor_id == doctor['doctor_id'], DoctorMonthlyPlan.product_id == product['product_id'], DoctorMonthlyPlan.date>=start_date, DoctorMonthlyPlan.date<=end_date))
                    prod = result.scalars().first()
                    if not prod:
                        raise HTTPException(status_code=404, detail=f"This product(id={product['product_id']}) is not attached to this doctor(id={doctor['doctor_id']}) for this month")
                    prod.fact =  product['compleated']
                    p_fact = PharmacyFact(date=kwargs['visit_date'], pharmacy_id = kwargs['pharmacy_id'], doctor_id = doctor['doctor_id'], product_id = product['product_id'], quantity = product['compleated'], monthly_plan=prod.monthly_plan) 
                    db.add(p_fact)
                    await DoctorFactService.set_fact(visit_date=kwargs['visit_date'], pharmacy_id=kwargs['pharmacy_id'], doctor_id=doctor['doctor_id'], product_id=product['product_id'], compleated=product['compleated'], db=db)                    
                    if product_dict.get(product['product_id']):
                        product_dict[product['product_id']] += product['compleated'] 
                    else:
                        product_dict[product['product_id']] = product['compleated'] 
            for key, value in product_dict.items():
                result = await db.execute(select(CheckingStockProducts).filter(CheckingStockProducts.chack==False, CheckingStockProducts.product_id==key).order_by(CheckingStockProducts.id.desc()))
                checking = result.scalars().first()
                if checking is None:
                    raise HTTPException(status_code=404, detail=f"Balance should be chacked before adding fact")
                pharmacy = await get_or_404(Pharmacy, kwargs['pharmacy_id'], db)
                if checking.saled > value:

                    hot_sale = PharmacyHotSale(amount=checking.saled - value, product_id=key, pharmacy_id=kwargs['pharmacy_id'])
                    db.add(hot_sale)
                    await UserProductPlan.user_plan_minus(product_id=key, quantity=checking.saled - value, med_rep_id=pharmacy.med_rep_id, db=db)
                checking.chack = True
            await db.commit()
        except IntegrityError as e:
            raise HTTPException(status_code=404, detail=str(e.orig).split('DETAIL:  ')[1].replace('.\n', ''))
