import calendar
from datetime import datetime
from app.models.database import get_or_404
from app.models.doctors import Bonus, BonusPayedAmounts, DoctorPostupleniyaFact
from app.models.hospital import HospitalReservation, HospitalReservationPayedAmounts, HospitalReservationProducts
from app.models.warehouse import CurrentFactoryWarehouse
from app.services.doctorFactService import DoctorFactService
from app.services.doctorPostupleniyaFactService import DoctorPostupleniyaFactService
from sqlalchemy.exc import IntegrityError
from fastapi import HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from app.models.users import Product


class BonusService:
    
    @staticmethod
    async def paying_bonus(self, amount: int, description: str, db: AsyncSession):
        payed = BonusPayedAmounts(amount=amount, description=description, bonus_id=self.id)
        db.add(payed)
        self.payed += amount
        difference = self.payed - self.amount
        if difference > 0:
            self.pre_investment = difference
        await db.commit()

    
    @staticmethod
    async def set_bonus(db: AsyncSession, **kwargs):
        year = datetime.now().year
        if kwargs.get('month_number') is None:
            month = datetime.now().month  
        else:
            month = kwargs.get('month_number')  
        num_days = calendar.monthrange(year, month)[1]
        start_date = datetime(year, month, 1)  
        end_date = datetime(year, month, num_days, 23, 59)
        product = await get_or_404(Product, kwargs['product_id'], db)
        amount = product.marketing_expenses * kwargs['compleated']
        result = await db.execute(select(Bonus).filter(Bonus.doctor_id==kwargs['doctor_id'], Bonus.product_id==kwargs['product_id'], Bonus.date>=start_date, Bonus.date<=end_date))
        month_bonus = result.scalars().first()
        if month_bonus is None:
            month_bonus = Bonus(date=start_date, doctor_id=kwargs['doctor_id'], product_id=kwargs['product_id'], product_quantity=kwargs['compleated'], amount=amount)
            db.add(month_bonus)
        else:
            month_bonus.amount += amount
            month_bonus.product_quantity += kwargs['compleated']
            if month_bonus.pre_investment >= amount:
                month_bonus.pre_investment -= amount
            else:
                month_bonus.pre_investment = 0 

    
    @staticmethod
    async def set_bonus_to_hospital(db: AsyncSession, **kwargs):
        year = datetime.now().year
        if kwargs.get('month_number') is None:
            month = datetime.now().month  
        else:
            month = kwargs.get('month_number')  
        num_days = calendar.monthrange(year, month)[1]
        start_date = datetime(year, month, 1)  
        end_date = datetime(year, month, num_days, 23, 59)
        product = await get_or_404(Product, kwargs['product_id'], db)
        result = await db.execute(select(Bonus).filter(Bonus.doctor_id==kwargs['doctor_id'], Bonus.product_id==kwargs['product_id'], Bonus.date>=start_date, Bonus.date<=end_date))
        month_bonus = result.scalars().first()
        if month_bonus is None:
            month_bonus = Bonus(date=start_date, doctor_id=kwargs['doctor_id'], product_id=kwargs['product_id'], product_quantity=kwargs['compleated'], amount=kwargs['bonus_sum'])
            db.add(month_bonus)
        else:
            month_bonus.amount += kwargs['bonus_sum']
            month_bonus.product_quantity += kwargs['compleated']
            if month_bonus.pre_investment >= kwargs['bonus_sum']:
                month_bonus.pre_investment -= kwargs['bonus_sum']
            else:
                month_bonus.pre_investment = 0 

    @staticmethod
    async def delete_bonus(db: AsyncSession, **kwargs):
        year = datetime.now().year
        num_days = calendar.monthrange(year, kwargs['month_number'])[1]
        start_date = datetime(year, kwargs['month_number'], 1)  
        end_date = datetime(year, kwargs['month_number'], num_days, 23, 59)
        product = await get_or_404(Product, kwargs['product_id'], db)
        amount = product.marketing_expenses * kwargs['quantity']
        result = await db.execute(select(Bonus).filter(Bonus.doctor_id==kwargs['doctor_id'], Bonus.product_id==kwargs['product_id'], Bonus.date>=start_date, Bonus.date<=end_date))
        bonus = result.scalars().first()
        if bonus is None:
            raise HTTPException(status_code=404, detail=f"Bonus not found (doctor_id={kwargs['doctor_id']}), (product_id={kwargs['product_id']})")
        elif bonus.product_quantity < kwargs['quantity']:
            raise HTTPException(status_code=404, detail=f"There is not enough amount bonus in doctor postupleniya (doctor_id={kwargs['doctor_id']}), (product_id={kwargs['product_id']}), (bonus={bonus.product_quantity}), (postupleniya={kwargs['quantity']})")
        else:
            bonus.amount -= amount
            bonus.product_quantity -= kwargs['quantity']
