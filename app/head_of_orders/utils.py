from app.models.warehouse import WholesaleReservationPayedAmounts, WholesaleReservation 
from app.models.hospital import HospitalReservationPayedAmounts, HospitalReservation
from app.models.pharmacy import ReservationPayedAmounts, Reservation
from sqlalchemy.future import select
from sqlalchemy import select, union_all, literal
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload


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


async def filter_by_invoice_number_with_products(db: AsyncSession, invoice_number: str):
    # Initialize an empty list to hold all reservations and their products
    all_reservations = []

    # Query for Reservation table with products
    query_reservation = select(Reservation).where(Reservation.invoice_number == invoice_number)
    result_reservation = await db.execute(query_reservation)
    reservations = result_reservation.scalars().all()  # Fetch all reservation instances
    all_reservations.extend(reservations)

    # Query for WholesaleReservation table with products
    query_wholesale = select(WholesaleReservation).where(WholesaleReservation.invoice_number == invoice_number)
    result_wholesale = await db.execute(query_wholesale)
    wholesale_reservations = result_wholesale.scalars().all()  # Fetch all wholesale reservation instances
    all_reservations.extend(wholesale_reservations)

    # Query for HospitalReservation table with products
    query_hospital = select(HospitalReservation).where(HospitalReservation.invoice_number == invoice_number)
    result_hospital = await db.execute(query_hospital)
    hospital_reservations = result_hospital.scalars().all()  # Fetch all hospital reservation instances
    all_reservations.extend(hospital_reservations)

    return all_reservations[0]
