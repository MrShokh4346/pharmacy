# from .main import ALGORITHM, SECRET_KEY, ACCESS_TOKEN_EXPIRE_MINUTES
from datetime import datetime, timedelta, timezone
from sqlalchemy.orm import Session
from jose import JWTError, jwt
from dotenv.main import load_dotenv
from fastapi import Request, Depends, HTTPException
import os
from .users import Users
from .pharmacy import Reservation
from typing import Annotated
from .database import get_db
from fastapi.security import HTTPBearer
from openpyxl import Workbook, load_workbook
import shutil


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


def check_if_med_rep(user: Users):
    if user.status != 'medical_representative':
        raise HTTPException(status_code=400, detail='You are not medical representative')
    return True


# def write_excel(reservation: Reservation):
#     exl1 = "Формула_УГП.xlsx"
#     exl2 = "Формула маркетинг.xlsx"
#     source_excel_file = exl1
#     destination_excel_file = '../excel/report.xlsx'


#     shutil.copy2(source_excel_file, destination_excel_file)
#     sheet_name = 'Сотув'
#     destination_wb = load_workbook(destination_excel_file)
#     destination_sheet = destination_wb[sheet_name]

#     destination_wb.save(destination_excel_file)
#     destination_wb.close()



