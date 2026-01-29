from app.models.dependencies import check_if_user_already_exists, get_current_user, auth_header
from app.models.users import Users
from fastapi import Depends, FastAPI, HTTPException
from .schemas import RegisterForRMSchema, UserOutSchema
from models.database import get_db
from typing import Annotated, Any 
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from sqlalchemy.ext.asyncio import AsyncSession

router = FastAPI()

@router.post('/register-for-rm', response_model=UserOutSchema, description='using RegisterForRMSchema')
async def register_user_for_rm(user: RegisterForRMSchema, manager: Annotated[Users, Depends(get_current_user)], token: HTTPAuthorizationCredentials = Depends(auth_header), db: AsyncSession = Depends(get_db)) -> Any:
    if manager.status == 'regional_manager':
        check_if_user_already_exists(username=user.username, db = db)
        new_user = Users(**user.dict(), region_manager_id=manager.id, ffm_id=manager.ffm_id, product_manager_id=manager.product_manager_id, deputy_director_id=manager.deputy_director_id, director_id=manager.director_id)
        await new_user.save(db=db)
        return new_user
    raise HTTPException(status_code=403, detail="You are not a regional manager")

