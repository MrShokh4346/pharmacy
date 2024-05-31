from sqlalchemy import Boolean, Column, ForeignKey, Integer, String, DateTime
from sqlalchemy.orm import relationship
from sqlalchemy.ext.asyncio import AsyncSession
from fastapi import Depends, FastAPI, HTTPException, status
from passlib.context import CryptContext
from datetime import date, datetime 
from sqlalchemy.exc import IntegrityError
from .database import Base, get_db, get_or_404


pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")


def verify_password(plain_password, hashed_password):
    return pwd_context.verify(plain_password, hashed_password)


def get_password_hash(password):
    return pwd_context.hash(password)


class Region(Base):
    __tablename__ = "region"

    id = Column(Integer, primary_key=True)
    name = Column(String, unique=True)
    
    async def save(self, db: AsyncSession):
        try:
            db.add(self)
            await db.commit()
            await db.refresh(self)
        except IntegrityError as e:
            raise HTTPException(status_code=404, detail=str(e.orig).split('DETAIL:  ')[1].replace('.\n', ''))


class ManufacturedCompany(Base):
    __tablename__ = "manufactured_company"

    id = Column(Integer, primary_key=True)
    name = Column(String, unique=True)
        
    async def save(self, db: AsyncSession):
        try:
            db.add(self)
            await db.commit()
            await db.refresh(self)
        except IntegrityError as e:
            raise HTTPException(status_code=404, detail=str(e.orig).split('DETAIL:  ')[1].replace('.\n', ''))


class ProductCategory(Base):
    __tablename__ = "product_category"

    id = Column(Integer, primary_key=True)
    name = Column(String, unique=True)

    async def save(self, db: AsyncSession):
        try:
            db.add(self)
            await db.commit()
            await db.refresh(self)
        except IntegrityError as e:
            raise HTTPException(status_code=404, detail=str(e.orig).split('DETAIL:  ')[1].replace('.\n', ''))


class Products(Base):
    __tablename__ = "products"

    id = Column(Integer, primary_key=True)
    name = Column(String, unique=True)
    price = Column(Integer)
    discount_price = Column(Integer)
    man_company = relationship("ManufacturedCompany", backref="product", lazy='selectin')
    man_company_id = Column(Integer, ForeignKey("manufactured_company.id"))
    category = relationship("ProductCategory", backref="product", lazy='selectin')
    category_id = Column(Integer, ForeignKey("product_category.id"))

    @classmethod
    def check_if_product_exists(cls, product_id: int, db: AsyncSession):
        product = db.query(cls).get(product_id)
        if product:
            return product
        else:
            raise HTTPException(
                status_code=400,
                detail="This product don't exists"
            )

    async def save(self, db: AsyncSession):
        try:
            db.add(self)
            await db.commit()
            await db.refresh(self)
        except IntegrityError as e:
            raise HTTPException(status_code=404, detail=str(e.orig).split('DETAIL:  ')[1].replace('.\n', ''))
        

class UserAttachedProduct(Base):
    __tablename__ = "user_attached_product"

    id = Column(Integer, primary_key=True)
    product = relationship("Products", backref="attch_prd")
    product_id = Column(Integer, ForeignKey("products.id"))
    user = relationship("Users", backref="ur_attch_prd")
    user_id = Column(Integer, ForeignKey("users.id"))


class DoctorPlan(Base):
    __tablename__ = "doctor_plan"

    id = Column(Integer, primary_key=True)
    description = Column(String)
    theme = Column(String, default='')
    date = Column(DateTime)
    status = Column(Boolean, default=False)
    postpone = Column(Boolean, default=False)
    doctor_id = Column(Integer, ForeignKey("doctor.id"))
    doctor = relationship("Doctor", backref="visit_plan")
    med_rep_id = Column(Integer, ForeignKey("users.id"))
    med_rep = relationship("Users", backref="doctor_visit_plan")

    async def save(self, db: AsyncSession):
        try:
            db.add(self)
            await db.commit()
            await db.refresh(self)
        except IntegrityError as e:
            raise HTTPException(status_code=404, detail=str(e.orig).split('DETAIL:  ')[1].replace('.\n', ''))

    async def update(self, db: AsyncSession, **kwargs):
        try:
            self.date = datetime.strptime(str(kwargs.get('date')), '%Y-%m-%d %H:%M') 
            self.postpone = kwargs.get('postpone')
            self.description = kwargs.get('description')
            self.theme = kwargs.get('theme')
            db.add(self)
            await db.commit()
            await db.refresh(self)
        except IntegrityError as e:
            raise HTTPException(status_code=404, detail=str(e.orig).split('DETAIL:  ')[1].replace('.\n', ''))
        except ValueError as e:
            raise HTTPException(status_code=404, detail=str(e))
            
    def attach(self, db: AsyncSession, **kwargs):
        try:
            DoctorPlanAttachedProduct.delete(id=self.id, db=db)
            self.description = kwargs.get('description', self.description)
            self.status = True
            for product in kwargs['products']:
                compleated = DoctorPlanAttachedProduct(**product, plan_id=self.id)
                db.add(compleated)
            db.commit()
        except IntegrityError as e:
            raise HTTPException(status_code=404, detail=str(e.orig).split('DETAIL:  ')[1].replace('.\n', ''))


class DoctorPlanAttachedProduct(Base):
    __tablename__ = "doctor_plan_attached_product"

    id = Column(Integer, primary_key=True)
    product_name = Column(String)
    compleated = Column(Integer)
    plan_id = Column(Integer, ForeignKey("doctor_plan.id"))
    plan = relationship("DoctorPlan", backref="products")

    @classmethod
    def delete(cls, id: int, db: AsyncSession):
        db.query(cls).filter(cls.plan_id==id).delete()
        db.commit()


