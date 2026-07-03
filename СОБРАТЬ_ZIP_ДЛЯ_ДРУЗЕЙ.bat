@echo off
chcp 65001 >nul
cd /d "%~dp0"
set "OUT=%~dp0..\SimTurnsAI_Patch_v1.0.0.zip"
powershell -NoProfile -Command "Compress-Archive -Path '%~dp0*' -DestinationPath '%OUT%' -Force"
echo.
echo Архив для раздачи:
echo %OUT%
echo.
echo Отправьте друзьям ZIP + ИНСТРУКЦИЯ.txt из папки SimTurnsAI_Patch
echo.
pause
