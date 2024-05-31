from datetime import datetime, timedelta, timezone
from fastapi import Depends, FastAPI, HTTPException, status
from jose import JWTError, jwt
from .schemas import *
from fastapi import APIRouter
from models.dependencies import create_access_token
from sqlalchemy.orm import Session
from models.users import *
from models.database import get_db
from sqlalchemy.future import select

router = APIRouter()


async def authenticate_user(db: Session, username: str, password: str):
    result = await db.execute(select(Users).filter(Users.username == username))
    user = result.scalar()
    if not user:
        return False
    if not verify_password(password, user.hashed_password):
        return False
    return user


@router.post("/login")
async def login_for_access_token(user: LoginSchema, db: Session = Depends(get_db)) -> TokenSchema:
    user = await authenticate_user(db, user.username, user.password)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect username or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    access_token = create_access_token(data={"sub": str(user.id)})
    return TokenSchema(id=user.id, access_token=access_token, status=user.status, region_id=user.region_id)


@router.post('/register')
async def register_director(user: RegisterSchema, db: Session = Depends(get_db)) -> UserOutSchema:
    result = await db.execute(select(Users).filter(Users.username == user.username))
    db_user = result.scalar()
    if db_user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Username already exists",
            headers={"WWW-Authenticate": "Bearer"},
        )
    new_user = Users(**user.dict(), status='director')
    await new_user.save(db=db)
    return UserOutSchema(**new_user.__dict__)


# @router.get('/getuser/{user_id}')
# async def get_user_by_id(user_id: int, db: Session = Depends(get_db)) -> UserOutSchema:
#     db_user = db.query(Users).filter(Users.id == user_id).first()
#     return UserOutSchema(**db_user.__dict__)


# @router.put('/update-user/{user_id}')
# async def update_user(user: UpdateUserSchema, user_id: int, db: Session = Depends(get_db)) -> UserOutSchema:
#     db_user = db.query(Users).filter(Users.id == user_id).first()
#     if not db_user:
#         raise HTTPException(
#             status_code=status.HTTP_400_BAD_REQUEST,
#             detail="There is not this user"
#         )
#     db_user.update(**user.dict(), db=db)
#     return UserOutSchema(**db_user.__dict__)

