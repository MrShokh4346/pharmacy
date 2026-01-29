from fastapi import HTTPException
from sqlalchemy.future import select
from db.db import async_session

async def get_db():
    async with async_session() as session:
        yield session

async def get_or_404(model, id, db):
    obj = await db.get(model, id)
    if not obj:
        raise HTTPException(status_code=404, detail=f"{model.__name__} not found")
    return obj

async def check_exists(model, field, value, db):
    exists = await db.execute(select(model).filter(field == value))
    return exists.scalar_one_or_none()
