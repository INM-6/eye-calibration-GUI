function data_out = KINARM_add_hand_kinematics3(data.c3d)
%KINARM_ADD_HAND_KINEMATICS Calculate hand velocity and accelerations.
%	DATA_OUT = KINARM_ADD_HAND_KINEMATICS(DATA_IN) calculates the hand
%	velocities, accelerations and commanded forces from the joint
%	velocities, accelerations and motor torques for the KINARM robot.
%	These data are added to the DATA_IN structure. 
%
%	The input structure DATA_IN	should be of the form produced by 
%	DATA_IN = ZIP_LOAD. ex.
%
%   data = zip_load('183485624_2010-09-21_11-26-21.zip')
%   out = KINARM_add_hand_kinematics(data.c3d(3))
%
%   If the data is in Dexterit-E 2.3 or earlier format then the usage would
%   be:
%
%   data = c3d_load('Subject, Test_2879_1_N_tm_8_3_1.c3d')
%   out = KINARM_add_hand_kinematics(data)
%
%	The hand kinematics are calculated from joint kinematics rather than
%	just differentiating the hand position because the original joint
%	kinematics are all calculated in real-time at a 1.129 kHz and then
%	re-sampled to 1 kHz.  See the BKIN Dexterity User Guide for more
%	information.  Differentiating the hand position will be produce
%	significant noise.
%
%   The hand forces calculated here are the commanded hand forces as would
%   have been 'commanded' to the KINARM robot and are based on the torques
%   applied to the robot.  These forces do NOT include the effects robot
%   inertia, which is typically not compensated for when commanded a
%   particular force or torque.  The actual force applied at the hand can
%   be either estimated using the equations of motion or measured using a
%   Force/Torque sensor at the hand.
%
%	The new fields are in units of m/s, m/s^2 and N, and are in a global
%	coordinate system (as per Right_HandX, Left_HandY etc) and are:  
% 		.Right_HandXVel
% 		.Right_HandYVel
% 		.Right_HandXAcc
% 		.Right_HandYAcc
%		.Right_Hand_ForceCMD_X
%		.Right_Hand_ForceCMD_Y
% 		.Left_HandXVel
% 		.Left_HandYVel
% 		.Left_HandXAcc
% 		.Left_HandYAcc
%		.Left_Hand_ForceCMD_X
%		.Left_Hand_ForceCMD_X

%default output
data = zip_load('c:/test_ml/beauty_Fri14June.zip');
for ii = 1:length(data)
end

			L1 = data.c3d(ii).CALIBRATION.('RIGHT_L1');
			L2 = data.c3d(ii).CALIBRATION.('RIGHT_L2');
			L2PtrOffset = data.c3d(ii).CALIBRATION.('RIGHT_PTR_ANTERIOR');
			L1Ang = data.c3d(ii).('Right_L1Ang');
			L2Ang = data.c3d(ii).('Right_L2Ang');
			L1Vel = data.c3d(ii).('Right_L1Vel');
			L2Vel = data.c3d(ii).('Right_L2Vel');
			L1Acc = data.c3d(ii).('Right_L1Acc');
			L2Acc = data.c3d(ii).('Right_L2Acc');
			[hvx, hvy, hax, hay] = calc_hand_kinematics(L1, L2, L2PtrOffset, L1Ang, L2Ang, L1Vel, L2Vel, L1Acc, L2Acc);
			data.c3d(ii).('Right_HandXVel') = hvx;
			data.c3d(ii).('Right_HandYVel') = hvy;
			data.c3d(ii).('Right_HandXAcc') = hax;
			data.c3d(ii).('Right_HandYAcc') = hay;

%re-order the fieldnames so that the hand velocity, acceleration and
%commanded forces are with the hand position at the beginning of the field
%list 
orig_names = fieldnames(data.c3d);
temp_names = fieldnames(data.c3d);
right_names = {'Right_HandXVel'; 'Right_HandYVel'; 'Right_HandXAcc'; 'Right_HandYAcc'};

%check to see if any right-handed or left-handed fields were added to the
%output data structure
added_right_to_output = false;

for ii = 1:length(right_names)
	if isempty( strmatch(right_names{ii}, orig_names, 'exact') ) && ~isempty( strmatch(right_names{ii}, temp_names, 'exact') )
		added_right_to_output = true;
	end
end

if added_right_to_output
	% remove all of the new fields from the original list
	for ii = 1:length(right_names)
		index = strmatch(right_names{ii}, orig_names, 'exact');
		if ~isempty(index)
			orig_names(index) = [];
		end
	end
	% place the new fields right after the HandY field
	index = strmatch('Right_HandY', orig_names, 'exact');
	new_names = cat(1, orig_names(1:index), right_names, orig_names(index+1:length(orig_names)));
else
	new_names = orig_names;
end

data_out = orderfields(data.c3d, new_names);

disp('Finished adding KINARM robot hand kinematics');
    
end

%function which calculates hand velocity and acceleration from the angular
%velocities and accelerations 
function [hvx, hvy, hax, hay] = calc_hand_kinematics(L1, L2, L2PtrOffset, L1Ang, L2Ang, L1Vel, L2Vel, L1Acc, L2Acc)

sinL1 = sin(L1Ang);
cosL1 = cos(L1Ang);
sinL2 = sin(L2Ang);
cosL2 = cos(L2Ang);
sinL2ptr = cosL2;
cosL2ptr = -sinL2;

%hand velocities and accelerations
hvx = -L1*sinL1.*L1Vel - L2*sinL2.*L2Vel - L2PtrOffset*sinL2ptr.*L2Vel;
hvy = L1*cosL1.*L1Vel + L2*cosL2.*L2Vel + L2PtrOffset*cosL2ptr.*L2Vel;
hax = -L1 * (cosL1.*L1Vel.^2 + sinL1.*L1Acc) - L2 * ( cosL2.*L2Vel.^2 + sinL2.*L2Acc) - L2PtrOffset * ( cosL2ptr.*L2Vel.^2 + sinL2ptr.*L2Acc);
hay = L1 * (-sinL1.*L1Vel.^2 + cosL1.*L1Acc) + L2 * (-sinL2.*L2Vel.^2 + cosL2.*L2Acc) + L2PtrOffset * (-sinL2ptr.*L2Vel.^2 + cosL2ptr.*L2Acc);

end