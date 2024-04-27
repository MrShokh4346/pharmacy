from sqlalchemy import Boolean, Column, ForeignKey, Integer, String
from sqlalchemy.orm import relationship
# from .dependencies import get_password_hash, verify_password
from sqlalchemy.orm import Session
from fastapi import Depends, FastAPI, HTTPException, status
from .pharmacy import *
from .plan import *
from .doctors import *
from passlib.context import CryptContext

from .database import Base, get_db


pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")


def verify_password(plain_password, hashed_password):
    return pwd_context.verify(plain_password, hashed_password)


def get_password_hash(password):
    return pwd_context.hash(password)


class Region(Base):
    __tablename__ = "region"

    id = Column(Integer, primary_key=True)
    name = Column(String)
    
    def save(self, db: Session):
        try:
            db.add(self)
            db.commit()
            db.refresh(self)
        except:
            raise AssertionError("Could not save")


class ManufacturedCompany(Base):
    __tablename__ = "manufactured_company"

    id = Column(Integer, primary_key=True)
    name = Column(String)


class Products(Base):
    __tablename__ = "products"

    id = Column(Integer, primary_key=True)
    name = Column(String)
    price = Column(Integer)
    man_company = relationship("ManufacturedCompany", cascade='all, delete', backref="product")
    man_company_id = Column(Integer, ForeignKey("manufactured_company.id", ondelete='CASCADE'), nullable=False)


class UserAttachedProduct(Base):
    __tablename__ = "user_attached_product"

    id = Column(Integer, primary_key=True)
    product = relationship("Products", cascade='all, delete', backref="attch_prd")
    product_id = Column(Integer, ForeignKey("products.id", ondelete='CASCADE'), nullable=False)
    user = relationship("Users", cascade='all, delete', backref="ur_attch_prd")
    user_id = Column(Integer, ForeignKey("users.id", ondelete='CASCADE'), nullable=False)


class DoctorMonthlyPlan(Base):
    __tablename__ = "doctor_monthly_plan"

    id = Column(Integer, primary_key=True)
    month_name = Column(String)
    date = Column(DateTime, default=datetime.now())

    user = relationship("Users", cascade='all, delete', backref="dm_plan")
    user_id = Column(Integer, ForeignKey("users.id", ondelete='CASCADE'), nullable=False)


class DoctorPlan(Base):
    __tablename__ = "doctor_plan"

    id = Column(Integer, primary_key=True)
    name = Column(String)
    doctor_plan = relationship("DoctorMonthlyPlan", cascade='all, delete', backref="dm_plan")
    doctor_plan_id = Column(Integer, ForeignKey("doctor_monthly_plan.id", ondelete='CASCADE'), nullable=False)


class PharmacyMonthlyPlan(Base):
    __tablename__ = "pharmacy_monthly_plan"

    id = Column(Integer, primary_key=True)
    month_name = Column(String)
    date = Column(DateTime, default=datetime.now())

    user = relationship("Users", cascade='all, delete', backref="pm_plan")
    user_id = Column(Integer, ForeignKey("users.id", ondelete='CASCADE'), nullable=False)


class PharmacyPlan(Base):
    __tablename__ = "pharmacy_plan"

    id = Column(Integer, primary_key=True)
    name = Column(String)
    pharmacy_plan = relationship("PharmacyMonthlyPlan", cascade='all, delete', backref="phm_plan")
    pharmacy_plan_id = Column(Integer, ForeignKey("pharmacy_monthly_plan.id", ondelete='CASCADE'), nullable=False)


class Users(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True)
    full_name = Column(String)
    username = Column(String, unique=True)
    hashed_password = Column(String)
    status = Column(String)
    deleted = Column(Boolean, default=False)

    region = relationship("Region", cascade='all, delete', backref="user")
    region_id = Column(Integer, ForeignKey("region.id", ondelete='CASCADE'))  #####
    region_manager_id = Column(Integer, ForeignKey("users.id", ondelete='CASCADE'))      #####
    region_manager = relationship("Users", cascade='all, delete', remote_side=[id], foreign_keys=[region_manager_id])
    ffm_id = Column(Integer, ForeignKey("users.id", ondelete='CASCADE'))               #####  
    ffm = relationship("Users", cascade='all, delete', remote_side=[id], foreign_keys=[ffm_id])
    product_manager_id = Column(Integer, ForeignKey("users.id", ondelete='CASCADE'))    #####
    product_manager = relationship("Users", cascade='all, delete', remote_side=[id], foreign_keys=[product_manager_id])
    deputy_director_id = Column(Integer, ForeignKey("users.id", ondelete='CASCADE'))    #####
    deputy_director = relationship("Users", cascade='all, delete', remote_side=[id], foreign_keys=[deputy_director_id])
    director_id = Column(Integer, ForeignKey("users.id", ondelete='CASCADE'))    #####
    director = relationship("Users", cascade='all, delete', remote_side=[id], foreign_keys=[director_id])

    @property
    def password(self):
        raise AttributeError("Passwprd was unrreadable")

    @password.setter
    def password(self, password):
        self.hashed_password = get_password_hash(password)

    def save(self, db: Session):
        try:
            db.add(self)
            db.commit()
            db.refresh(self)
        except:
            raise AssertionError("Could not save")

    def update(self, db: Session,  **kwargs):
        try:
            self.full_name = kwargs.get('full_name', self.full_name)
            if kwargs.get('username') and kwargs.get('username') != self.username:
                user = db.query(Users).filter(Users.username == kwargs.get('username')).first()
                if user:
                    raise HTTPException(
                        status_code=status.HTTP_400_BAD_REQUEST,
                        detail="This username already exists"
                    )
                self.username = kwargs.get('username', self.username)
            self.status = kwargs.get('status', self.status)
            if kwargs.get('password'):
                self.password = kwargs.get('password')
            self.region_id =  kwargs.get('region_id', self.region_id)
            db.commit()
            db.refresh(self)
        except:
            raise AssertionError("Could not update")
