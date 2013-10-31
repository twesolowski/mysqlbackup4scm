@echo off



set file_structure=%repository%\%database%-structure.sql
set file_data=%repository%\%database%-data.sql

REM set proper password part of command 
IF NOT [%password%]==[] set password=-p%password%
REM create destination dir
IF NOT EXIST %repository%  mkdir %repository%

echo \q | %mysql% -u %username% -h %hostname% %password% 2>nul


REM CONTROLLER

if "%ERRORLEVEL%" == "0" (
		echo CONNECTION OK
		IF "%1"=="import" (
		GOTO IMPORT
	) else (
		GOTO DUMP
	)
  
) else (
	echo CONNECTION FAILED
	GOTO EOF
)



:DUMP
	echo|set /p=DUMPING STRUCTURE 
	%md% -u %username% %password% -h %hostname% -d   %database%  >  %file_structure%
	if "%ERRORLEVEL%" == "0" (
	   echo OK
	) else (
		echo FAIL
	)

	echo|set /p=DUMPING DATA 
	%md% -u %username% %password% -h %hostname% --replace --no-create-info --extended-insert=FALSE --complete-insert=TRUE %database%  >  %file_data%
	if "%ERRORLEVEL%" == "0" (
		echo OK
	) else (
		echo FAIL
	)

	GOTO EOF


	
:IMPORT
	
	IF "%2"=="structure" (
		echo|set /p=IMPORTING STRUCTURE 
		set filetoimport=%file_structure%
	) else if "%2"=="data" (
		echo|set /p=IMPORTING DATA 
		set filetoimport=%file_data%
	) else (
		echo SELECT IMPORT TYPE
	)
	
	IF NOT EXIST %filetoimport% (
		echo FILE %filetoimport% DOESN'T EXIST
		GOTO EOF
	)
	
	IF NOT [%filetoimport%]==[] (

			%mysql% --verbose -u %username% -h %hostname% %password% %database%  < %filetoimport% 
			if ERRORLEVEL 0 (
				echo OK 
			) else (
				echo FAIL 
			)
	)

	GOTO EOF	

:EOF
	echo I'M DONE