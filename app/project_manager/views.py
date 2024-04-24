from datetime import datetime, timedelta, timezone
from fastapi import Depends, FastAPI, HTTPException, status
from jose import JWTError, jwt
from .schemas import *
from fastapi import APIRouter
from models.dependencies import create_access_token
from sqlalchemy.orm import Session
from models.users import *
from models.database import get_db
from models.dependencies import *
from typing import Any


router = APIRouter(prefix="/pm")


@router.post('/register-for-pm', response_model=UserOutSchema, response_model_exclude_unset=True)
async def register_user_for_pm(user: RegisterForPMSchema, manager: Annotated[Users, Depends(get_current_user)], db: Session = Depends(get_db)) -> Any:
    check_if_user_already_exists(username=user.username)
    if user.status == 'medical_representative':
        if not (user.region_manager_id and user.ffm_id):
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="region_manager_id, ffm_id should be declared"
            )
        new_user = Users(**user.dict(), project_manager_id=manager.id)
        new_user.save(db=db)
    elif user.status == 'regional_manager':
        if not user.ffm_id:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="ffm_id should be declared"
            )
        new_user = Users(**user.dict(), project_manager_id=manager.id)
        new_user.save(db=db)
    else:
        new_user = Users(**user.dict(), project_manager_id=manager.id)
        new_user.save(db=db)
    print(**new_user.__dict__)
    return new_user
    # return UserOutSchema(**new_user.__dict__)