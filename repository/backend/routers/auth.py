from datetime import datetime, timedelta, timezone

from fastapi import APIRouter, Cookie, Depends, HTTPException, Response, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from jose import JWTError
from jose import jwt as jose_jwt
from pydantic import BaseModel
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from core.config import ACCESS_TOKEN_EXPIRE_MINUTES, get_secret_key
from core.database import get_session
from core.security import ALGORITHM, create_access_token, decode_token, verify_password
from models.user import User
from schemas.user import UserOut

router = APIRouter(prefix="/api/auth", tags=["auth"])
bearer = HTTPBearer()


class LoginRequest(BaseModel):
    username: str
    password: str


class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"


async def get_current_user(
    creds: HTTPAuthorizationCredentials = Depends(bearer),
    session: AsyncSession = Depends(get_session),
) -> User:
    username = decode_token(creds.credentials)
    if not username:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid token")
    result = await session.execute(select(User).where(User.username == username))
    user = result.scalar_one_or_none()
    if not user:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="User not found")
    return user


async def require_admin(user: User = Depends(get_current_user)) -> User:
    if not user.is_admin:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Admin required")
    return user


@router.post("/login", response_model=TokenResponse)
async def login(req: LoginRequest, session: AsyncSession = Depends(get_session)):
    result = await session.execute(select(User).where(User.username == req.username))
    user = result.scalar_one_or_none()
    if not user or not verify_password(req.password, user.password_hash):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid credentials")
    token = create_access_token(user.username)
    return TokenResponse(access_token=token)


@router.get("/me", response_model=UserOut)
async def me(user: User = Depends(get_current_user)):
    return user


@router.post("/refresh", response_model=TokenResponse)
async def refresh_token(user: User = Depends(get_current_user)):
    """Issue a fresh token for an active session. Called automatically by the
    frontend when the current token is within 5 minutes of expiry."""
    return TokenResponse(access_token=create_access_token(user.username))


_PMA_COOKIE = "pma_access"


@router.post("/pma-token", status_code=204)
async def issue_pma_token(
    response: Response,
    user: User = Depends(require_admin),
):
    """Issue a short-lived HttpOnly cookie that grants nginx access to /pma/.
    Called by the frontend immediately before opening /pma/ in a new tab."""
    expire = datetime.now(timezone.utc) + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    token = jose_jwt.encode(
        {"sub": user.username, "exp": expire, "pma": True},
        get_secret_key(),
        algorithm=ALGORITHM,
    )
    response.set_cookie(
        key=_PMA_COOKIE,
        value=token,
        httponly=True,
        samesite="lax",
        path="/pma/",
        max_age=ACCESS_TOKEN_EXPIRE_MINUTES * 60,
    )


@router.delete("/pma-token", status_code=204)
async def revoke_pma_token(response: Response):
    """Clear the pma_access cookie on logout. No auth required — harmless if cookie absent."""
    response.delete_cookie(key=_PMA_COOKIE, path="/pma/", httponly=True, samesite="lax")


@router.get("/pma-auth")
async def pma_auth_check(pma_access: str | None = Cookie(default=None)):
    """Internal endpoint called by nginx auth_request on every /pma/ request.
    Validates the pma_access cookie — no database query, pure JWT check."""
    if not pma_access:
        raise HTTPException(status_code=401, detail="No PMA access cookie")
    try:
        payload = jose_jwt.decode(pma_access, get_secret_key(), algorithms=[ALGORITHM])
        if not payload.get("pma"):
            raise HTTPException(status_code=401, detail="Not a PMA token")
    except JWTError:
        raise HTTPException(status_code=401, detail="Invalid or expired PMA token")
    return Response(status_code=200)
