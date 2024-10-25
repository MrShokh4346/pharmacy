# from sqlalchemy import Column, Integer, String, Boolean ,ForeignKey, DateTime
# from sqlalchemy.orm import relationship
# from sqlalchemy.sql.expression import null, text
# from sqlalchemy.sql.sqltypes import TIMESTAMP
# from datetime import datetime

# from db.db import Base


# # class Office(Base):
# #     __tablename__ = "office"

# #     id = Column(Integer, primary_key=True, nullable=False)
# #     name = Column(String(50), unique=True, index=True, nullable=False)
# #     status = Column(Boolean, nullable=False)
# #     created_at = Column(TIMESTAMP(timezone=True), nullable=False, server_default=text('now()'))
# #     updated_at = Column(TIMESTAMP(timezone=True), nullable=False, server_default=text('now()'))

# #     expense = relationship("Expense", back_populates="office")
# #     expense_categories = relationship("ExpenseCategories", back_populates="office")



# class Office(Base):
#     __tablename__ = "office"

#     id = Column(Integer, primary_key=True)
#     name = Column(String, unique=True)
#     status = Column(String)
#     created_at = Column(DateTime, default=datetime.now())
#     updated_at = Column(DateTime, default=datetime.now())

#     region = relationship("Region",  backref="med_org", lazy='selectin')
#     region_id = Column(Integer, ForeignKey("region.id"))

#     # expense = relationship("Expense",  backref="office")
#     # expense_categories


