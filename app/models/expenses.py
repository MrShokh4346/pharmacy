from sqlalchemy import Column, Integer, String, Boolean ,ForeignKey, DateTime
from sqlalchemy.orm import relationship
from sqlalchemy.sql.expression import null, text
from sqlalchemy.sql.sqltypes import TIMESTAMP
from datetime import datetime
from db.db import Base



class Expense(Base):
    __tablename__ = "expense"
    __table_args__ = {'extend_existing': True}
    

    id = Column(Integer, primary_key=True)
    name = Column(String, unique=True)
    who_added = Column(String)
    categories_id = Column(Integer, ForeignKey("expense_categories.id"), index=True) 
    office_id = Column(Integer, ForeignKey("office.id"), index=True) 
    amount = Column(Integer)
    description = Column(String)
    status = Column(Boolean)
    created_at = Column(DateTime, default=datetime.now(), index=True)
    updated_at = Column(DateTime, default=datetime.now())

    office = relationship("app.models.expenses.Office",  backref="expense")
    expense_categories = relationship("app.models.expenses.ExpenseCategories",  backref="expense")


class ExpenseCategories(Base):
    __tablename__ = "expense_categories"
    __table_args__ = {'extend_existing': True}
    

    id = Column(Integer, primary_key=True)
    name = Column(String, unique=True)
    office_id = Column(Integer, ForeignKey("office.id"), index=True) 
    status = Column(Boolean)
    created_at = Column(DateTime, default=datetime.now(), index=True)
    updated_at = Column(DateTime, default=datetime.now())

    office = relationship("app.models.expenses.Office",  backref="expense_categories")
    # expense = relationship("Expense",  backref="expense_categories")


class Office(Base):
    __tablename__ = "office"
    __table_args__ = {'extend_existing': True}
    

    id = Column(Integer, primary_key=True)
    name = Column(String, unique=True)
    status = Column(Boolean)
    created_at = Column(DateTime, default=datetime.now(), index=True)
    updated_at = Column(DateTime, default=datetime.now())

    # expense = relationship("Expense",  backref="office")
    # expense_categories


