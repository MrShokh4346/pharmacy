from app.med_rep.wholesale_schemas import FactoryWarehouseOutSchema, WholesaleProductListSchema, WholesaleReportSchema, WholesaleReservationPayedAmountsSchema
from app.models.pharmacy import CurrentBalanceInStock, IncomingBalanceInStock
from app.models.users import Product
from fastapi import Depends
from app.common_depetencies import StartEndDates
from fastapi import APIRouter
from sqlalchemy.ext.asyncio import AsyncSession
from app.models.warehouse import CurrentWholesaleWarehouse, Wholesale, CurrentFactoryWarehouse, WholesaleReservationPayedAmounts
from app.models.database import get_db
from typing import List
from sqlalchemy.future import select
from sqlalchemy.orm import selectinload
from sqlalchemy import and_


router = APIRouter()


@router.get('/get-all-wholesale-products', response_model=List[WholesaleProductListSchema])
async def get_all_wholesale_products(db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(CurrentWholesaleWarehouse))
    return result.scalars().all()


@router.get('/search-wholesale-products', response_model=List[WholesaleProductListSchema])
async def search_for_med_rep_attached_doctors(region_id: int, search: str, db: AsyncSession = Depends(get_db)):
    query = (select(CurrentWholesaleWarehouse)
            .join(CurrentWholesaleWarehouse.product)
            .join(CurrentWholesaleWarehouse.wholesale)
            .where(
                and_(
                    Product.name.like(f'%{search}%'),
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
    result = await db.execute(select(CurrentFactoryWarehouse).filter(CurrentFactoryWarehouse.product.has(Product.name.like(f"%{search}%"))))
    return result.scalars().all()


@router.get('/wholesale-report-by-wholesale-id/{wholesale_id}', response_model=List[WholesaleReportSchema])
async def wholesale_report(wholesale_id: int, filter_date: StartEndDates, db: AsyncSession = Depends(get_db)):
    start_date = filter_date['start_date']
    end_date = filter_date['end_date']
    result = await db.execute(select(IncomingBalanceInStock).options(selectinload(IncomingBalanceInStock.wholesale), selectinload(IncomingBalanceInStock.pharmacy)).filter(IncomingBalanceInStock.wholesale_id == wholesale_id, IncomingBalanceInStock.date >= start_date, IncomingBalanceInStock.date <= end_date))
    objects = result.scalars().all()
    data = []
    for obj in objects:
        prd_list = []
        for product in obj.products:
            result = await db.execute(select(CurrentBalanceInStock).filter(CurrentBalanceInStock.pharmacy_id==obj.pharmacy.id, CurrentBalanceInStock.product_id==product.product.id))
            current_amount = result.scalars().first()
            prd_list.append({**product.__dict__, "current_amount":current_amount.amount})
        data.append({
            "date" : obj.date,
            "wholesale": {**obj.wholesale.__dict__},
            "pharmacy": {**obj.pharmacy.__dict__},
            "products": prd_list
        })
    return data


@router.get('/wholesale-report-by-wholesale-reservation-id/{reservation_id}', response_model=List[WholesaleReservationPayedAmountsSchema])
async def wholesale_report(reservation_id: int, filter_date: StartEndDates, db: AsyncSession = Depends(get_db)):
    start_date = filter_date['start_date']
    end_date = filter_date['end_date']
    result = await db.execute(select(WholesaleReservationPayedAmounts).filter(WholesaleReservationPayedAmounts.reservation_id == reservation_id, WholesaleReservationPayedAmounts.date >= start_date, WholesaleReservationPayedAmounts.date <= end_date))
    return result.scalars().all()
