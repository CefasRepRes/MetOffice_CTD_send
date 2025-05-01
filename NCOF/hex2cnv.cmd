@echo off
:: hex2cnv.cmd  — convert fresh *.hex ➜ *.cnv  (Sea-Bird datcnv.exe)

:: ---------- EDIT THESE VARIABLES -----------------
:: Tested on Windows 10 (should also work on 11/Server 2019+)
set "RAW_DIR=C:\seabird\ctd_data\raw"        :: folder for incoming .hex files (e.g. from SeaSave)
set "NRT_DIR=C:\NRT_data"                    :: where new .cnv files should go
set "ARCHIVE_DIR=%RAW_DIR%\processed"        :: (optional archive) move processed *.hex here (or comment to keep in place)
set "SBE_BIN=C:\Program Files (x86)\Sea-Bird\DataProcessing"    :: Sea‑Bird Data Processing binaries directory (contains datcnv.exe, alignctd.exe, filter.exe …)
set "PROCESSING_DEF=C:\seabird\configs\my_cast_processing.psa"  :: XMLCON or .psa processing file for datcnv
:: --------------------------------------------------

:: create output / archive on first run
if not exist "%NRT_DIR%" mkdir "%NRT_DIR%"
if defined ARCHIVE_DIR if not exist "%ARCHIVE_DIR%" mkdir "%ARCHIVE_DIR%"

echo [%date% %time%] === hex2cnv pass started ===

:: convert any HEX younger than 2 min (safety net against re-processing old files)
for %%F in ("%RAW_DIR%\*.hex") do (
    for /f %%A in ('powershell -NoProfile -Command ^
        "(New-TimeSpan (Get-Date '%%~tF') (Get-Date)).TotalMinutes"') do set /a "AGE=%%A * -1"
    if %AGE% lss 2 (
        "%SBE_BIN%\datcnv.exe" /i"%%F" /o"%NRT_DIR%" /p"%PROCESSING_DEF%" /overwrite >nul
        if exist "%NRT_DIR%\%%~nF.cnv" (
            if defined ARCHIVE_DIR move /Y "%%F" "%ARCHIVE_DIR%\"
            echo   ▶  wrote %NRT_DIR%\%%~nF.cnv
        ) else (
            echo   !! conversion failed for %%~nxF
        )
    )
)

echo [%date% %time%] === hex2cnv pass finished ===
