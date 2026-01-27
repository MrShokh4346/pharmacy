from app.models.pharmacy import Pharmacy
from sqlalchemy.exc import IntegrityError
from fastapi import HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from app.models.doctors import  Doctor, pharmacy_doctor


class PharmacyService:
    @staticmethod
    async def attach_doctor(pharmacy: Pharmacy, db: AsyncSession, **kwargs):
        try:
            doctor = await db.get(Doctor, kwargs.get('doctor_id'))
            if (not doctor) or (doctor.deleted == True):
                raise HTTPException(status_code=404, detail=f"Doctor not found")
            association_entry = pharmacy_doctor.insert().values(
                doctor_id=kwargs.get('doctor_id'),
                pharmacy_id=pharmacy.id,
            )
            await db.execute(association_entry)
            await db.commit()
        except IntegrityError as e:
            raise HTTPException(status_code=404, detail=str(e.orig).split('DETAIL:  ')[1].replace('.\n', ''))
