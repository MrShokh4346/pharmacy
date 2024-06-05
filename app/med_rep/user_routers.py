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

# ########
# @router.get('/get-notifications', response_model=List[NotificationOutSchema])
# async def notifications(user: Annotated[Users, Depends(get_current_user)], token: HTTPAuthorizationCredentials = Depends(auth_header), db: Session = Depends(get_db)):
#     check_if_med_rep(user)
#     notifications = db.query(Notification).filter(Notification.med_rep_id==user.id).all()
#     return notifications







# UPDATE medical_organization 
# SET med_rep_id = NULL 
# WHERE med_rep_id IN (SELECT id FROM users WHERE status = 'medical_representative' AND id != 31 AND id != 32);





# BEGIN;

# UPDATE users 
# SET medical_representative_id = NULL 
# WHERE medical_representative_id IN (SELECT id FROM users WHERE status = 'medical_representative' AND id != 31 AND id != 32);

# UPDATE pharmacy 
# SET medical_representative_id = NULL 
# WHERE medical_representative_id IN (SELECT id FROM users WHERE status = 'medical_representative' AND id != 31 AND id != 32);

# UPDATE doctor 
# SET medical_representative_id = NULL 
# WHERE medical_representative_id IN (SELECT id FROM users WHERE status = 'medical_representative' AND id != 31 AND id != 32);

# DELETE FROM users 
# WHERE status = 'medical_representative' AND id != 31 AND id != 32;

# COMMIT;

# DELETE FROM products WHERE id=1;




# #med rep
# BEGIN;

# UPDATE pharmacy 
# SET med_rep_id = NULL 
# WHERE med_rep_id IN (SELECT id FROM users WHERE status = 'medical_representative');

# UPDATE doctor 
# SET med_rep_id = NULL 
# WHERE med_rep_id IN (SELECT id FROM users WHERE status = 'medical_representative');

# UPDATE doctor_plan 
# SET med_rep_id = NULL 
# WHERE med_rep_id IN (SELECT id FROM users WHERE status = 'medical_representative');

# UPDATE pharmacy_plan 
# SET med_rep_id = NULL 
# WHERE med_rep_id IN (SELECT id FROM users WHERE status = 'medical_representative');

# DELETE FROM users 
# WHERE status = 'medical_representative';

# COMMIT;

