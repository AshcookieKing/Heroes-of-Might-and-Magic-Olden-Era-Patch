@echo off
chcp 65001 >nul
cd /d "%~dp0"
python "%~dp0make_zip.py"
if errorlevel 1 (
    echo Python not found. Run: python make_zip.py
    pause
    exit /b 1
)
echo.
echo Send SimTurnsAI_Patch_v1.0.0.zip to friends.
pause
