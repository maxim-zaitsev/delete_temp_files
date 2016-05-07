@echo off

:: Маска директорий для удаления
SET DirMask=tmp*
:: Указываем разницу во времени, в секундах
Set TimeDiff=1800

SET start_time=%TIME%
SET start_time=%start_time:~0,8%
for /F %%x in ('wmic logicaldisk where name^='c:' get freespace /format:value') do set %%~x>nul
for /F %%A in ('powershell %freespace% / 1073741824') do set freespace=%%A
for /f "tokens=1 delims=," %%a in ( "%freespace%" ) do set freediskspace_gb=%%a
for /F "tokens=2 delims== skip=2" %%a in ('WMIC LogicalDisk WHERE Caption^="C:" GET Size /VALUE') do set diskspace=%%a
for /F %%A in ('powershell %diskspace% / 1073741824') do set diskspace=%%A
for /F "tokens=1 delims=," %%a in ( "%diskspace%" ) do set diskspace_gb=%%a
echo %DATE% %start_time% START Free Space: %freediskspace_gb% GB of %diskspace_gb% GB>>logs.txt


echo step1: delete files from "%SYSTEMDRIVE%\Temp"
if not exist "%SYSTEMDRIVE%\Temp" (
    echo "%SYSTEMDRIVE%\Temp" is not exist. Go next step.
) else (
    echo "%SYSTEMDRIVE%\Temp" is exist. Let's delete all folders and files here!
    call :DELETE_FUNC "%SYSTEMDRIVE%\Temp" %TimeDiff%
)
echo step2: delete files from "%WINDIR%\Temp"
call :DELETE_FUNC "%WINDIR%\Temp\%DirMask%" %TimeDiff%
if %Temp%==%Tmp% (
    echo step3: delete files from "%Temp%"
    call :DELETE_FUNC "%Temp%\%DirMask%" %TimeDiff%
) else (
    echo step3: delete files from "%Temp%" and from "%Tmp%"
	call :DELETE_FUNC "%Temp%\%DirMask%"
    call :DELETE_FUNC "%Tmp%\%DirMask%"
)
SET end_time=%TIME%
SET end_time=%end_time:~0,8%
for /F %%x in ('wmic logicaldisk where name^='c:' get freespace /format:value') do set %%~x>nul
for /F %%A in ('powershell %freespace% / 1073741824') do set freespace=%%A
for /f "tokens=1 delims=," %%a in ( "%freespace%" ) do set freediskspace_gb=%%a
for /F "tokens=2 delims== skip=2" %%a in ('WMIC LogicalDisk WHERE Caption^="C:" GET Size /VALUE') do set diskspace=%%a
for /F %%A in ('powershell %diskspace% / 1073741824') do set diskspace=%%A
for /F "tokens=1 delims=," %%a in ( "%diskspace%" ) do set diskspace_gb=%%a
echo %DATE% %end_time% END   Free Space: %freediskspace_gb% GB of %diskspace_gb% GB>>logs.txt

::exit

:: deleting all files from folder then removing empty folders
:DELETE_FUNC
CALL delete_by_time.bat %1 %2
exit /b

