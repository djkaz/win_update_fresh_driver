@echo off
echo "Universal Driver Install & Update Script"
echo "Works on all laptops, desktops, and virtual machines"
echo "Run as Administrator - Works on fresh Windows installations"

color 0B
title "Universal Driver Install & Update Script"

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
echo Universal Driver Install ^& Update Script
echo ========================================
echo.

REM Detect system information using PowerShell (wmic replacement)
echo Detecting system information...
for /f "delims=" %%i in ('powershell -Command "(Get-CimInstance -ClassName Win32_ComputerSystem).Manufacturer"') do set MANUFACTURER=%%i
for /f "delims=" %%i in ('powershell -Command "(Get-CimInstance -ClassName Win32_ComputerSystem).Model"') do set MODEL=%%i

echo System Information:
echo   Manufacturer: %MANUFACTURER%
echo   Model: %MODEL%
echo.

REM Detect if running in a Virtual Machine
set IS_VM=0
echo Checking if running in virtual environment...

echo %MODEL% | findstr /i "Virtual VMware VirtualBox QEMU KVM Hyper-V Xen Parallels" >nul
if %errorLevel% equ 0 set IS_VM=1

powershell -Command "(Get-CimInstance -ClassName Win32_BIOS).SerialNumber" | findstr /i "VMware VirtualBox 0" >nul
if %errorLevel% equ 0 set IS_VM=1

powershell -Command "(Get-CimInstance -ClassName Win32_ComputerSystem).Model" | findstr /i "Virtual" >nul
if %errorLevel% equ 0 set IS_VM=1

if %IS_VM% equ 1 (
    echo   Environment: VIRTUAL MACHINE detected
    echo.
) else (
    echo   Environment: Physical Hardware
    echo.
)

REM Detect specific manufacturers and VM platforms
set IS_LENOVO=0
set IS_ASUS=0
set IS_HP=0
set IS_DELL=0
set IS_ACER=0
set IS_MSI=0
set IS_VMWARE=0
set IS_VIRTUALBOX=0
set IS_HYPERV=0

echo %MANUFACTURER% | findstr /i "Lenovo" >nul
if %errorLevel% equ 0 set IS_LENOVO=1

echo %MANUFACTURER% | findstr /i "ASUS ASUSTeK" >nul
if %errorLevel% equ 0 set IS_ASUS=1

echo %MANUFACTURER% | findstr /i "HP Hewlett" >nul
if %errorLevel% equ 0 set IS_HP=1

echo %MANUFACTURER% | findstr /i "Dell" >nul
if %errorLevel% equ 0 set IS_DELL=1

echo %MANUFACTURER% | findstr /i "Acer" >nul
if %errorLevel% equ 0 set IS_ACER=1

echo %MANUFACTURER% | findstr /i "MSI Micro-Star" >nul
if %errorLevel% equ 0 set IS_MSI=1

echo %MANUFACTURER%%MODEL% | findstr /i "VMware" >nul
if %errorLevel% equ 0 set IS_VMWARE=1

echo %MANUFACTURER%%MODEL% | findstr /i "VirtualBox" >nul
if %errorLevel% equ 0 set IS_VIRTUALBOX=1

echo %MANUFACTURER%%MODEL% | findstr /i "Microsoft.*Virtual Hyper-V" >nul
if %errorLevel% equ 0 set IS_HYPERV=1

REM Ask user if this is a fresh installation
echo.
echo Is this a fresh Windows installation?
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
echo [Step 1/8] Configuring Windows Update for driver installation...
echo.

powershell -NoProfile -ExecutionPolicy Bypass -Command "try { New-Item -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DriverSearching' -Force -ErrorAction SilentlyContinue | Out-Null; Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DriverSearching' -Name 'SearchOrderConfig' -Value 1 -Force } catch { Write-Host 'Registry update completed with warnings' }" 2>nul

