<##################################################################
 TITLE: QC Pipeline Script                                               
 VERSION: 10
 DATE: (5/8/2018)                                                  
                                                                 
-------------------------------------------------------------------
 DESCRIPTION:                                                    
 ------------------------------------------------------------------                                                     
 This script does the following (if file is present):   
                               
 1. Downloads the QC_Standard Raw file onto the local hard drive 
 2. Initiates a MaxQuant search of the file (via custom mqpar)   
 3. Moves the evidence/AP/msms/msScans.txt file to an appropriate folder on G:   
 4. Deletes the remaining MaxQuant output folders and files      
 5. Calls MatLab QC_Standard script to generate QC_plots   
            
* Updated to process multiple .RAW files
* Updated to only run MQ script if one RAW file exists

-------------------------------------------------------------------
BEFORE USING:
-------------------------------------------------------------------
1. Replace all file paths that include "..." between \Users\ and \Documents\
   with your own preferred file paths 
2. Make sure you have installed MaxQuant
3. Make sure you have indicated the proper file path for MaxQuant
4. Download the included mqpar file or generate one of your own, which will
   be dynamically customized by this script
5. If you aren't interested in running the associated Matlab Analysis script,
   comment out that section
6. This script checks a shared Google Drive folder everyday for newly added .RAW
   files of a standard sample; make sure to properly direct this script to that folder

###################################################################>

#powershell -ExecutionPolicy ByPass -File Full_QC_Pipeline_local_v8.ps1

#------------------------------------------------------------------
#Start transcript
#------------------------------------------------------------------
Start-Transcript -Path "C:\transcripts\QEQC_log.txt" -Append -IncludeInvocationHeader



#------------------------------------------------------------------
# Source and destination folders (Configure these for your own system)
#------------------------------------------------------------------
$RAW_source = "G:/My Drive/MS/RAW_DATA_SCOPE/"
$RAW_local = "C:\Users\...\Documents\RAW_FILES\Pipeline"
$evidenceDestination = "G:/My Drive/MS/QEQC/QC_Standards/"

#------------------------------------------------------------------
# Dynamically formatted filenames/folders [WORKS! 3.21.18]
#------------------------------------------------------------------
# RAW file
$date_String = (get-date).ToString('yyMMdd')
#$fileName = $date + "S_QC_"
$date = (get-date).Date
$fileName = "S_QC_"
$EndTime = Get-Date
$StartTime =  Get-Date -Day ($EndTime.Day -1) -Month $EndTime.Month -Year $EndTime.Year -Hour 6 -Minute 0 -Second 0

