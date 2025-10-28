from datetime import datetime, timedelta, timezone
from fastapi import Depends, FastAPI, HTTPException, status
from jose import JWTError, jwt
from .schemas import *
from fastapi import APIRouter
from sqlalchemy.orm import Session
from models.database import get_db, get_or_404
from models.warehouse import ReportFactoryWerehouse, CurrentFactoryWarehouse, Wholesale, CurrentWholesaleWarehouse,  WholesaleOutput, WholesaleReservation, WholesaleReservationPayedAmounts
from models.pharmacy import CurrentBalanceInStock
from models.dependencies import *
from typing import Any, List
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
# from dotenv.main import load_dotenv

# load_dotenv()

# FASTAPI_ROOT_PATH = os.getenv("FASTAPI_ROOT_PATH")
# router = FastAPI(root_path=FASTAPI_ROOT_PATH)
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


# @router.get('/get-wholesale-warehouse-incomes/{wholesale_id}', response_model=List[WholesaleWarehouseIncomeOutSchema])
# async def get_wholesale_warehouse_incomes(wholesale_id: int, db: AsyncSession = Depends(get_db)):
#     result = await db.execute(select(ReportWholesaleWarehouse).filter(ReportWholesaleWarehouse.wholesale_id==wholesale_id))  
#     return result.scalars().all()


@router.post('/wholesale-output', response_model=WholesaleOutputOutSchema)
async def warehouse_output(data: WholesaleOutputSchema, db: AsyncSession = Depends(get_db)):
    output = WholesaleOutput(**data.dict())
    await output.save(data.wholesale_id, db)
    return output


@router.get('/get-wholesale-outputs', response_model=List[WholesaleOutputOutSchema])
async def get_wholesale_outputs(db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(WholesaleOutput))
    return result.scalars().all()


@router.post('/return-product/{wholesale_id}')
async def return_wholesale(wholesale_id: int, obj: ReturnProductSchema, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(CurrentBalanceInStock).filter(CurrentBalanceInStock.pharmacy_id==obj.pharmacy_id, CurrentBalanceInStock.product_id==obj.product_id))
    balance = result.scalars().first()
    if (balance is None) or (balance.amount < obj.amount):
        raise HTTPException(status_code=404, detail="There is not enough product in pharmacy")
    balance.amount -= obj.amount
    result = await db.execute(select(CurrentWholesaleWarehouse).filter(CurrentWholesaleWarehouse.wholesale_id==wholesale_id, CurrentWholesaleWarehouse.product_id==obj.product_id))
    wholesale_warehouse = result.scalars().first()
    if wholesale_warehouse is None:
        raise HTTPException(status_code=404, detail="There is not this product in wholesale")
    wholesale_warehouse.amount += obj.amount
    await db.commit()
    return {"msg":"Done"}



@router.post('/wholesale-reservation/{wholesale_id}', response_model=ReservationOutSchema)
async def wholesale_reservation(wholesale_id: int, res: WholesaleReservationSchema, db: AsyncSession = Depends(get_db)):
    pharmacy = await get_or_404(Wholesale, wholesale_id, db)
    reservation = await WholesaleReservation.save(**res.dict(), db=db, wholesale_id=wholesale_id)
    return reservation


@router.get('/get-wholesale-reservation-products/{reservation_id}', response_model=ReservationSchema)
async def get_hospital_reservation(reservation_id: int, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(WholesaleReservation).where(WholesaleReservation.id==reservation_id))
    res = result.scalar()
    if res is None:
        raise HTTPException(status_code=404, detail="Reservation no found")
    return res


@router.get('/get-wholesale-reservation-history/{reservation_id}', response_model=List[ReservationHistorySchema])
async def get_reservation_history(reservation_id: int, db: AsyncSession = Depends(get_db)):
    history = await db.execute(select(WholesaleReservationPayedAmounts).filter(WholesaleReservationPayedAmounts.reservation_id==reservation_id, WholesaleReservationPayedAmounts.payed==True))
    return history.scalars().all()


@router.get('/get-wholesale-report/{reservation_id}')
async def get_report(reservation_id: int, db: AsyncSession = Depends(get_db)):
    return await write_excel_wholesale(reservation_id, db)