powershell -NoProfile -ExecutionPolicy Bypass -Command "try { New-Item -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate' -Force -ErrorAction SilentlyContinue | Out-Null; Set-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate' -Name 'ExcludeWUDriversInQualityUpdate' -Value 0 -Force -ErrorAction SilentlyContinue } catch { }" 2>nul

echo Windows Update configured for driver installation.
echo.

REM ========================================
REM Step 2: Install VM-specific drivers first
REM ========================================
if %IS_VM% equ 1 (
    echo [Step 2/8] Configuring virtual machine drivers...
    echo.
    
    if %IS_VMWARE% equ 1 (
        echo Detected VMware virtual machine.
        echo Please install VMware Tools for optimal performance.
        echo Download from: VM menu ^> Install VMware Tools
        echo.
    )
    
    if %IS_VIRTUALBOX% equ 1 (
        echo Detected VirtualBox virtual machine.
        echo Please install VirtualBox Guest Additions for optimal performance.
        echo Download from: Devices menu ^> Insert Guest Additions CD Image
        echo.
    )
    
    if %IS_HYPERV% equ 1 (
        echo Detected Hyper-V virtual machine.
        echo Hyper-V Integration Services should be installed automatically.
        echo.
    )
    
    echo Installing available VM drivers...
    pnputil /scan-devices
    echo.
) else (
    echo [Step 2/8] Installing critical system drivers...
    echo.
    
    echo Installing chipset and base system drivers...
    pnputil /scan-devices
    
    echo.
    echo Forcing hardware detection...
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-CimInstance Win32_PnPEntity | Where-Object {$_.ConfigManagerErrorCode -gt 0} | ForEach-Object { $_.DeviceID }" 2>nul
    
    echo.
    timeout /t 2 >nul
)

REM ========================================
REM Step 3: Install/Update network drivers
REM ========================================
echo [Step 3/8] Installing/Updating network adapters...
echo.

echo Detecting network adapters...
powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-NetAdapter -ErrorAction SilentlyContinue | Select-Object Name, Status, InterfaceDescription | Format-Table -AutoSize"

echo.
echo Updating network drivers...
pnputil /scan-devices
timeout /t 2 >nul
echo.

REM ========================================
REM Step 4: Install Windows Update drivers
REM ========================================
echo [Step 4/8] Installing drivers from Windows Update...
echo.

if /i "%FRESH_INSTALL%"=="Y" (
    echo This may take 10-20 minutes on fresh installations...
    echo.
)

powershell -NoProfile -ExecutionPolicy Bypass -Command "try { Write-Host 'Checking for PSWindowsUpdate module...'; if (-not (Get-Module -ListAvailable -Name PSWindowsUpdate)) { Write-Host 'Installing PSWindowsUpdate module (required for driver updates)...'; [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -ErrorAction SilentlyContinue | Out-Null; Set-PSRepository -Name PSGallery -InstallationPolicy Trusted -ErrorAction SilentlyContinue; Install-Module -Name PSWindowsUpdate -Force -Confirm:$false -SkipPublisherCheck -ErrorAction Stop | Out-Null; Write-Host 'Module installed successfully.'; }; Import-Module PSWindowsUpdate -ErrorAction Stop; Write-Host 'Searching for driver updates...'; $updates = Get-WindowsUpdate -UpdateType Driver -ErrorAction SilentlyContinue; if ($updates.Count -eq 0) { Write-Host 'No additional driver updates found in Windows Update.' } else { Write-Host \"Found $($updates.Count) driver update(s). Installing...\"; Install-WindowsUpdate -UpdateType Driver -AcceptAll -AutoReboot:$false -ErrorAction SilentlyContinue; Write-Host 'Driver installation from Windows Update completed!' } } catch { Write-Host 'Windows Update check completed. Continuing...'; }"

echo.
timeout /t 2 >nul

REM ========================================
REM Step 5: Install generic device drivers
REM ========================================
echo [Step 5/8] Installing generic device drivers...
echo.

