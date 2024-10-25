# from sqlalchemy import Column, Integer, String, Boolean ,ForeignKey, DateTime
# from sqlalchemy.orm import relationship
# from sqlalchemy.sql.expression import null, text
# from sqlalchemy.sql.sqltypes import TIMESTAMP
# from datetime import datetime


# from db.db import Base

# # class ExpenseCategories(Base):
# #     __tablename__ = "expense_categories"

# #     id = Column(Integer, primary_key=True, nullable=False)
# #     name = Column(String(50), unique=True, index=True, nullable=False)
# #     office_id = Column(Integer, ForeignKey("office.id", ondelete="SET NULL"))
# #     status = Column(Boolean, nullable=False)
# #     created_at = Column(TIMESTAMP(timezone=True), nullable=False, server_default=text('now()'))
# #     updated_at = Column(TIMESTAMP(timezone=True), nullable=False, server_default=text('now()'))

# #     expense = relationship("Expense", back_populates="expense_categories")
# #     office = relationship("Office", back_populates="expense_categories")

    
# class ExpenseCategories(Base):
#     __tablename__ = "expense_categories"

#     id = Column(Integer, primary_key=True)
#     name = Column(String, unique=True)
#     office_id = Column(Integer, ForeignKey("office.id")) 
#     status = Column(Boolean)
#     created_at = Column(DateTime, default=datetime.now())
#     updated_at = Column(DateTime, default=datetime.now())

#     office = relationship("Office",  backref="expense_categories")
#     # expense = relationship("Expense",  backref="expense_categories")