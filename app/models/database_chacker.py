from sqlalchemy.ext.asyncio import AsyncSession, create_async_engine
from .database import engine
import asyncio
from .pharmacy import Reservation
from datetime import datetime
from sqlalchemy.future import select


async def delete_expired_objects():
    while True:
        print('Checking for expired objects')
        async with AsyncSession(engine) as session:
            async with session.begin():
                result = await session.execute(
                    select(Reservation).filter(Reservation.expire_date < datetime.now(), Reservation.checked == False)
                )
                reservations = result.scalars().all()
                for reservation in reservations:
                    await session.delete(reservation)
            await session.commit()
        await asyncio.sleep(86400)