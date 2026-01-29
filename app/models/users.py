from sqlalchemy import Boolean, Column, ForeignKey, Integer, String, DateTime, Date, Float
from sqlalchemy.orm import relationship
from sqlalchemy.ext.asyncio import AsyncSession
from fastapi import Depends, FastAPI, HTTPException, status
from passlib.context import CryptContext
from datetime import date, datetime,  timedelta 
from sqlalchemy.exc import IntegrityError
from sqlalchemy.future import select
from sqlalchemy import update
import calendar
from .database import get_db, get_or_404
from db.db import Base


pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")


def verify_password(plain_password, hashed_password):
    return pwd_context.verify(plain_password, hashed_password)


def get_password_hash(password):
    return pwd_context.hash(password)


class Region(Base):
    __tablename__ = "region"
    __table_args__ = {'extend_existing': True}
    

    id = Column(Integer, primary_key=True)
    name = Column(String, unique=True)
    
    async def save(self, db: AsyncSession):
        try:
            db.add(self)
            await db.commit()
            await db.refresh(self)
        except IntegrityError as e:
            raise HTTPException(status_code=404, detail=str(e.orig).split('DETAIL:  ')[1].replace('.\n', ''))

    async def update(self, db: AsyncSession, **kwargs):
        try:
            self.name = kwargs.get('name', self.name)
            await db.commit()
            await db.refresh(self)
        except IntegrityError as e:
            raise HTTPException(status_code=404, detail=str(e.orig).split('DETAIL:  ')[1].replace('.\n', ''))


class ManufacturedCompany(Base):
    __tablename__ = "manufactured_company"
    __table_args__ = {'extend_existing': True}
    

    id = Column(Integer, primary_key=True)
    name = Column(String, unique=True)
        
    async def save(self, db: AsyncSession):
        try:
            db.add(self)
            await db.commit()
            await db.refresh(self)
        except IntegrityError as e:
            raise HTTPException(status_code=404, detail=str(e.orig).split('DETAIL:  ')[1].replace('.\n', ''))

    async def update(self, db: AsyncSession, **kwargs):
        try:
            self.name = kwargs.get('name', self.name)
            await db.commit()
            await db.refresh(self)
        except IntegrityError as e:
            raise HTTPException(status_code=404, detail=str(e.orig).split('DETAIL:  ')[1].replace('.\n', ''))


class ProductCategory(Base):
    __tablename__ = "product_category"
    __table_args__ = {'extend_existing': True}
    

    id = Column(Integer, primary_key=True)
    name = Column(String, unique=True)

    async def save(self, db: AsyncSession):
        try:
            db.add(self)
            await db.commit()
            await db.refresh(self)
        except IntegrityError as e:
            raise HTTPException(status_code=404, detail=str(e.orig).split('DETAIL:  ')[1].replace('.\n', ''))

    async def update(self, db: AsyncSession, **kwargs):
        try:
            self.name = kwargs.get('name', self.name)
            await db.commit()
            await db.refresh(self)
        except IntegrityError as e:
            raise HTTPException(status_code=404, detail=str(e.orig).split('DETAIL:  ')[1].replace('.\n', ''))


class ExpenseCategory(Base):
    __tablename__ = 'expense_category'
    __table_args__ = {'extend_existing': True}
    

    id = Column(Integer, primary_key=True)
    name = Column(String, unique=True)

    async def save(self, db: AsyncSession):
        try:
            db.add(self)
            await db.commit()
            await db.refresh(self)
        except IntegrityError as e:
            raise HTTPException(status_code=404, detail=str(e.orig).split('DETAIL:  ')[1].replace('.\n', ''))



class ProductExpenses(Base):
    __tablename__ = 'product_expenses'
    __table_args__ = {'extend_existing': True}
    

    id = Column(Integer, primary_key=True)
    marketing_expense = Column(Integer, default=0)
    salary_expenses = Column(Integer, default=0)
    date = Column(DateTime, default=datetime.now())
    product = relationship("app.models.users.Product", backref="product_expenmses", lazy='selectin')
    product_id = Column(Integer, ForeignKey("products.id"))


class Product(Base):
    __tablename__ = "products"
    __table_args__ = {'extend_existing': True}
    

    id = Column(Integer, primary_key=True)
    name = Column(String, unique=True)
    price = Column(Integer)
    discount_price = Column(Integer)
    is_exist = Column(Boolean, default=True)
    marketing_expenses = Column(Integer, default=0)
    salary_expenses = Column(Integer, default=0)
    man_company = relationship("app.models.users.ManufacturedCompany", backref="product", lazy='selectin')
    man_company_id = Column(Integer, ForeignKey("manufactured_company.id"))
    category = relationship("app.models.users.ProductCategory", backref="product", lazy='selectin')
    category_id = Column(Integer, ForeignKey("product_category.id"))

    async def save(self, db: AsyncSession):
        try:
            db.add(self)
            await db.commit()
            await db.refresh(self)
        except IntegrityError as e:
            raise HTTPException(status_code=404, detail=str(e.orig).split('DETAIL:  ')[1].replace('.\n', ''))
        

