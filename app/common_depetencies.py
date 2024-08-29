from typing import Annotated
from fastapi import Depends
from datetime import date , datetime
import calendar

async def month_number_or_dates(month_number: int | None = None, start_date: date | None = None, end_date: date | None = None):
    if start_date is None or end_date is None:
        if not month_number:
            month_number = datetime.now().month
        year = datetime.now().year
        num_days = calendar.monthrange(year, month_number)[1]
        start_date = datetime(year, month_number, 1)
        end_date = datetime(year, month_number, num_days, 23, 59)
    return {"start_date": start_date, "end_date": end_date}


StartEndDates = Annotated[dict, Depends(month_number_or_dates)]

