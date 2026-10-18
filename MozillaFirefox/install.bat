@echo off
setlocal enabledelayedexpansion

set "USER_PROFILES=profiles.ini"
set "USER_PROFILER=user.js"


:: Check if a file was dragged and dropped onto the script
if "%~1"=="" (
    echo [Error] No settings file provided.
    echo Please drag and drop your settings file onto this batch script.
    echo.
    pause
    exit /b 1
)

set "CONFIG_FILE=%~1"
if not exist "%CONFIG_FILE%" (
    echo [Error] Settings file not found: %CONFIG_FILE%
    pause
    exit /b 1
)

set "FIREFOX_ROOT=%APPDATA%\Mozilla\Firefox"
set "PROFILES_INI=%FIREFOX_ROOT%\%USER_PROFILES%"

if not exist "%PROFILES_INI%" (
    echo [Error] Firefox %USER_PROFILES% not found at: %PROFILES_INI%
    pause
    exit /b 1
)

:: Parse profiles to find the profile path, prioritizing default-release
set "PROFILE_PATH="
set "IS_RELATIVE=1"
set "FALLBACK_PATH="
set "FALLBACK_REL=1"

for /f "usebackq tokens=*" %%A in ("%PROFILES_INI%") do (
    set "LINE=%%A"
    if not "!LINE!"=="" (
        for /f "tokens=1* delims==" %%i in ("!LINE!") do (
            set "PROP_KEY=%%i"
            set "PROP_VAL=%%j"
            call :Trim PROP_KEY
            call :Trim PROP_VAL
            
            if /i "!PROP_KEY!"=="Path" (
                set "CURRENT_PATH=!PROP_VAL!"
                echo !CURRENT_PATH! | findstr /i "default-release" >nul
                if not errorlevel 1 (
                    set "PROFILE_PATH=!CURRENT_PATH!"
                ) else if not defined FALLBACK_PATH (
                    set "FALLBACK_PATH=!CURRENT_PATH!"
                )
            )
            if /i "!PROP_KEY!"=="IsRelative" (
                if defined CURRENT_PATH if "!CURRENT_PATH!"=="!PROFILE_PATH!" (
                    set "IS_RELATIVE=!PROP_VAL!"
                ) else if not defined IS_RELATIVE (
                    set "FALLBACK_REL=!PROP_VAL!"
                )
            )
        )
    )
)

if not defined PROFILE_PATH (
    set "PROFILE_PATH=!FALLBACK_PATH!"
    set "IS_RELATIVE=!FALLBACK_REL!"
    echo [Info] Fallback: !FALLBACK_PATH!
)

if not defined PROFILE_PATH (
    echo [Error] Could not resolve a profile path from !USER_PROFILES!.
    pause
    exit /b 1
)

:: Resolve relative vs absolute path
if "%IS_RELATIVE%"=="1" (
    set "TARGET_DIR=%FIREFOX_ROOT%\%PROFILE_PATH%"
) else (
    set "TARGET_DIR=%PROFILE_PATH%"
)

:: Normalize path slashes
set "TARGET_DIR=%TARGET_DIR:/=\%"
set "USER_JS=%TARGET_DIR%\%USER_PROFILER%"

if not exist "%TARGET_DIR%" (
    echo [Error] Profile directory does not exist: %TARGET_DIR%
    pause
    exit /b 1
) else (
    echo [Info] Target: %TARGET_DIR%
)

:: Backup existing profiler if it exists
if exist "%USER_JS%" (
    copy /y "%USER_JS%" "%USER_JS%.bak" >nul
    echo [Info] Backup profile target: %USER_PROFILER%
)

echo // Managed from local file: %CONFIG_FILE% >> "%USER_JS%"

:: Read config file, skip comments, split key/value and append
for /f "usebackq tokens=1* delims==" %%i in ("%CONFIG_FILE%") do (
    set "KEY=%%i"
    set "VAL=%%j"
    
    if defined KEY if defined VAL (
        :: Thoroughly strip all leading and trailing spaces/tabs from both ends
        call :Trim KEY
        call :Trim VAL
        
        :: Skip comment lines
        set "FIRST_CHAR=!KEY:~0,1!"
        set "FIRST_TWO=!KEY:~0,2!"
        if not "!FIRST_CHAR!"=="#" if not "!FIRST_TWO!"=="//" (
            set "OUT_LINE=user_pref("!KEY!", !VAL!);"
            echo !OUT_LINE! >> "%USER_JS%"
        )
    )
)
echo.
echo Success! Restart Firefox to apply the preferences.
timeout 500
goto :eof

:: Helper routine to trim leading and trailing spaces
:Trim
setlocal enabledelayedexpansion
set "str=!%~1!"
:trim_loop
if "!str:~0,1!"==" " set "str=%str:~1%" & goto trim_loop
:trim_loop2
if "!str:~-1!"==" " set "str=%str:~0,-1%" & goto trim_loop2
endlocal & set "%~1=%str%"
goto :eof