class PharmacyPlan(Base):
    __tablename__ = "pharmacy_plan"

    id = Column(Integer, primary_key=True)
    description = Column(String)
    theme = Column(String, default='')
    date = Column(DateTime)
    status = Column(Boolean, default=False)
    postpone = Column(Boolean, default=False)
    pharmacy_id = Column(Integer, ForeignKey("pharmacy.id"))
    pharmacy = relationship("Pharmacy", backref="visit_plan")
    med_rep_id = Column(Integer, ForeignKey("users.id"))
    med_rep = relationship("Users", backref="pharmacy_visit_plan")

    async def save(self, db: AsyncSession):
        try:
            db.add(self)
            await db.commit()
            await db.refresh(self)
        except IntegrityError as e:
            raise HTTPException(status_code=404, detail=str(e.orig).split('DETAIL:  ')[1].replace('.\n', ''))

    async def update(self, db: AsyncSession, **kwargs):
        try:
            self.date = datetime.strptime(str(kwargs.get('date')), '%Y-%m-%d %H:%M') 
            self.postpone = kwargs.get('postpone')
            self.description = kwargs.get('description')
            self.theme = kwargs.get('theme')
            db.add(self)
            await db.commit()
            await db.refresh(self)
        except IntegrityError as e:
            raise HTTPException(status_code=404, detail=str(e.orig).split('DETAIL:  ')[1].replace('.\n', ''))
        except ValueError as e:
            raise HTTPException(status_code=404, detail=str(e))

    def attach(self, db: AsyncSession, **kwargs):
        try:
            PharmacyPlanAttachedProduct.delete(id=self.id, db=db)
            self.description = kwargs.get('description', self.description)
            self.status = True
            for doctor in kwargs['doctors']:
                doctor_copy = doctor.copy()
                del doctor_copy['products']
                for product in doctor['products']:
                        compleated = PharmacyPlanAttachedProduct(**product, **doctor_copy, plan_id=self.id)
                        db.add(compleated)
            db.commit()
        except IntegrityError as e:
            raise HTTPException(status_code=404, detail=str(e.orig).split('DETAIL:  ')[1].replace('.\n', ''))


class PharmacyPlanAttachedProduct(Base):
    __tablename__ = "pharmacy_plan_attached_product"

    id = Column(Integer, primary_key=True)
    doctor_name = Column(String)
    doctor_speciality = Column(String)
    product_name = Column(String)
    compleated = Column(Integer)
    plan_id = Column(Integer, ForeignKey("pharmacy_plan.id"))
    plan = relationship("PharmacyPlan", backref="products")

    @classmethod
    def delete(cls, id: int, db: AsyncSession):
        db.query(cls).filter(cls.plan_id==id).delete()
        db.commit()


class Notification(Base):
    __tablename__ = "notification"

    id = Column(Integer, primary_key=True)
    author = Column(String)
    theme = Column(String)
    description = Column(String)
    date = Column(DateTime, default=date.today())
    unread = Column(Boolean, default=True)
    med_rep_id = Column(Integer, ForeignKey("users.id"))
    med_rep = relationship("Users", backref="notifications", foreign_keys=[med_rep_id])
    region_manager_id = Column(Integer, ForeignKey("users.id"))
    region_manager = relationship("Users", backref="rm_notifications", foreign_keys=[region_manager_id])
    pharmacy_id = Column(Integer, ForeignKey("pharmacy.id"))
    pharmacy = relationship("Pharmacy", backref="notifications", lazy='selectin')
    doctor_id = Column(Integer, ForeignKey("doctor.id"))
    doctor = relationship("Doctor", backref="notifications", lazy='selectin')
    wholesale_id = Column(Integer, ForeignKey("wholesale.id"))
    wholesale = relationship("Wholesale", backref="notifications", lazy='selectin')

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
        db.add(self)
        await db.commit()
        await db.refresh(self)


class UserProductPlan(Base):
    __tablename__ = "user_product_plan"

    id = Column(Integer, primary_key=True)
    amount = Column(Integer)
    date = Column(DateTime, default=datetime.now())
    product = relationship("Products", backref="product_plan")
    product_id = Column(Integer, ForeignKey("products.id"))
    med_rep = relationship("Users", backref="product_plan")
    med_rep_id = Column(Integer, ForeignKey("users.id"))


class Users(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True)
    full_name = Column(String)
    username = Column(String, unique=True)
    hashed_password = Column(String)
    status = Column(String)
    deleted = Column(Boolean, default=False)

    region = relationship("Region", backref="user")
    region_id = Column(Integer, ForeignKey("region.id"))  #####
    region_manager_id = Column(Integer, ForeignKey("users.id"))      #####
    region_manager = relationship("Users", remote_side=[id], foreign_keys=[region_manager_id])
    ffm_id = Column(Integer, ForeignKey("users.id"))               #####  
    ffm = relationship("Users", remote_side=[id], foreign_keys=[ffm_id])
    product_manager_id = Column(Integer, ForeignKey("users.id"))    #####
    product_manager = relationship("Users", remote_side=[id], foreign_keys=[product_manager_id])
    deputy_director_id = Column(Integer, ForeignKey("users.id"))    #####
    deputy_director = relationship("Users", remote_side=[id], foreign_keys=[deputy_director_id])
    director_id = Column(Integer, ForeignKey("users.id"))    #####
    director = relationship("Users", remote_side=[id], foreign_keys=[director_id])

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

    def update(self, db: AsyncSession,  **kwargs):
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
        except IntegrityError as e:
            raise HTTPException(status_code=404, detail=str(e.orig).split('DETAIL:  ')[1].replace('.\n', ''))
