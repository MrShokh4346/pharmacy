from datetime import datetime, timedelta, timezone
from app.models.dependencies import check_if_user_already_exists, get_current_user, auth_header
from app.models.users import Users
from fastapi import Depends, FastAPI, HTTPException, status
from jose import JWTError, jwt
from .schemas import *
from fastapi import APIRouter
from models.database import get_db
from typing import Annotated, Any, List 
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from deputy_director.schemas import NotificationOutSchema
from sqlalchemy.ext.asyncio import AsyncSession
# from dotenv.main import load_dotenv

# load_dotenv()

# FASTAPI_ROOT_PATH = os.getenv("FASTAPI_ROOT_PATH")
# router = FastAPI(root_path=FASTAPI_ROOT_PATH)
router = FastAPI()

@router.post('/register-for-rm', response_model=UserOutSchema, description='using RegisterForRMSchema')
async def register_user_for_rm(user: RegisterForRMSchema, manager: Annotated[Users, Depends(get_current_user)], token: HTTPAuthorizationCredentials = Depends(auth_header), db: AsyncSession = Depends(get_db)) -> Any:
    if manager.status == 'regional_manager':
        check_if_user_already_exists(username=user.username, db = db)
        new_user = Users(**user.dict(), region_manager_id=manager.id, ffm_id=manager.ffm_id, product_manager_id=manager.product_manager_id, deputy_director_id=manager.deputy_director_id, director_id=manager.director_id)
        await new_user.save(db=db)
        return new_user
    raise HTTPException(status_code=403, detail="You are not a regional manager")

# #######
# @router.get('/get-notifications', response_model=List[NotificationOutSchema])
# async def notifications(user: Annotated[Users, Depends(get_current_user)], token: HTTPAuthorizationCredentials = Depends(auth_header), db: Session = Depends(get_db)):
#     notifications = db.query(Notification).filter(Notification.region_manager_id==user.id).all()
#     return notifications

