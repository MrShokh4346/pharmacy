from typing import List
from starlette.responses import JSONResponse
from sqlalchemy.future import select
from sqlalchemy import delete, update
from expenses.schemas.sch_office import OfficeSchema, OfficeGetSchema
from models.expenses import Office
from sqlalchemy.ext.asyncio import AsyncSession
from fastapi import FastAPI, Response, status, HTTPException, Depends, APIRouter
from models.database import get_db


router = APIRouter(
    # prefix="/",
    tags=["office"]
)


@router.post("/office", status_code=status.HTTP_201_CREATED, response_model=OfficeSchema)
async def create_office(office: OfficeSchema, db: AsyncSession = Depends(get_db)):
    new_office = Office(**office.dict())

    db.add(new_office)
    await db.commit()
    await db.refresh(new_office)

    return new_office


@router.get("/office", response_model=List[OfficeGetSchema])
async def get_office(db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(Office))
    office = result.scalars().all()

    return office


@router.get("/office/{id}", response_model=OfficeGetSchema)
async def get_office_id(id: int, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(Office).filter(Office.id == id))
    office = result.scalars().first()
    if not office:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND,
                            detail=f"post with id: {id} was not found")
    return office


@router.put("/office/{id}", response_model=OfficeGetSchema)
async def update_office(id: int, updated_office: OfficeSchema, db: AsyncSession = Depends(get_db)):

    office_query = select(Office).filter(Office.id == id)
    result = await db.execute(office_query)
    office = result.scalars().first()

    if office == None:  # so'ralgan id yo'q bo'lsa hato bermaslik uschun
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND,
                            detail=f"post with id: {id} does not exist")


    update_query = update(Office).where(Office.id == id).values(**updated_office.dict()).returning(Office)

    result = await db.execute(update_query)

    return result.scalar()


@router.delete("/office/{id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_office(id: int, db: AsyncSession = Depends(get_db)):

    result = await db.execute(select(Office).filter(Office.id == id))
    office = result.scalars().first()

    if office == None:  # so'ralgan id yo'q bo'lsa hato bermaslik uschun
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND,
                            detail=f"post with id: {id} does not exist")

    delete_query = delete(Office).where(Office.id == id)
    await db.execute(delete_query)
    await db.commit()

    return Response(status_code=status.HTTP_204_NO_CONTENT)