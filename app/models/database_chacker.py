from sqlalchemy.ext.asyncio import AsyncSession, create_async_engine
from .database import engine
import asyncio
from .pharmacy import Reservation
from .hospital import HospitalReservation
from datetime import datetime
from sqlalchemy.future import select
from sqlalchemy import text 


async def delete_expired_objects():
    while True:
        print('Checking for expired objects')
        async with AsyncSession(engine) as session:
            async with session.begin():
                query = "delete from reservation WHERE expire_date <= now() and checked='0'"
                query2 = "delete from hospital_reservation WHERE expire_date <= now() and checked='0'"
                      
                result = await session.execute(text(query))
                result = await session.execute(text(query2))


            #     result = await session.execute(
            #         select(Reservation).filter(Reservation.expire_date < datetime.now(), Reservation.checked == False)
            #     )
            #     reservations = result.scalars().all()
            #     for reservation in reservations:
            #         await session.delete(reservation)
            #     result1 = await session.execute(
            #         select(HospitalReservation).filter(HospitalReservation.expire_date < datetime.now(), HospitalReservation.checked == False)
            #     )
            #     h_reservations = result1.scalars().all()
            #     for reservation in h_reservations:
            #         await session.delete(reservation)
            # await session.commit()
        await asyncio.sleep(86400)