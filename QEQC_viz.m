function y = QEQC_viz( Cell_Array, OUTPUT_DIR)
% This function allows the visualization of multiple QC files
%   Input a cell array of folder names and an output folder name.
%   The output folder name will appear in the QC_Standards Dir.

% Updated on 9/18 to present grouped metrics first and individual metrics
% afterwards

global path fid numFiles

% Viz Directories

% Generating output directory
QC_Dir = [path 'QEQC/QC_Standards/'];

mkdir( [path 'QEQC/QC_Standards/' 'Viz/' OUTPUT_DIR] );
full_name = OUTPUT_DIR;
server_dir = [OUTPUT_DIR '/'];
outputFolder = [path 'QEQC/QC_Standards/Viz/' OUTPUT_DIR '/'];
input_Folder = [path 'QEQC/QC_Standards/'];

% Creating/Finding .dat files for each sample
for i=1:numel(Cell_Array)
    DIR = Cell_Array(i);
    DIR_2 = ['QEQC/QC_Standards/' char(DIR)];
    exp_Folder = [input_Folder char(Cell_Array(i))];
    dirs = regexp( DIR, '/', 'split' );
    name = dirs{end}; 
    if numel(name) == 0, name = dirs{end-1}; end
    %if nargin < 3, RUN_PERL = 0; end 
    %if nargin >= 2 && ~isempty(Y)
    %    y = Y;
    %else
    evi_structure = dir([exp_Folder 'evidence.txt']);
    if (exist( [exp_Folder 'data.mat'], 'file' ) ~= 2) & (evi_structure.bytes > 250) %||...
        %(nargin==3 && RUN_PERL>0)
        [y.ms, y.mss] = load_MS_DataM(  path,  DIR_2, 'msmsScans.txt');
        [y.qc, y.qcc] = load_MS_DataM(  path,  DIR_2, 'evidence.txt');
        [y.ap, y.app] = load_MS_allPeptides (  path,  DIR_2, 'allPeptides.txt');
        [y.msms, y.msmss] = load_MS_DataM(path,  DIR_2, 'msms.txt');
        [y.msScan, y.msScans] = load_MS_DataM(path,  DIR_2, 'msScans.txt');
        save( [exp_Folder 'data'], 'y' );
    elseif(exist( [exp_Folder 'data.mat'], 'file' ) == 2)
        load( [exp_Folder 'data.mat'] );
        %system( [ 'open '  path DIR 'glance/index.html'] );  return
   end
end

% Loading data for each selected experiment into a structure
raw_file_folder = [path 'RAW_DATA_SCOPE/']

for i=1:numel(Cell_Array)
    exp_Folder = [input_Folder char(Cell_Array(i))];
    load([exp_Folder 'data.mat']);
    dirs = regexp( Cell_Array(i), '/', 'split' );
    name = dirs{1,1}; 
    name_prefix = char(name(1,1));
    RawNamePart = extractAfter(name_prefix,"-");
    S = dir([raw_file_folder '*' RawNamePart '.raw']);
    date_input = datenum(char(S.date), 'dd-mmm-yyyy HH:MM:SS');
    time_format = 'mm/dd HH:MM';
    time_to_store = datestr(date_input, time_format);
    QEQC_DataFrame{i,1} = char(name(1,1));
    QEQC_DataFrame{i,2} = y.qc;
    QEQC_DataFrame{i,3} = y.qcc;
    QEQC_DataFrame{i,4} = y.ap;
    QEQC_DataFrame{i,5} = y.app;
    QEQC_DataFrame{i,6} = y.ms;
    QEQC_DataFrame{i,7} = y.mss;
    QEQC_DataFrame{i,8} = y.msms;
    QEQC_DataFrame{i,9} = y.msmss;
    QEQC_DataFrame{i,10} = y.msScan;
    QEQC_DataFrame{i,11} = y.msScans;
    QEQC_DataFrame{i,12} = char(time_to_store);
end

% Generating HTML file
copyfile( [path 'QEQC/html/bin/index.html'],    outputFolder ); 
fid = fopen( [outputFolder 'index.html'], 'a' ) 
fprintf( fid, '<title>QEQC | %s | Slavov Lab</title>\n', full_name  );
fprintf( fid, '</head> <body> \n <header> \n\n' );
fprintf( fid, '<h1 class="title">QEQC: %s</h1>\n\n\n', full_name  );    
fprintf( fid, '</header><main> \n\n' );  

% P1: Sort_PEP plot
open_section('Confidence of ID')
QEQC_Viz_Helper(QEQC_DataFrame, 'PEP');
File_Name = 'PEP';
close_section( outputFolder, File_Name );

% P2: [WORKS] Precursor Intensities 

open_section( 'Precursor Intensities' );
QEQC_Viz_Helper(QEQC_DataFrame, 'Pre');
File_Name = 'Precursor_Int';
close_section( outputFolder, File_Name );

% P3: [WORKS] Elution Peaks (Base) 

