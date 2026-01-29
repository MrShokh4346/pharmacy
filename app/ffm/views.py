from app.auth.schemas import UserOutSchema
from app.ffm.schemas import RegisterForFFMSchema
from app.models.dependencies import check_if_user_already_exists, get_current_user, auth_header
from app.models.users import Users
from fastapi import Depends, FastAPI, HTTPException, status
from sqlalchemy.orm import Session
from app.models.database import get_db
from typing import Annotated, Any
from fastapi.security import HTTPAuthorizationCredentials

router = FastAPI()

@router.post('/register-for-ffm', response_model=UserOutSchema, description='using RegisterForFFMSchema')
async def register_user_for_ffm(user: RegisterForFFMSchema, manager: Annotated[Users, Depends(get_current_user)], token: HTTPAuthorizationCredentials = Depends(auth_header), db: Session = Depends(get_db)) -> Any:
    if manager.status == 'ff_manager':
        check_if_user_already_exists(username=user.username, db = db)
        if user.status == 'medical_representative':
            if not user.region_manager_id:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="region_manager_id should be declared"
                )
            new_user = Users(**user.dict(), ffm_id=manager.id, product_manager_id=manager.product_manager_id, deputy_director_id=manager.deputy_director_id, director_id=manager.director_id)
            new_user.save(db=db)
        else:
            new_user = Users(**user.dict(), ffm_id=manager.id, product_manager_id=manager.product_manager_id, deputy_director_id=manager.deputy_director_id, director_id=manager.director_id)
            new_user.save(db=db)
        return new_user
    raise HTTPException(status_code=403, detail="You are not a field force manager")


