#!/usr/bin/env python3
"""
auth.py
=======
Real authentication layer for the Fund AI application.

Stores users in a small, writable SQLite database (separate from the
read-only fund_combined_db.db), hashes passwords with Werkzeug, and issues
signed JWT (HS256) tokens that the React frontend validates via jwt-decode.

Public helpers used by fund_ai_app.py:
    init_auth_db()                  -> ensure schema + seed default user
    authenticate(username, pw)      -> user dict or None
    create_user(...)                -> user dict (raises ValueError on dup)
    issue_token(user)               -> JWT string
    decode_token(token)             -> payload dict or None
    require_auth(fn)                -> Flask route decorator
    get_current_user()              -> user dict for the request's Bearer token
    user_count()                    -> int
"""

import os
import sqlite3
import secrets
from datetime import datetime, timezone, timedelta
from functools import wraps

import jwt  # PyJWT
from flask import request, jsonify, g
from werkzeug.security import generate_password_hash, check_password_hash

# ═══════════════════════════════════════════════════════════════
# CONFIGURATION
# ═══════════════════════════════════════════════════════════════

AUTH_DB_PATH = os.environ.get(
    "AUTH_DB_PATH",
    os.path.join(os.path.dirname(os.path.abspath(__file__)), "auth.db"),
)

# Token lifetime (days). Frontend jwt-decode enforces the same "exp".
TOKEN_TTL_DAYS = int(os.environ.get("AUTH_TOKEN_TTL_DAYS", 7))

_JWT_ALG = "HS256"


def _jwt_secret():
    """Resolve the JWT signing secret.

    Prefers env JWT_SECRET. If unset, generates a random per-process secret
    and warns — usable for local dev, but tokens won't survive a restart and
    it must be set explicitly for any real/shared deployment.
    """
    secret = os.environ.get("JWT_SECRET", "").strip()
    if secret:
        return secret
    if not getattr(_jwt_secret, "_warned", False):
        print("  WARNING  : JWT_SECRET not set — using a random per-process "
              "secret. Set JWT_SECRET in .env for persistent sessions.")
        _jwt_secret._warned = True
    # Cache a stable per-process fallback so tokens are valid within one run.
    if not getattr(_jwt_secret, "_fallback", None):
        _jwt_secret._fallback = secrets.token_urlsafe(48)
    return _jwt_secret._fallback


# ═══════════════════════════════════════════════════════════════
# DATABASE
# ═══════════════════════════════════════════════════════════════

def _connect():
    conn = sqlite3.connect(AUTH_DB_PATH)
    conn.row_factory = sqlite3.Row
    return conn


def init_auth_db():
    """Create the users table if missing and seed a default user if empty.

    The default user is taken from AUTH_DEFAULT_USERNAME / AUTH_DEFAULT_PASSWORD
    so there is a real, working login without a self-service sign-up UI.
    Returns a short status dict for the startup banner.
    """
    conn = _connect()
    try:
        conn.execute(
            """
            CREATE TABLE IF NOT EXISTS users (
                id            INTEGER PRIMARY KEY AUTOINCREMENT,
                username      TEXT NOT NULL UNIQUE,
                email         TEXT,
                name          TEXT,
                password_hash TEXT NOT NULL,
                created_at    TEXT NOT NULL
            )
            """
        )
        conn.commit()

        count = conn.execute("SELECT COUNT(*) FROM users").fetchone()[0]
        seeded = False
        if count == 0:
            default_user = os.environ.get("AUTH_DEFAULT_USERNAME", "admin").strip()
            default_pass = os.environ.get("AUTH_DEFAULT_PASSWORD", "").strip()
            if not default_pass:
                default_pass = "admin123"
                print("  WARNING  : AUTH_DEFAULT_PASSWORD not set — seeding "
                      f"user '{default_user}' with a weak default password. "
                      "Set AUTH_DEFAULT_PASSWORD in .env.")
            _insert_user(
                conn,
                username=default_user,
                password=default_pass,
                email=os.environ.get("AUTH_DEFAULT_EMAIL", f"{default_user}@example.com"),
                name=os.environ.get("AUTH_DEFAULT_NAME", "Administrator"),
            )
            conn.commit()
            seeded = True
            count = 1

        return {"users": count, "seeded": seeded, "db_path": AUTH_DB_PATH}
    finally:
        conn.close()


