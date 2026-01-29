from typing import List
from sqlalchemy.future import select
from sqlalchemy import delete, update
from expenses.schemas.sch_categories import ExpenseCategoriesSchema, CategoriesGetSchema
from models.expenses import ExpenseCategories
from sqlalchemy.ext.asyncio import AsyncSession
from fastapi import Response, status, HTTPException, Depends, APIRouter
from models.database import get_db


router = APIRouter(
    # prefix="/",
    tags=["categories"]
)


@router.post("/categories", status_code=status.HTTP_201_CREATED, response_model=ExpenseCategoriesSchema)
async def create_categories(categories: ExpenseCategoriesSchema, db: AsyncSession = Depends(get_db)):
    new_categories = ExpenseCategories(**categories.dict())

    db.add(new_categories)
    await db.commit()
    return new_categories


@router.get("/categories", response_model=List[CategoriesGetSchema])
async def get_categories(db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(ExpenseCategories))
    categories = result.scalars().all()
    return categories


@router.get("/categories/{id}", response_model=CategoriesGetSchema)
async def get_categories_id(id: int, db: AsyncSession = Depends(get_db)):
    # categories = db.query(ExpenseCategories).filter(ExpenseCategories.id == id).first()
    result = await db.execute(select(ExpenseCategories).filter(ExpenseCategories.id == id))
    categories = result.scalars().first()

    if not categories:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND,
                            detail=f"post with id: {id} was not found")
    return categories


@router.put("/categories/{id}", response_model=CategoriesGetSchema)
async def update_categories(id: int, updated_categories: ExpenseCategoriesSchema, db: AsyncSession = Depends(get_db)):
   
    query = select(ExpenseCategories).filter(ExpenseCategories.id == id)
    result = await db.execute(query)
    category = result.scalars().first()

    if category == None:  # so'ralgan id yo'q bo'lsa hato bermaslik uschun
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND,
                            detail=f"post with id: {id} does not exist")


    update_query = update(ExpenseCategories).where(ExpenseCategories.id == id).values(**updated_categories.dict()).returning(ExpenseCategories)

    result = await db.execute(update_query)
    await db.commit()

    return result.scalar()


@router.delete("/categories/{id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_category(id: int, db: AsyncSession = Depends(get_db)):

    result = await db.execute(select(ExpenseCategories).filter(ExpenseCategories.id == id))
    categories = result.scalars().first()

    if categories == None:  # so'ralgan id yo'q bo'lsa hato bermaslik uschun
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND,
                            detail=f"post with id: {id} does not exist")

    delete_query = delete(ExpenseCategories).where(ExpenseCategories.id == id)
    await db.execute(delete_query)
    await db.commit()

    return Response(status_code=status.HTTP_204_NO_CONTENT)