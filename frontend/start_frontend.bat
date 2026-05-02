@echo off
echo ============================================
echo   Fund Explorer Frontend - Starting...
echo ============================================
echo.
echo Installing npm dependencies (first time only)...
call npm install
echo.
echo Starting dev server on http://localhost:5173
echo.
call npm run dev
pause
