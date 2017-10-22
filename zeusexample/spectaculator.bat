@echo off
C:
CD %~dp0
cd..\bin

start "%PROGRAMFILES(X86)%\Spectaculator\Spectaculator.exe" ayfxtest.z80

REM pause
