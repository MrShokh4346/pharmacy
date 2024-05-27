from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from sqlalchemy import exists
from fastapi import HTTPException


SQLALCHEMY_DATABASE_URL = "sqlite:///./sql_app.db"
# SQLALCHEMY_DATABASE_URL = "postgresql://postgres:password@localhost:5432/pharmacy"

engine = create_engine(
    SQLALCHEMY_DATABASE_URL
)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

from sqlalchemy.orm import Session

def get_or_404(model, name: str, obj_id: int, db: Session):
    obj = db.query(model).get(obj_id) if obj_id > 0 else None
    if obj:
        return obj
    raise HTTPException(status_code=404, detail=f"There is not {name} with this id")


def check_exists(model, name: str, id: int, db: Session):
    ret = db.query(exists().where(model.id==id)).scalar()
    print(ret)
    if ret:
        return ret 
    raise HTTPException(status_code=404, detail=f"There is not {name} with this id")


Base = declarative_base()