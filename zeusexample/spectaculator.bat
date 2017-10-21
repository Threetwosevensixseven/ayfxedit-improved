@echo off
C:
CD %~dp0
cd..\bin

start "%PROGRAMFILES(X86)%\Spectaculator\Spectaculator.exe" playtest.z80

REM pause
