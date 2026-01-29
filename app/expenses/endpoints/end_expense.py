from typing import List
from sqlalchemy.future import select
from sqlalchemy import delete, update
from expenses.schemas.sch_expense import ExpenseSchema, ExpenseGetSchema
from models.expenses import Expense
from sqlalchemy.ext.asyncio import AsyncSession
from fastapi import FastAPI, Response, status, HTTPException, Depends, APIRouter
from models.database import get_db

router = APIRouter(
    # prefix="/",
    tags=["expense"]
)


@router.post("/expense", status_code=status.HTTP_201_CREATED, response_model=ExpenseSchema)
async def create_expense(expense: ExpenseSchema, db: AsyncSession = Depends(get_db)):
    new_expense = Expense(**expense.dict())

    db.add(new_expense)
    await db.commit()
    await db.refresh(new_expense)
    return new_expense


@router.get("/expense", response_model=List[ExpenseGetSchema])
async def get_expense(db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(Expense))
    expense = result.scalars().all()
    return expense


@router.get("/expense/{id}", response_model=ExpenseGetSchema)
async def get_expense_id(id: int, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(Expense).filter(Expense.id == id))
    expense = result.scalars().first()
    if not expense:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND,
                            detail=f"post with id: {id} was not found")
    return expense


@router.put("/expense/{id}", response_model=ExpenseGetSchema)
async def update_expense(id: int, updated_expense: ExpenseSchema, db: AsyncSession = Depends(get_db)):

    query = select(Expense).filter(Expense.id == id)
    result = await db.execute(query)
    expense = result.scalars().first()

    if expense == None:  # so'ralgan id yo'q bo'lsa hato bermaslik uschun
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND,
                            detail=f"post with id: {id} does not exist")


    update_query = update(Expense).where(Expense.id == id).values(**updated_expense.dict()).returning(Expense)

    result = await db.execute(update_query)
    await db.commit()

    return result.scalar()


@router.delete("/expense/{id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_expense(id: int, db: AsyncSession = Depends(get_db)):

    result = await db.execute(select(Expense).filter(Expense.id == id))
    expense = result.scalars().first()

    if expense == None:  # so'ralgan id yo'q bo'lsa hato bermaslik uschun
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND,
                            detail=f"post with id: {id} does not exist")
    delete_query = delete(Expense).where(Expense.id == id)
    await db.execute(delete_query)
    await db.commit()
    return Response(status_code=status.HTTP_204_NO_CONTENT)