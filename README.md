<h1 align="center">Claude Science for Windows </h1>

<p align="center">
  <b>The unofficial 1-click Windows installer for Claude Science.</b><br>
  Run Anthropic's AI Workbench natively via WSL 2 with zero configuration.
</p>

---

##  Quick Start

Anthropic currently only ships a native Claude Science app for macOS and Linux. This tool gives you a seamless, 1-click way to install and run the official Linux version directly on your Windows machine using Windows Subsystem for Linux (WSL 2).

It handles everything automatically: downloading Ubuntu (if needed), configuring Linux dependencies (as root), and downloading Claude Science from Anthropic.

### 1️⃣ Download this tool

**Option A (Easiest): Download the ZIP**
1. Click the **[Code]** button at the top right of this page and select **Download ZIP**.
2. Extract the ZIP folder anywhere on your computer (e.g., your Desktop or Downloads folder).

**Option B: Clone with Git**
If you have Git installed, simply open your terminal and run:
```powershell
git clone https://github.com/YOUR-USERNAME/claude-science-windows.git
```

### 2️⃣ Run it

1. Open the folder you just downloaded/extracted.
2. Double-click the **`ClaudeScience-Windows.cmd`** file.
3. *That's it!* 

#### What to Expect During Installation
- **First Run**: A PowerShell window will open. If you don't have WSL Ubuntu installed, Windows may prompt you for Administrator permission to install it. 
- **The Long Download**: You will see native Linux `apt-get` and `curl` progress bars in your Windows console. This step takes about **3-5 minutes** as it sets up a robust Linux environment behind the scenes. This only happens once!
- **Launch**: Once finished, it will automatically start the Claude Science daemon in the background and pop open the sign-in URL in your default Windows browser.
- **Future Runs**: After the initial setup, double-clicking the `.cmd` file will launch Claude Science almost instantly.

---

##  Prerequisites 

Before you launch the app, ensure you meet Anthropic's requirements:
- A Claude account on a plan that includes Claude Science beta access.
- (Optional but helpful) You can read Anthropic's official getting started guide here: [Claude Science Docs](https://claude.com/docs/claude-science/get-started).

*(Note: No Anthropic API key is required to sign in!)*

---

## 🛠️ Advanced Options

If you prefer to use the command line directly, or want to manage the background process manually, you can run the core PowerShell script directly:

Open PowerShell in this folder and run:
```powershell
# Install and launch
.\ClaudeScience-Windows.ps1

# Stop Claude Science cleanly
.\ClaudeScience-Windows.ps1 -Action stop

# Check your setup for errors
.\ClaudeScience-Windows.ps1 -Action doctor

# Update Claude Science to the latest version
.\ClaudeScience-Windows.ps1 -Action update
```

##  Troubleshooting

- **Admin prompt:** If this is your very first time using WSL, Windows might prompt you for Administrator approval to install the underlying Linux environment. This is normal.
- **Where is my data stored?** Claude Science stores its app data, projects, and conversation history inside your WSL home directory under `~/.claude-science`. 

---
<p align="center"><i>This repo is an unofficial helper around Anthropic's documented installation path. It does not bypass Claude account, plan, or organization access requirements.</i></p>
