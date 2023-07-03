@echo off

:: Check if the script is running as administrator
NET SESSION >NUL 2>&1
IF %ERRORLEVEL% EQU 0 (
    goto :check_torrc
) else (
    echo Requesting administrator privileges...
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"
    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /B
)

:check_torrc
:: Check if torrc file exists, create it if not
set torrcDir=C:\Users\%USERNAME%\AppData\Roaming\tor
set torrcPath=%torrcDir%\torrc

if not exist "%torrcPath%" (
    echo Creating torrc file...
    echo SocksPort 9050 > "%torrcPath%"
    echo torrc file created at "%torrcPath%"
)

:start
set proxyAddress=127.0.0.1
set proxyPort=8118

echo Enabling manual proxy settings...
:: Enabling manual proxy settings using windows registry.
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyEnable /t REG_DWORD /d 1 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyServer /d "%proxyAddress%:%proxyPort%" /f

echo Starting Tor and Privoxy...
REM I used here `privoxy.exe.lnk` (shortcut a shortcut of privoxy.exe) because when i tried to run `privoxy.exe` it didn't work.
start "" "%~dp0privoxy\privoxy.exe.lnk"
start /B "" "%~dp0tor\tor.exe"

timeout /t 5

CLS

echo Tor and Privoxy are running. Press any key to close them and disable the manual proxy settings.
echo.  
pause >nul
echo.  

taskkill /IM tor.exe /F
taskkill /IM privoxy.exe /F

echo Disabling manual proxy settings...
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyEnable /t REG_DWORD /d 0 /f

echo Tor and Privoxy have been closed, and manual proxy settings have been disabled.
pause