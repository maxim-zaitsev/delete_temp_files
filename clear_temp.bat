@echo off
SET start_time=%TIME%
SET start_time=%start_time:~0,8%
for /F %%x in ('wmic logicaldisk where name^='c:' get freespace /format:value') do set %%~x>nul
for /F %%A in ('powershell %freespace% / 1073741824') do set freespace=%%A
for /f "tokens=1 delims=," %%a in ( "%freespace%" ) do set freediskspace_gb=%%a
for /F "tokens=2 delims== skip=2" %%a in ('WMIC LogicalDisk WHERE Caption^="C:" GET Size /VALUE') do set diskspace=%%a
for /F %%A in ('powershell %diskspace% / 1073741824') do set diskspace=%%A
for /F "tokens=1 delims=," %%a in ( "%diskspace%" ) do set diskspace_gb=%%a
echo %DATE% %start_time% START Free Space: %freediskspace_gb% GB of %diskspace_gb% GB>>logs.txt
@echo on

for /D %%f in (%WINDIR%\Temp\tmp*) do DEL /f /s /q %%f
rem for /D %f in (%WINDIR%\Temp\tmp*) do DEL /f /s /q %f
rem for /d %a in ("%WINDIR%\Temp\tmp*") do RMDIR /s /q "%a"
for /d %%a in ("%WINDIR%\Temp\tmp*") do RMDIR /s /q "%%a"
rem DEL /F /S /Q %SYSTEMDRIVE%\Temp\.
if %Temp%==%Tmp% (
	rem DEL /f /s /q %Temp%\tmp*
    for /D %%f in (%Temp%\tmp*) do DEL /f /s /q %%f    
	for /d %%a in ("%Temp%\tmp*") do RMDIR /s /q "%%a"
) else (
	DEL /f /s /q %Temp%\tmp*
	RMDIR /s /q %Temp%\
	DEL /f /s /q %Tmp%\tmp*
	RMDIR /s /q %Tmp%\
)

@echo off
SET end_time=%TIME%
SET end_time=%end_time:~0,8%
for /F %%x in ('wmic logicaldisk where name^='c:' get freespace /format:value') do set %%~x>nul
for /F %%A in ('powershell %freespace% / 1073741824') do set freespace=%%A
for /f "tokens=1 delims=," %%a in ( "%freespace%" ) do set freediskspace_gb=%%a
for /F "tokens=2 delims== skip=2" %%a in ('WMIC LogicalDisk WHERE Caption^="C:" GET Size /VALUE') do set diskspace=%%a
for /F %%A in ('powershell %diskspace% / 1073741824') do set diskspace=%%A
for /F "tokens=1 delims=," %%a in ( "%diskspace%" ) do set diskspace_gb=%%a
echo %DATE% %end_time% END   Free Space: %freediskspace_gb% GB of %diskspace_gb% GB>>logs.txt

echo on
