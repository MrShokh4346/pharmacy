# from sqlalchemy import Column, Integer, String, Boolean ,ForeignKey, DateTime
# from sqlalchemy.orm import relationship
# from sqlalchemy.sql.expression import null, text
# from sqlalchemy.sql.sqltypes import TIMESTAMP
# from datetime import datetime


# from db.db import Base


# # class Expense(Base):
# #     __tablename__ = "expense"

# #     id = Column(Integer, primary_key=True, nullable=False)
# #     who_added = Column(String(50), index=True, nullable=False)
# #     categories_id = Column(Integer, ForeignKey("expense_categories.id", ondelete="SET NULL"))
# #     office_id = Column(Integer, ForeignKey("office.id", ondelete="SET NULL"))
# #     amount = Column(Integer, nullable=False)
# #     description = Column(String , index=True, nullable=False)
# #     status = Column(Boolean, nullable=False)
# #     created_at = Column(TIMESTAMP(timezone=True), nullable=False, server_default=text('now()'))
# #     updated_at = Column(TIMESTAMP(timezone=True), nullable=False, server_default=text('now()'))

# #     expense_categories = relationship("ExpenseCategories", back_populates="expense")
# #     office = relationship("Office", back_populates="expense")



# class Expense(Base):
#     __tablename__ = "expense"

#     id = Column(Integer, primary_key=True)
#     name = Column(String, unique=True)
#     who_added = Column(String)
#     categories_id = Column(Integer, ForeignKey("expense_categories.id")) 
#     office_id = Column(Integer, ForeignKey("office.id")) 
#     amount = Column(Integer)
#     description = Column(String)
#     status = Column(Boolean)
#     created_at = Column(DateTime, default=datetime.now())
#     updated_at = Column(DateTime, default=datetime.now())

#     office = relationship("Office",  backref="expense")
#     expense_categories = relationship("ExpenseCategories",  backref="expense")