def _row_to_user(row):
    """Convert a DB row to a public user dict (never expose password_hash)."""
    if row is None:
        return None
    name = row["name"] or row["username"]
    initials = "".join(part[0] for part in name.split()[:2]).upper() or "U"
    return {
        "id": row["id"],
        "username": row["username"],
        "email": row["email"],
        "name": name,
        "avatar": None,
        "initials": initials,
    }


def _insert_user(conn, username, password, email=None, name=None):
    now = datetime.now(timezone.utc).isoformat()
    cursor = conn.execute(
        "INSERT INTO users (username, email, name, password_hash, created_at) "
        "VALUES (?, ?, ?, ?, ?)",
        (username, email, name or username, generate_password_hash(password), now),
    )
    row = conn.execute(
        "SELECT * FROM users WHERE id = ?", (cursor.lastrowid,)
    ).fetchone()
    return _row_to_user(row)


def create_user(username, password, email=None, name=None):
    """Create a new user. Raises ValueError on missing fields or duplicates."""
    username = (username or "").strip()
    password = password or ""
    if not username or not password:
        raise ValueError("Username and password are required")

    conn = _connect()
    try:
        existing = conn.execute(
            "SELECT 1 FROM users WHERE username = ?", (username,)
        ).fetchone()
        if existing:
            raise ValueError("Username already exists")
        user = _insert_user(conn, username, password, email, name)
        conn.commit()
        return user
    finally:
        conn.close()


def authenticate(username, password):
    """Return the user dict if credentials are valid, else None."""
    username = (username or "").strip()
    if not username or not password:
        return None
    conn = _connect()
    try:
        row = conn.execute(
            "SELECT * FROM users WHERE username = ?", (username,)
        ).fetchone()
        if row is None:
            return None
        if not check_password_hash(row["password_hash"], password):
            return None
        return _row_to_user(row)
    finally:
        conn.close()


def get_user_by_id(user_id):
    conn = _connect()
    try:
        row = conn.execute(
            "SELECT * FROM users WHERE id = ?", (user_id,)
        ).fetchone()
        return _row_to_user(row)
    finally:
        conn.close()


def user_count():
    conn = _connect()
    try:
        return conn.execute("SELECT COUNT(*) FROM users").fetchone()[0]
    finally:
        conn.close()


# ═══════════════════════════════════════════════════════════════
# JWT
# ═══════════════════════════════════════════════════════════════

def issue_token(user):
    """Create a signed JWT for the given user dict."""
    now = datetime.now(timezone.utc)
    payload = {
        "sub": str(user["id"]),
        "username": user["username"],
        "iat": int(now.timestamp()),
        "exp": int((now + timedelta(days=TOKEN_TTL_DAYS)).timestamp()),
    }
    return jwt.encode(payload, _jwt_secret(), algorithm=_JWT_ALG)


def decode_token(token):
    """Decode and verify a JWT. Returns the payload dict, or None if invalid."""
    if not token or not isinstance(token, str):
        return None
    try:
        return jwt.decode(token, _jwt_secret(), algorithms=[_JWT_ALG])
    except jwt.PyJWTError:
        return None


def _bearer_token():
    header = request.headers.get("Authorization", "")
    if header.startswith("Bearer "):
        return header[len("Bearer "):].strip()
    return None


def get_current_user():
    """Resolve the user for the request's Bearer token, or None."""
    payload = decode_token(_bearer_token())
    if not payload:
        return None
    try:
        return get_user_by_id(int(payload["sub"]))
    except (KeyError, ValueError, TypeError):
        return None


def require_auth(fn):
    """Flask decorator: reject requests without a valid Bearer token."""
    @wraps(fn)
    def wrapper(*args, **kwargs):
        user = get_current_user()
        if user is None:
            return jsonify({"error": "Unauthorized"}), 401
        g.current_user = user
        return fn(*args, **kwargs)
    return wrapper
