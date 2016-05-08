# delete_temp_files
CMD-скрипт для удаления временных папок и файлов с диска С
Список папок, из которых происходит удаление:
1. %SYSTEMDRIVE%\Temp                       (С:\Temp\)
2. "%WINDIR%\Temp\                          (C:\Windows\Temp)                                      
3. %Temp%                                   (C:\Users\YOUR_NAME\AppData\Local\Temp)

Ограничения:
1. Удаляет только поддиректории из указанных выше папок
2. Задать можно только одну маску