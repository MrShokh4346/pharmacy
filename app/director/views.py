from app.auth.schemas import UserOutSchema
from app.director.schemas import RegisterForDSchema
from app.models.dependencies import check_if_user_already_exists, get_current_user, auth_header
from app.models.users import Users
from fastapi import Depends, FastAPI, HTTPException, status
from fastapi import APIRouter
from app.models.database import get_db
from typing import Annotated, Any
from fastapi.security import HTTPAuthorizationCredentials
from sqlalchemy.ext.asyncio import AsyncSession


router = FastAPI()

@router.post('/register-for-d', response_model=UserOutSchema, description='using RegisterForDSchema')
async def register_user_for_pm(user: RegisterForDSchema, manager: Annotated[Users, Depends(get_current_user)], token: HTTPAuthorizationCredentials = Depends(auth_header), db: AsyncSession = Depends(get_db)) -> Any:
    if manager.status == 'director':
        check_if_user_already_exists(username=user.username, db = db)
        if user.status == 'medical_representative':
            if not (user.region_manager_id and user.ffm_id and user.product_manager_id and user.deputy_director_id):
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="region_manager_id, ffm_id, product_manager_id, deputy_director_id should be declared"
                )
            new_user = Users(**user.dict(), director_id=manager.id)
            await new_user.save(db=db)
        elif user.status == 'regional_manager':
            if not (user.ffm_id and user.product_manager_id and user.deputy_director_id):
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="ffm_id, product_manager_id, deputy_director_id should be declared"
                )
            new_user = Users(**user.dict(), director_id=manager.id)
            await new_user.save(db=db)
        elif user.status == 'ff_manager':
            if not (user.product_manager_id and user.deputy_director_id):
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="product_manager_id, deputy_director_id should be declared"
                )
            new_user = Users(**user.dict(), director_id=manager.id)
            await new_user.save(db=db)
        elif user.status == 'product_manager':
            if not user.deputy_director_id:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="deputy_director_id should be declared"
                )
            new_user = Users(**user.dict(), director_id=manager.id)
            await new_user.save(db=db)
        else:
            new_user = Users(**user.dict(), director_id=manager.id)
            await new_user.save(db=db)
        return new_user
    raise HTTPException(status_code=403, detail="You are not a director")


