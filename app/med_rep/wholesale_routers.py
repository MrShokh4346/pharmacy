from datetime import datetime, timedelta, timezone, date
from fastapi import Depends, FastAPI, HTTPException, status
from jose import JWTError, jwt
from .wholesale_schemas import *
from fastapi import APIRouter
from sqlalchemy.ext.asyncio import AsyncSession
from models.pharmacy import *
from models.warehouse import CurrentWholesaleWarehouse, Wholesale, CurrentFactoryWarehouse
from models.database import get_db, get_or_404
from models.dependencies import *
from fastapi.security import HTTPAuthorizationCredentials
from typing import List
from sqlalchemy import text
from sqlalchemy.future import select
from sqlalchemy.orm import selectinload
from sqlalchemy import and_


router = APIRouter()


@router.get('/search-wholesale-products', response_model=List[WholesaleProductListSchema])
async def search_for_med_rep_attached_doctors(region_id: int, search: str, db: AsyncSession = Depends(get_db)):
    query = (select(CurrentWholesaleWarehouse)
            .join(CurrentWholesaleWarehouse.product)
            .join(CurrentWholesaleWarehouse.wholesale)
            .where(
                and_(
                    Products.name.like(f'%{search}%'),
                    Wholesale.region_id == region_id
                )
            )
            .options(
                selectinload(CurrentWholesaleWarehouse.product),
                selectinload(CurrentWholesaleWarehouse.wholesale)
            )
        )
    result = await db.execute(query)
    return result.scalars().all()


@router.get('/search-from-facroty-warehouse', response_model=List[FactoryWarehouseOutSchema])
async def search_from_factory_warehouse(search: str, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(CurrentFactoryWarehouse).filter(CurrentFactoryWarehouse.product.has(Products.name.like(f"%{search}%"))))
    return result.scalars().all()
