from fastapi import Depends, FastAPI, HTTPException, status
from fastapi import APIRouter
from .end_categories import router as c_router 
from .end_expense import router as ex_router 
from .end_office import router as of_router
# from dotenv.main import load_dotenv
# import os

# load_dotenv()

# FASTAPI_ROOT_PATH = os.getenv("FASTAPI_ROOT_PATH")
# router = FastAPI(root_path=FASTAPI_ROOT_PATH)
router = FastAPI()

router.include_router(c_router)
router.include_router(ex_router)
router.include_router(of_router)


