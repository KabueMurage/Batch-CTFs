@Echo Off
SetLocal EnableDelayedExpansion

rem ===============================================================
rem Author : Kabue Murage 
rem Forums : 254peepee
rem directory sorting using winbatch

rem Copy this file to : C:\Users\%username%\AppData\Roaming\Microsoft\Windows\SendTo
rem and using file explorer, select the directory you want to sort and right click
rem for the context menu and navigate to "Send To" and select "DirSortByModDate.bat"

rem ===============================================================

set bSortFiles_Folders=3
rem 0 = Will skip sorting folders. [default]
rem 1 = Will also sort folders.
rem 3 = Sort both files and folders


set fastmode=0
rem 0 = slow sorting with colored output.
rem 1 = fast sorting with plain output.

rem space delimited filetypes to ignore.. comment to not ignore any filetype.
set sIgnoredFileTypes=.bat .ini .ink

rem help params
set vHelpParameters=^-h ^--h ^--help help

Set AttribHidden=/a:h /a:-h
rem if /i "%cd%" EQU "C:\Users\%username%\AppData\Roaming\Microsoft\Windows\SendTo" (
rem 	call :msgPrompt "Got a folder called :  %~1" "Folder sort" "%~1" sConfirmedPth
rem 	echo MagicSort : %sConfirmedPth%
rem )

pushd "%~1"
title Sorting :%cd%
	call :Settings "%cd%" !bSortFiles_Folders! cm
	set ifolderCount=0
	set ifileCount=0
	set iTotal_f=0

	::delims is disabled # eol is disabled tokens=* is redundant
	rem For /f tokens^=*^ delims^=^ eol^= %%a in ("###trim ###") do echo.%%a

	For /F tokens^=*^ eol^= %%a in ('!cm! !AttribHidden!') do (
		call :cnt totalcount NumberFiles 0
		set "filename=%%a"
		call :IsDir "!filename!" isd
		title Sorted [folders :!ifolderCount!]  files [!ifileCount!]
		if !isd! EQU 1 (
			call :cnt ifolderCount foldervar 0
			if %fastmode% NEQ 1 ( 
				call :cl 0b " Sorting folder "
				call :cl 0c ": !filename!"
				echo.
			) else (echo Sorting folder !filename!)
		) else (
			call :cnt ifileCount filesCountvar 0
			if %fastmode% NEQ 1 ( 
				call :cl 0b " Found a file called "
				call :cl 0c ": !filename!"
				echo.
			) else (echo Found a file called !filename!)
		)
		for /f "tokens=1,2,3 delims=/ " %%k in ("%%~ta") do (
				rem echo Received as : %%k ==  %%l === %%m
				call :iDate2sMonth_resolve "%%k" "%%l" "%%m" sMonth
				call :sortme "!filename!" "!sMonth!" "%%m"
		)
		rem echo debug ok 4
	)
call :GetTotal !ifolderCount! !ifileCount! iTotal_f
Title Sorted [folders :%ifolderCount%]  files [%ifileCount%] total = %iTotal_f%
rem clean up temp file by func cl.
if %fastmode% NEQ 1 if exist "X" del /f /q "X"
popd

pause
exit /b

:GetTotal iCount1 iCount2 Resultvar
set _n1=%1
set _n2=%2
set /a _total=!_n1!+!_n2!
set %3=%_total%
exit /b

rem External counter.
:cnt VarName VarOutPut initialVal
	if not defined %1 (SET %1=%3)
	Set "%2=%1"
	set /a %1+=1
	set %2=%2
exit /b

:sortme <file or folder> <creation month = !sMonth!> <year mod>
	rem fix illegal chars in filename that may cause an error.
	set "_f=%~1"

	If exist "%cd%\%~2 %~3\" (
		Echo.    File   [!_f!] was last modified on : %~2  year : %~3
		Echo.    Moving [!_f!] to ".\%~2 %~3\"		
		rem move /Y "!_f!" "%cd%\!sMonth! %%m\"
	) else (
		Echo.    Folder [!_f!]       was last modified on : %~2 year : %~3
		Echo.    Folder [./%~2 %~3] does not exist, making it..
		rem if not exist "%cd%\!sMonth! %%m\" (md "%cd%\!sMonth! %%m\")
		Echo.    moving [!_f!] to ".\%~2 %~3\"
		rem move /Y "%%a" "%cd%\!sMonth! %%m\"
	)
exit /b

:Settings <sFQPN> <foldervaretting> <FinalCommand>
	rem Eval settings..
	if /i %2 EQU 1 (set _fol=D) else (
			if /i %2 EQU 0 (set _fol=-D) else (
				if /i %2 EQU 3 (
					set %3=dir "%~1" /b
					exit /b)
				)
		)
	set %3=dir "%~1" /b /A:!_fol!
exit /b

:msgPrompt <sMsgPrompt> <stitlebar> <sDefaultAnswer> <vOutVar>
	> usermessage.vbs ECHO WScript.Echo InputBox( "%~1", "%~2", "%~3" )
	FOR /F "tokens=*" %%A IN ('CSCRIPT.EXE //NoLogo usermessage.vbs') DO SET "%4=%%A"
	DEL /f /q usermessage.vbs
exit /b

rem Helper function to determine if the directory is already sorted.
rem includesfunction IsDir

:DirAlreadySorted <sFQPN> <return var>
rem call :IsDir "%~1"
rem if %errorlevel% EQU 1 (
	set "_f=January February March April May June July August September October November December"
	ECHO.%~1 | findstr /S /M /I "%_f%"
	if %errorlevel% == 1 (set "%2=0" &Echo.F %~1 has been created before) else (set "%2=1" &Echo.F %~1 has not been created before)
rem ) 
goto :EOF


:cl
if not defined null (
	for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do (set "null=%%a")
	) 
<nul > X set /p ".=."
set "param=^%~2" !
set "param=!param:"=\"!"
findstr /p /A:%1 "." "!param!\..\X" nul
<nul set /p ".=%null%%null%%null%%null%%null%%null%%null%"
exit /b

:iDate2sMonth_resolve <iMonth> <iday> <iYear> <smonthVar>
Set /a Counter=0
call :strrep "%~1" "0" "" iMonth
For %%a in (January February March April May June July August September October November December) do (
        Set /a Counter=!Counter!+1
        If /i "!counter!" EQU "!iMonth!" (
                set "%4=%%a"
                exit /b 0
                )
        Set Counter=!Counter!
)
exit /b 1

rem example : call :IsDir "!filename!" isd
rem if !isd! EQU 1 Echo Found a folder : %%a
:IsDir <sFQPN> <var>
set ATTR=%~a1
set DIRATTR=%ATTR:~0,1%
if /I "%DIRATTR%"=="d" (SET "%2=1") else (SET "%2=0")
goto :eof

:help 
echo help info..
pause
exit /b 


:strrep <string> <word> <replace> <result>
	SET "string=%~1"
	SET "%4=!string:%~2=%~3!"
GOTO :EOF
