from sqlalchemy.ext.asyncio import AsyncSession, create_async_engine
from sqlalchemy.orm import sessionmaker, declarative_base
from fastapi import HTTPException
from sqlalchemy.future import select
from sqlalchemy.orm import lazyload

DATABASE_URL = "postgresql+asyncpg://postgres:password@localhost:5432/test_pharmacy"

engine = create_async_engine(DATABASE_URL)
async_session = sessionmaker(engine, expire_on_commit=False, class_=AsyncSession)

Base = declarative_base()

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
