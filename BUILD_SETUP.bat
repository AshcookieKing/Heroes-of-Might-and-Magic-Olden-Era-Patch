@echo off
chcp 65001 >nul
cd /d "%~dp0"
echo Building SimTurnsAI themed installer...
python make_installer_assets.py
if errorlevel 1 (
    echo Asset generation failed.
    pause
    exit /b 1
)
where iscc >nul 2>&1
if errorlevel 1 (
    set "ISCC=%LOCALAPPDATA%\Programs\Inno Setup 6\ISCC.exe"
    if not exist "%ISCC%" set "ISCC=C:\Program Files (x86)\Inno Setup 6\ISCC.exe"
) else (
    set "ISCC=iscc"
)
if not exist "%ISCC%" (
    echo.
    echo Inno Setup not found. Install from: https://jrsoftware.org/isdl.php
    pause
    exit /b 1
)
"%ISCC%" installer.iss
if errorlevel 1 (
    echo Build failed.
    pause
    exit /b 1
)
echo.
echo Done: ..\SimTurnsAI_Patch_Setup_v1.0.5.exe
pause
