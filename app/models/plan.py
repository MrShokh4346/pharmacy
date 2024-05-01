from sqlalchemy import Boolean, Column, ForeignKey, Integer, String, DateTime
from datetime import datetime
from sqlalchemy.orm import relationship
from sqlalchemy.orm import Session
from fastapi import Depends, FastAPI, HTTPException, status
from .users import *
from .pharmacy import *
from .doctors import *

from .database import Base, get_db


class Plan(Base):
    __tablename__ = "plan"

    id = Column(Integer, primary_key=True)
    date = Column(DateTime, default=datetime.now())
    description = Column(String)

    medical_organization_id = Column(Integer, ForeignKey("medical_organization.id"))
    medical_organization = relationship("MedicalOrganization", backref="plan")
    pharmacy = relationship("Pharmacy", backref="plan")
    pharmacy_id = Column(Integer, ForeignKey("pharmacy.id"))
    med_rep = relationship("Users", backref="plan")
    med_rep_id = Column(Integer, ForeignKey("users.id"))
    

class PlanAttachedProduct(Base):
    __tablename__ = "plan_attached_product"

    id = Column(Integer, primary_key=True)
    quantity = Column(Integer)

    product = relationship("Products", backref="planattachedproduct")
    product_id = Column(Integer, ForeignKey("products.id"))
    plan = relationship("Plan", backref="planattachedproduct")
    plan_id = Column(Integer, ForeignKey("plan.id"))


class RoutePlanMonth(Base):
    __tablename__ = "route_plan_month"

    id = Column(Integer, primary_key=True)
    remains = Column(Integer)
    month = Column(String)

    plan = relationship("Plan", backref="routeplanmonth")
    plan_id = Column(Integer, ForeignKey("plan.id"))


class RoutePlanWeek(Base):
    __tablename__ = "route_plan_week"

    id = Column(Integer, primary_key=True)
    remains = Column(Integer)
    load = Column(Integer)
    date = Column(DateTime, default=datetime.now())

    plan_month = relationship("RoutePlanMonth", backref="routeplanweek")
    plan_month_id = Column(Integer, ForeignKey("route_plan_month.id"))


