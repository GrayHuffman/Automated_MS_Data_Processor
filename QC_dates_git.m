function h = QC_dates(range)
 global path
 
 % ----------------------
 % Overview: This function allows you to get the folders of all QC runs 
 % that fall within a given date range
 % ----------------------
 % Written: 5/5/2018 (RGH)
 % ----------------------
 % Input type: Char/String
 % Input Format:
 %
 % + 'One','one', and '1' will give you all runs from the last week
 % + 'Two','two', and '2' will give you all runs from the last two weeks
 % + 'Three','three', and '3' will give you all runs from the last three
 %    weeks
 
 
% Getting the contents of the QC directory
fileinfo = dir([path 'QEQC/QC_Standards/']);

% Getting those items which are subfolders
ind = [fileinfo.isdir];
subFolders = fileinfo(ind);

% Getting the dates of the contents
dates = datetime({subFolders.date});

% Getting the current dat
numSubFolders = (size(subFolders,1)-1);

for i=3:numSubFolders

    indivfileinfo = dir([path 'QEQC/QC_Standards/' subFolders(i).name]);
    IFN = subFolders(i).name;
    IFI_table = struct2table(indivfileinfo);
    Evi_entry =IFI_table(ismember(IFI_table.name,'evidence.txt'),:);
    dateOfEvi = datetime(Evi_entry.date);
    if(~(contains(string(IFN),'Viz')))
    %if(~(string(IFN) == 'Viz'))
        output_tableIFN{i-2} = IFN;
        output_tableDATE(i-2) = dateOfEvi;
    end
end

% Matching those items which fall within a given time frame
if (strcmpi( range, 'One' )|strcmpi( range, '1' ));
    oneWeek = datestr(now-7);   
    %matches = dates > oneWeek;
    matches = output_tableDATE > oneWeek;
elseif (strcmpi( range, 'Two' ) | strcmpi( range, '2' ));
    twoWeek = datestr(now-14);
    %matches = dates > twoWeek;
    matches = output_tableDATE > twoWeek;
elseif (strcmpi( range, 'Three' ) | strcmpi( range, '3' ));
    threeWeek = datestr(now-21);
    %matches = dates > threeWeek;
    matches = output_tableDATE > threeWeek;
elseif (strcmpi(range, 'All'));
    allWeeks = datestr(now-365);
    matches = output_tableDATE > allWeeks
else 
    twoWeek = datestr(now-14);
    %matches = dates > twoWeek;
    matches = output_tableDATE > twoWeek;
end

%getting a cell array of folders which match the condition
%matchingFolders = {subFolders(matches).name};
matchingFolders = output_tableIFN(matches);

%Removing those items with short names (probably '.' or '..')
%matchingFolders(3 >= cellfun(@numel,matchingFolders)) = [];
%matchingFolders = strcat(string(matchingFolders),'/');
matchingFoldersS = cellfun(@(c)[c '/'],matchingFolders,'uni',false);
h = matchingFoldersS;
end