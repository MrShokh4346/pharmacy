from datetime import datetime, timedelta, timezone
from fastapi import Depends, FastAPI, HTTPException, status
from jose import JWTError, jwt
from .schemas import *
from fastapi import APIRouter
from sqlalchemy.orm import Session
from models.database import get_db, get_or_404
from models.warehouse import ReportFactoryWerehouse, CurrentFactoryWarehouse, Wholesale
from models.dependencies import *
from typing import Any, List
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials


router = FastAPI()


@router.post('/add-factory-warehouse')
async def add_to_factory_warehouse(obj: FactoryWarehouseInSchema, db: AsyncSession = Depends(get_db)):
    report = await ReportFactoryWerehouse.save(**obj.dict(), db=db)
    return {"msg":'Done'}


@router.get('/get-current-factory-warehouse/{factory_id}', response_model=List[FactoryWarehouseOutSchema])
async def get_current_factory_warehouse(factory_id: int, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(CurrentFactoryWarehouse).filter(CurrentFactoryWarehouse.factory_id==factory_id))
    return result.scalars().all()


@router.get('/get-factory-warehouse/{id}', response_model=FactoryWarehouseIncomeOutSchema)
async def get_factory_warehouse(id: int, db: AsyncSession = Depends(get_db)):
    return await get_or_404(ReportFactoryWerehouse, id, db) 


@router.get('/get-factory-warehouse-incomes/{factory_id}', response_model=List[FactoryWarehouseIncomeOutSchema])
async def get_factory_warehouse(factory_id: int, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(ReportFactoryWerehouse).filter(ReportFactoryWerehouse.factory_id==factory_id))  
    return result.scalars().all()


@router.post('/add-wholesale', response_model=WholesaleOutSchema)
async def wholesale(wholesale: WholesaleSchema, db: AsyncSession = Depends(get_db)):
    wholesale = Wholesale(**wholesale.dict())
    await wholesale.save(db)
    return wholesale


@router.get('/get-wholesales', response_model=List[WholesaleListSchema])
async def wholesale(db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(Wholesale))  
    return result.scalars().all()


@router.patch('/update-wholesale/{wholesale_id}', response_model=WholesaleOutSchema)
async def update_wholesale(wholesale_id: int, data: WholesaleUpdateSchema, db: AsyncSession = Depends(get_db)):
    wholesale = await get_or_404(Wholesale, wholesale_id, db) 
    await wholesale.update(**data.dict(), db=db)
    return wholesale


# @router.post('/wholesale-attach-product/{wholesale_id}')
# async def wholesale_attach_product(wholesale_id: int, product: WholesaleProductsListSchema, db: AsyncSession = Depends(get_db)):
#     wholesale = db.query(Wholesale).get(wholesale_id)
#     wholesale.attach(**product.dict(), db=db)
#     return {"msg":"Done"}


