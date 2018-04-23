function calibData=TargetStructureFilling_c3d(pathname, filename)
%
% The function TargetStructureFilling_c3d opens a Dexterit-E c3d datafile.
% I actually opens a zip file containing all the c3d (one per trial
% usually). All the informations about targets and voltages recorded during
% calibration are stored in the calibData structure.

data = zip_load([pathname filename]);

nb_trial_seq = size(data.c3d,2);
for t=1:nb_trial_seq
    trial_target(t,1)=t;                                                        % create a table with as first column the number of trial
    trial_target(t,2)=data.c3d(t).TP_TABLE.Target(data.c3d(t).TRIAL.TP);        % second column is the target displayed
    trial_target(t,3)=size(find(trial_target(1:t,2)==trial_target(t,2)),1);     % third column the number of times this target appeared before
    
end

calibData.setupData.targetNum=size(unique(trial_target(:,2)),1);                % create a setupData structure containing the targetNum which represents the number
% of targets that were displayed


for trialIndex=1:nb_trial_seq   
    calibData.targetData(trial_target(trialIndex,2)).targetID = trial_target(trialIndex,2);            % Create the targetID structure
    calibData.targetData(trial_target(trialIndex,2)).rankTrial(trial_target(trialIndex,3))= trialIndex;% rankTrial represents the number of trial in which the target appears
    calibData.targetData(trial_target(trialIndex,2)).nbTrial = trial_target(trialIndex,3);             % represents the number of times this target appeared since the beginning
    calibData.targetData(trial_target(trialIndex,2)).targetXpos = data.c3d(trialIndex).TARGET_TABLE.X(trial_target(trialIndex,2)); % represents the Xposition of the target
    calibData.targetData(trial_target(trialIndex,2)).targetYpos = data.c3d(trialIndex).TARGET_TABLE.Y(trial_target(trialIndex,2)); % represents the Yposition
    calibData.targetData(trial_target(trialIndex,2)).eyeDataRight(trial_target(trialIndex,3)).flag= 1;                             % flags are set equal to 1
    calibData.targetData(trial_target(trialIndex,2)).eyeDataLeft(trial_target(trialIndex,3)).flag= 1;                              % flags set equal to 1
%     %IndexC= strfind(data.c3d(trialIndex).EVENTS.LABELS,'Unnamed Event: code 12346');                                                    % find the index of the cell where the task button for recording appears
     IndexC= strfind(data.c3d(trialIndex).EVENTS.LABELS,'Unnamed Event: code 40001');
%     %IndexC= strfind(data.c3d(trialIndex).EVENTS.LABELS,'ACQUISITION_START');                                                    % find the index of the cell when the subject pushes the ok button (beginning of recording)
%     button_index = find(not(cellfun('isempty', IndexC)),1,'last');                                                                 % the model will send out an event named Acquisition_start
%     IndexC= strfind(data.c3d(trialIndex).EVENTS.LABELS,data.c3d(trialIndex).EVENTS.LABELS{button_index +1});                       % find the index of the event just after the task button (which corresponds
%     time_index = find(not(cellfun('isempty', IndexC)),1,'last');                                                                   % to the second time it appears, that's why we use last)
%     temps_start(trialIndex)= floor(data.c3d(trialIndex).EVENTS.TIMES(time_index)*1000);                                                   % time where the button was pushed minus 50ms
%     temps_stop(trialIndex)= floor(data.c3d(trialIndex).EVENTS.TIMES(time_index )*1000+100);                                                    %time where the button was pushed plus 50ms
    
    indexStart = find(not(cellfun('isempty', strfind(data.c3d(trialIndex).EVENTS.LABELS,'57002'))));
    indexTest(trialIndex,1) = find(not(cellfun('isempty', strfind(data.c3d(trialIndex).EVENTS.LABELS,'57002'))));
    time_start(trialIndex)= floor(data.c3d(trialIndex).EVENTS.TIMES(indexStart)*1000);
    indexStop =  find(not(cellfun('isempty', strfind(data.c3d(trialIndex).EVENTS.LABELS,'57100'))));
    indexTest(trialIndex,2) =  find(not(cellfun('isempty', strfind(data.c3d(trialIndex).EVENTS.LABELS,'57100'))));
    time_stop(trialIndex)= floor(data.c3d(trialIndex).EVENTS.TIMES(indexStop)*1000);
    indexTest(trialIndex,3) = indexTest(trialIndex,2) - indexTest(trialIndex,1);
end



% If the right eye is present we extract the values
if isfield(data.c3d,'eye_x_r')
    for trialIndex=1:nb_trial_seq
        calibData.targetData(trial_target(trialIndex,2)).eyeDataRight(trial_target(trialIndex,3)).eyeXVolt= data.c3d(trialIndex).eye_x_r(time_start(trialIndex):time_start(trialIndex)+100)';
        calibData.targetData(trial_target(trialIndex,2)).eyeDataRight(trial_target(trialIndex,3)).eyeYVolt= data.c3d(trialIndex).eye_y_r(time_start(trialIndex):time_start(trialIndex)+100)';
    end
end
% Same for left eye
if isfield(data.c3d,'eye_x_l')
    for trialIndex=1:nb_trial_seq
        calibData.targetData(trial_target(trialIndex,2)).eyeDataLeft(trial_target(trialIndex,3)).eyeXVolt= data.c3d(trialIndex).eye_x_l(time_start(trialIndex):time_start(trialIndex)+100)';
        calibData.targetData(trial_target(trialIndex,2)).eyeDataLeft(trial_target(trialIndex,3)).eyeYVolt= data.c3d(trialIndex).eye_y_l(time_start(trialIndex):time_start(trialIndex)+100)';
    end
end