$folders =  Get-ChildItem -Path $RAW_source -Recurse -Include "*$fileName*" -Exclude "*blank*" |Where-Object { $_.LastWriteTime -gt $StartTime -and $_.LastWriteTime -lt $EndTime}  
foreach ($folder in $folders){

# Get RAWFile name and path
$RAWFilePath = $folder.FullName
$RAWFileName = $folder.Name
$Folder_param = $RAWFileName -match "S_QC_(?<content>.*).raw"
$Dest_loc = $matches['content']
$RAW_local_date = $RAW_local +"\" + $date_String + "\"

# mqpar file (This may not be used)
$mqpar_FileName =  "Test_Doc_for_PS.xml"
$mqpar_file_fullPath = $RAW_source + $mqpar_FileName
$rawFileName = $RAW_local_date + $RAWFileName

# Location of MQ output: evidence file
$evidence_Source_Folder = $RAW_local_date + "combined\txt\"
$evidence_File_Path = $evidence_Source_Folder + "evidence.txt"
$AP_File_Path = $evidence_Source_Folder + "allPeptides.txt"
$msms_File_Path = $evidence_Source_Folder + "msms.txt"
$msScans_File_Path = $evidence_Source_Folder + "msScans.txt"
$msmsScans_File_Path = $evidence_Source_Folder + "msmsScans.txt"

# Local Folder for Matlab Processing
$Matlab_Files = "C:\ML_local\"
$evidence_Destination_MatLab = $Matlab_Files + $date_String + "/"
$evidence_Folder_Matlab_Contents = $evidence_Destination_MatLab + "*"


# Specific destination folder for evidence file
$evidence_Destination_Drive = $evidenceDestination + $date_String + "-" +$Dest_loc + "/"

#-----------------------------------------------------------------
# Copy Recent QC file from File Stream to local hard drive [WORKS! 3.21.18]
#-----------------------------------------------------------------
New-Item -ItemType Directory -Force -Path $RAW_local_date
Copy-Item $RAWFilePath -Destination $RAW_local_date

#-----------------------------------------------------------------
# Dynamically populate mqpar XML file [WORKS! 3.21.18] (input the location where you stored the mqpar file)
#-----------------------------------------------------------------
[xml]$test = Get-Content "C:/Users/.../Documents/RAW_FILES/Pipeline/mqpar_for_PS_Script.xml"
$test.DocumentElement.filePaths.ChildNodes.Item(0)."#text" = $rawFileName
$test.Save('C:/Users/.../Documents/RAW_FILES/Pipeline/QE_QC_mqpar.xml')
Write-Output "XML File generation complete"
#-----------------------------------------------------------------
# Run MaxQuant (using new mqpar file) [WORKS! 3.21.18]
#-----------------------------------------------------------------
& "C:/Program Files (x86)/MaxQuant/bin/MaxQuantCmd.exe" "C:/Users/.../Documents/RAW_FILES/Pipeline/QE_QC_mqpar.xml"

Write-Output "MaxQuant Finished"
#-----------------------------------------------------------------
# Copy Evidence File to local Matlab directory [Works! 3.21.18]
#-----------------------------------------------------------------
#New-Item -ItemType Directory -Force -Path $evidence_Destination_Matlab
#Copy-Item $evidence_File_Path -Destination $evidence_Destination_Matlab

New-Item -ItemType Directory -Force -Path $evidence_Destination_Drive
Copy-Item $evidence_File_Path -Destination $evidence_Destination_Drive
Copy-Item $AP_File_Path -Destination $evidence_Destination_Drive
Copy-Item $msms_File_Path -Destination $evidence_Destination_Drive
Copy-Item $msScans_File_Path -Destination $evidence_Destination_Drive
Copy-Item $msmsScans_File_Path -Destination $evidence_Destination_Drive

Write-Output "MaxQuant txt files sent to proper directories"
#-----------------------------------------------------------------
# Delete MaxQuant Output on Local Disk [UNTESTED]
#-----------------------------------------------------------------
#Remove-Item $SourceFiles

}

Start-Sleep -Seconds 300

#-----------------------------------------------------------------
# Matlab Function [WORKS! 3.21.18]
#-----------------------------------------------------------------
#$CheckFile = Test-Path $RAWFilePath
#if($CheckFile){
Write-Output "Matlab condition passed"
Set-Location "C:\"
matlab.exe -nodisplay -nosplash -nodesktop -r "run('C:/Users/G.Huffman/Documents/QC_Pipeline/Pipeline_script_050718.m');exit;"
#Previously exit used in quote block after semicolon above
Start-Sleep -Seconds 1200
Write-Output "Post Pause"
Write-Output "Version 10A"
#}else{exit}
#matlab.exe -nodisplay -nosplash -nodesktop -r "run('G:/My Drive/SingleCell/QE_QC_plots_v9_2.m');exit;"
#"C:/Program Files/MATLAB/R2017a/bin/matlab.exe -nodisplay -nosplash -nodesktop -r" "run('G:/My Drive/MatLab/QE_QC_standard_script_local.m');exit;"

#-----------------------------------------------------------------
# Copy evidence/extract/QCPlot to drive [Works! 3.21.18] (replace with your own preferred output folder)
#-----------------------------------------------------------------
#New-Item -ItemType Directory -Force -Path $evidence_Destination_Drive
#Copy-Item $evidence_Folder_Matlab_Contents -Destination "G:/My Drive/SingleCell_Data/QC_Standards/180321/"
Stop-Transcript