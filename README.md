# Windows 11 Setup Tool

A PowerShell-based Windows 11 post-install automation tool designed to streamline system setup after a fresh install.

---

## Features

- Install selected applications using `winget`
- Remove preinstalled Windows apps (debloat)
- Interactive menu system
- GUI-based app selection (checkbox UI — no Ctrl clicking)
- Automatic admin elevation
- Silent installs (no spam output)
- Progress tracking during installs
- Logging support
- Modular script structure

---

## Tech Stack

- **PowerShell 5+** – Core scripting and automation
- **winget (Windows Package Manager)** – Application installation
- **Windows Forms (System.Windows.Forms)** – GUI checkbox selector
- **PS2EXE** – Converts PowerShell script into executable
- **JSON** – Configuration for apps and removals
- **Windows AppX / DISM APIs** – App removal (AppxPackage & ProvisionedPackage)

---

## Project Structure
win11-setup-tool/
│
├── config/
│ ├── apps.json # Apps to install
│ └── removals.json # Apps to remove
│
├── scripts/
│ ├── install-apps.ps1 # Handles app installs
│ └── remove-apps.ps1 # Handles app removal
│
├── ui/
│ └── menu.ps1 # Main menu system
│
├── logs/ # Runtime logs (auto-created)
├── run.ps1 # Entry point script
├── Win11SetupTool.exe # Compiled executable
└── README.md

## Usage
1. make sure winget is installed
2. Simply run the tool in the exe 
