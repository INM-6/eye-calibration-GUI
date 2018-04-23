function  calibData = TargetStructureFilling(varargin)

if nargin == 1 && strcmp(varargin{1},'test')
    NEV = openNEV('overwrite');
    NSx = openNSx('read');
    
elseif nargin == 2
    NEV = varargin{1};
    NSx = varargin{2};
end

% Data collection and preparation.
% We get the event code list from the NEV file
codeList = cast(NEV.Data.SerialDigitalIO.UnparsedData','double');
% And we get also the time stamps associated with these events
% First we need to cast everyone because it's in uint32
rawCodeTimeList = cast(NEV.Data.SerialDigitalIO.TimeStamp,'double');
nsxSampleFreq = cast(NSx.MetaTags.SamplingFreq,'double');
nevSampleFreq = cast(NEV.MetaTags.SampleRes,'double');
nsxData = cast(NSx.Data,'double');
% Then we resample timestamps in the same frequency than in the NSx file
codeTimeList = ceil((rawCodeTimeList * nsxSampleFreq) / nevSampleFreq);

% We cut the NSx file into pieces for different trials between code 12345
% (NewTrial) and code 13000 (TrialEnd). This includes both data and
% metadata period.
% First, we define the timeList for trial start and trial end
trialStartTimeList = codeTimeList(codeList == 12345);                       % <--- FVB Test which event code we use 
trialEndTimeList = codeTimeList(codeList == 13000 | codeList == 13006);

% We check the file integrity
if length(trialStartTimeList) ~= length(trialEndTimeList)
    disp('ERROR trial start and trial end numbers mismatch.');
    return
end

% We create a temporary structure containing separated trials
errorCount = 0;
trialIndex = 1;
for loopIndex = 1:1:size(trialEndTimeList,2)  % For each trials
    if codeList(codeTimeList == trialEndTimeList(loopIndex)) == 13000  % that were correct
        % We put in Data the content of NSx.Data between trial start and
        % trial end
        tempTrialStruct(trialIndex).Data = nsxData(:,trialStartTimeList(loopIndex):trialEndTimeList(loopIndex));
        % We put in Codes the content of event codes from NEV for which the
        % index is between the index of trial start time and trial end time
        tempTrialStruct(trialIndex).Codes = codeList(find(codeTimeList == trialStartTimeList(loopIndex)):find(codeTimeList == trialEndTimeList(loopIndex)));
        % We put in TimeStampLocal the time of these events reinitialized
        % to start at 1 to be in the trial timeline
        tempTrialStruct(trialIndex).TimeStampLocal = ...
            codeTimeList(find(codeTimeList == trialStartTimeList(loopIndex)):find(codeTimeList == trialEndTimeList(loopIndex))) - (trialStartTimeList(loopIndex) - 1);
        % We get the target name knowing that target ON code are 21xx1 with
        % xx = target number
        tempTrialStruct(trialIndex).TargetCode = tempTrialStruct(trialIndex).Codes(tempTrialStruct(trialIndex).Codes > 21000 & tempTrialStruct(trialIndex).Codes < 22000);
        % And we also put it on a list of target codes for correct trials
        targetCodeList(trialIndex) = tempTrialStruct(trialIndex).TargetCode;
        trialIndex = trialIndex +1;
    else
        errorCount = errorCount + 1; % Error count if bad trial (13006 code)
    end
end

% Now we can go across trials and get for each the sample we need located
% with buttonPress code
for trialIndex = 1:1:size(tempTrialStruct,2) % For each kept trial
    % We put in CalibSample the Data between 25ms and 75ms after
    % buttonPressCode timeStampLocal
    tempTrialStruct(trialIndex).CalibSample = tempTrialStruct(trialIndex).Data(:,tempTrialStruct(trialIndex).TimeStampLocal(tempTrialStruct(trialIndex).Codes==57025):tempTrialStruct(trialIndex).TimeStampLocal(tempTrialStruct(trialIndex).Codes==57025)+101);
end


% We get the "real" target ID (only the xx in the 21xx1 code) whole list
targetIDCompleteList = floor((targetCodeList - (floor(targetCodeList / 1000)*1000))/10);
targetIDList = unique(targetIDCompleteList);

% We group the trials according to the target they belong to.

% First we put on a first level of the structure what is common to everyone
calibData.setupData.eyeHeight = 0;
calibData.setupData.eyeScreenDist = 0;
calibData.setupData.targetNum = size(targetIDList,2);
% Then for each different targetID
for targetIndex = 1:1:size(targetIDList,2)
    % We save the target ID itself
    calibData.targetData(targetIndex).targetID = targetIDList(targetIndex);
    % And the number and rank of trials where we used this target
    calibData.targetData(targetIndex).rankTrial = find(targetIDCompleteList == targetIDList(targetIndex));
    calibData.targetData(targetIndex).nbTrial = size(calibData.targetData(targetIndex).rankTrial,2);    
    % And its corresponding coordinates on the screen
    firstTrialForThisTarget =  calibData.targetData(targetIndex).rankTrial(1);
    tempXpos = tempTrialStruct(firstTrialForThisTarget).Codes(find(tempTrialStruct(firstTrialForThisTarget).Codes == 1110,1,'first')+1);
    tempYpos = tempTrialStruct(firstTrialForThisTarget).Codes(find(tempTrialStruct(firstTrialForThisTarget).Codes == 1120,1,'first')+1);
    % Because numeric values are sent with an offset of 2^15 to have symetric values around 0
    calibData.targetData(targetIndex).targetXpos = (tempXpos - (2^15))/100;
    calibData.targetData(targetIndex).targetYpos = (tempYpos - (2^15))/100;
    tmpTrialNumber = 0;
    % Then for each found trial
    while tmpTrialNumber < calibData.targetData(targetIndex).nbTrial
        tmpTrialNumber = tmpTrialNumber + 1;
        % We set the use / don't use flag to default 1 (use)
        calibData.targetData(targetIndex).eyeData(tmpTrialNumber).flag = 1;
        % And we save the data
        calibData.targetData(targetIndex).eyeData(tmpTrialNumber).eyeX = ...
            tempTrialStruct(calibData.targetData(targetIndex).rankTrial(tmpTrialNumber)).CalibSample(1,:);
        calibData.targetData(targetIndex).eyeData(tmpTrialNumber).eyeY = ...
            tempTrialStruct(calibData.targetData(targetIndex).rankTrial(tmpTrialNumber)).CalibSample(2,:);
        calibData.targetData(targetIndex).eyeData(tmpTrialNumber).eyeXVolt = calibData.targetData(targetIndex).eyeData(tmpTrialNumber).eyeX .* (10./(2^16)); % To accord with 10v = 16bits in eyelink
        calibData.targetData(targetIndex).eyeData(tmpTrialNumber).eyeYVolt = calibData.targetData(targetIndex).eyeData(tmpTrialNumber).eyeY .* (10./(2^16));
    end    
end

