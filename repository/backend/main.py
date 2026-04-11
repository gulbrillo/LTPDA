import logging
import traceback
from contextlib import asynccontextmanager

from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse

from core.config import ensure_ssh_sync_config, is_configured
from core.phpmyadmin import write_pma_config
from routers import auth, settings, setup, users, repos
from routers.objects import router as objects_router

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("ltpda")


@asynccontextmanager
async def lifespan(_app: FastAPI):
    ensure_ssh_sync_config()   # fills in missing SSH sync credentials for old installs
    write_pma_config()
    yield


app = FastAPI(title="LTPDA Repository API", version="3.0.0", lifespan=lifespan)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.exception_handler(Exception)
async def unhandled_exception_handler(request: Request, exc: Exception):
    tb = traceback.format_exc()
    logger.error("Unhandled exception on %s %s:\n%s", request.method, request.url.path, tb)
    return JSONResponse(
        status_code=500,
        content={"detail": f"{type(exc).__name__}: {exc}"},
    )


@app.middleware("http")
async def require_configured(request: Request, call_next):
    """Block all routes except /api/setup/* and /api/health when not configured."""
    path = request.url.path
    if not is_configured() and not path.startswith("/api/setup") and path != "/api/health":
        return JSONResponse(
            {"detail": "Not configured", "setup_required": True},
            status_code=503,
        )
    return await call_next(request)


@app.get("/api/health")
async def health():
    return {"status": "ok", "configured": is_configured()}


app.include_router(setup.router)
app.include_router(auth.router)
app.include_router(users.router)
app.include_router(settings.router)
app.include_router(repos.router)
app.include_router(objects_router)
