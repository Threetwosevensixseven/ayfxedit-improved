@echo off
C:
CD %~dp0

zcl.exe playtest.asm
REM start "%PROGRAMFILES(X86)%\Spectaculator\Spectaculator.exe" ayfxtest.tap

REM pause
