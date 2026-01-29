from datetime import datetime, timedelta
from app.auth.schemas import EditablePlanMonthsSchema, LoginEmailCodeSchema, LoginEmailSchema, LoginSchema, RegisterSchema, TokenSchema, UserLoginMonitoringSchema, UserLogoutMonitoringSchema, UserOutSchema
from app.models.users import EditablePlanMonths, UserLoginMonitoring, Users, verify_password
from fastapi import Depends, HTTPException, status
from fastapi import APIRouter
from app.models.dependencies import create_access_token
from sqlalchemy.ext.asyncio import AsyncSession
from app.models.pharmacy import Reservation
from app.models.database import get_db, get_or_404
from sqlalchemy.future import select
import string
from common_depetencies import StartEndDates2
import random
from typing import List

router = APIRouter()


async def authenticate_user(db: AsyncSession, username: str, password: str):
    result = await db.execute(select(Users).filter(Users.username == username))
    user = result.scalar()
    hashed_password = user.hashed_password
    if not user:
        return False
    if isinstance(hashed_password, bytes):
        hashed_password = hashed_password.decode('utf-8')
    if not verify_password(password, hashed_password):
        return False
    return user


@router.post("/login")
async def login_for_access_token(user: LoginSchema, db: AsyncSession = Depends(get_db)) -> TokenSchema:
    user = await authenticate_user(db, user.username, user.password)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect username or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    access_token = create_access_token(data={"sub": str(user.id)})
    return TokenSchema(id=user.id, access_token=access_token, status=user.status, region_id=user.region_id)


@router.post('/register')
async def register_director(user: RegisterSchema, db: AsyncSession = Depends(get_db)) -> UserOutSchema:
    result = await db.execute(select(Users).filter(Users.username == user.username))
    db_user = result.scalar()
    if db_user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Username already exists",
            headers={"WWW-Authenticate": "Bearer"},
        )
    new_user = Users(**user.dict())
    await new_user.save(db=db)
    return UserOutSchema(**new_user.__dict__)


async def code_generator(size=6, chars=string.digits):
    return ''.join(random.choice(chars) for x in range(size))


@router.post('/login-with-email')
async def send_mail(email: LoginEmailSchema, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(Users).filter(Users.username == 'test_user'))
    user = result.scalar()
    if user:
        code = await code_generator()
        user.code = code
        user.expire_date = datetime.now() + timedelta(minutes = 2)
        await db.commit()
        # return await simple_send(email.email, code)
    else:
        return {"msg":"No user with this email"}


@router.post('/check-code')
async def check_code(obj: LoginEmailCodeSchema, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(Users).filter(Users.username == 'test_user'))
    user = result.scalar()
    if user is not None and user.code == obj.code:
        if user.expire_date > datetime.now():
            user.code = None
            await db.commit()
            access_token = create_access_token(data={"sub": str(user.id)})
            return TokenSchema(id=user.id, access_token=access_token, status=user.status, region_id=user.region_id)
        else:
            user.code = None
            await db.commit()
            return {"msg": "Code expired"}
    else:
        return {"msg": "Wrong code"}


@router.post('/login-time-write')
async def login_time_write(monitoring_data: UserLoginMonitoringSchema, db: AsyncSession = Depends(get_db)):
    monitoring = UserLoginMonitoring(**monitoring_data.dict())
    await monitoring.save(db)
    return {'monitoring_id':monitoring.id}


@router.post('/logout-time-write')
async def logout_time_write(monitoring_data: UserLogoutMonitoringSchema, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(UserLoginMonitoring).filter(UserLoginMonitoring.id==monitoring_data.monitoring_id)) 
    monitoring = result.scalar()
    delta = monitoring_data.logout_date - monitoring.login_date
    await monitoring.update(monitoring_data.logout_date, delta, db)
    return {'msg':'Success'}


@router.get('/get-login-monitoring')
async def get_login_monitoring(user_id: int | None = None, filter_date: StartEndDates2 = None, db: AsyncSession = Depends(get_db)):
    start_date = filter_date['start_date']
    end_date = filter_date['end_date']
    query = select(UserLoginMonitoring).filter(UserLoginMonitoring.logout_date!=None)
    if start_date is not None:
        query = query.filter(UserLoginMonitoring.login_date>=start_date, UserLoginMonitoring.login_date<=end_date)
    if user_id:
        query = query.filter(UserLoginMonitoring.user_id==user_id)
    result = await db.execute(query)
    data = []
    for i in result.scalars().all():
        data.append({
            'login_date': i.login_date,
            'logout_date': i.logout_date,
            'location': i.location,
            'latitude': i.latitude,
            'longitude': i.longitude,
            'durstion': i.duration,
            'user_id': i.user_id,
            'user_full_name': i.user.full_name,
            'user_status': i.user.status
        })
    return data 


@router.get('/get-editable-months', response_model=List[EditablePlanMonthsSchema])
async def get_editable_months(db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(EditablePlanMonths))
    return result.scalars().all()


@router.post('/update-editable-month-status/{id}', response_model=List[EditablePlanMonthsSchema])
async def update_editable_month_status(id: int, status: bool, db: AsyncSession = Depends(get_db)):
    month = await get_or_404(EditablePlanMonths, id, db)
    await month.update(status, db)
    result = await db.execute(select(EditablePlanMonths))
    return result.scalars().all()


@router.post('/delete-postupleniya/{reservation_id}')
async def delete_postupleniya(reservation_id: int, db: AsyncSession = Depends(get_db)):
    reservation = await get_or_404(Reservation, reservation_id, db)
    await reservation.delete_postupleniya(db)
    return {"msg":"Success"}

