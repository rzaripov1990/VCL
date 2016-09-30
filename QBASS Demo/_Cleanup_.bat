@echo off
title Delete temp files (Delphi) - ZuBy
color 02
cls
echo Deleting....
del *.dcu /s
del *.ppu /s
del *.o /s
del *.~* /s
del *.dsk /s
del *.cfg /s
del *.dof /s
del *.bk? /s
del *.mps /s
del *.rst /s
del *.s /s
del *.a /s
del *.local /s
del *.identcache /s
del *.tvsconfig /s
pause
echo Clear...
exit