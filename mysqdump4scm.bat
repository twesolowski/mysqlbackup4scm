@echo off

REM databse config
set database=database
set username=root
set password=
set hostname=127.0.0.1
set repository=mysql_dump


REM file prefix
set prefix=prefix-

REM mysql.exe command path, use absolute path if isn't in PATH
set mysql=mysql.exe
REM mysqldump.exe command path, use absolute path if isn't in PATH
set md=mysqldump.exe

set file_structure=%repository%\%database%-structure.sql
set file_data=%repository%\%database%-data.sql

REM set proper password part of command 
IF NOT [%password%]==[] set password=-p%password%
REM create destination dir
IF NOT EXIST %repository%  mkdir %repository%

echo \q | %mysql% -u %username% -h %hostname% %password% 2>nul

if "%ERRORLEVEL%" == "0" (
  echo CONNECTION OK
  GOTO DUMP
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
%md% -u %username% %password% -h %hostname% --replace --no-create-info --skip-extended-insert %database%  >  %file_data%
if "%ERRORLEVEL%" == "0" (
    echo OK
) else (
    echo FAIL
)

echo I'M DONE
:EOF