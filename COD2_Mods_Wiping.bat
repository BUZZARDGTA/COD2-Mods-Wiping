@echo off
::------------------------------------------------------------------------------
:: NAME
::     COD2_Mods_Wiping.bat - COD2 Mods Wiping
::
:: DESCRIPTION
::     That script remove your modded scripts
::     from your Call Of Duty 2 installation PATH.
::     Note that only *.iwd files are processed.
::     Folders, *.cfg, *.dat, *.log, *.txt, ... are ignored.
::
:: AUTHOR
::     IB_U_Z_Z_A_R_Dl
::
:: CREDITS
::     @Grub4K - Helped excluding game files.
::     @Grub4K - Helped with deletion error message.
::     @Grub4K - Helped allowing poison characters in file names.
::     @Sintrode - Helped me encoding the CLI.
::     A project created in the "server.bat" Discord: https://discord.gg/GSVrHag
::------------------------------------------------------------------------------
>nul chcp 65001
>nul 2>&1 dism || (
    echo  ■ This script must be "Run as administrator".
    echo.
    <nul set /p= ■ Press {ANY KEY} to exit...
    >nul pause
    exit /b 1
)
set error=
set "@ERROR=for %%a in ("!database[%%a]!") do (echo. & echo ERROR: Failed deleting: "%%~nxa". & echo You can still do it manually through Windows file manager. & if not defined error set error=1)"
Setlocal EnableDelayedExpansion
cd /d "%~dp0"
title COD2 Mods Wiping

:GET_PATH
cls
for /f "tokens=8delims=\" %%a in ('reg query "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall" ^| findstr /c:"Call of Duty 2"') do (
    for /f "tokens=2*" %%b in ('2^>nul reg query "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\%%a" /v "InstallLocation"') do (
        set "InstallLocation=%%c"
    )
)
call :CHECK_PATH InstallLocation && goto :START
echo Enter your COD2 installation PATH:
echo Example: "C:\Program Files (x86)\Call of Duty 2\"
set InstallLocation=
set /p "InstallLocation=> "
call :CHECK_PATH InstallLocation && goto :START
echo.
echo ERROR: "mss32.dll" is missing from that PATH.
echo This is probably not your COD2 PATH.
timeout /t 3
goto :GET_PATH

:START
cls
echo.
echo  ■ Searching mods in: "!InstallLocation!"
echo  ├──────────────────────────────────────
Setlocal DisableDelayedExpansion
set first=
set database[#]=0
Setlocal EnableDelayedExpansion
set first=1
for /f "tokens=1*delims=:" %%a in ('2^>nul dir "!InstallLocation!*.iwd" /a:-d /b /s ^| findstr /vrc:"iw_..\.iwd" /c:"localized_.*_iw..\.iwd" ^| findstr /nrc:".*"') do (
    if defined first endlocal
    echo  │ %%~fb
    set "database[%%a]=%%~fb"
    set "database[#]=%%a"
)
Setlocal EnableDelayedExpansion
if "!database[#]!"=="0" echo  │ No files found.
echo  └──────────────────────────────────────
if "!database[#]!"=="0" call :EXIT
echo.
<nul set /p=" ■ Do you confirm to delete those listed files: [Y/N] ? "
choice /n /c YN
if "!errorlevel!"=="1" (
    for /l %%a in (1 1 !database[#]!) do (
        if exist "!database[%%a]!" (
            >nul 2>&1 del /f /q "!database[%%a]!"
            if exist "!database[%%a]!" %@ERROR%
        ) else (
            %@ERROR%
        )
    )
    if defined error call :EXIT 2
    call :EXIT 1
)

:EXIT
echo.
if not "%1"=="" (
    if "%1"=="1" echo  ■ Successfully delete all files.
    if "%1"=="2" echo  ■ Some files could not be deleted.
    echo.
)
<nul set /p= ■ Press {ANY KEY} to exit...
>nul pause
exit

:CHECK_PATH
if not defined %1 exit /b 1
set "%1=!%1:"=!"
set "%1=!%1:/=\!"
if not "!%1:~-1!"=="\" set "%1=!%1!\"
:STRIP_WHITE_SPACES
if "!%1:~0,1!"==" " set "%1=!%1:~1!" & goto :STRIP_WHITE_SPACES
:_STRIP_WHITE_SPACES
if "!%1:~-1!"==" " set "%1=!%1:~0,-1!" & goto :_STRIP_WHITE_SPACES
:STRIP_SLASHES
if "!%1:~-2!"=="\\" set "%1=!%1:~0,-1!" & goto :STRIP_SLASHES
if exist "!%1!\mss32.dll" exit /b 0
exit /b 1