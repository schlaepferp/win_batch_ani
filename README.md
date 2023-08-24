# win_batch_ani
compute ANI values between two sequences using windows cmd.exe
The batch file (win_batch_ani.bat) calculates ANI values between genomes for two or more genomes present in an equal number of .fasta files. The script produces resulting ANI values as .txt- and a .tsv files.

## Version:
1.0

## Date:
24.08.2023

## Authors:
- Dylan Winterflood
- Pascal Schlaepfer

## Affiliation:
Laboratory Medicine, University Hospital Basel, 4031 Basel, SWITZERLAND

## Dependencies:
- usearch11.0.667_win32.exe (http://www.drive5.com/usearch/download.html, Version: usearch11.0.667_win32.exe.gz)
- OAU.jar (https://www.ezbiocloud.net/tools/orthoaniu)

## Instructions:
1. Copy all .fasta files, between which you want to calculate ANI scores, into a single folder. ANI values will be calculated for each combination of 2 .fasta files in this folder. NOTE: only .fasta file endings allowed.
2. Copy this .bat file to the same folder where the .fasta files are stored.
3. Modify line 50 with the path to your OAU.jar file.
4. Modify line 52 with the path to your usearch executable file.
5. Save this bat file and close it.
6. Execute your .bat file: The calculation now starts. The calculation can take hours to days, depending on the number of .fasta files. (approx. 13 seconds per file, depending on the computer).

## Mandatory input: 
- A folder containing at least two fasta files, each with one genome.

## Output:
(Files generated in search folder)
- status.txt: Text file that shows whether the calculation has already been completed. It is possible that the program is aborted. In this case, simply re-execute this.bat file. The script will then continue where it left off.
- results.txt: Text file containing all calculations of ANI values. This raw data is then converted into a .tsv file.
- result_for_excel.tsv: A TAB separated file containing ANI values, allowing for easy import into EXCEL.

## NOTE:
- please modify the paths on line 50 and 52.
- Versions of both usearch11.0.667_win32.exe and OAU.jar included in this build, but you might need other versions, depending on your computer architecture
