from sqlalchemy import Boolean, Column, ForeignKey, Integer, String, Float
from sqlalchemy.orm import relationship
from sqlalchemy.orm import Session
from fastapi import Depends, FastAPI, HTTPException, status
from .users import *
from .plan import *
from .doctors import *
from datetime import date 


from .database import Base, get_db


class BalanceInStock(Base):
    __tablename__ = "balance_in_stock"

    id = Column(Integer, primary_key=True)
    product_name = Column(String)
    quantity = Column(Integer)
    date = Column(DateTime, default=date.today())

    pharmacy_id = Column(Integer, ForeignKey("pharmacy.id"))
    pharmacy = relationship("Pharmacy", backref='balanceinstock')

    @classmethod
    def save(cls, db: Session, **kwargs):
        try:
            for product in kwargs['products']:
                stock_product = cls(**product, date=kwargs['date'], pharmacy_id=kwargs['pharmacy_id'])
                db.add(stock_product)
            db.commit()
        except:
            raise AssertionError("Could not saved")


class PharmacyAttachedProducts(Base):
    __tablename__ = "pharmacy_attached_products"

    id = Column(Integer, primary_key=True)
    monthly_plan = Column(Integer)
    product_id = Column(Integer, ForeignKey("products.id"))
    product = relationship("Products", backref="pharmacy_attached_product")


class Debt(Base):
    __tablename__ = "debt"

    id = Column(Integer, primary_key=True)
    description = Column(String)
    amount = Column(Integer)
    payed = Column(Boolean, default=False) 
    date = Column(DateTime, default=date.today())
    pharmacy_id = Column(Integer, ForeignKey("pharmacy.id"))
    pharmacy = relationship("Pharmacy", backref="debts")

    def save(self, db: Session):
        try:
            db.add(self)
            db.commit()
            db.refresh(self)
        except:
            raise AssertionError("Could not saved")

    def update(self, db: Session, **kwargs):
        self.payed = kwargs.get('payed', self.payed)
        db.commit()
        db.refresh(self)


class FactoryWarehouse(Base):
    __tablename__ = "factory_warehouse"

    id = Column(Integer, primary_key=True)
    quantity = Column(Integer)
    product_id = Column(Integer, ForeignKey("products.id"))
    product = relationship("Products", backref="products")


class Reservation(Base):
    __tablename__ = "reservation"

    id = Column(Integer, primary_key=True)
    company = Column(String)
    date = Column(DateTime, default=date.today())
    discount = Column(Float)
    total_quantity = Column(Integer)
    total_amount = Column(Float)
    total_payable = Column(Float)

    @classmethod
    def save(cls, db: Session, **kwargs):
        try:
            products = kwargs.pop('products')
            reservation = cls(**kwargs)
            db.add(reservation)
            for product in products:
                res_product = ReservationProducts(**product)
                reservation.products.append(res_product)
            db.commit()
            db.refresh(reservation)
            return reservation
        except:
            AssertionError("Could not saved")
            

class ReservationProducts(Base):
    __tablename__ = "reservation_products"

    id = Column(Integer, primary_key=True)
    product_name = Column(String)
    quantity = Column(Integer)
    price = Column(Float)
    discount_price = Column(Integer)
    reservation_id = Column(Integer, ForeignKey("reservation.id"))
    reservation = relationship("Reservation", backref="products")


class Wholesale(Base):
    __tablename__ = "wholesale"

    id = Column(Integer, primary_key=True)
    name = Column(String)
    contact = Column(String)
    region_id = Column(Integer, ForeignKey("region.id")) 
    region = relationship("Region", backref="wholesales")

    def save(self, db: Session):
        try:
            db.add(self)
            db.commit()
            db.refresh(self)
        except:
            raise AssertionError("Could not saved")

    def update(self, db: Session, **kwargs):
        try:
            for key in list(kwargs.keys()):
                kwargs.pop(key) if kwargs[key]==None else None 
            self.name = kwargs.get('name', self.name)
            self.contact = kwargs.get('contact', self.contact)
            self.region_id = kwargs.get('region_id', self.region_id)
            db.add(self)
            db.commit()
            db.refresh(self)
        except:
            raise AssertionError("Could not updated")

    def attach(self, db: Session, **kwargs):
        try:
            WholesaleProduct.delete(id=self.id, db=db)
            for product in kwargs['products']:
                    wh_product = WholesaleProduct(**product, wholesale_id=self.id)
                    db.add(wh_product)
            db.commit()
        except:
            raise AssertionError("Could not updated")


