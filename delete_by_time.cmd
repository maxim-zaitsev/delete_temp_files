@Echo Off
SetLocal EnableDelayedExpansion

:: ���� � ���������� c �������
Set WorkDir="%Temp%"
:: ����� ����������
Set DirMask=tmp*

:: ��������� ������� �� �������, � ��������
Set TimeDiff=30


:: ������ VBS, ����� ������ ���������� ������, ��������� � ���, ���
:: ~tX ������ ����� ��������� �����������, � �� ��������, � �����
:: ���������������� ��������� ����� �� �������� ����������.
>"%Temp%\GetCreationDate.vbs" (
	Echo Set objFS=CreateObject^("Scripting.FileSystemObject"^)
	Echo Set objArgs = WScript.Arguments
	Echo strFile= objArgs^(0^)
	Echo WScript.Echo objFS.GetFolder^(strFile^).DateCreated
)

:: �������� ������� ����� � ���� ��� ���������
Call :ParseTimestamp %time:~-0,8%
Call :SerializeTime
Set TimeNow=%STime%
Set DateNow=%Date%

:: �������� ��� ����� �� ���������� � ��������� �������������, �������� ��
:: � �������� ��������� ����� ���������� �������.
For /D %%A In ("%WorkDir%\%DirMask%") Do (
	For /F "tokens=1,2" %%B In ('CScript //nologo "%Temp%\GetCreationDate.vbs" "%%A"') Do (
rem ��������� �� ���� � ����� ��������, �� ���������� �� ������� �������� - �������
		If "%DateNow%"=="%%B" (
rem ����������� ���������� �� VBS ��������� ����� ��� ����������� ���������
			Call :ParseTimestamp %%~C
			Call :SerializeTime
rem �������� �������
			Call :TMinus %TimeNow% !STime!
rem ���� ������� ������ ���������� ������� - �������
			If !Result! GTR !TimeDiff! (
                rmdir /s /q "%%~A"
                Echo DELETED: "%%~nxA" ^=^> !Result!s after creation date
            ) Else echo IGNORED "%%~nxA" ^=^> !Result!s after creation date
		) Else (
rem ���� �� �������, ����� ��������� ���� ������, �������.
			rmdir /s /q "%%~A"
			Echo   %%~nxA too old - created %%B
		)
	)
)

:: ��������� �� �����
Del "%Temp%\GetCreationDate.vbs"
:: Pause&Exit


::===������� ������ �� �������� � .bat====================================
:: Anonymous, 2010
:: v 1.3
:ParseTimestamp
:: ��������� �� ������������ ��������� ����� ������� ��:��:��
:: ������:   Call :ParseTimestamp (�����)
:: � ������� - Call :ParseTimestamp %time:~-0,8%
:: ����� - � ���������� HH MM � SS
For /F "tokens=1,2,3 delims=:" %%A In ("%1") Do (
    Set HH=%%A
    Set MM=%%B
    Set SS=%%C
)

:SerializeTime
:: ����������� ����� �� ���������� HH MM � SS
:: ����� - � ErrorLevel
Call :Cut %HH% HH&Call :Cut %MM% MM&Call :Cut %SS% SS
Set /A STime=(HH*60*60)+(MM*60)+SS
Exit /B %STime%

:DeserializeTime
:: ������������� �����, �������� ��� � ������������ �������
:: ������:   Call :DeserializeTime (��������������� �����)
:: ����� - � ���������� DHH DMM � DSS
Set DHH=00&Set DMM=00&Set DSS=00
Set /A DHH=%1/60/60
Set /A DMM=(%1/60)-(DHH*60)
Set /A DSS=%1-(DHH*60*60)-(DMM*60)
If %DHH%==24 Set DHH=00
If %DHH% LSS 10 Set DHH=0%DHH%
If %DMM% LSS 10 Set DMM=0%DMM%
If %DSS% LSS 10 Set DSS=0%DSS%
Exit /B

:TMinus
:: ������� ��������� ��� ���������������� �������
:: ������:   Call :TMinus (��������������� �����) (������� ������ ������)
:: ����� - � ErrorLevel
Set Result=
Set /A Result=%1-%2
If %2 GTR %1 (
    Set /A Result=86400+%1-%2
)
Exit /B %Result%

:TPlus
:: ������� ����������� ��� ���������������� �������
:: ������:   Call :TPlus (��������������� �����) (������� ������ ���������)
:: ����� - � ErrorLevel
Set Result=
Set /A Result=%1+%2
If %Result% GTR 86400 (
    Set /A Result=%1+%2-86400
)
Exit /B %Result%

:Timer
:: ����������� ��������� � ��������� ������� �����
:: ������:   Call :Timer (����������� ��������������� �����)
:: ����� - � ErrorLevel
:: ���� ������� ��������� ������� �����, ����� ���� ���������� �� 1
:: ��� ��������� � ���������� ED (� �������������) // ��, ����, ��� ������� � ��������
Set OTime=%1
If "%ED%"=="" Set ED=0
Call :ParseTimestamp %time:~-0,8%
Call :SerializeTime
Set CTime=%STime%
If %OTime% GTR %CTime% (
    Set /A Timer=86400-%OTime%+%CTime%
    Set /A ED+=1
) Else (
    Set /A Timer=CTime-OTime
)
Exit /B %Timer%

:Timer2
:: ���������, ������ �� �������� ���������� �������
:: ������:   Call :Timer2 (����������� ��������������� �����) (���������� � ��������)
:: ����� - � ErrorLevel (������ 0=���������� ���� ��� 1=���������� ��� �� ����)
Call :ParseTimestamp %time:~-0,8%
Call :SerializeTime
Call :TMinus %STime% %1
If %2 GTR %Result% Set Timer2=1&Exit /B 1
Set Timer2=0&Exit /B 0

:Cut
:: �������� ������� ����� � ��������
:: ������:   Call :Cut (����������� �����) (����������, ���� ������� ��������)
Set d=%1
If "%d:~,1%"=="0" Set %2=%d:~1%
If "%d:~,1%"==" " Set %2=%d:~1%
Exit /B
::========================================================================