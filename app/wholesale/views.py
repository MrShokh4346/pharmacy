from datetime import datetime, timedelta, timezone
from fastapi import Depends, FastAPI, HTTPException, status
from jose import JWTError, jwt
from .schemas import *
from fastapi import APIRouter
from sqlalchemy.orm import Session
from models.database import get_db, get_or_404
from models.warehouse import ReportFactoryWerehouse, CurrentFactoryWarehouse, Wholesale, CurrentWholesaleWarehouse, ReportWholesaleWarehouse
from models.dependencies import *
from typing import Any, List
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials



router = FastAPI()


@router.post('/add-wholesale', response_model=WholesaleOutSchema)
async def wholesale(wholesale: WholesaleSchema, db: AsyncSession = Depends(get_db)):
    wholesale = Wholesale(**wholesale.dict())
    await wholesale.save(db)
    return wholesale


@router.get('/get-wholesales', response_model=List[WholesaleListSchema])
async def wholesale(db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(Wholesale))  
    return result.scalars().all()


@router.get('/get-wholesale/{wholesale_id}', response_model=WholesaleOutSchema)
async def wholesale(wholesale_id: int, db: AsyncSession = Depends(get_db)):
    result = await get_or_404(Wholesale, wholesale_id, db)  
    return result


@router.patch('/update-wholesale/{wholesale_id}', response_model=WholesaleOutSchema)
async def update_wholesale(wholesale_id: int, data: WholesaleUpdateSchema, db: AsyncSession = Depends(get_db)):
    wholesale = await get_or_404(Wholesale, wholesale_id, db) 
    await wholesale.update(**data.dict(), db=db)
    return wholesale


@router.post('/wholesale-add-product/{wholesale_id}')
async def wholesale_add_product(wholesale_id: int, product: WholesaleProductsInSchema, db: AsyncSession = Depends(get_db)):
    wholesale = await get_or_404(Wholesale, wholesale_id, db)
    await wholesale.add(**product.dict(), db=db)
    return {"msg":"Done"}


@router.get('/get-wholesale-products/{wholesale_id}', response_model=List[WholesaleProductsSchema])
async def get_wholesale_products(wholesale_id: int, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(CurrentWholesaleWarehouse).filter(CurrentWholesaleWarehouse.wholesale_id==wholesale_id))
    return result.scalars().all()


@router.get('/get-wholesale-warehouse-incomes/{wholesale_id}', response_model=List[WholesaleWarehouseIncomeOutSchema])
async def get_wholesale_warehouse_incomes(wholesale_id: int, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(ReportWholesaleWarehouse).filter(ReportWholesaleWarehouse.wholesale_id==wholesale_id))  
    return result.scalars().all()