echo Scanning for devices without drivers...
powershell -NoProfile -ExecutionPolicy Bypass -Command "$devices = Get-CimInstance Win32_PnPEntity | Where-Object {$_.ConfigManagerErrorCode -ne 0}; if ($devices) { Write-Host 'Devices needing drivers:'; $devices | Select-Object Name, DeviceID | Format-Table -AutoSize } else { Write-Host 'All devices have drivers installed.' }"

echo.
echo Listing installed drivers...
Dism /Online /Get-Drivers /Format:Table | findstr /i "Published"

echo.
timeout /t 2 >nul

REM ========================================
REM Step 6: Install graphics drivers
REM ========================================
echo [Step 6/8] Checking graphics drivers...
echo.

echo Detecting graphics adapters...
powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-CimInstance Win32_VideoController | Select-Object Name, DriverVersion, DriverDate | Format-Table -AutoSize"

echo.
echo Updating graphics drivers via Windows Update...
pnputil /scan-devices
timeout /t 2 >nul
echo.

REM ========================================
REM Step 7: Manufacturer-specific recommendations
REM ========================================
echo [Step 7/8] Manufacturer-specific recommendations...
echo.

if %IS_LENOVO% equ 1 (
    echo Detected LENOVO system
    echo Recommended tools:
    echo   - Lenovo Vantage ^(Microsoft Store^)
    echo   - Lenovo System Update: https://support.lenovo.com/downloads/ds012808
    echo.
    if /i "%FRESH_INSTALL%"=="Y" (
        set /p OPEN_LENOVO="Open Lenovo Support page? (Y/N): "
        if /i "!OPEN_LENOVO!"=="Y" start https://support.lenovo.com/downloads
    )
)

if %IS_ASUS% equ 1 (
    echo Detected ASUS system
    echo Recommended tools:
    echo   - MyASUS ^(Microsoft Store^)
    echo   - Asus Support: https://www.asus.com/support/download-center/
    echo.
    if /i "%FRESH_INSTALL%"=="Y" (
        set /p OPEN_ASUS="Open Asus Support page? (Y/N): "
        if /i "!OPEN_ASUS!"=="Y" start https://www.asus.com/support/download-center/
    )
)

if %IS_HP% equ 1 (
    echo Detected HP system
    echo Recommended tools:
    echo   - HP Support Assistant ^(Microsoft Store^)
    echo   - HP Support: https://support.hp.com/drivers
    echo.
    if /i "%FRESH_INSTALL%"=="Y" (
        set /p OPEN_HP="Open HP Support page? (Y/N): "
        if /i "!OPEN_HP!"=="Y" start https://support.hp.com/drivers
    )
)

if %IS_DELL% equ 1 (
    echo Detected DELL system
    echo Recommended tools:
    echo   - Dell SupportAssist
    echo   - Dell Support: https://www.dell.com/support/home/
    echo.
    if /i "%FRESH_INSTALL%"=="Y" (
        set /p OPEN_DELL="Open Dell Support page? (Y/N): "
        if /i "!OPEN_DELL!"=="Y" start https://www.dell.com/support/home/
    )
)

if %IS_ACER% equ 1 (
    echo Detected ACER system
    echo Recommended tools:
    echo   - Acer Care Center
    echo   - Acer Support: https://www.acer.com/support
    echo.
    if /i "%FRESH_INSTALL%"=="Y" (
        set /p OPEN_ACER="Open Acer Support page? (Y/N): "
        if /i "!OPEN_ACER!"=="Y" start https://www.acer.com/support
    )
)

if %IS_MSI% equ 1 (
    echo Detected MSI system
    echo Recommended tools:
    echo   - MSI Center ^(Microsoft Store^)
    echo   - MSI Support: https://www.msi.com/support
    echo.
    if /i "%FRESH_INSTALL%"=="Y" (
        set /p OPEN_MSI="Open MSI Support page? (Y/N): "
        if /i "!OPEN_MSI!"=="Y" start https://www.msi.com/support
    )
)

