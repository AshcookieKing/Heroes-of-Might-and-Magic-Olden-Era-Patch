@echo off
chcp 65001 >nul
title SimTurnsAI Patch — статус
cd /d "%~dp0"

echo.
echo ========================================
echo   SimTurnsAI Patch — СТАТУС
echo ========================================
echo.

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0status.ps1"
echo.
pause
