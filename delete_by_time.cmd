@Echo Off
SetLocal EnableDelayedExpansion

:: Путь к директории c файлами
Set WorkDir="%Temp%"
:: Маска директории
Set DirMask=tmp*

:: Указываем разницу во времени, в секундах
Set TimeDiff=30


:: Создаём VBS, чтобы обойти неприятный момент, связанный с тем, что
:: ~tX выдает время последней модификации, а не создания, и такое
:: предопределенное поведение вроде бы поменять невозможно.
>"%Temp%\GetCreationDate.vbs" (
	Echo Set objFS=CreateObject^("Scripting.FileSystemObject"^)
	Echo Set objArgs = WScript.Arguments
	Echo strFile= objArgs^(0^)
	Echo WScript.Echo objFS.GetFolder^(strFile^).DateCreated
)

:: Получаем текущее время и дату для сравнения
Call :ParseTimestamp %time:~-0,8%
Call :SerializeTime
Set TimeNow=%STime%
Set DateNow=%Date%

:: Получаем все файлы из директории и вложенных поддиректорий, передаем их
:: в качестве аргумента ранее созданному скрипту.
For /D %%A In ("%WorkDir%\%DirMask%") Do (
	For /F "tokens=1,2" %%B In ('CScript //nologo "%Temp%\GetCreationDate.vbs" "%%A"') Do (
rem Проверяем на дату и время создания, не подходящие по времени создания - удаляем
		If "%DateNow%"=="%%B" (
rem Сериализуем полученную от VBS временную метку для дальнейшего сравнения
			Call :ParseTimestamp %%~C
			Call :SerializeTime
rem Получаем разницу
			Call :TMinus %TimeNow% !STime!
rem Если разница больше указанного времени - удаляем
			If !Result! GTR !TimeDiff! (
                rmdir /s /q "%%~A"
                Echo DELETED: "%%~nxA" ^=^> !Result!s after creation date
            ) Else echo IGNORED "%%~nxA" ^=^> !Result!s after creation date
		) Else (
rem Дата не сошлась, время проверять нету смысла, удаляем.
			rmdir /s /q "%%~A"
			Echo   %%~nxA too old - created %%B
		)
	)
)

:: Подчищаем за собой
Del "%Temp%\GetCreationDate.vbs"
:: Pause&Exit


::===Функции работы со временем в .bat====================================
:: Anonymous, 2010
:: v 1.3
:ParseTimestamp
:: Разбирает на составляющие временную метку формата ЧЧ:ММ:СС
:: Формат:   Call :ParseTimestamp (время)
:: К примеру - Call :ParseTimestamp %time:~-0,8%
:: Вывод - в переменные HH MM и SS
For /F "tokens=1,2,3 delims=:" %%A In ("%1") Do (
    Set HH=%%A
    Set MM=%%B
    Set SS=%%C
)

:SerializeTime
:: Сериализует время из переменных HH MM и SS
:: Вывод - в ErrorLevel
Call :Cut %HH% HH&Call :Cut %MM% MM&Call :Cut %SS% SS
Set /A STime=(HH*60*60)+(MM*60)+SS
Exit /B %STime%

:DeserializeTime
:: Десериализует время, приводит его к стандартному формату
:: Формат:   Call :DeserializeTime (сериализованное время)
:: Вывод - в переменные DHH DMM и DSS
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
:: Функция вычитания для сериализованного времени
:: Формат:   Call :TMinus (сериализованное время) (сколько секунд отнять)
:: Вывод - в ErrorLevel
Set Result=
Set /A Result=%1-%2
If %2 GTR %1 (
    Set /A Result=86400+%1-%2
)
Exit /B %Result%

:TPlus
:: Функция прибавления для сериализованного времени
:: Формат:   Call :TPlus (сериализованное время) (сколько секунд прибавить)
:: Вывод - в ErrorLevel
Set Result=
Set /A Result=%1+%2
If %Result% GTR 86400 (
    Set /A Result=%1+%2-86400
)
Exit /B %Result%

:Timer
:: Отсчитывает прошедшее с заданного момента время
:: Формат:   Call :Timer (запомненное сериализованное время)
:: Вывод - в ErrorLevel
:: Если счетчик переходит границу суток, число дней возрастает на 1
:: Дни выводятся в переменную ED (и накапливаются) // да, знаю, что костыль и быдлокод
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
:: Проверяет, прошел ли заданный промежуток времени
:: Формат:   Call :Timer2 (запомненное сериализованное время) (промежуток в секундах)
:: Вывод - в ErrorLevel (только 0=промежуток истёк или 1=промежуток ещё не истёк)
Call :ParseTimestamp %time:~-0,8%
Call :SerializeTime
Call :TMinus %STime% %1
If %2 GTR %Result% Set Timer2=1&Exit /B 1
Set Timer2=0&Exit /B 0

:Cut
:: Убирание ведущих нулей и пробелов
:: Формат:   Call :Cut (Двухзначное число) (Переменная, куда вывести резуьтат)
Set d=%1
If "%d:~,1%"=="0" Set %2=%d:~1%
If "%d:~,1%"==" " Set %2=%d:~1%
Exit /B
::========================================================================