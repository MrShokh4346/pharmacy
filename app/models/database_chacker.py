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
                query3 = "delete from wholesale_reservation WHERE expire_date <= now() and checked='0'"
                query4 = "update wholesale_reservation set prosrochenniy_debt='1' where expire_date <= now() and checked='0' and debt >= 10000"
                query5 = "update hospital_reservation set prosrochenniy_debt='1' where expire_date <= now() and checked='0' and debt >= 10000"
                query6 = "update reservation set prosrochenniy_debt='1' where expire_date <= now() and checked='0' and debt >= 10000"
                      
                result = await session.execute(text(query))
                result = await session.execute(text(query2))
                result = await session.execute(text(query3))
                result = await session.execute(text(query4))
                result = await session.execute(text(query5))
                result = await session.execute(text(query6))

        await asyncio.sleep(86400)