class DoctorPlan(Base):
    __tablename__ = "doctor_plan"
    __table_args__ = {'extend_existing': True}
    

    id = Column(Integer, primary_key=True)
    description = Column(String)
    theme = Column(String, default='')
    date = Column(DateTime)
    status = Column(Boolean, default=False)
    postpone = Column(Boolean, default=False)
    doctor_id = Column(Integer, ForeignKey("doctor.id", ondelete="CASCADE"))
    doctor = relationship("app.models.doctors.Doctor", cascade="all, delete", backref="visit_plan")
    med_rep_id = Column(Integer, ForeignKey("users.id"), nullable=True)
    med_rep = relationship("app.models.users.Users", backref="doctor_visit_plan")

    async def save(self, db: AsyncSession):
        try:
            db.add(self)
            await db.commit()
            await db.refresh(self)
        except IntegrityError as e:
            raise HTTPException(status_code=404, detail=str(e.orig).split('DETAIL:  ')[1].replace('.\n', ''))

    async def update(self, db: AsyncSession, **kwargs):
        try:
            self.date = datetime.strptime(str(kwargs.get('date', str(self.date).rsplit(":", 1)[0])), '%Y-%m-%d %H:%M') 
            self.postpone = kwargs.get('postpone', self.postpone)
            self.description = kwargs.get('description', self.description)
            self.theme = kwargs.get('theme', self.theme)
            self.status = kwargs.get('status', self.status)
            db.add(self)
            await db.commit()
            await db.refresh(self)
        except IntegrityError as e:
            raise HTTPException(status_code=404, detail=str(e.orig).split('DETAIL:  ')[1].replace('.\n', ''))
        except ValueError as e:
            raise HTTPException(status_code=404, detail=str(e))
            

class DoctorVisitInfo(Base):
    __tablename__ = "doctor_visit_info"
    __table_args__ = {'extend_existing': True}
    

    id = Column(Integer, primary_key=True)
    recept = Column(Integer)
    data = Column(DateTime, default = datetime.now())
    doctor_id = Column(Integer, ForeignKey("doctor.id", ondelete="CASCADE"))
    doctor = relationship("app.models.doctors.Doctor", cascade="all, delete", backref="visit_info")
    product_id = Column(Integer, ForeignKey("products.id"))
    product = relationship("app.models.users.Product", backref="visit_info")

    @classmethod
    async def save(cls, db: AsyncSession, **kwargs):
        try:
            products = [cls(**obj, doctor_id=kwargs['doctor_id']) for obj in kwargs['products']]
            db.add_all(products)
            await db.commit()
        except IntegrityError as e:
            raise HTTPException(status_code=404, detail=str(e.orig).split('DETAIL:  ')[1].replace('.\n', ''))


class PharmacyPlan(Base):
    __tablename__ = "pharmacy_plan"
    __table_args__ = {'extend_existing': True}
    

    id = Column(Integer, primary_key=True)
    description = Column(String)
    theme = Column(String, default='')
    date = Column(DateTime)
    status = Column(Boolean, default=False)
    postpone = Column(Boolean, default=False)
    pharmacy_id = Column(Integer, ForeignKey("pharmacy.id", ondelete="CASCADE"))
    pharmacy = relationship("app.models.pharmacy.Pharmacy", cascade="all, delete", backref="visit_plan")
    med_rep_id = Column(Integer, ForeignKey("users.id"))
    med_rep = relationship("app.models.users.Users", backref="pharmacy_visit_plan")

    async def save(self, db: AsyncSession):
        try:
            db.add(self)
            await db.commit()
            await db.refresh(self)
        except IntegrityError as e:
            raise HTTPException(status_code=404, detail=str(e.orig).split('DETAIL:  ')[1].replace('.\n', ''))

    async def update(self, db: AsyncSession, **kwargs):
        try:
            for key in list(kwargs.keys()):
                kwargs.pop(key) if kwargs[key]==None else None
            
            self.date = datetime.strptime(str(kwargs.get('date', str(self.date).rsplit(":", 1)[0])), '%Y-%m-%d %H:%M') 
            self.postpone = kwargs.get('postpone', self.postpone)
            self.description = kwargs.get('description', self.description)
            self.theme = kwargs.get('theme', self.theme)
            self.status = kwargs.get('status', self.status)
            db.add(self)
            await db.commit()
            await db.refresh(self)
        except IntegrityError as e:
            raise HTTPException(status_code=404, detail=str(e.orig).split('DETAIL:  ')[1].replace('.\n', ''))
        except ValueError as e:
            raise HTTPException(status_code=404, detail=str(e))


