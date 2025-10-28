from fastapi import  FastAPI
from fastapi.middleware.cors import CORSMiddleware
from auth.views import router as auth_router
from common.views import router as common_router
from ffm.views import router as ffm_router
from project_manager.views import router as pm_router
from region_manager.views import router as rm_router
from deputy_director.views import router as dd_router
from director.views import router as d_router
from db.db import Base
from models.database_chacker import delete_expired_objects
from expenses.endpoints.routers import router as ex_router
from med_rep.router import router as mr_router
from head_of_orders.views import router as ho_router
from wholesale.views import router as w_router
import asyncio
import os
from dotenv.main import load_dotenv

load_dotenv()

FASTAPI_ROOT_PATH = os.getenv("FASTAPI_ROOT_PATH")
app = FastAPI(root_path=FASTAPI_ROOT_PATH)

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

app.mount("/pm", pm_router)
app.mount("/common", common_router)
app.mount("/ffm", ffm_router)
app.mount("/rm", rm_router)
app.mount("/dd", dd_router)
app.mount("/d", d_router)
app.mount("/mr", mr_router)
app.mount("/head", ho_router)
app.mount("/ws", w_router)
app.mount("/ex", ex_router)


@app.on_event("startup")
async def start_background_tasks():
    asyncio.create_task(delete_expired_objects())




