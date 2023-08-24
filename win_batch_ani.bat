@ECHO OFF
REM ###############################################################################################
REM FUNCTION: win_batch_ani.bat
REM This batch file (win_batch_ani.bat) calculates ANI values between genomes for two or more 
REM genomes present in an equal number of .fasta files. The script produces resulting ANI values as
REM .txt- and a .tsv files.
REM
REM VERSION: 1.0
REM
REM AUTHORS:
REM - Dylan Winterflood
REM - Pascal Schlaepfer
REM
REM AFFILIATION:
REM Laboratory Medicine USB, 4031 Basel, SWITZERLAND
REM
REM DATE: 24.08.2023
REM ###############################################################################################
REM 
REM REQUIREMENTS:
REM - usearch11.0.667_win32.exe (http://www.drive5.com/usearch/download.html, Version: 
REM   usearch11.0.667_win32.exe.gz)
REM - OAU.jar (https://www.ezbiocloud.net/tools/orthoaniu)
REM
REM INSTRUCTIONS:
REM 1.) Copy all .fasta files, between which you want to calculate ANI scores, into a single 
REM     folder. ANI values will be calculated for each combination of 2 .fasta files in this 
REM     folder. NOTE: only .fasta file endings allowed.
REM 2.) Copy this .bat file to the same folder where the .fasta files are stored.
REM 3.) Modify line 50 with the path to your OAU.jar file.
REM 4.) Modify line 52 with the path to your usearch executable file.
REM 5.) Save this bat file and close it.
REM 6.) Execute your .bat file: The calculation now starts. The calculation can take hours to days, 
REM     depending on the number of .fasta files. (approx. 13 seconds per file, depending on the 
REM     computer).
REM
REM INPUT: 
REM - A folder containing at least two fasta files, each with one genome.
REM 
REM OUTPUT (Files generated in search folder):
REM - status.txt: Text file that shows whether the calculation has already been completed. It is 
REM               possible that the program is aborted. In this case, simply re-execute this.bat 
REM               file. The script will then continue where it left off.
REM - results.txt: Text file containing all calculations of ANI values. This raw data is then 
REM                converted into a .tsv file.
REM - result_for_excel.tsv: A TAB separated file containing ANI values, allowing for easy import
REM                         into EXCEL.
REM ###############################################################################################

REM ### !!! HERE USER ACTION IS NEEDED !!! ###
REM Set the path to your oua java executable. For example: C:\OUA
set oua_path="[Set path here]"
REM Set the path to your usearch executable. For exasmple: C:\usearch
set usearch_path="[Set path here]"

REM Test if paths to third party software are valid.
IF NOT EXIST %oua_path%\OAU.jar (
	echo OAU.jar not found in %oua_path%.
	echo Abort.
	EXIT /B
)
IF NOT EXIST %usearch_path%\usearch11.0.667_win32.exe (
	echo usearch11.0.667_win32.exe not found in %usearch_path%.
	echo Abort.
	EXIT /B
)

REM First, all .fasta files, and programs for ANI calculations are copied to the local drive for 
REM optimal speed. This creates new directories. Next, ANI scores for every pair of .fasta files
REM are calculated.
REM Results are stored in results.txt and are copied back to the original folder where .fasta files
REM were stored. After the calculations, all created directories on the local drive are removed.

setlocal enabledelayedexpansion

REM .fasta files and programs (OAU.jar and usearch) used for calculation copied to local harddisk
REM (for faster calculation). Only on the 1st start of the .bat file. This does not happen again, 
REM if the .bat file was aborted.

IF NOT EXIST *.fasta (
	echo No Fasta-files detected.
	echo Abort.
	EXIT /B
)

IF NOT EXIST "C:\ani_temp" (
md C:\ani_temp
md C:\ani_temp_programme
xcopy "%CD%\*.fasta" "C:\ani_temp"
xcopy "%oua_path%\OAU.jar" "C:\ani_temp_programme"
xcopy "%usearch_path%\usearch11.0.667_win32.exe" "C:\ani_temp_programme"
) > nul

set "dir_path=C:\ani_temp"

REM create status.txt output
echo "Attention: ANI calculations not finished yet. Restart the .bat file" > %CD%\status.txt

REM Calculation of ANI values between each combination of 2 .fasta files. So that file x is not
REM compared with file y and then file y with file x, file x is deleted at the end of the outer for
REM loop.
REM specifications when calling the java file; -jar: specification pathway where program OAU.jar 
REM stored, -u: specification where algorythm usearch stored, -f1 and -f2: pathways to the .fasta 
REM files to compared, -n: how many cores used 
for %%f in (%dir_path%\*) do (
  for %%g in (%dir_path%\*) do (
    if /I not "%%f"=="%%g" if "%%~nxf" neq "%%~nxg" (
	java -jar C:\ani_temp_programme\OAU.jar -u C:\ani_temp_programme\usearch11.0.667_win32.exe -f1 "%%f" -f2 "%%g" -n 10 >> C:\ani_temp_programme\results.txt
    )
  )
del %%f 
)

REM copy results.txt back to .fasta folder
xcopy "C:\ani_temp_programme\results.txt" "%CD%" > nul

REM update status
rm "%CD%\status.txt"
echo "ANI calculations finished" > %CD%\status.txt

REM delete local directory used for calculations
rd /S /Q "C:\ani_temp_programme"
rd /S /Q "C:\ani_temp"

REM The following code uses the output of the exe usearch11.0.667_win32.exe, stored in the file
REM results.txt, that was produced above and processes it. The output is quite convoluted, because
REM it consists of screen output of multiple runs of the same software. Here, we use the fact that
REM the information of interest all start with 1 [TAB]. This is then either followed by declaring
REM which two files were compared to each other, or it is follwed by a numeric character which then
REM introduces all the ANI values. All comparisons and values are collected and then written into a
REM matrix in the form of a .tsv file.

REM Allow for the variable definition while running code using the !variable! system
SETLOCAL ENABLEDELAYEDEXPANSION

REM set constants at the beginning
SET "tab=	"
SET "fileout=result_for_excel.tsv"
SET "filein=results.txt"

REM Write header line
ECHO sample_compared%tab%orthoANI_value%tab%avg_aligned_length%tab%query_coverage%tab%subject_coverage%tab%query_length%tab%subject_length > %fileout%

REM Loop through result file, split lines into at max 7 items that were spaced by a Tab character
FOR /F "tokens=1,2,3,4,5,6,7 delims=%tab%" %%A IN (%filein%) DO (
	REM Get first item
	SET tok1=%%A
	
	REM Test if this First item was a 1, if so, this is a line of interest
	IF !tok1!==1 ( 
		REM Get second item to check if this one starts with a C, the local hard disk
		SET tok2=%%B
		
		REM Get the first letter of the second item
		SET tok2_1=!tok2:~0,1!
		
		REM Check if the first letter is a C
		IF !tok2_1!==C (
			REM If so, then write this without a new line character at the end into 
			REM the output file.
			ECHO|SET /p="!tok2!" >> %fileout%
		) ELSE (
			REM If not, then this is a content line, lets take the remaining values
			REM and space them with tabs, and write it to the output file.
			SET tok3=%%C
			SET tok4=%%D
			SET tok5=%%E
			SET tok6=%%F
			SET tok7=%%G
			
			REM This time, add a tab in front (to space it from the content in the 
			REM upper clause) and then a new line character at the end (no |Set /p=)
			ECHO %tab%!tok2!%tab%!tok3!%tab%!tok4!%tab%!tok5!%tab%!tok6!%tab%!tok7! >> %fileout%
		)
	)
)

EXIT /B


