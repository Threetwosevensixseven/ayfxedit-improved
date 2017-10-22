@echo off
C:
CD %~dp0

pasmo --tapbas playtest.asm ayfxtest.tap playtest.txt
REM start "%PROGRAMFILES(X86)%\Spectaculator\Spectaculator.exe" ayfxtest.tap

REM pause
