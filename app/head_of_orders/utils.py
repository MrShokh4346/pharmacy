from models.warehouse import WholesaleReservationPayedAmounts 
from models.hospital import HospitalReservationPayedAmounts
from models.pharmacy import ReservationPayedAmounts
from sqlalchemy.future import select



async def get_postupleniyas(start_date, end_date, db):
    pharmacy_postupleniya = []
    result = await db.execute(select(ReservationPayedAmounts).filter(ReservationPayedAmounts.date>=start_date, ReservationPayedAmounts.date<=end_date))
    pharmacy_postupleniya = result.scalars().all()
    result = await db.execute(select(WholesaleReservationPayedAmounts).filter(WholesaleReservationPayedAmounts.payed==True, WholesaleReservationPayedAmounts.date>=start_date, WholesaleReservationPayedAmounts.date<=end_date))
    wholesale_postupleniya = result.scalars().all()
    result = await db.execute(select(HospitalReservationPayedAmounts).filter(HospitalReservationPayedAmounts.date>=start_date, HospitalReservationPayedAmounts.date<=end_date))
    hospital_postupleniya = result.scalars().all()
    pharmacy_postupleniya.extend(wholesale_postupleniya)
    pharmacy_postupleniya.extend(hospital_postupleniya)
    return pharmacy_postupleniya
