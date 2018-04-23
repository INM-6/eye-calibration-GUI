function [extracted] = getkin
%   -----------------------------------------------------------------------
%   GETKIN - Calculates & Extracts Kinematic & Event Data from .c3d files
%   -----------------------------------------------------------------------
%   Extracts hand & target position, velocity, acceleration, events &
%   trials from .c3d files. Run function and select data file to filter. 
%   This will be saved automatically into a getkin_[date+time].mat file.
%   The function has been optimised for the NHP-Kinarm at the INT, Marseille
%   and will only extract right-handed data. 
%
%   The hand kinematics are calculated from joint kinematics rather than
%	just differentiating the hand position because the original joint
%	kinematics are all calculated in real-time at a 1.129 kHz and then
%	re-sampled to 1 kHz. See the BKIN Dexterity User Guide for more
%	information.  Differentiating the hand position will be produce
%	significant noise (from KINARM_add_hand_kinematics.m).
%
%   Make sure the C3D loading functions from BKIN are available in Matlab
%   (www.bkintechnologies). 
%
%   The EXTRACTED fields are:
%       .Right_HandX      Right Hand Position X coordinate
%       .Right_HandY      Right Hand Position Y coordinate
%       .Right_HandXVel   Right Hand Velocity X coordinate
%       .Right_HandYVel   Right Hand Velocity Y coordinate
%       .Right_HandXAcc   Right Hand Acceleration X coordinate
%       .Right_HandYAcc   Right Hand Acceleration Y coordinate
%       .Events           Event Description
%       .Trials           Trail Description
%       .Target           Target Position, Movement, etc.
%
%   The OVERVIEW fields are:
%       .Program             Name of Task Program
%       .Protocol            Name of Task Protocol   
%       .Start               Session Start (YYYY-MM-DD HH:MM:SS)
%       .End                 Session End (YYYY-MM-DD HH:MM:SS)
%       .Tot_Time            Total Session Time (HH:MM:SS)
%       .Tot_Trials          Total Amount of Trials in Session
%       .Success             Successful Trials in Session
%       .Hand_Out            Failed Trials due to Hand out of Target
%       .Time_Out            Failed Trails due to Target Time-Out
%       .TP_Target_Direction Target Direction (clockwise/counter-cw) 
%       .TP_Target_Size      Target Size (cm)
%       .TP_Target_Speed     Target Speed (ms)
%       .TP_Follow_Time      Amount of Target Follow Time (ms)
%       .TP_Reward           Amount of Applesauce (ms)
%
%   Written by Marcel Jan de Haan on 1 August 2013 for the Vision for Action
%   Project - A collaboration of INT, Marseille & INM-6, Juelich.
%   Supervisors: Alexa Riehle, PhD (INT) & Sonja Grun, PhD (INM-6.
% 
%   **2013-08-08: Fixed data loading/output routine, added new overview
%   fields, made preliminary plot figure with Position, Velocity and
%   Acceleration as subplots.
%
%   **2013-08-01: Extracting relevant data from original Dexterit-E data files, 
%   Getting event data, time, trials and derivatives. Based on
%   BKINTechnologie's KINARM_add_hand_kinematics function.
%   -----------------------------------------------------------------------

clear all

% Enters data location, opens file-browser and allows you to choose a data
% file to extract.
cd('C:\Users\de-haan.m\Documents\BKIN Dexterit-E Data\Rhesus Macaque_Yamako_01');
[file, path] = uigetfile('*.zip', 'Pick a Dexterit-E data file');
zip_load_input = strcat(path, file);

% Zip_load is a BKINTechnology function which automatically extracts .c3d files and
% puts it into a Matlab compatible format.
data = zip_load(zip_load_input);

for ii = 1:length(data.c3d);
    L1 = data.c3d(ii).CALIBRATION.RIGHT_L1;
    L2 = data.c3d(ii).CALIBRATION.RIGHT_L2;
    L2PtrOffset = data.c3d(ii).CALIBRATION.RIGHT_PTR_ANTERIOR;
    L1Ang = data.c3d(ii).Right_L1Ang;
    L2Ang = data.c3d(ii).Right_L2Ang;
    L1Vel = data.c3d(ii).Right_L1Vel;
    L2Vel = data.c3d(ii).Right_L2Vel;
    L1Acc = data.c3d(ii).Right_L1Acc;
    L2Acc = data.c3d(ii).Right_L2Acc;
    hx = data.c3d(ii).Right_HandX;
    hy = data.c3d(ii).Right_HandY;
    ev = data.c3d(ii).EVENTS;
    tr = data.c3d(ii).TRIAL;
    tr1 = data.c3d(ii).TRIAL.TRIAL_NUM;
    ta = data.c3d(ii).TARGET_TABLE;
    
    %Function which calculates hand velocity and acceleration from the angular
    %velocities and accelerations [Adopted from BKINTechnology function 
    %'KINARM_add_hand_Kinematics.m']
    sinL1 = sin(L1Ang);
    cosL1 = cos(L1Ang);
    sinL2 = sin(L2Ang);
    cosL2 = cos(L2Ang);
    sinL2ptr = cosL2;
    cosL2ptr = -sinL2;
    
    %Hand velocities and accelerations [Adopted from BKINTechnology
    %function 'KINARM_add_hand_Kinematics.m']
    hvx = -L1*sinL1.*L1Vel - L2*sinL2.*L2Vel - L2PtrOffset*sinL2ptr.*L2Vel;
    hvy = L1*cosL1.*L1Vel + L2*cosL2.*L2Vel + L2PtrOffset*cosL2ptr.*L2Vel;
    hax = -L1 * (cosL1.*L1Vel.^2 + sinL1.*L1Acc) - L2 * ( cosL2.*L2Vel.^2 + sinL2.*L2Acc) - L2PtrOffset * ( cosL2ptr.*L2Vel.^2 + sinL2ptr.*L2Acc);
    hay = L1 * (-sinL1.*L1Vel.^2 + cosL1.*L1Acc) + L2 * (-sinL2.*L2Vel.^2 + cosL2.*L2Acc) + L2PtrOffset * (-sinL2ptr.*L2Vel.^2 + cosL2ptr.*L2Acc);
    
    %Place output into single structure
    EXTRACTED(ii).Right_HandX = hx;
    EXTRACTED(ii).Right_HandY = hy;
    EXTRACTED(ii).Right_HandXVel = hvx;
    EXTRACTED(ii).Right_HandYVel = hvy;
    EXTRACTED(ii).Right_HandXAcc = hax;
    EXTRACTED(ii).Right_HandYAcc = hay;
    EXTRACTED(ii).Events = ev;% Recheck: need to extract the labels from each c3d file and sum each event
    EXTRACTED(ii).Trials = tr;% Recheck
    EXTRACTED(ii).Target = ta;% Recheck
    
end

%clc

%Task Protocol Info 1
OVERVIEW.Program = data.c3d(1,1).EXPERIMENT.TASK_PROGRAM;
OVERVIEW.Protocol = data.c3d(1,1).EXPERIMENT.TASK_PROTOCOL;

%Session time
tlength = length(data.c3d);
t1 = char(data.c3d(1,1).TRIAL.TIME(1:8));
t2 = char(data.c3d(1,tlength).TRIAL.TIME(1:8));
tstart = [(data.c3d(1,1).TRIAL.DATE),' ', t1];
tfinish = [(data.c3d(1,1).TRIAL.DATE),' ', t2];
tstart_n = datenum(tstart,'yyyy-mm-dd HH:MM:SS');
tfinish_n = datenum(tfinish,'yyyy-mm-dd HH:MM:SS');
tsub = tfinish_n - tstart_n;
hrs = datestr(tsub, 'HH');
mins = datestr(tsub, 'MM');
secs = datestr(tsub, 'SS');
tsession = [hrs,'h ', mins, 'm ', secs 's'];
OVERVIEW.Start = tstart;
OVERVIEW.End = tfinish;
%OVERVIEW.HOURS = str2num(hrs);
%OVERVIEW.MINUTES = str2num(mins);
%OVERVIEW.SECONDS = str2num(secs);
OVERVIEW.Tot_Time = tsession;
OVERVIEW.Tot_Trials = tr1;

%Trials: Successful/Hand_Out/Time_Out
sx1=zeros(1,length(data.c3d));
sx2=zeros(1,length(data.c3d));
sx3=zeros(1,length(data.c3d));
for ii = 1:length(data.c3d);
suc2 = char(data.c3d(1,1).EVENT_DEFINITIONS.LABELS(6));
suc3 = char(data.c3d(1,1).EVENT_DEFINITIONS.LABELS(7));
suc4 = char(data.c3d(1,1).EVENT_DEFINITIONS.LABELS(8));
suc5 = cell2mat(strfind(data.c3d(ii).EVENTS.LABELS, suc2));
suc6 = cell2mat(strfind(data.c3d(ii).EVENTS.LABELS, suc3));
suc7 = cell2mat(strfind(data.c3d(ii).EVENTS.LABELS, suc4));
if suc5==1;
    sx1(ii)=1;
else
    sx1(ii)=0;
end
if suc6==1;
    sx2(ii)=1;
else
    sx2(ii)=0;
end
if suc7==1;
    sx3(ii)=1;
else
    sx3(ii)=0;
end
end
success=sum(sx1);
handout=sum(sx2);
timeout=sum(sx3);
OVERVIEW.Success = success;
OVERVIEW.Hand_Out = handout;
OVERVIEW.Time_Out = timeout;

% Task Protocol Info 2
if data.c3d(1,1).TP_TABLE.Direction == 1;
    OVERVIEW.TP_Target_Direction = 'Counter-Clockwise';
else
    OVERVIEW.TP_Target_Direction = 'Clockwise';
end
OVERVIEW.TP_Target_Size = data.c3d(1,1).TARGET_TABLE.Visual_Radius(1,1);
OVERVIEW.TP_Target_Speed = data.c3d(1,1).TP_TABLE.Target_Speed(1,1);
OVERVIEW.TP_Follow_Time = data.c3d(1,1).TP_TABLE.Delay_Reward_T2(1,1);
OVERVIEW.TP_Reward = data.c3d(1,1).TP_TABLE.Reward_T2(1,1);

% Remove all variables except 'extracted'
clearvars -except EXTRACTED OVERVIEW;
disp(OVERVIEW)

% Save to getkin_[date,time].mat file
cd('C:\getkin_saves\');
SAVE_DATE = datestr(clock,31);
save (['getkin_',SAVE_DATE(1:10),'_',SAVE_DATE(12:13),'h',SAVE_DATE(15:16),'m',SAVE_DATE(18:19)]);

% Show Plot Position, Velocity & Acceleration
set(gcf,'numbertitle','off','name', (SAVE_DATE))
for ii=1:length(EXTRACTED)
    hold on
	plot(EXTRACTED(ii).Right_HandX, EXTRACTED(ii).Right_HandY);
    ylabel('Y (m)');
    xlabel('X (m)');
    title ('Hand Paths XY(all trials)');
    subplot (2,2,1)
    plot(EXTRACTED(ii).Right_HandXVel, EXTRACTED(ii).Right_HandYVel);
%    ylabel('Y (m)');
%    xlabel('X (m)');
    title ('Hand Velocity XY (all trials)');
    subplot (2,2,2)
    plot(EXTRACTED(ii).Right_HandXAcc, EXTRACTED(ii).Right_HandYAcc);
%    ylabel('Y (m)');
%    xlabel('X (m)');
    title ('Hand Acceleration XY (all trials)');
    subplot (2,2,3)
end

end