@echo off
REM Laptop Driver Install & Update Script for Lenovo and Asus
REM Run as Administrator - Works on fresh Windows installations

color 0B
title Laptop Driver Install & Update Script

REM Check for Administrator privileges
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo.
    echo ========================================
    echo ERROR: Administrator privileges required
    echo ========================================
    echo.
    echo Please right-click this script and select "Run as Administrator"
    echo.
    pause
    exit /b 1
)

echo ========================================
echo  Laptop Driver Install ^& Update Script
echo ========================================
echo.

REM Detect laptop manufacturer
for /f "tokens=2 delims==" %%i in ('wmic computersystem get manufacturer /value ^| find "="') do set MANUFACTURER=%%i
for /f "tokens=2 delims==" %%i in ('wmic computersystem get model /value ^| find "="') do set MODEL=%%i

echo Detected Manufacturer: %MANUFACTURER%
echo Detected Model: %MODEL%
echo.

REM Check if Lenovo or Asus
set IS_LENOVO=0
set IS_ASUS=0

echo %MANUFACTURER% | findstr /i "Lenovo" >nul
if %errorLevel% equ 0 set IS_LENOVO=1

echo %MANUFACTURER% | findstr /i "ASUS ASUSTeK" >nul
if %errorLevel% equ 0 set IS_ASUS=1

if %IS_LENOVO% equ 0 if %IS_ASUS% equ 0 (
    echo.
    echo ========================================
    echo WARNING: Unsupported Manufacturer
    echo ========================================
    echo.
    echo This script is designed for Lenovo or Asus laptops only.
    echo Detected: %MANUFACTURER%
    echo.
    pause
    exit /b 1
)

REM Ask user if this is a fresh installation
echo.
echo Is this a fresh Windows installation or new laptop?
set /p FRESH_INSTALL="(Y=Yes, fresh install / N=No, just update existing drivers): "
echo.

if /i "%FRESH_INSTALL%"=="Y" (
    echo Running in FRESH INSTALLATION mode...
    echo This will install all missing drivers.
    echo.
) else (
    echo Running in UPDATE mode...
    echo This will update existing drivers.
    echo.
)

echo Starting driver installation/update process...
echo This may take 15-30 minutes depending on your system.
echo.
timeout /t 3 >nul

REM ========================================
REM Step 1: Enable Windows Update for drivers
REM ========================================
echo [Step 1/7] Configuring Windows Update for driver installation...
echo.

powershell -NoProfile -ExecutionPolicy Bypass -Command "Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DriverSearching' -Name 'SearchOrderConfig' -Value 1 -Force" 2>nul
powershell -NoProfile -ExecutionPolicy Bypass -Command "Set-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate' -Name 'ExcludeWUDriversInQualityUpdate' -Value 0 -Force -ErrorAction SilentlyContinue" 2>nul

echo Windows Update configured for driver installation.
echo.

REM ========================================
REM Step 2: Install critical drivers first
REM ========================================
if /i "%FRESH_INSTALL%"=="Y" (
    echo [Step 2/7] Installing critical system drivers...
    echo.
    
    echo Installing chipset and base system drivers...
    pnputil /scan-devices
    
    echo.
    echo Forcing hardware detection...
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-WmiObject Win32_PnPEntity | Where-Object {$_.ConfigManagerErrorCode -gt 0} | ForEach-Object { $_.DeviceID }" 2>nul
    
    echo.
    timeout /t 2 >nul
) else (
    echo [Step 2/7] Scanning existing drivers...
    echo.
    pnputil /scan-devices
    echo.
)

REM ========================================
REM Step 3: Install/Update network drivers
REM ========================================
echo [Step 3/7] Installing/Updating network adapters...
echo.

echo Detecting network adapters...
powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-NetAdapter | Select-Object Name, Status, InterfaceDescription | Format-Table -AutoSize"

echo.
echo Updating network drivers...
pnputil /scan-devices
timeout /t 2 >nul
echo.

REM ========================================
REM Step 4: Install Windows Update drivers
REM ========================================
echo [Step 4/7] Installing drivers from Windows Update...
echo.

if /i "%FRESH_INSTALL%"=="Y" (
    echo This may take 10-20 minutes on fresh installations...
    echo.
)

powershell -NoProfile -ExecutionPolicy Bypass -Command "try { Write-Host 'Checking for PSWindowsUpdate module...'; if (-not (Get-Module -ListAvailable -Name PSWindowsUpdate)) { Write-Host 'Installing PSWindowsUpdate module (required for driver updates)...'; [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -ErrorAction SilentlyContinue | Out-Null; Set-PSRepository -Name PSGallery -InstallationPolicy Trusted -ErrorAction SilentlyContinue; Install-Module -Name PSWindowsUpdate -Force -Confirm:$false -SkipPublisherCheck | Out-Null; Write-Host 'Module installed successfully.'; }; Import-Module PSWindowsUpdate -ErrorAction Stop; Write-Host 'Searching for driver updates...'; $updates = Get-WindowsUpdate -UpdateType Driver -Verbose; if ($updates.Count -eq 0) { Write-Host 'No additional driver updates found in Windows Update.' } else { Write-Host \"Found $($updates.Count) driver update(s). Installing...\"; Install-WindowsUpdate -UpdateType Driver -AcceptAll -AutoReboot:$false -Verbose; Write-Host 'Driver installation from Windows Update completed!' } } catch { Write-Host 'Windows Update check completed with warnings. Continuing...'; Write-Host $_.Exception.Message }"

