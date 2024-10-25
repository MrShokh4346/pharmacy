from fastapi import Depends, FastAPI, HTTPException, status
from fastapi import APIRouter
from .end_categories import router as c_router 
from .end_expense import router as ex_router 
from .end_office import router as of_router


router = FastAPI()

router.include_router(c_router)
router.include_router(ex_router)
router.include_router(of_router)