class WholesaleProduct(Base):
    __tablename__ = "wholesaleproduct"

    id = Column(Integer, primary_key=True)
    product_name = Column(String)
    price = Column(Integer)
    quantity = Column(Integer)
    wholesale_id = Column(Integer, ForeignKey("wholesale.id"))
    wholesale = relationship("Wholesale", backref="products")

    @classmethod
    def delete(cls, id: int, db: Session):
        db.query(cls).filter(cls.wholesale_id==id).delete()
        db.commit()


class Pharmacy(Base):
    __tablename__ = "pharmacy"

    id = Column(Integer, primary_key=True)
    company_name = Column(String)
    contact = Column(String)
    latitude = Column(String)
    longitude = Column(String)
    address = Column(String)
    bank_account_number = Column(String)
    inter_branch_turnover = Column(String)
    classification_of_economic_activities = Column(String)
    VAT_payer_code = Column(String)
    pharmacy_director = Column(String)
    discount = Column(Integer)
    
    med_rep_id = Column(Integer, ForeignKey("users.id"))
    med_rep = relationship("Users", backref="mr_pharmacy", foreign_keys=[med_rep_id])
    region_manager_id = Column(Integer, ForeignKey("users.id"))
    region_manager = relationship("Users", backref="rm_pharmacy", foreign_keys=[region_manager_id])
    ffm_id = Column(Integer, ForeignKey("users.id"))
    ffm = relationship("Users", backref="ffm_pharmacy", foreign_keys=[ffm_id])
    product_manager_id = Column(Integer, ForeignKey("users.id"))
    product_manager = relationship("Users", backref="pm_pharmacy", foreign_keys=[product_manager_id])
    deputy_director_id = Column(Integer, ForeignKey("users.id"))   
    deputy_director = relationship("Users",  foreign_keys=[deputy_director_id])
    director_id = Column(Integer, ForeignKey("users.id"))    
    director = relationship("Users",  foreign_keys=[director_id])
    region = relationship("Region", backref="pharmacy")
    region_id = Column(Integer, ForeignKey("region.id")) 

    def save(self, db: Session):
        try:
            db.add(self)
            db.commit()
            db.refresh(self)
        except:
            raise AssertionError("Could not saved")

    def update(self, db: Session, **kwargs):
        try:
            for key in list(kwargs.keys()):
                kwargs.pop(key) if kwargs[key]==None else None 
            self.company_name = kwargs.get('company_name', self.company_name)
            self.contact = kwargs.get('contact', self.contact)
            self.address = kwargs.get('address', self.address)
            self.latitude = kwargs.get('latitude', self.latitude)
            self.longitude = kwargs.get('longitude', self.longitude)
            self.bank_account_number = kwargs.get('bank_account_number', self.bank_account_number)
            self.inter_branch_turnover = kwargs.get('inter_branch_turnover', self.inter_branch_turnover)
            self.classification_of_economic_activities = kwargs.get('classification_of_economic_activities', self.classification_of_economic_activities)
            self.VAT_payer_code = kwargs.get('VAT_payer_code', self.VAT_payer_code)
            self.pharmacy_director = kwargs.get('pharmacy_director', self.pharmacy_director)
            self.med_rep_id = kwargs.get('med_rep_id', self.med_rep_id)
            self.region_manager_id = kwargs.get('region_manager_id', self.region_manager_id)
            self.ffm_id = kwargs.get('ffm_id', self.ffm_id)
            self.product_manager_id = kwargs.get('product_manager_id', self.product_manager_id)
            self.deputy_director_id = kwargs.get('deputy_director_id', self.deputy_director_id)
            self.director_id = kwargs.get('director_id', self.director_id)
            self.region_id = kwargs.get('region_id', self.region_id)
            db.add(self)
            db.commit()
            db.refresh(self)
        except:
            raise AssertionError("Could not updated")

    @classmethod
    def attach_doctor(cls, db: Session, **kwargs):
        try:
            doc = db.query(cls).filter(cls.doctors.any(Doctor.id==kwargs.get('doctor_id'))).first()
            if not doc:
                pharmacy = db.query(cls).get(kwargs.get('pharmacy_id'))
                pharmacy.doctors.append(db.query(Doctor).get(kwargs.get('doctor_id')))
                db.commit()
                db.refresh(pharmacy)
            else:
                raise HTTPException(
                status_code=400,
                detail="This doctor already attached"
            )
        except:
            raise AssertionError('Something went wrong')

            



    
    


