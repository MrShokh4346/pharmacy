from datetime import datetime, timedelta, timezone, date
from fastapi import Depends, FastAPI, HTTPException, status
from jose import JWTError, jwt
from .wholesale_schemas import *
from fastapi import APIRouter
from sqlalchemy.ext.asyncio import AsyncSession
from models.pharmacy import *
from models.users import PharmacyPlan, Notification
from models.database import get_db, get_or_404
from models.dependencies import *
from fastapi.security import HTTPAuthorizationCredentials
from typing import List
from sqlalchemy import text
from sqlalchemy.future import select
from sqlalchemy.orm import selectinload


router = APIRouter()

# @router.post('/add-wholesale', response_model=WholesaleOutSchema)
# async def wholesale(wholesale: WholesaleSchema, db: AsyncSession = Depends(get_db)):
#     wholesale = Wholesale(**wholesale.dict())
#     wholesale.save(db)
#     return wholesale


# @router.patch('/update-wholesale/{wholesale_id}', response_model=WholesaleOutSchema)
# async def update_wholesale(wholesale_id: int, data: WholesaleUpdateSchema, db: AsyncSession = Depends(get_db)):
#     wholesale = db.query(Wholesale).get(wholesale_id)
#     wholesale.update(**data.dict(), db=db)
#     return wholesale


# @router.post('/wholesale-attach-product/{wholesale_id}')
# async def wholesale_attach_product(wholesale_id: int, product: WholesaleProductsListSchema, db: AsyncSession = Depends(get_db)):
#     wholesale = db.query(Wholesale).get(wholesale_id)
#     wholesale.attach(**product.dict(), db=db)
#     return {"msg":"Done"}


# @router.get('/search-wholesale-products', response_model=List[WholesaleOutSchema])
# async def search_for_med_rep_attached_doctors(region_id: int, search: str, db: AsyncSession = Depends(get_db)):
#     wholesale = db.query(Wholesale).filter(Wholesale.region_id==region_id, Wholesale.products.any(Products.name.like(f"%{search}%"))).all()
#     return wholesale


# @router.get('/search-from-warehouse', response_model=List[FactoryWarehouseOutSchema])
# async def search_from_factory_warehouse(search: str, db: AsyncSession = Depends(get_db)):
#     products = db.query(FactoryWarehouse).filter(FactoryWarehouse.product.has(Products.name.like(f"%{search}%"))).all()
#     return products