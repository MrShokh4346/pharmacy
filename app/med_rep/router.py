from fastapi import Depends, FastAPI, HTTPException, status
from fastapi import APIRouter
from .pharmacy_routers import router as ph_router 
from .doctor_routers import router as dr_router 
from .hospital_routers import router as ur_router 
from .wholesale_routers import router as wh_router


router = FastAPI()

router.include_router(ph_router)
router.include_router(dr_router)
router.include_router(ur_router)
router.include_router(wh_router)




