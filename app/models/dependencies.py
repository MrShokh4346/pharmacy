# from .main import ALGORITHM, SECRET_KEY, ACCESS_TOKEN_EXPIRE_MINUTES
from datetime import datetime, timedelta, timezone
from sqlalchemy.ext.asyncio import AsyncSession
from jose import JWTError, jwt
from dotenv.main import load_dotenv
from fastapi import Request, Depends, HTTPException
import os
from .users import Users, Products, Region
from .doctors import DoctorCategory, Speciality, MedicalOrganization, Doctor
from .pharmacy import Reservation
from typing import Annotated
from .database import get_db
from fastapi.security import HTTPBearer
from openpyxl import Workbook, load_workbook
import shutil
from fastapi.responses import FileResponse
import os
from sqlalchemy.future import select
from sqlalchemy.orm import selectinload


load_dotenv()


SECRET_KEY = os.environ['SECRET_KEY']
ALGORITHM = os.environ['ALGORITHM']
ACCESS_TOKEN_EXPIRE_MINUTES = 30

auth_header = HTTPBearer()


def create_access_token(data: dict):
    to_encode = data.copy()
    expire = datetime.now(timezone.utc) + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt


async def validate_token(request: Request):
    token = request.headers.get("Authorization")
    if not token:
        raise HTTPException(status_code=401, detail="Token is missing")
    try:
        token = token.split("Bearer ")[1]
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        id: str = payload.get("sub")
        if id is None:
            raise HTTPException(status_code=401, detail="Invalid token")
    except jwt.ExpiredSignatureError:
        raise HTTPException(status_code=401, detail="Token has expired")
    except (jwt.JWTError, IndexError):
        raise HTTPException(status_code=401, detail="Could not validate credentials")
    return id


async def get_current_user(id: Annotated[str, Depends(validate_token)], db: AsyncSession = Depends(get_db)):
    user = await db.get(Users, int(id))
    if user is None:
        raise HTTPException(
            status_code=401,
            detail="Could not validate credentials",
            headers={"WWW-Authenticate": "Bearer"},
        )
    return user


async def check_if_user_already_exists(username: str, db: AsyncSession):
    result = await db.execute(select(Users).where(Users.username==username))
    db_user = result.all()
    if db_user:
        raise HTTPException(
            status_code=400,
            detail="Username already exists"
        )
    return False


async def get_user(user_id: int, db: AsyncSession):
    user = await db.get(Users, user_id)
    if not user:
        raise HTTPException(status_code=400, detail="There isn't user with this id")
    return user 


async def write_excel(reservation_id: int, db: AsyncSession):
    source_excel_file = 'app/report/Book.xlsx'
    destination_excel_file = 'app/report/report.xlsx'
    sheet_name = 'Sheet1'
    shutil.copy2(source_excel_file, destination_excel_file)
    destination_wb = load_workbook(destination_excel_file)
    destination_sheet = destination_wb[sheet_name]

    result = await db.execute(select(Reservation).options(selectinload(Reservation.pharmacy)).where(Reservation.id==reservation_id))
    reservation = result.scalar()

    destination_sheet['E2'] = reservation.pharmacy.discount

    count = 9

    for product in reservation.products:
        data_to_write = {
            f'D{count}' : product.product.name,
            f'E{count}' : product.quantity,
            f'F{count}' : product.product.price,
            f'H{count}' : product.quantity * product.product.price
        }
        count += 1
        for cell_address, value in data_to_write.items():
            destination_sheet[cell_address] = value

    # destination_sheet["H9"] = 'sum'

    destination_wb.save(destination_excel_file)
    destination_wb.close()
    return FileResponse("app/report/report.xlsx")


async def get_doctor_or_404(id, db):
    obj = await db.get(Doctor, id)
    if (not obj) or (obj.deleted == True):
        raise HTTPException(status_code=404, detail=f"Doctor not found")
    return obj

