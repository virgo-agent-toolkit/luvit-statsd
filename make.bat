@ECHO off

IF NOT "x%1" == "x" GOTO :%1

:statsd
IF NOT EXIST lit.exe CALL make.bat lit
ECHO "Building statsd"
lit.exe make
GOTO :end

:lit
ECHO "Building lit"
PowerShell -NoProfile -ExecutionPolicy unrestricted -Command "iex ((new-object net.webclient).DownloadString('https://github.com/luvit/lit/raw/0.11.0/get-lit.ps1'))"
GOTO :end

:clean
IF EXIST stasd.exe DEL /F /Q statsd.exe
IF EXIST lit.exe DEL /F /Q lit.exe

:end
