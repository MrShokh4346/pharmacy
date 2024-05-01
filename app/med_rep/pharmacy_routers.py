from datetime import datetime, timedelta, timezone
from fastapi import Depends, FastAPI, HTTPException, status
from jose import JWTError, jwt
from .schemas import *
from fastapi import APIRouter
from sqlalchemy.orm import Session
from models.users import Users
from models.database import get_db

router = APIRouter()


@router.post('/add-pharmacy')
async def add_pharmacy(new_pharmacy: PharmacyAddSchema, db: Session = Depends(get_db)) -> PharmacyAddSchema:
    data = {}
    if new_pharmacy.med_rep_id is not None:
        med_rep = db.query(Users).filter(Users.id == new_pharmacy.med_rep_id).first()
        if not med_rep:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="There is not user with this id"
            )
            data['med_rep_id'] = med_rep.id
            data['region_manager_id'] = med_rep.region_manager_id
            data['ffm_id'] = med_rep.ffm_id
            data['product_manager_id'] = med_rep.product_manager_id
    else:
        region_manager = db.query(Users).filter(Users.id == new_pharmacy.region_manager_id).first()
        if not region_manager:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="There is not user with this id"
            )
    new_user = Users(**user.dict())
    new_user.save(db=db)
    return UserOutSchema(**new_user.__dict__)