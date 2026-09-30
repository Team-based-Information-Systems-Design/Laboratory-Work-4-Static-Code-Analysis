@echo off
setlocal
rem  %1 = project folder name, %2 = source encoding, %3 = library jar in project\lib (optional)
set "HERE=%~dp0"
set "PROJ=%HERE%..\%~1"
set "ENC=%~2"
set "LIBJAR=%~3"

if not exist "%PROJ%\src" (
  echo [ERROR] Project folder not found: %PROJ%
  echo Extract lab4_projects.zip and this archive into the same folder, e.g. C:\lab4
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

set "OUT=%HERE%build\%~1"
if exist "%OUT%" rmdir /s /q "%OUT%"
mkdir "%OUT%"
if not exist "%HERE%results" mkdir "%HERE%results"
dir /s /b "%PROJ%\src\*.java" > "%HERE%build\%~1_sources.txt"

set "CPARG="
set "AUXARG="
if not "%LIBJAR%"=="" set "CPARG=-cp %PROJ%\lib\%LIBJAR%"
if not "%LIBJAR%"=="" set "AUXARG=-auxclasspath %PROJ%\lib\%LIBJAR%"

echo.
echo [1/3] Compiling %~1 ...
"%J%\bin\javac.exe" -encoding %ENC% --release 17 -nowarn -proc:none %CPARG% -d "%OUT%" @"%HERE%build\%~1_sources.txt" 2>nul
if errorlevel 1 (
  echo [ERROR] Compilation failed. Details:
  "%J%\bin\javac.exe" -encoding %ENC% --release 17 -nowarn -proc:none %CPARG% -d "%OUT%" @"%HERE%build\%~1_sources.txt"
  pause
  exit /b 1
)

echo [2/3] Running SpotBugs 4.8.6 (effort: max, confidence: low) ...
"%J%\bin\java.exe" -jar "%HERE%spotbugs-4.8.6\lib\spotbugs.jar" -textui -effort:max -low %AUXARG% -sourcepath "%PROJ%\src" -xml:withMessages -output "%HERE%results\%~1.xml" "%OUT%"
"%J%\bin\java.exe" -jar "%HERE%spotbugs-4.8.6\lib\spotbugs.jar" -textui -effort:max -low -sortByClass %AUXARG% "%OUT%" > "%HERE%results\%~1.txt"
for /f %%c in ('type "%HERE%results\%~1.txt" ^| find /c /v ""') do echo Warnings found: %%c

echo [3/3] Opening SpotBugs window with results ...
start "" "%J%\bin\javaw.exe" -jar "%HERE%spotbugs-4.8.6\lib\spotbugs.jar" -gui "%HERE%results\%~1.xml"
echo Done. Make a screenshot of the SpotBugs window (Win+Shift+S).
timeout /t 5 >nul