open_section( 'Retention Length at Base' );
QEQC_Viz_Helper(QEQC_DataFrame, 'ReL');
File_Name = 'Retention_Length_at_Base';
close_section( outputFolder, File_Name );

% P4: [WORKS] Elution Peaks (FWHM) 

open_section( 'Peak Width FWHM' );
QEQC_Viz_Helper(QEQC_DataFrame, 'FWHM');
File_Name = 'Peak_Width_at_FWHM';
close_section( outputFolder, File_Name );

% P5: Correlation to Bulk

open_section( 'Correlation to Carrier' );
QEQC_Viz_Helper(QEQC_DataFrame, 'Corr2Bulk');
File_Name = 'Corr2Bulk';
close_section( outputFolder, File_Name );

% P6: [WORKS] Distribution of PIFs 

open_section( 'PIF Distributions' );
QEQC_Viz_Helper(QEQC_DataFrame, 'PIF');
File_Name = 'PIF_Distributions';
close_section( outputFolder, File_Name );

% P7: [WORKS] Successfully Identified MSMS for retention range

open_section( 'IDd MSMS by RT' );
QEQC_Viz_Helper(QEQC_DataFrame, 'IDbyRT');
File_Name = 'IDd_MSMS_by_RT';
close_section( outputFolder, File_Name );

% P8: Scan Events per Minute
%Needs Work: Fix perl script to load msmsCount
%open_section( 'Duty Cycle' );
%QEQC_Viz_Helper(QEQC_DataFrame, 'DutyCycles');
%File_Name = 'Scan_events_per_minute';
%close_section( outputFolder, File_Name );

% P8: Long Retained Ions (Possible Contaminants) 
%Needs work: x-axis labels are not correct

open_section( 'Long Retained Ions' );
QEQC_Viz_Helper(QEQC_DataFrame, 'LongRetIons');
File_Name = 'Long_ret_ions';
close_section( outputFolder, File_Name );

% P9: [WORKS] Charge States for all samples (from AP) 

open_section( 'Charge States (AP): All Samples' );
QEQC_Viz_Helper(QEQC_DataFrame, 'ChargeStatesAll');
File_Name = 'Charge_States_from_AP_all';
close_section( outputFolder, File_Name );

% P10: [WORKS] Charge States of Most Recent Sample (from AP) 

open_section( 'Charge States (AP): Most Recent' );
QEQC_Viz_Helper(QEQC_DataFrame, 'ChargeStatesSingle');
File_Name = 'Charge_States_from_AP_Single';
close_section( outputFolder, File_Name );

% P11: [WORKS] Recent Intensities per Channel 

open_section( 'Intensities per Channel' );
QEQC_Viz_Helper(QEQC_DataFrame, 'RecentInt');
File_Name = 'Int_per_channel';
close_section( outputFolder, File_Name );

% P12: [WORKS] Ion Map 

open_section( 'Ion Map (AP)' );
QEQC_Viz_Helper(QEQC_DataFrame, 'IonMap');
File_Name = 'Ion_Map';
close_section( outputFolder, File_Name );

% P13: Fraction of Missing Data

open_section( 'Fraction of Missing Data' );
QEQC_Viz_Helper(QEQC_DataFrame, 'FracMissing');
File_Name = 'FracMissing';
close_section( outputFolder, File_Name );


% Finishing HTML document construction

fprintf( fid, '</main></body></html>\n' );
fclose( fid );

%html_Folder = [path 'SCoPE/SingleCell_Data/html/QEQC/' full_name '_QEQCviz/']
html_Folder = [path 'QEQC/QC/' OUTPUT_DIR ]
display(html_Folder);
mkdir( html_Folder );
copyfile( [outputFolder 'index.html'],   html_Folder );
copyfile( [outputFolder '*.png'],   html_Folder );
%if strcmp( path(1:2), '/U' )
%    system( [ 'open '  html_Folder '/index.html'] );
%else
%   system( [ 'start '  html_Folder '/index.html'] );
%end

%html_Folder_web = [path 'qeqc/' full_name '_QEQC/'];
%mkdir( html_Folder_web );
%copyfile( [outputFolder 'index.html'],   html_Folder_web );
%copyfile( [outputFolder '*.png'],   html_Folder_web );
if numel(path)>14 && strcmp( path, 'C:/Google_Drive/MS/' )
    %system( [ 'open '  html_Folder '/index.html'] );    
else
   system( [ 'start '  html_Folder '/index.html'] );
end


function open_section( Title )
global fid
close all
fprintf( fid, '<section>\n' );
fprintf( fid, '  <h2 class="bigtitle-title">%s</h2>\n', Title );


%Auxiliary Helper Functions

function close_section( Folder, File_Name )
global fid 
Pix_SS = get(0,'screensize');
if Pix_SS< 1500
   set( gcf, 'Position', [0.045    0.068    0.50    0.50] ) 
end
saveas(gcf, [Folder File_Name], 'png');
fprintf( fid, '<img class="figure-img" src="%s.png" alt="important graph">\n', File_Name );  
fprintf( fid, '</section>\n\n' );



