from sqlalchemy.ext.asyncio import AsyncSession, create_async_engine
from sqlalchemy.orm import sessionmaker, declarative_base
from fastapi import HTTPException
from sqlalchemy.future import select
from sqlalchemy.orm import lazyload
import os
from dotenv.main import load_dotenv

load_dotenv()

# Ensure all required environment variables are set
required_env_vars = ['POSTGRES_USER', 'POSTGRES_PASSWORD', 'DB_HOST', 'DB_PORT', 'POSTGRES_DATABASE']
for var in required_env_vars:
    if not os.getenv(var):
        raise ValueError(f"Environment variable {var} is not set")
# DATABASE_URL = os.getenv("DATABASE_URL")
DATABASE_URL = f"postgresql+asyncpg://{os.getenv('POSTGRES_USER')}:{os.getenv('POSTGRES_PASSWORD')}@{os.getenv('DB_HOST')}:{os.getenv('DB_PORT')}/{os.getenv('POSTGRES_DATABASE')}"

# Create async engine with connection pooling settings
engine = create_async_engine(
    DATABASE_URL,
    pool_size=20,           # Keep 20 connections open
    max_overflow=10,        # Allow up to 10 extra connections under load
    pool_timeout=30,        # Wait 30 seconds for a connection
    pool_recycle=1800,      # Recycle connections after 30 minutes
    pool_pre_ping=True      # Check connection health before use
)

# Session factory for async sessions
async_session = sessionmaker(
    engine,
    expire_on_commit=False,
    class_=AsyncSession
)

Base = declarative_base()




