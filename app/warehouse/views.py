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



