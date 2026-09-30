@echo off
setlocal
rem  Local run of SpotBugs on Windows (for screenshots). CI uses run_spotbugs.sh instead.
rem  %1 = result name, %2 = source folder (relative to repo root),
rem  %3 = source encoding, %4 = library jar (relative to repo root, optional)
set "HERE=%~dp0"
set "ROOT=%HERE%.."
set "NAME=%~1"
set "SRC=%ROOT%\%~2"
set "ENC=%~3"
set "LIBJAR="
if not "%~4"=="" set "LIBJAR=%ROOT%\%~4"

if not exist "%SRC%" (
  echo [ERROR] Source folder not found: %SRC%
  pause
  exit /b 1
)

rem ---- find JDK 21 or 17 downloaded by IntelliJ IDEA ----
set "J="
for /d %%d in ("%USERPROFILE%\.jdks\*17*") do if exist "%%d\bin\javac.exe" if exist "%%d\lib\modules" set "J=%%d"
for /d %%d in ("%USERPROFILE%\.jdks\*21*") do if exist "%%d\bin\javac.exe" if exist "%%d\lib\modules" set "J=%%d"
if not defined J (
  echo [ERROR] JDK 21 or 17 not found in %USERPROFILE%\.jdks
  echo Download it in IntelliJ IDEA: File - Project Structure - SDK - Download JDK - version 21
  pause
  exit /b 1
)
echo Using JDK: %J%

rem ---- download SpotBugs 4.8.6 if missing ----
if not exist "%HERE%spotbugs-4.8.6\lib\spotbugs.jar" (
  echo SpotBugs 4.8.6 not found, downloading...
  curl -L -o "%HERE%spotbugs-4.8.6.tgz" https://github.com/spotbugs/spotbugs/releases/download/4.8.6/spotbugs-4.8.6.tgz
  if errorlevel 1 (
    echo [ERROR] Download failed
    pause
    exit /b 1
  )
  tar -xzf "%HERE%spotbugs-4.8.6.tgz" -C "%HERE%."
  if errorlevel 1 (
    echo [ERROR] Unpack failed
    pause
    exit /b 1
  )
  del "%HERE%spotbugs-4.8.6.tgz"
)

set "OUT=%ROOT%\build\%NAME%"
if exist "%OUT%" rmdir /s /q "%OUT%"
mkdir "%OUT%"
if not exist "%ROOT%\results" mkdir "%ROOT%\results"
dir /s /b "%SRC%\*.java" > "%ROOT%\build\%NAME%_sources.txt"

set "CPARG="
set "AUXARG="
if defined LIBJAR set "CPARG=-cp "%LIBJAR%""
if defined LIBJAR set "AUXARG=-auxclasspath "%LIBJAR%""

echo.
echo [1/3] Compiling %NAME% ...
"%J%\bin\javac.exe" -encoding %ENC% --release 17 -nowarn -proc:none %CPARG% -d "%OUT%" @"%ROOT%\build\%NAME%_sources.txt" 2>nul
if errorlevel 1 (
  echo [ERROR] Compilation failed. Details:
  "%J%\bin\javac.exe" -encoding %ENC% --release 17 -nowarn -proc:none %CPARG% -d "%OUT%" @"%ROOT%\build\%NAME%_sources.txt"
  pause
  exit /b 1
)

echo [2/3] Running SpotBugs 4.8.6 (effort: max, confidence: low) ...
"%J%\bin\java.exe" -jar "%HERE%spotbugs-4.8.6\lib\spotbugs.jar" -textui -effort:max -low %AUXARG% -sourcepath "%SRC%" -xml:withMessages -output "%ROOT%\results\%NAME%.xml" "%OUT%"
"%J%\bin\java.exe" -jar "%HERE%spotbugs-4.8.6\lib\spotbugs.jar" -textui -effort:max -low -sortByClass %AUXARG% "%OUT%" > "%ROOT%\results\%NAME%.txt"
for /f %%c in ('type "%ROOT%\results\%NAME%.txt" ^| find /c /v ""') do echo Warnings found: %%c

echo [3/3] Opening SpotBugs window with results ...
start "" "%J%\bin\javaw.exe" -jar "%HERE%spotbugs-4.8.6\lib\spotbugs.jar" -gui "%ROOT%\results\%NAME%.xml"
echo Done. Make a screenshot of the SpotBugs window (Win+Shift+S).
timeout /t 5 >nul
