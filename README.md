# python-dev-setup
A Chocolatey Python Dev Environment Setup. Installs Python, VSCode, Git and necessary extensions

## Steps
1. Open Powershell with Administrator Rights
2. Enable Script execution using following commands
```
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```
4. run setup.ps1

## Make EXE Commands
1. Open powershell as administrator
2. Install the module from the PowerShell Gallery:
```
Install-Module -Name PS2EXE -Scope CurrentUser
```
3. Convert your script using the Invoke-PS2EXE command, providing the path to your source .ps1 file and the desired output .exe file:
```
Invoke-PS2EXE -InputFile "C:\Scripts\MyScript.ps1" -OutputFile "C:\Scripts\MyExecutable.exe"
```
You can add optional parameters, such as -noConsole to prevent a console window from appearing or -icon to specify a custom icon. 
