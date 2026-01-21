# win_update_fresh_driver
Automated batch script for installing and updating drivers on Lenovo and Asus laptops. Supports fresh Windows installations and existing systems. Uses Windows Update, Device Manager, and manufacturer tools for comprehensive driver coverage. Run as admin and restart when done.


# Laptop Driver Install & Update Script

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform](https://img.shields.io/badge/platform-Windows-blue.svg)](https://www.microsoft.com/windows)
[![Batch Script](https://img.shields.io/badge/script-batch-green.svg)](https://en.wikipedia.org/wiki/Batch_file)

A comprehensive batch script designed to automatically install and update drivers on **Lenovo** and **Asus** laptops. Perfect for fresh Windows installations or routine driver maintenance.

## 🌟 Features

- **Automatic Manufacturer Detection** - Identifies Lenovo or Asus laptops automatically
- **Fresh Installation Support** - Installs all missing drivers on new laptops
- **Driver Update Mode** - Updates existing drivers on configured systems
- **Windows Update Integration** - Leverages Windows Update for comprehensive driver coverage
- **Network Driver Priority** - Ensures connectivity drivers are installed first
- **Device Verification** - Identifies devices still needing drivers
- **Manufacturer-Specific Recommendations** - Provides links to official support tools
- **Progress Tracking** - Clear 7-step process with detailed feedback
- **Administrator Privilege Check** - Ensures proper permissions before execution

## 🚀 Quick Start

### Prerequisites

- Windows 7 or later
- Administrator privileges
- Internet connection (for driver downloads)

### Usage

1. **Download** the script:
   ```bash
   git clone https://github.com/yourusername/laptop-driver-script.git
   cd laptop-driver-script
   ```

2. **Run as Administrator**:
   - Right-click `Install-Update-Drivers.bat`
   - Select "Run as Administrator"

3. **Follow the prompts**:
   - Choose between Fresh Installation or Update mode
   - Wait for the process to complete (15-30 minutes)
   - Restart when prompted

## 📋 What It Does

### 7-Step Process

1. **Configure Windows Update** - Enables automatic driver installation
2. **Install Critical Drivers** - Chipset and base system drivers
3. **Network Adapters** - Ensures internet connectivity
4. **Windows Update Drivers** - Downloads and installs from Microsoft servers
5. **Generic Device Drivers** - Installs Windows-provided drivers
6. **Manufacturer-Specific** - Guides you to official tools (Lenovo Vantage/MyASUS)
7. **Final Verification** - Scans for remaining issues

### Supported Manufacturers

- ✅ **Lenovo** - All models
- ✅ **Asus/ASUSTeK** - All models

## 💡 Use Cases

### Fresh Windows Installation
Perfect for newly purchased laptops or after a clean Windows install. The script will:
- Install all missing device drivers
- Configure Windows Update for automatic driver updates
- Guide you to manufacturer-specific tools for specialized drivers

### Regular Maintenance
Keep your existing system up-to-date with:
- Automatic driver updates from Windows Update
- Device Manager driver scans
- Verification of driver health

## 📊 Example Output

```
========================================
  Laptop Driver Install & Update Script
========================================

Detected Manufacturer: LENOVO
Detected Model: ThinkPad X1 Carbon Gen 9

[Step 1/7] Configuring Windows Update...
[Step 2/7] Installing critical system drivers...
[Step 3/7] Installing network adapters...
[Step 4/7] Installing drivers from Windows Update...
Found 12 driver update(s). Installing...
[Step 5/7] Installing generic device drivers...
[Step 6/7] Installing manufacturer-specific drivers...
[Step 7/7] Final verification scan...

All devices are functioning properly!
```

## ⚙️ Advanced Options

The script automatically:
- Installs PSWindowsUpdate module if needed
- Configures Windows registry for driver updates
- Scans for PnP devices without drivers
- Provides manufacturer support page links

## 🛠️ Recommended Follow-up

After running the script:

### For Lenovo:
- Install [Lenovo Vantage](https://www.microsoft.com/store/productId/9WZDNCRFJ4MV) from Microsoft Store
- Or download [Lenovo System Update](https://support.lenovo.com/downloads/ds012808)

### For Asus:
- Install [MyASUS](https://www.microsoft.com/store/productId/9N7R5S6B0ZZH) from Microsoft Store
- Or download drivers from [Asus Support Center](https://www.asus.com/support/download-center/)

## ⚠️ Important Notes

- **Administrator privileges required** - Script will prompt if not running as admin
- **Restart required** - Most drivers need a reboot to take effect
- **Internet connection needed** - For downloading drivers from Windows Update
- **Takes 15-30 minutes** - Fresh installations require more time
- **Manufacturer tools recommended** - For optimal performance and specialized drivers

## 🐛 Troubleshooting

### Script won't run
- Ensure you're running as Administrator
- Check if execution policies are blocking the script

### Drivers not installing
- Verify internet connection
- Run Windows Update manually first
- Check Device Manager for specific error codes

### Some devices still missing drivers
- Install manufacturer-specific tools (Lenovo Vantage/MyASUS)
- Visit manufacturer support page for manual driver downloads
- Some specialized drivers may not be available through Windows Update

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📧 Support

For issues and questions:
- Open an [Issue](https://github.com/djkaz/laptop-driver-script/issues)
- Check existing issues for solutions

## ⭐ Acknowledgments

- Built for the Windows command-line ecosystem
- Utilizes Windows Update and Device Manager APIs
- Supports Lenovo and Asus hardware ecosystems

---

**Note**: This script is designed for Lenovo and Asus laptops only. Other manufacturers may be added in future versions.
