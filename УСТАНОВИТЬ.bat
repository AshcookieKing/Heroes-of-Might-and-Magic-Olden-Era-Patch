@echo off
chcp 65001 >nul
title SimTurnsAI Patch — установка
cd /d "%~dp0"

echo.
echo ========================================
echo   SimTurnsAI Patch — УСТАНОВКА
echo   Heroes of Might and Magic: Olden Era
echo ========================================
echo.

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0install.ps1"
if errorlevel 1 (
    echo.
    echo Установка не удалась. См. ИНСТРУКЦИЯ.txt
    pause
    exit /b 1
)

echo.
pause
