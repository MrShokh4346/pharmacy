from datetime import datetime, timedelta, timezone
from fastapi import Depends, FastAPI, HTTPException, status
from jose import JWTError, jwt
from .schemas import *
from fastapi import APIRouter
from sqlalchemy.orm import Session
from models.users import *
from models.dependencies import *
from models.database import get_db
from typing import Annotated, List

router = APIRouter(prefix="/common")

# @router.post("/login")
# async def login_for_access_token(user: LoginSchema, db: Session = Depends(get_db)) -> TokenSchema:

@router.get("/get-regions", response_model=List[RegionSchema])
async def get_regions(db: Session = Depends(get_db)):
    stmt = db.query(Region).all()
    # regions = session.scalars(stmt).all()
    # lst = []
    # for region in regions:
        # lst.append({"id":region.id})
    return stmt







# async def get_regions(user: Annotated[Users, Depends(get_current_user)])
