from datetime import datetime, timedelta, timezone
from fastapi import Depends, FastAPI, HTTPException, status
from jose import JWTError, jwt
from models.users import *
from fastapi import APIRouter
from sqlalchemy.orm import Session
from models.database import get_db
from models.dependencies import *
from fastapi.security import HTTPAuthorizationCredentials
from typing import List
from .user_schemas import *
from deputy_director.schemas import NotificationOutSchema


router = APIRouter()


@router.get('/get-notifications', response_model=List[NotificationOutSchema])
async def notifications(user: Annotated[Users, Depends(get_current_user)], token: HTTPAuthorizationCredentials = Depends(auth_header), db: Session = Depends(get_db)):
    check_if_med_rep(user)
    notifications = db.query(Notification).filter(Notification.med_rep_id==user.id).all()
    return notifications


