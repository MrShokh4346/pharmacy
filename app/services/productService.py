from app.models.users import Product, ProductExpenses, UserProductPlan
from sqlalchemy.exc import IntegrityError
from fastapi import HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import update


class ProductService:   

    @staticmethod
    async def update(product: Product, db: AsyncSession, **kwargs):
        try:
            for key in list(kwargs.keys()):
                kwargs.pop(key) if kwargs[key]==None else None 
            product.name = kwargs.get('name', product.name)
            product.is_exist = kwargs.get('is_exist', product.is_exist)
            product.price = kwargs.get('price', product.price)
            product.discount_price = kwargs.get('discount_price', product.discount_price)
            if kwargs.get('price', None) or kwargs.get('discount_price', None):
                await db.execute(update(UserProductPlan).where(UserProductPlan.plan_month >= datetime.now()).values(price=kwargs.get('price', product.price), discount_price=kwargs.get('discount_price', product.discount_price)))
            product.man_company_id = kwargs.get('man_company_id', product.man_company_id)
            product.category_id = kwargs.get('category_id', product.category_id)
            await db.commit()
            await db.refresh(product)
        except IntegrityError as e:
            raise HTTPException(status_code=404, detail=str(e.orig).split('DETAIL:  ')[1].replace('.\n', ''))

    @staticmethod
    async def set_expenses(product, db: AsyncSession, **kwargs):
        product.marketing_expenses = kwargs.get('marketing_expenses') if kwargs.get('marketing_expenses') else product.marketing_expenses
        product.salary_expenses = kwargs.get('salary_expenses') if kwargs.get('salary_expenses') else product.salary_expenses
        expense = ProductExpenses(
            marketing_expense = kwargs.get('marketing_expenses'),
            salary_expenses = kwargs.get('salary_expenses'),
            product_id = product.id 
            )
        db.add(expense)
        await db.commit()
        await db.refresh(product)
