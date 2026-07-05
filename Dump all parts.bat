@echo off
setlocal enabledelayedexpansion

REM ============================================================
REM  dump_partitions.bat
REM  Dumps every partition listed under /dev/block/by-name
REM  on a device connected via hdc, using dd on-device and
REM  hdc file recv to pull the image back to the current folder.
REM
REM  NOTE: "ls /dev/block/by-name" prints a multi-column table
REM  (several partition names per line), so each line is
REM  tokenized on whitespace rather than treated as one name.
REM ============================================================

set OUTDIR=%~dp0dumps
if not exist "%OUTDIR%" mkdir "%OUTDIR%"

echo [*] Querying partition list from /dev/block/by-name ...
set LISTFILE=%TEMP%\hdc_partlist.txt
hdc root
hdc shell ls /dev/block/by-name > "%LISTFILE%" 2>nul

if not exist "%LISTFILE%" (
    echo [!] Failed to get partition list. Is the device connected?
    goto :end
)

echo [*] Raw listing:
type "%LISTFILE%"
echo.

REM Build a single space-separated list of every partition name
REM by tokenizing each line (handles the multi-column ls output).
set "ALLPARTS="
for /f "usebackq delims=" %%L in ("%LISTFILE%") do (
    set "LINE=%%L"
    for %%W in (!LINE!) do (
        set "TOK=%%W"
        REM skip empty tokens and anything that isn't a plausible
        REM partition name (defensive: skip tokens with slashes)
        if not "!TOK!"=="" (
            set "ALLPARTS=!ALLPARTS! !TOK!"
        )
    )
)

if "%ALLPARTS%"=="" (
    echo [!] No partition names parsed from output.
    goto :end
)

echo [*] Parsed partitions:
echo %ALLPARTS%
echo.

for %%P in (%ALLPARTS%) do (
    call :dump_one "%%P"
)

echo.
echo [*] Done. Images are in: %OUTDIR%
goto :end


:dump_one
set "PART=%~1"
if "%PART%"=="" goto :eof

echo ============================================================
echo [*] Dumping partition: %PART%
echo ============================================================

echo   [1/3] dd on device: /dev/block/by-name/%PART% -^> /data/%PART%.img
hdc shell dd if=/dev/block/by-name/%PART% of=/data/%PART%.img
if errorlevel 1 (
    echo   [!] dd failed for %PART%, skipping.
    goto :eof
)

echo   [2/3] Pulling /data/%PART%.img to "%OUTDIR%\%PART%.img"
hdc file recv /data/%PART%.img "%OUTDIR%\%PART%.img"
if errorlevel 1 (
    echo   [!] file recv failed for %PART%.
    goto :eof
)

echo   [3/3] Cleaning up on-device copy
hdc shell rm -f /data/%PART%.img

echo   [OK] %PART%.img saved to %OUTDIR%
echo.
goto :eof


:end
endlocal
echo.
echo Press any key to close this window...
pause >nul