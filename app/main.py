from datetime import datetime, timedelta, timezone
from typing import Annotated

from fastapi import Depends, FastAPI, HTTPException, status
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from jose import JWTError, jwt
from pydantic import BaseModel
from auth.views import router as auth_router
from common.views import router as common_router
from ffm.views import router as ffm_router
from project_manager.views import router as pm_router
from region_manager.views import router as rm_router
from deputy_director.views import router as dd_router
from director.views import router as d_router
from models.database import SessionLocal, engine, Base
from fastapi.middleware.cors import CORSMiddleware


Base.metadata.create_all(bind=engine)

app = FastAPI()

origins = [
    "*"
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth_router)
app.include_router(pm_router)
app.include_router(common_router)
app.include_router(ffm_router)
app.include_router(rm_router)
app.include_router(dd_router)
app.include_router(d_router)





