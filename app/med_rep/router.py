from fastapi import Depends, FastAPI, HTTPException, status
from fastapi import APIRouter
from .pharmacy_routers import router as ph_router 
from .doctor_rourers import router as dr_router 
from .user_routers import router as ur_router 


router = FastAPI()

router.include_router(ph_router)
router.include_router(dr_router)
router.include_router(ur_router)



