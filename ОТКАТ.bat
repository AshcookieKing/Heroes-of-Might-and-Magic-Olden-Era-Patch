@echo off
chcp 65001 >nul
title SimTurnsAI Patch — откат
cd /d "%~dp0"

echo.
echo ========================================
echo   SimTurnsAI Patch — ОТКАТ
echo ========================================
echo.

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0restore.ps1"
if errorlevel 1 (
    echo.
    echo Откат не удался.
    pause
    exit /b 1
)

echo.
pause
