
🔐 WoW Credential Filler

A Windows-based script combo to securely store and automatically input your World of Warcraft credentials upon game launch. Useful for Classic, Retail, or Hardcore/Fresh realms.
✨ Features

    🔒 Secure, encrypted storage of your WoW credentials

    🚀 Auto-launches the correct WoW version

    🕵️‍♂️ Waits for the game process before sending input

    🎯 Focuses WoW window and types in credentials (username → Tab → password → Enter)

    🛠 Optional debug/echo mode for troubleshooting

📁 File Overview
File	Description
StoreWowCredentials.ps1	Prompts for and securely stores your username/password
OpenWow.bat	Launches WoW and uses stored credentials
sendkeys.js	Simulates keyboard input into the WoW window
⚙ Setup Instructions
1. 🔐 Store Your Credentials

Run the PowerShell script to securely store your WoW username and password (encrypted and user-bound):

.\StoreWowCredentials.ps1

This creates the following files in your WoW directory:

    encrypted_username.txt

    encrypted_password.txt

2. 🧭 Configure WoW Path (Optional)

If your WoW install is not at the default path, open OpenWow.bat and update the following lines:

set WOW_PATH="D:\Games\Blizzard\World of Warcraft\_classic_\WowClassic.exe"

Also update the corresponding paths to encrypted_username.txt and encrypted_password.txt if needed.
3. 🚀 Launch and Auto-Login

Run the batch file to:

    Decrypt credentials

    Launch WoW

    Wait for the game to start

    Send login credentials

OpenWow.bat

🛡 Security

Credentials are encrypted using PowerShell's ConvertFrom-SecureString, tied to your current Windows user profile. Only your account can decrypt them. They are never stored in plaintext.
🧠 Notes

    Make sure WoW's login window title is still "World of Warcraft" (used for focusing).

    Adjust delays in sendkeys.js if your system is slower and login fails.

    Tested on Windows 10+.

📝 License

This project is intended for personal use only. Provided as-is, without warranty. Use responsibly.

Would you like this saved as a file (README.md) or added with commit instructions?