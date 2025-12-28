@echo off
setlocal
set "script_dir=%~dp0"

python "%script_dir%1Luobo-StartHelper.py" %*
if %errorlevel% neq 0 (
    pause
)

endlocal
