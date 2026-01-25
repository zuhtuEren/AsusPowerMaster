# 💻 Asus Power Master v2.6 (Final Gold)

Hardware-level power and profile management automation for Asus Vivobook Pro 14X and similar models running Kali/Debian Linux. This tool eliminates the need for heavy GUI applications by interacting directly with the Linux Kernel via Sysfs interfaces.

## 🚀 Key Features

- **🔋 Battery Health Guard:** Set hardware-level charge thresholds (e.g., 80%) to significantly extend lithium battery lifespan.
- **🚀 Performance & Thermal Control:** Manage Intel Turbo Boost and Fan profiles (Balanced, Overboost, Silent) on the fly.
- **🧠 Smart Watchdog (Monitor):** Instantly detects AC/Battery transitions and automatically applies user-defined profiles.
- **📊 Live Telemetry:** Real-time monitoring of power consumption (Power Draw in Watts), CPU temperature, and hardware status via the dashboard.
- **💾 Advanced Profile Management:** Define custom behaviors for both AC and Battery modes using --set-ac and --set-bat commands with zero conflict.

## 🛠️ Installation & Uninstallation

### Installation
git clone https://github.com/YOUR_USERNAME/AsusPowerMaster.git
cd AsusPowerMaster
sudo bash install.sh

### Uninstallation (Complete Cleanup)
sudo bash uninstall.sh

## 📖 Usage Guide

### 1. Basic CLI Commands

| Command        | Parameter | Description                                            |
| :------------: | :-------: | :----------------------------------------------------: |
| -s, --status   | None      | Displays the system dashboard.                         |
| -b, --battery  | [60-100]  | Sets the battery charge limit. Use -p for persistence. |
| -t, --turbo    | [on|off]  | Toggles Intel Turbo Boost. Use -p for persistence.     |
| -f, --fan      | [0|1|2]   | Fan Mode: 0:Balanced, 1:Overboost, 2:Silent            |
| -k, --keyboard | [0-3]     | Sets keyboard backlight brightness level.              |
| --monitor      | [-k val]  | Starts the smart watchdog monitoring service.          |

### 2. Advanced Profile Customization (Hybrid Logic)

Override default watchdog behaviors to match your specific workflow:

- Set AC (Plugged-in) Profile: sudo asus-pwr --set-ac -f 0 -t on -k 2
  (Fans remain balanced, Turbo enabled, and backlight at level 2 when plugged in)

- Set Battery Profile: sudo asus-pwr --set-bat -f 2 -t off -k 0
  (Fans go silent, Turbo disabled, and backlight turned off to save energy)

## ⚙️ Technical Details & Architecture

The tool communicates with the Linux Kernel through the following Sysfs paths:
- Fan Control: /sys/devices/platform/.../throttle_thermal_policy
- CPU Turbo: /sys/devices/system/cpu/intel_pstate/no_turbo
- Battery Threshold: /sys/class/power_supply/BAT*/charge_control_end_threshold
- Modular Structure: Library modules for battery, dashboard, performance, and service management are located in the lib/ directory.

---
*Developed for security researchers and power users on Kali Linux. Optimized for Asus hardware.*
