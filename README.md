# Automated_MS_Data_Processor
Powershell script for automated processing of .RAW files via MaxQuant
---------
Overview
---------
This repository includes all the files necessary (assuming you have installed MaxQuant) for setting up an automated .RAW file processing pipeline. This collection of scripts was generated so that instrument performance could be tracked over time by running a standard sample on a daily basis and comparing the day-to-day performance of the mass spectrometer across a range of parameters (MS1 intensity, number of peptides identified, retention length at base, etc.)

----------
Components
----------
POWERSHELL
1. Full_QC_Pipeline_local_v10A.ps1 
    This powershell script can be automatically called by your local scheduling application to run everyday at a set time. It will locate     the most recently uploaded .RAW files to a specified directory, automatically search them using MaxQuant, store the search results in     a specified folder, and finally generate downstream visualizations using MATLAB (Pipeline_script_050718.m) 

MAXQUANT
1. mqpar_for_PS_Script.xml
    This mqpar file is used as a template by the powershell script. Everyday it is automatically update so that the searched files are         given a timestamped identifier.

MATLAB
1. Pipeline_script_050718.m: 
    This is the main Matlab script called by PowerShell script. It automatically generates visualizations of the searched .RAW files and 
    then concludes by emailing a list of contacts that new search results have been generated.  
2. QC_dates.m:
    This helper script locates all the searched data files generated in a given time frame (1 week, 2 weeks, etc.)
3. QEQC_viz.m:
    This helper script generates an html document containing visualizations of the searched .RAW files
4. QEQC_Viz_Helper.m:
    This helper script generates individual plots for a number of parameters of interest, such as retention length at base and precursor       apex offset time to assist in establishing the performance of an MS instrument.
    
--------------
Before You Begin
--------------
We typically store all our matlab scripts and searched mass spec data files on a shared drive, which is then defined in all included scripts (as a file path in the Powershell script and as a global path in the Matlab scripts). Make sure to customize the included scripts with your own file locations before running this pipeline.

The powershell script will automatically generate a transcript file for debugging purposes, so that you can track its run time and failure points, should any arise.

