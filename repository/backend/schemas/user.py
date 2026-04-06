from datetime import datetime

from pydantic import BaseModel, EmailStr


class UserBase(BaseModel):
    username: str
    given_name: str | None = None
    family_name: str | None = None
    email: str | None = None
    institution: str | None = None
    is_admin: bool = False


class UserCreate(UserBase):
    password: str


class UserUpdate(BaseModel):
    given_name: str | None = None
    family_name: str | None = None
    email: str | None = None
    institution: str | None = None
    is_admin: bool | None = None
    password: str | None = None


class UserOut(UserBase):
    id: int
    created_at: datetime

    model_config = {"from_attributes": True}
