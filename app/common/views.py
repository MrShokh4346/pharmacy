from datetime import datetime, timedelta, timezone
from fastapi import Depends, FastAPI, HTTPException, status
from jose import JWTError, jwt
from .schemas import *
from fastapi import APIRouter
from sqlalchemy.orm import Session
from models.users import *
from models.dependencies import *
from models.database import get_db
from typing import Annotated, List
from fastapi.security import HTTPAuthorizationCredentials

router = APIRouter(prefix="/common")

@router.get("/get-regions", response_model=List[RegionSchema])
async def get_regions(db: Session = Depends(get_db)):
    regions = db.query(Region).all()
    return regions


@router.post("/add-region", response_model=List[RegionSchema])
async def add_region(name: str, token: HTTPAuthorizationCredentials = Depends(auth_header), db: Session = Depends(get_db)):
    region = Region(name = name)
    region.save(db)
    regions = db.query(Region).all()
    return regions


@router.get("/get-users", response_model=List[UserOutSchema])
async def get_users(user: Annotated[Users, Depends(get_current_user)], token: HTTPAuthorizationCredentials = Depends(auth_header), db: Session = Depends(get_db)):
    if user.status == 'director':
        users = db.query(Users).filter(Users.director_id == user.id).all()
    elif user.status == 'deputy_director':
        users = db.query(Users).filter(Users.deputy_director_id == user.id).all()
    elif user.status == 'product_manager':
        users = db.query(Users).filter(Users.product_manager_id == user.id).all()
    elif user.status == 'ff_manager':
        users = db.query(Users).filter(Users.ffm_id == user.id).all()
    elif user.status == 'regional_manager':
        users = db.query(Users).filter(Users.region_manager_id == user.id).all()
    else:
        return []
    return users


