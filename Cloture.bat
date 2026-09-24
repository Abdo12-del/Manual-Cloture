@echo off
rem ====================================================================
rem  Cloture annuelle - lanceur de l'interface graphique
rem  Double-cliquez sur ce fichier pour ouvrir la fenetre du programme.
rem  (Pas de texte accentue ici : le fichier reste lisible en ANSI.)
rem ====================================================================
setlocal
cd /d "%~dp0"
title Cloture annuelle

where powershell.exe >nul 2>&1
if errorlevel 1 (
    echo.
    echo   PowerShell n'est pas installe sur ce systeme.
    echo   PowerShell is not installed on this system.
    echo.
    pause
    exit /b 1
)

powershell.exe -NoProfile -ExecutionPolicy Bypass -STA -File "%~dp0Cloture.ps1"

if errorlevel 1 (
    echo.
    echo   Le programme s'est termine avec une erreur.
    echo   The program exited with an error.
    echo.
    pause
)

exit /b 0
