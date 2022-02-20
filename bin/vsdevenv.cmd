@echo off
@setlocal
@FOR /F "tokens=*" %%g IN ('"bash %~dp0\..\utils\findvsdevcmd.sh"') do (SET vsdevcmd=%%g)
echo [vsdevcmd] arch=%1 shell=%2 script=%3 vsdevcmd=%vsdevcmd% 
@call %vsdevcmd% -no_logo -arch=%1 -host_arch=amd64
@FOR /F "tokens=*" %%g IN ('"bash %~dp0\..\utils\findmlexepath.sh"') do (SET msvc_mlpath=%%g)
@REM echo [vsdevcmd] arch=%1 shell=%2 script=%3 msvc_mlpath=%msvc_mlpath% 

if "%1" == "amd64" set PreferredToolArchitecture=x64
if "%1" == "x64" set PreferredToolArchitecture=x64

set _err=128

REM support snippet execution eg: as "vsdevenv x64 bash -- [bash commands]"
if "%3" == "--" FOR /F "tokens=*" %%g IN ('"openssl rand -hex 12"') do (
    set msvc_shell=%2
    set tmpfile=%%g.tmp
    goto expanded
    :expanded
    echo %* | sed -e 's/^%1 %2 -- //' >> msvc_%tmpfile%
    REM echo | tail --verbose msvc_%tmpfile%
    REM echo msvc_mlpath=%msvc_mlpath%
    set "PATH=%PATH%;%msvc_mlpath%"
    call :%msvc_shell% msvc_%tmpfile%
    del /q msvc_%tmpfile%
    exit /b %_err%
)

@echo on
@REM echo msvc_mlpath=%msvc_mlpath%
@set "PATH=%PATH%;%msvc_mlpath%"
@call :%2 %3
@exit /b %_err%

:powershell
powershell -command "$ErrorActionPreference = 'stop' ; get-content '%1' | Invoke-Expression ; if ((Test-Path -LiteralPath variable:\LASTEXITCODE)) { exit $LASTEXITCODE }"
@goto _exit

:pwsh
pwsh -command "$ErrorActionPreference = 'stop' ; get-content '%1' | Invoke-Expression ; if ((Test-Path -LiteralPath variable:\LASTEXITCODE)) { exit $LASTEXITCODE }"
@goto _exit

:cmd
%ComSpec% /Q /D /E:ON /V:OFF /S /C "( type %1 & echo. ) | cmd"
@goto _exit

:bash
bash --noprofile --norc -eo pipefail %1
@goto _exit

:_exit
@set _err=%errorlevel%
@if "%errorlevel%" == "0" ( goto _bye)
echo errorlevel=%_err%
exit /b %_err%
:_bye
endlocal
