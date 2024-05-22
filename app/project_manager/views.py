from datetime import datetime, timedelta, timezone
from fastapi import Depends, FastAPI, HTTPException, status
from jose import JWTError, jwt
from .schemas import *
from fastapi import APIRouter
from sqlalchemy.orm import Session
from models.users import *
from models.database import get_db
from models.dependencies import *
from typing import Any
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials


router = FastAPI()


@router.post('/register-for-pm', response_model=UserOutSchema, description='using RegisterForPMSchema')
async def register_user_for_pm(user: RegisterForPMSchema, manager: Annotated[Users, Depends(get_current_user)], token: HTTPAuthorizationCredentials = Depends(auth_header), db: Session = Depends(get_db)) -> Any:
    if manager.status == 'product_manager':
        check_if_user_already_exists(username=user.username, db = db)
        if user.status == 'medical_representative':
            if not (user.region_manager_id and user.ffm_id):
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="region_manager_id, ffm_id should be declared"
                )
            new_user = Users(**user.dict(), product_manager_id=manager.id, deputy_director_id=manager.deputy_director_id, director_id=manager.director_id)
            new_user.save(db=db)
        elif user.status == 'regional_manager':
            if not user.ffm_id:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="ffm_id should be declared"
                )
            new_user = Users(**user.dict(), product_manager_id=manager.id, deputy_director_id=manager.deputy_director_id, director_id=manager.director_id)
            new_user.save(db=db)
        else:
            new_user = Users(**user.dict(), product_manager_id=manager.id, deputy_director_id=manager.deputy_director_id, director_id=manager.director_id)
            new_user.save(db=db)
        return new_user
    raise HTTPException(status_code=403, detail="You are not a product manager")