class PharmacyPlanAttachedProduct(Base):
    __tablename__ = "pharmacy_plan_attached_product"
    __table_args__ = {'extend_existing': True}
    

    id = Column(Integer, primary_key=True)
    doctor_name = Column(String)
    doctor_speciality = Column(String)
    product_name = Column(String)
    compleated = Column(Integer)
    plan_id = Column(Integer, ForeignKey("pharmacy_plan.id", ondelete="CASCADE"))
    plan = relationship("app.models.users.PharmacyPlan", cascade="all, delete", backref="products")

    @classmethod
    def delete(cls, id: int, db: AsyncSession):
        db.query(cls).filter(cls.plan_id==id).delete()
        db.commit()


class Notification(Base):
    __tablename__ = "notification"
    __table_args__ = {'extend_existing': True}
    

    id = Column(Integer, primary_key=True)
    author = Column(String)
    theme = Column(String)
    description = Column(String)
    description2 = Column(String)
    date = Column(DateTime, default=datetime.now())
    unread = Column(Boolean, default=True)
    med_rep_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"))
    med_rep = relationship("app.models.users.Users", backref="notifications", cascade="all, delete", foreign_keys=[med_rep_id], primaryjoin="app.models.users.Notification.med_rep_id == app.models.users.Users.id")
    region_manager_id = Column(Integer, ForeignKey("users.id"))
    region_manager = relationship("app.models.users.Users", backref="rm_notifications", foreign_keys=[region_manager_id], primaryjoin="app.models.users.Notification.region_manager_id == app.models.users.Users.id")
    pharmacy_id = Column(Integer, ForeignKey("pharmacy.id", ondelete="CASCADE"))
    pharmacy = relationship("app.models.pharmacy.Pharmacy", backref="notifications", cascade="all, delete", lazy='selectin')
    doctor_id = Column(Integer, ForeignKey("doctor.id", ondelete="CASCADE"))
    doctor = relationship("app.models.doctors.Doctor", backref="notifications", cascade="all, delete", lazy='selectin')
    wholesale_id = Column(Integer, ForeignKey("wholesale.id", ondelete="CASCADE"))
    wholesale = relationship("app.models.warehouse.Wholesale", backref="notifications", cascade="all, delete", lazy='selectin')

    @classmethod
    async def save(cls, db: AsyncSession, **kwargs):
        try:
            med_rep = await get_or_404(Users, kwargs['med_rep_id'], db)
            notification = Notification(**kwargs, region_manager_id=med_rep.region_manager_id)
            db.add(notification)
            await db.commit()
            await db.refresh(notification)
            return notification
        except IntegrityError as e:
            raise HTTPException(status_code=404, detail=str(e.orig).split('DETAIL:  ')[1].replace('.\n', ''))

    async def read(self, db: AsyncSession):
        self.unread = False
        await db.commit()
        await db.refresh(self)
    
    async def reply(self, db: AsyncSession, **kwargs):
        self.description2 = kwargs.get('description2')
        self.unread = kwargs.get('unread')
        await db.commit()
        await db.refresh(self)


class UserProductPlan(Base):
    __tablename__ = "user_product_plan"
    __table_args__ = {'extend_existing': True}
    

    id = Column(Integer, primary_key=True)
    amount = Column(Integer)
    current_amount = Column(Integer)
    date = Column(DateTime, default=datetime.now(), index=True)
    plan_month = Column(DateTime)
    price = Column(Integer)
    discount_price = Column(Integer)
    product = relationship("app.models.users.Product", backref="product_plan", lazy='selectin')
    product_id = Column(Integer, ForeignKey("products.id"), index=True)
    med_rep = relationship("app.models.users.Users", cascade="all, delete", backref="product_plan")
    med_rep_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), index=True)

    async def update(self, amount: int, db: AsyncSession):
        try:
            difference = amount - self.amount
            self.amount = amount
            self.current_amount += difference
            if self.current_amount < 0:
                raise HTTPException(status_code=404, detail="Current amount should be grater than 0")
            db.add(self)
            await db.commit()
            await db.refresh(self)
        except IntegrityError as e:
            raise HTTPException(status_code=404, detail=str(e.orig).split('DETAIL:  ')[1].replace('.\n', ''))

    @classmethod
    async def user_plan_minus(cls, db: AsyncSession, **kwargs):
        year = datetime.now().year
        month = datetime.now().month  
        num_days = calendar.monthrange(year, month)[1]
        start_date = datetime(year, month, 1)  
        end_date = datetime(year, month, num_days, 23, 59)
        result = await db.execute(select(cls).filter(cls.product_id==kwargs['product_id'], cls.med_rep_id==kwargs['med_rep_id'], cls.date>=start_date, cls.date<=end_date))
        product = result.scalars().first()
        if not product:
            raise HTTPException(status_code=400, detail="Med rep has not product plan for this product in this month")
        elif product.current_amount < kwargs['quantity']:
            product.current_amount = 0
            # raise HTTPException(status_code=400, detail="Med rep has not enough product plan for this product in this month")
        product.current_amount -= kwargs['quantity']


