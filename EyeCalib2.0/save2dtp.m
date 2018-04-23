function save2dtp(param,filename)
% This function saves the model parameters in the .dtp file dexterit-e uses
% to fill in the different tables that describe the task.
%
% In this function, we read the current version of .dtp file and we select
% the part that concerns the TWP table. Then we replace the values of the
% 32 last parameters by the calibration model output.
%
% The function needs two arguments:
% param which is a list of 32 labels and 32 values.
% filename which is the name of the dtp file to modify.

% We read the source dtp file as a single huge string
myFile = fileread(filename);
% We split this huge string into small ones (one for each line)
splitedStrings = textscan(myFile,'%s','Delimiter','\n');

dataSize = size(splitedStrings{1});

% So we look for the first tag for TW parameter table
twIsParamStart = zeros(dataSize(1),dataSize(2));
for i=1:1:dataSize(1)
    twIsParamStart(i) = strcmp(splitedStrings{1}{i},'<tasklevelparams>');
end
twParamStart = find(twIsParamStart);

% And we take the next array element as source data and we remove starting
% and ending square brackets
sourceData = splitedStrings{1}{twParamStart+1};
sourceData = sourceData(sourceData ~= '[' & sourceData ~= ']' & sourceData ~= '''');
%and we split it into the different parameter elements (separated with a , )
sourceData = textscan(sourceData,'%s','Delimiter',',');

% Source data is a cell array that contains a vector of 100 cells.
% Each cell with an odd index is a label
% The corresponding values are located in the next cells

% For all the parameter labels (30 items) + mean voltage for central target
% on X and Y axis (2 items)
for i=1:32
    % We check in the odd cells if there's a name matching
    for j=1:2:99
        if strcmp(sourceData{1}{j},param(i).title)
            % And if it's true, we replace the value by the one of the
            % current parameter
            sourceData{1}{j+1} = param(i).value*100; %*100 because of the format e-005 (bug in Dexterit-e)
        end
    end
end

% We prepare the Data we will save into the destination .dtp file
% It's a table whose final form is [[element1], [element2],...,[elementN]]
finalData = [];
for i = 1:2:size(sourceData{1},1)-1
    finalData = [finalData '[''' sourceData{1}{i} ''', ' num2str(sourceData{1}{i+1}) '], ']; 
end
% and we finish with a ] to close the table
finalData = ['[' finalData(1:end-1) ']'];

% We put back the data into the global .dtp string
for i=1:1:dataSize(1);
    if (strcmp(splitedStrings{1}{i}, '<tasklevelparams>') ) % && (strcmp(splitedStrings{1}{i+2}, '</tasklevelparams>'))
        splitedStrings{1}{i+1} = finalData;
        break;
    end
end

% and we write it into the destination file
try
fid = fopen(filename,'w+');
catch
    disp('PATH OR FILNAME NOT VALID. DID YOU UPDATE DEXTERITY ?')
end
for i=1:1:dataSize(1);
    fprintf(fid,'%s',splitedStrings{1}{i});       %# Print the string
    fprintf(fid,'\n');
end

fclose(fid);