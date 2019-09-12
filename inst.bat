@echo off
set CURRENT_PATH=%~dp0
rem for /d %%i in ("%CURRENT_PATH%") do set CURR_PATH=%%~fi
for /d %%i in ("%~d0%~p0..\") do set CURR_PATH=%%~fi
set TARGETDIR=%cd%
set MSI_FILE_NAME=Unified_Functional_Testing.msi
set MSI_LOG_FILE_NAME=UFTSetup.log
set MSI_FILE_NAME_32=Unified_Functional_Testing_x86.msi
set MSI_FILE_NAME_64=Unified_Functional_Testing_x64.msi

set FULL_PATH=%CURR_PATH%MSI\

rem The %PWRAPPER_TIMESTAMP% will be passed to this .bat file when iHP Prerequisite Wrapper (setup.exe) calling it.
rem This variable does not exist if running .bat file directly.
if not "%PWRAPPER_TIMESTAMP%"=="" ( set MSI_LOG_FILE_NAME=UFTSetup_%PWRAPPER_TIMESTAMP%.log )

rem un install QTP dummy msi (which was added to UFT 11.50 to support QC10 integration)
rem run the un install comamnd only if QTP dummy msi detected on the machine
Set Reg.Key=HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{EB221B44-30B0-424D-88A6-E7C42DFCC72C}
Set Reg.Val=InstallLocation
For /F "Tokens=2*" %%A In ('Reg Query "%Reg.Key%" /v "%Reg.Val%" 2^>NUL ^| Find /I "%Reg.Val%"' ) Do Call Set simsdir=%%B
if not "%simsdir%"=="" start /WAIT msiexec /x {EB221B44-30B0-424D-88A6-E7C42DFCC72C} /q

IF EXIST "%FULL_PATH%%MSI_FILE_NAME%" ( @start msiexec /i "%FULL_PATH%%MSI_FILE_NAME%" /l*v %temp%\%MSI_LOG_FILE_NAME% %* )

IF EXIST "%FULL_PATH%%MSI_FILE_NAME%" ( goto END )

IF "%ProgramFiles(x86)%"=="" ( IF EXIST "%FULL_PATH%%MSI_FILE_NAME_32%" ( @start msiexec /i "%FULL_PATH%%MSI_FILE_NAME_32%" /l*xv %temp%\%MSI_LOG_FILE_NAME% %*) )

IF "%ProgramFiles(x86)%"==""( goto END )


IF NOT "%ProgramFiles(x86)%"=="" ( IF EXIST "%FULL_PATH%%MSI_FILE_NAME_64%" ( @start msiexec /i "%FULL_PATH%%MSI_FILE_NAME_64%" /l*xv %temp%\%MSI_LOG_FILE_NAME% %* ) )

goto END

:END