class EditablePlanMonths(Base):
    __tablename__ = "editable_plan_months"
    __table_args__ = {'extend_existing': True}
    

    id = Column(Integer, primary_key=True)
    month = Column(Integer)
    status = Column(Boolean, default=False)
    created_at = Column(DateTime, default=datetime.now())
    updated_at = Column(DateTime, default=datetime.now())

    async def update(self, status: int, db: AsyncSession):
        try:
            self.status = status
            self.updated_at = datetime.now()
            await db.commit()
        except IntegrityError as e:
            raise HTTPException(status_code=404, detail=str(e.orig).split('DETAIL:  ')[1].replace('.\n', ''))

class UserLoginMonitoring(Base):
    __tablename__ = "user_login_monitoring"
    __table_args__ = {'extend_existing': True}
    

    id = Column(Integer, primary_key=True)

    login_date = Column(DateTime)
    logout_date = Column(DateTime)
    location = Column(String)
    latitude = Column(String)
    longitude = Column(String)
    duration = Column(String)

    user = relationship("app.models.users.Users", backref="monitoring", lazy='selectin')
    user_id = Column(Integer, ForeignKey("users.id"))

    async def save(self, db: AsyncSession):
        try:
            db.add(self)
            await db.commit()
            await db.refresh(self)
        except IntegrityError as e:
            raise HTTPException(status_code=404, detail=str(e.orig).split('DETAIL:  ')[1].replace('.\n', ''))

    async def update(self, logout_date: datetime, delta: timedelta, db: AsyncSession):
        try:
            self.logout_date = logout_date
            duration = f"{delta.seconds//3600}:{(delta.seconds%3600)//60}:{(delta.seconds%3600)%60}"
            self.duration = duration
            await db.commit()
        except IntegrityError as e:
            raise HTTPException(status_code=404, detail=str(e.orig).split('DETAIL:  ')[1].replace('.\n', ''))


class Users(Base):
    __tablename__ = "users"
    __table_args__ = {'extend_existing': True}
    

    id = Column(Integer, primary_key=True)
    full_name = Column(String)
    username = Column(String, unique=True)
    hashed_password = Column(String)
    status = Column(String)
    deleted = Column(Boolean, default=False)
    email = Column(String)
    code = Column(String)
    expire_date = Column(DateTime)

    region = relationship("app.models.users.Region", backref="user")
    region_id = Column(Integer, ForeignKey("region.id"), index=True)  #####
    region_manager_id = Column(Integer, ForeignKey("users.id"), index=True)      #####
    region_manager = relationship("app.models.users.Users", remote_side=[id], foreign_keys=[region_manager_id])
    ffm_id = Column(Integer, ForeignKey("users.id"), index=True)               #####  
    ffm = relationship("app.models.users.Users", remote_side=[id], foreign_keys=[ffm_id])
    product_manager_id = Column(Integer, ForeignKey("users.id"), index=True)    #####
    product_manager = relationship("app.models.users.Users", remote_side=[id], foreign_keys=[product_manager_id])
    deputy_director_id = Column(Integer, ForeignKey("users.id"), index=True)    #####
    deputy_director = relationship("app.models.users.Users", remote_side=[id], foreign_keys=[deputy_director_id])
    director_id = Column(Integer, ForeignKey("users.id"), index=True)    #####
    director = relationship("app.models.users.Users", remote_side=[id], foreign_keys=[director_id])
   
    @property
    def password(self):
        raise AttributeError("Passwprd was unrreadable")

    @password.setter
    def password(self, password):
        self.hashed_password = get_password_hash(password)

    async def save(self, db: AsyncSession):
        try:
            db.add(self)
            await db.commit()
            await db.refresh(self)
        except IntegrityError as e:
            raise HTTPException(status_code=404, detail=str(e.orig).split('DETAIL:  ')[1].replace('.\n', ''))

    async def update(self, db: AsyncSession,  **kwargs):
        try:
            for key in list(kwargs.keys()):
                kwargs.pop(key) if kwargs[key]==None else None
            self.full_name = kwargs.get('full_name', self.full_name)
            self.email = kwargs.get('email', self.email)
            if kwargs.get('username') and kwargs.get('username') != self.username:
                result = await db.execute(select(Users).filter(Users.username == kwargs.get('username')))
                user = result.scalars().first()
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
            await db.commit()
            await db.refresh(self)
        except IntegrityError as e:
            raise HTTPException(status_code=404, detail=str(e.orig).split('DETAIL:  ')[1].replace('.\n', ''))
