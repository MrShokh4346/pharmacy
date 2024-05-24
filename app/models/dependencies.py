# from .main import ALGORITHM, SECRET_KEY, ACCESS_TOKEN_EXPIRE_MINUTES
from datetime import datetime, timedelta, timezone
from sqlalchemy.orm import Session
from jose import JWTError, jwt
from dotenv.main import load_dotenv
from fastapi import Request, Depends, HTTPException
import os
from .users import Users, Products
from .pharmacy import Reservation
from typing import Annotated
from .database import get_db
from fastapi.security import HTTPBearer
from openpyxl import Workbook, load_workbook
import shutil
from fastapi.responses import FileResponse
import os


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


async def get_current_user(id: Annotated[str, Depends(validate_token)], db: Session = Depends(get_db)):
    user = db.query(Users).filter(Users.id == id).first()
    if user is None:
        raise HTTPException(
            status_code=401,
            detail="Could not validate credentials",
            headers={"WWW-Authenticate": "Bearer"},
        )
    return user


def check_if_user_already_exists(username: str, db: Session):
    db_user = db.query(Users).filter(Users.username == username).first()
    if db_user:
        raise HTTPException(
            status_code=400,
            detail="Username already exists"
        )
    return False


def get_user(user_id: int, db: Session):
    user = db.query(Users).get(user_id)
    if not user:
        raise HTTPException(status_code=400, detail="There isn't user with this id")
    return user 


def write_excel(reservation_id: int, db: Session):
    source_excel_file = 'app/report/Book.xlsx'
    destination_excel_file = 'app/report/report.xlsx'
    sheet_name = 'Sheet1'
    shutil.copy2(source_excel_file, destination_excel_file)
    destination_wb = load_workbook(destination_excel_file)
    destination_sheet = destination_wb[sheet_name]

    reservation = db.query(Reservation).get(reservation_id)

    count = 9

    for product in reservation.products:
        data_to_write = {
            f'D{count}' : product.product_name,
            f'E{count}' : product.quantity,
            f'F{count}' : product.price,
            f'H{count}' : product.quantity * product.price
        }
        count += 1
        for cell_address, value in data_to_write.items():
            destination_sheet[cell_address] = value

    # destination_sheet["H9"] = 'sum'

    destination_wb.save(destination_excel_file)
    destination_wb.close()
    return FileResponse("app/report/report.xlsx")


def filter_doctor(category_id: int | None = None, speciality_id: int | None = None, region_id: int | None = None):
    query = """SELECT doctor.*, speciality.* FROM doctor
    LEFT JOIN speciality ON doctor.speciality_id = speciality.id  WHERE """
    conditions = []

    if category_id is not None:
        conditions.append(f"category_id = {category_id}")
    if speciality_id is not None:
        conditions.append(f"speciality_id = {speciality_id}")
    if region_id is not None:
        conditions.append(f"region_id = {region_id}")
    if not conditions:
        raise ValueError("At least one argument must be provided")

    query += " AND ".join(conditions)
    return query


def filter_pharmacy(doctor_id: int | None = None, product_id: int | None = None, region_id: int | None = None):
    query = """SELECT pharmacy.id, pharmacy.company_name, pharmacy.region_id  FROM pharmacy
    LEFT JOIN pharmacy_doctor ON pharmacy.id = pharmacy_doctor.pharmacy_id 
    LEFT JOIN pharmacy_attached_products ON pharmacy.id = pharmacy_attached_products.pharmacy_id  WHERE """
    conditions = []

    if doctor_id is not None:
        conditions.append(f"pharmacy_doctor.doctor_id = {doctor_id}")
    if product_id is not None:
        conditions.append(f"pharmacy_attached_products.product_id = {product_id}")
    if region_id is not None:
        conditions.append(f"pharmacy.region_id = {region_id}")
    if not conditions:
        raise ValueError("At least one argument must be provided")

    query += " AND ".join(conditions)
    return query