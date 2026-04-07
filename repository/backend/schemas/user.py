from datetime import datetime

from pydantic import BaseModel


class UserBase(BaseModel):
    username: str
    first_name: str | None = None
    last_name: str | None = None
    email: str | None = None
    institution: str | None = None
    is_admin: bool = False


class UserCreate(UserBase):
    password: str
    mysql_password: str | None = None


class UserUpdate(BaseModel):
    first_name: str | None = None
    last_name: str | None = None
    email: str | None = None
    institution: str | None = None
    is_admin: bool | None = None
    password: str | None = None
    mysql_password: str | None = None


class UserOut(UserBase):
    id: int
    created_at: datetime

    model_config = {"from_attributes": True}
