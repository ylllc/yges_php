cd /d %~dp0
if exist _setpath.bat call _setpath.bat
doxygen Doxyfile
pause
