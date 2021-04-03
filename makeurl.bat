@echo on

:: Version 1.1 (Initial Release)

rmdir /Q /S dl
::Checks/Creates the library file.
call :makelib
:libexist
cls

:: Sets the Book ID
if exist "found.txt" ( echo -- Previously found book results exist, new ones will be added to the end --
echo if you would prefer to start a fresh list, delete found.txt and run this again
echo.
)
echo Book ID -^> Open OverDrive.com. Search, Select book, ID is number after /media/
echo Manually type ID into the box below or right click to paste
echo.
set bkid=error
set /p bkid=Enter the book ID:
call set this=%%bkid
cls
echo Searching. This should take under a minute. Hang on.

::Starts the library downloads. Uses lib.txt as its source
md dl
setlocal
set minbytesize=25
set filename=lib.txt
for /F "tokens=*" %%a in ('type %FileName%') do (
	powershell -Command "(New-Object Net.WebClient).DownloadFile('https://www.overdrive.com/_Ajax/get-libraries-for-media?mediaId=%bkid%&resultLimit=1&position=%%a', 'dl\%%a.txt')"
)
endlocal

:: Delete Libraries with no results
for %%j in (dl\*) do if %%~zj lss 25 del "%%~j"
:: Cleans up the dl files for pretty output
powershell "gci 'dl' -Filter *.txt | ren -NewName { $_.Name -replace '^[^\#]*\#' }"
powershell "gci 'dl' -Filter *.txt | ren -NewName { $_.Name -replace '(.+?)_.+','$1' }"

:: If files exist. yes results. If not, no result
for /F %%i in ('dir /b "%cd%\dl\*.*"') do (
goto resultsfound
)
goto noresults

:: Echo's the found.txt file for easy viewing.
:resultsfound
echo ---------- %bkid% ---------- >> found.txt
for %%f in ("dl\*") do echo %%~nf >> found.txt
cls
echo These libraries have the book in question
echo see found.txt for an easy-to-copy list
echo.
type found.txt
echo.
call :cleanup
pause
exit


:: Opens the Xenos library if you chose too.
:noresults
call :cleanup
cls
echo Seems none of my bigger libraries had the book you were looking for
Echo Would you like to open the Xenos Christian Library page?
echo They're a small niche library that specialize in Christian Reference Materials.
echo.
echo if Xenos has the book. Paste link to book in the form
echo if the book says "RECOMMEND" in an orange box. They do NOT have the book..
echo.
setlocal
choice /m ""
if errorlevel 2 (exit) else (goto open)
endlocal

:open
start "" "https://xenos.overdrive.com/"
exit


:: Library Source Text. 
:: Don't mess with this unless you know what you are doing.
:makelib
if exist "lib.txt" ( goto libexist )
(
echo 40.6612083,-73.948261#Brooklyn
echo 41.8762205,-87.628287#Chicago
echo 41.4041094,-81.6978607#Cuyahoga
echo 40.7071623,-83.8442906#OhioDigital
echo 33.6541366,-112.0985295#GreatPhoenix
echo 30.0123954,-95.5097501#HarrisCounty
echo 39.1025072,-94.583923#KansasCity
echo 47.3590811,-122.1218869#KingCounty
echo 34.0502905,-118.2550447#LAPublic
echo 33.980294,-118.2188164#LACounty
echo 41.5011912,-81.6917925#CleveNet
echo 25.7745788,-80.1973908#MiamiDade
echo 39.1006555,-94.4191583#MidCont
echo 40.2010413,-92.5729926#MoLib2Go
echo 36.1621075,-86.7818797#Nashville
echo 33.3506399,-105.6618152#NMLib2go
echo 40.7074855,-73.7944033#Queens
echo 37.1307212,-93.2985468#Springfield
echo 43.0599652,-88.0089757#WIConsort
:: These ones are short term, I may not have in the future
echo 43.671806,-79.3869188#Toronto
echo 44.9805962,-93.2701555#Hennepin
)>"lib.txt"
goto libexist


:cleanup
rmdir /Q /S dl
:: Comment out v this line if you want to keep lib.txt bc you made changes to it.
del /S /Q lib.txt >nul