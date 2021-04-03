REM Copy the files to the Windows target dirs
if exist ..\Win32\Debug\ (
  copy Lang.de.ini ..\Win32\Debug\
  copy Lang.en.ini ..\Win32\Debug\
  copy Lang.ru.ini ..\Win32\Debug\
)