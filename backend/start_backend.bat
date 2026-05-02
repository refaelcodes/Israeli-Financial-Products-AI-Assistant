@echo off
echo ============================================
echo   Fund AI Backend - Starting...
echo ============================================
echo.
echo Installing Python dependencies...
pip install -r requirements.txt
echo.
echo Starting Flask server on http://localhost:5000
echo.
python fund_ai_app.py
pause