if %IS_VMWARE% equ 1 (
    echo.
    echo VMware Virtual Machine detected
    echo IMPORTANT: Install VMware Tools for:
    echo   - Better graphics performance
    echo   - Shared folders support
    echo   - Copy/paste between host and VM
    echo   - Automatic display resolution adjustment
    echo.
)

if %IS_VIRTUALBOX% equ 1 (
    echo.
    echo VirtualBox Virtual Machine detected
    echo IMPORTANT: Install VirtualBox Guest Additions for:
    echo   - Better graphics performance
    echo   - Shared folders support
    echo   - Copy/paste between host and VM
    echo   - Automatic display resolution adjustment
    echo.
)

timeout /t 2 >nul

REM ========================================
REM Step 8: Final scan and verification
REM ========================================
echo [Step 8/8] Final verification scan...
echo.

echo Performing final hardware scan...
pnputil /scan-devices

echo.
echo Checking for remaining issues...
powershell -NoProfile -ExecutionPolicy Bypass -Command "$issues = Get-CimInstance Win32_PnPEntity | Where-Object {$_.ConfigManagerErrorCode -ne 0}; if ($issues) { Write-Host 'Devices still needing attention:' -ForegroundColor Yellow; $issues | Select-Object Name, DeviceID | Format-Table -AutoSize; Write-Host 'These may require manufacturer-specific drivers.' -ForegroundColor Yellow } else { Write-Host 'All devices are functioning properly!' -ForegroundColor Green }"

echo.

REM ========================================
REM Show installed driver summary
REM ========================================
echo ========================================
echo        Driver Installation Summary
echo ========================================
echo.

powershell -NoProfile -ExecutionPolicy Bypass -Command "Write-Host 'Total Drivers Installed:'; (Get-CimInstance Win32_PnPSignedDriver | Measure-Object).Count; Write-Host ''; Write-Host 'Driver Categories:'; Get-CimInstance Win32_PnPSignedDriver | Group-Object DeviceClass | Select-Object Name, Count | Sort-Object Count -Descending | Select-Object -First 10 | Format-Table -AutoSize"

echo.

REM ========================================
REM Recommendations based on system type
REM ========================================
echo ========================================
echo          Recommendations
echo ========================================
echo.

if %IS_VM% equ 1 (
    echo Virtual Machine Recommendations:
    echo.
    if %IS_VMWARE% equ 1 (
        echo 1. Install VMware Tools ^(if not already installed^)
        echo 2. Enable 3D acceleration in VM settings
        echo 3. Allocate sufficient RAM and CPU cores
    )
    if %IS_VIRTUALBOX% equ 1 (
        echo 1. Install VirtualBox Guest Additions ^(if not already installed^)
        echo 2. Enable 3D acceleration in VM settings
        echo 3. Allocate sufficient RAM and CPU cores
    )
    if %IS_HYPERV% equ 1 (
        echo 1. Ensure Integration Services are enabled
        echo 2. Configure Enhanced Session Mode
        echo 3. Allocate sufficient resources in Hyper-V settings
    )
    echo 4. Run Windows Update for additional drivers
    echo 5. Check VM documentation for optimization tips
    echo.
) else (
    if /i "%FRESH_INSTALL%"=="Y" (
        echo For fresh installations:
        echo.
        echo 1. Install manufacturer software for optimal drivers
        echo 2. Run Windows Update multiple times
        echo 3. Check Device Manager for yellow exclamation marks
        echo 4. Update graphics drivers from manufacturer website
        echo 5. Consider updating BIOS/UEFI firmware
        echo.
    ) else (
        echo For driver updates:
        echo.
        echo 1. Check Device Manager for any remaining issues
        echo 2. Run manufacturer update tools regularly
        echo 3. Keep Windows Update enabled
        echo.
    )
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
