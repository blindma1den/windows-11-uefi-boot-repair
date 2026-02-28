@echo off
setlocal EnableDelayedExpansion

REM repair-uefi-boot-win11.bat
REM Version: 1.0.0
REM License: MIT
REM Description: Rebuilds the Windows UEFI bootloader using bcdboot (WinRE/Recovery)

echo.
echo ===============================================
echo   Windows UEFI Boot Repair Script
echo ===============================================
echo.
echo This script will:
echo - Detect your Windows installation
echo - List volumes so you can identify the EFI partition
echo - Mount the EFI partition temporarily
echo - Rebuild UEFI boot files using bcdboot
echo.
echo Press CTRL+C to cancel, or any key to continue...
pause >nul

echo.
echo Step 1: Detecting Windows installation...
echo.

set "WINVOL="

for %%D in (C D E F G H I J K L M N O P Q R S T U V W Y Z) do (
    if exist %%D:\Windows\System32\config\SYSTEM (
        set "WINVOL=%%D:"
        goto :found
    )
)

:found
if "%WINVOL%"=="" (
    echo.
    echo ERROR: Windows installation could not be detected automatically.
    echo Try checking manually:
    echo   dir C:\Windows
    echo   dir D:\Windows
    echo.
    echo If you find it on another drive letter, you can run bcdboot manually:
    echo   bcdboot X:\Windows /s Z: /f UEFI
    echo.
    pause
    exit /b 1
)

echo Windows installation found at %WINVOL%
echo.

echo Step 2: Listing volumes (identify the EFI partition)...
echo.

set "DPTMP=%temp%\diskpart_listvol.txt"
echo list volume > "%DPTMP%"
echo exit >> "%DPTMP%"
diskpart /s "%DPTMP%"
del "%DPTMP%" >nul 2>&1

echo.
echo Identify the EFI partition:
echo - File system: FAT32
echo - Size: usually 100MB to 500MB
echo - Often labeled SYSTEM or BOOT
echo.
set /p EFIVOL=Enter the EFI volume number: 

if "%EFIVOL%"=="" (
    echo ERROR: No EFI volume selected. Exiting.
    exit /b 1
)

echo.
echo Step 3: Mounting EFI partition as Z: ...
echo.

set "DPTMP=%temp%\diskpart_mount_efi.txt"
echo select volume %EFIVOL% > "%DPTMP%"
echo assign letter=Z >> "%DPTMP%"
echo exit >> "%DPTMP%"
diskpart /s "%DPTMP%"
set "DPERR=%errorlevel%"
del "%DPTMP%" >nul 2>&1

if not "%DPERR%"=="0" (
    echo.
    echo ERROR: Failed to mount the EFI partition.
    echo Make sure you selected the correct FAT32 EFI volume and try again.
    pause
    exit /b 1
)

echo.
echo Step 4: Rebuilding UEFI boot files...
echo Running:
echo   bcdboot %WINVOL%\Windows /s Z: /f UEFI
echo.

bcdboot %WINVOL%\Windows /s Z: /f UEFI
set "BCERR=%errorlevel%"

if not "%BCERR%"=="0" (
    echo.
    echo ERROR: Boot repair failed (bcdboot returned %BCERR%).
    echo Possible causes:
    echo - Wrong EFI volume selected
    echo - BitLocker locked system volume
    echo - Windows folder not found where detected
    echo.
    echo You can verify the Windows folder:
    echo   dir %WINVOL%\Windows
    echo.
    pause
    exit /b 1
)

echo.
echo Boot files successfully created.
echo.
echo Restart your system and Windows should boot normally.
echo.

pause
endlocal
exit /b 0
