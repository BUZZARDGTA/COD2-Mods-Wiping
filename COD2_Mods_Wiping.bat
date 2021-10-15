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
cls
>nul chcp 65001
title COD2 Mods Wiping
>nul 2>&1 dism || call :EXIT 1
setlocal DisableDelayedExpansion
cd /d "%~dp0"
set "@ERROR=for %%A in ("!Database[%%A]!") do (echo. & echo ERROR: Failed deleting: "%%~nxA". & echo You can still do it manually through Windows file manager. & if not defined error set error=1)"
setlocal EnableDelayedExpansion
set error=

:GET_PATH
cls
for /f "tokens=8delims=\" %%A in ('reg query "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall" ^| findstr /c:"Call of Duty 2"') do (
    for /f "tokens=2*" %%B in ('2^>nul reg query "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\%%A" /v "InstallLocation"') do (
        set "InstallLocation=%%C"
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
echo  ■ Searching modded scripts in: "!InstallLocation!"
echo  ├──────────────────────────────────────────────────────────────────────────────
setlocal DisableDelayedExpansion
set First=
set Database[#]=0
setlocal EnableDelayedExpansion
set First=1
for /f "tokens=1*delims=:" %%A in ('2^>nul dir "!InstallLocation!*.iwd" /a:-d /b /s ^| findstr /vrc:"iw_..\.iwd" /c:"localized_.*_iw..\.iwd" ^| findstr /nrc:".*"') do (
    if defined First endlocal
    echo  ├ %%~fB
    set "Database[%%A]=%%~fB"
    set "Database[#]=%%A"
)
setlocal EnableDelayedExpansion
if "!Database[#]!"=="0" echo  │ No modded scripts found.
echo  └──────────────────────────────────────────────────────────────────────────────
if "!Database[#]!"=="0" call :EXIT
echo.
<nul set /p=" ■ Do you confirm to delete those listed files: [Y/N] ? "
choice /n /c YN
if "!ErrorLevel!"=="1" (
    for /l %%A in (1 1 !Database[#]!) do (
        if exist "!Database[%%A]!" (
            >nul 2>&1 del /f /q "!Database[%%A]!"
            if exist "!Database[%%A]!" %@ERROR%
        ) else (
            %@ERROR%
        )
    )
    if defined error call :EXIT 2
    call :EXIT 3
)

:EXIT
echo.
if not "%1"=="" (
    if "%1"=="1" echo  ■ This script must be "Run as administrator".
    if "%1"=="2" echo  ■ Some files could not be deleted.
    if "%1"=="3" echo  ■ Successfully delete all files.
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