echo.
timeout /t 2 >nul

REM ========================================
REM Step 5: Install generic device drivers
REM ========================================
echo [Step 5/7] Installing generic device drivers...
echo.

echo Scanning for devices without drivers...
powershell -NoProfile -ExecutionPolicy Bypass -Command "$devices = Get-WmiObject Win32_PnPEntity | Where-Object {$_.ConfigManagerErrorCode -ne 0}; if ($devices) { Write-Host 'Devices needing drivers:'; $devices | Select-Object Name, DeviceID | Format-Table -AutoSize } else { Write-Host 'All devices have drivers installed.' }"

echo.
echo Installing available drivers from Windows...
Dism /Online /Get-Drivers /Format:Table

echo.
timeout /t 2 >nul

REM ========================================
REM Step 6: Manufacturer-specific drivers
REM ========================================
echo [Step 6/7] Installing manufacturer-specific drivers...
echo.

if %IS_LENOVO% equ 1 (
    echo Detected Lenovo laptop. Checking for manufacturer drivers...
    echo.
    
    if /i "%FRESH_INSTALL%"=="Y" (
        echo IMPORTANT: For fresh Lenovo installations, you should install:
        echo   1. Lenovo Vantage from Microsoft Store
        echo   2. OR download Lenovo System Update from:
        echo      https://support.lenovo.com/downloads/ds012808
        echo.
        set /p OPEN_LENOVO="Open Lenovo Support page in browser? (Y/N): "
        if /i "!OPEN_LENOVO!"=="Y" (
            start https://support.lenovo.com/downloads
        )
    ) else (
        echo For complete driver updates, use Lenovo Vantage or System Update.
    )
    echo.
)

if %IS_ASUS% equ 1 (
    echo Detected Asus laptop. Checking for manufacturer drivers...
    echo.
    
    if /i "%FRESH_INSTALL%"=="Y" (
        echo IMPORTANT: For fresh Asus installations, you should install:
        echo   1. MyASUS app from Microsoft Store
        echo   2. OR download drivers manually from:
        echo      https://www.asus.com/support/download-center/
        echo.
        set /p OPEN_ASUS="Open Asus Support page in browser? (Y/N): "
        if /i "!OPEN_ASUS!"=="Y" (
            start https://www.asus.com/support/download-center/
        )
    ) else (
        echo For complete driver updates, use MyASUS app.
    )
    echo.
)

timeout /t 2 >nul

REM ========================================
REM Step 7: Final scan and verification
REM ========================================
echo [Step 7/7] Final verification scan...
echo.

echo Performing final hardware scan...
pnputil /scan-devices

echo.
echo Checking for remaining issues...
powershell -NoProfile -ExecutionPolicy Bypass -Command "$issues = Get-WmiObject Win32_PnPEntity | Where-Object {$_.ConfigManagerErrorCode -ne 0}; if ($issues) { Write-Host 'Devices still needing attention:' -ForegroundColor Yellow; $issues | Select-Object Name, DeviceID | Format-Table -AutoSize; Write-Host 'These may require manufacturer-specific drivers.' -ForegroundColor Yellow } else { Write-Host 'All devices are functioning properly!' -ForegroundColor Green }"

echo.

REM ========================================
REM Show installed driver summary
REM ========================================
echo ========================================
echo        Driver Installation Summary
echo ========================================
echo.

powershell -NoProfile -ExecutionPolicy Bypass -Command "Write-Host 'Total Drivers Installed:'; (Get-WmiObject Win32_PnPSignedDriver | Measure-Object).Count; Write-Host ''; Write-Host 'Driver Categories:'; Get-WmiObject Win32_PnPSignedDriver | Group-Object DeviceClass | Select-Object Name, Count | Sort-Object Count -Descending | Select-Object -First 10 | Format-Table -AutoSize"

echo.

REM ========================================
REM Recommendations
REM ========================================
echo ========================================
echo          Recommendations
echo ========================================
echo.

if /i "%FRESH_INSTALL%"=="Y" (
    echo For fresh installations, we recommend:
    echo.
    echo 1. Install manufacturer software:
    if %IS_LENOVO% equ 1 (
        echo    - Lenovo Vantage ^(Microsoft Store^)
        echo    - Lenovo System Update
    )
    if %IS_ASUS% equ 1 (
        echo    - MyASUS ^(Microsoft Store^)
        echo    - Asus Armoury Crate ^(for gaming models^)
    )
    echo.
    echo 2. Run Windows Update manually:
    echo    - Settings ^> Update ^& Security ^> Windows Update
    echo.
    echo 3. Check Device Manager for any remaining issues:
    echo    - Right-click Start ^> Device Manager
    echo    - Look for yellow exclamation marks
    echo.
) else (
    echo Driver update completed successfully!
    echo.
    echo Next steps:
    echo 1. Check Device Manager for any remaining issues
    echo 2. Run manufacturer update tools for optimal performance
    echo.
)

REM ========================================
REM Restart prompt
REM ========================================
echo ========================================
echo     Installation/Update Complete
echo ========================================
echo.
echo A restart is REQUIRED to complete driver installation.
echo.

set /p RESTART="Would you like to restart now? (Y/N): "

if /i "%RESTART%"=="Y" (
    echo.
    echo Restarting in 15 seconds...
    echo Press Ctrl+C to cancel.
    timeout /t 15
    shutdown /r /f /t 0
) else (
    echo.
    echo IMPORTANT: Please restart your computer as soon as possible!
    echo.
    pause
)
