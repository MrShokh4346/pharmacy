from datetime import datetime, timedelta, timezone
from fastapi import Depends, FastAPI, HTTPException, status
from jose import JWTError, jwt
from .schemas import *
from fastapi import APIRouter
from sqlalchemy.orm import Session
from models.users import *
from models.database import get_db
from models.dependencies import *
from typing import Any, List 
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from deputy_director.schemas import NotificationOutSchema


router = FastAPI()


@router.post('/register-for-rm', response_model=UserOutSchema, description='using RegisterForRMSchema')
async def register_user_for_rm(user: RegisterForRMSchema, manager: Annotated[Users, Depends(get_current_user)], token: HTTPAuthorizationCredentials = Depends(auth_header), db: Session = Depends(get_db)) -> Any:
    if manager.status == 'regional_manager':
        check_if_user_already_exists(username=user.username, db = db)
        new_user = Users(**user.dict(), region_manager_id=manager.id, ffm_id=manager.ffm_id, product_manager_id=manager.product_manager_id)
        new_user.save(db=db)
        return new_user
    raise HTTPException(status_code=403, detail="You are not a regional manager")


@router.get('/get-notifications', response_model=List[NotificationOutSchema])
async def notifications(user: Annotated[Users, Depends(get_current_user)], token: HTTPAuthorizationCredentials = Depends(auth_header), db: Session = Depends(get_db)):
    notifications = db.query(Notification).filter(Notification.region_manager_id==user.id).all()
    return notifications

