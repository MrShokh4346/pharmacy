from app.models.hospital import RemainderSumFromReservation
from sqlalchemy.exc import IntegrityError
from fastapi import HTTPException
from sqlalchemy.ext.asyncio import AsyncSession


class RemainderSumFromReservationService:
    @staticmethod
    async def set_remainder(db: AsyncSession, **kwargs):
        try:
            obj = RemainderSumFromReservation(
                        amonut=kwargs['amonut'],
                        pharmacy_id=kwargs['pharmacy_id'],
                        reservation_invoice_number=kwargs['reservation_invoice_number']
                    )
            db.add(obj)
        except IntegrityError as e:
            raise HTTPException(status_code=404, detail=str(e.orig).split('DETAIL:  ')[1].replace('.\n', ''))
