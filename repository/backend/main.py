from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse

from core.config import is_configured
from routers import auth, settings, setup, users

app = FastAPI(title="LTPDA Repository API", version="3.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
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
