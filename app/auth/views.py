from datetime import datetime, timedelta, timezone
from fastapi import Depends, FastAPI, HTTPException, status
from jose import JWTError, jwt
from .schemas import *
from fastapi import APIRouter
from ..models.dependencies import create_access_token
from sqlalchemy.orm import Session
from ..models.users import *
from ..models.database import get_db

router = APIRouter()


def authenticate_user(db: Session, username: str, password: str):
    user = db.query(Users).filter(Users.username == username).first()
    if not user:
        return False
    if not verify_password(password, user.hashed_password):
        return False
    return user


@router.post("/login")
async def login_for_access_token(user: LoginSchema, db: Session = Depends(get_db)) -> TokenSchema:
    user = authenticate_user(db, user.username, user.password)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect username or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    access_token = create_access_token(data={"sub": user.id})
    return TokenSchema(access_token=access_token)


@router.post('/register')
async def register_user(user: RegisterSchema, db: Session = Depends(get_db)) -> UserOutSchema:
    db_user = db.query(Users).filter(Users.username == user.username).first()
    if db_user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Username already exists",
            headers={"WWW-Authenticate": "Bearer"},
        )
    new_user = Users(**user.dict())
    new_user.save(db=db)
    return UserOutSchema(**new_user.__dict__)


@router.get('/getuser/{user_id}')
async def get_user_by_id(user_id: int, db: Session = Depends(get_db)) -> UserOutSchema:
    db_user = db.query(Users).filter(Users.id == user_id).first()
    return UserOutSchema(**db_user.__dict__)


@router.put('/update-user/{user_id}')
async def update_user(user: UpdateUserSchema, user_id: int, db: Session = Depends(get_db)) -> UserOutSchema:
    db_user = db.query(Users).filter(Users.id == user_id).first()
    if not db_user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="There is not this user"
        )
    db_user.update(**user.dict(), db=db)
    return UserOutSchema(**db_user.__dict__)

