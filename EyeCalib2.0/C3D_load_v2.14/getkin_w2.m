function [extracted] = getkin
%clear 
cd('C:\Users\de-haan.m\Documents\BKIN Dexterit-E Data\Rhesus Macaque_Yamako_01');
[file, path] = uigetfile('*.zip', 'Pick a Dexterit-E data file');
zip_load_input = strcat(path, file);
cd('C:\Users\de-haan.m\Documents\MATLAB');
data = zip_load(zip_load_input);
%clear file;
%clear path;
%clear zip_load_input;

    for ii = 1:length(data.c3d);
    end
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
    ta = data.c3d(ii).TARGET_TABLE;
    
    sinL1 = sin(L1Ang);
    cosL1 = cos(L1Ang);
    sinL2 = sin(L2Ang);
    cosL2 = cos(L2Ang);
    sinL2ptr = cosL2;
    cosL2ptr = -sinL2;
    
hvx = -L1*sinL1.*L1Vel - L2*sinL2.*L2Vel - L2PtrOffset*sinL2ptr.*L2Vel;
hvy = L1*cosL1.*L1Vel + L2*cosL2.*L2Vel + L2PtrOffset*cosL2ptr.*L2Vel;
hax = -L1 * (cosL1.*L1Vel.^2 + sinL1.*L1Acc) - L2 * ( cosL2.*L2Vel.^2 + sinL2.*L2Acc) - L2PtrOffset * ( cosL2ptr.*L2Vel.^2 + sinL2ptr.*L2Acc);
hay = L1 * (-sinL1.*L1Vel.^2 + cosL1.*L1Acc) + L2 * (-sinL2.*L2Vel.^2 + cosL2.*L2Acc) + L2PtrOffset * (-sinL2ptr.*L2Vel.^2 + cosL2ptr.*L2Acc);

    extracted.c3d.Right_HandX = hx;
    extracted.c3d.Right_HandY = hy;
    extracted.c3d.Right_HandXVel = hvx;
    extracted.c3d.Right_HandYVel = hvy;
    extracted.c3d.Right_HandXAcc = hax;
    extracted.c3d.Right_HandYAcc = hay;
    extracted.c3d.Events = ev;
    extracted.c3d.Trials = tr;
    extracted.c3d.Target = ta;

%Contents = extracted.c3d
%clear L*;
%clear s*;
%clear c*;
%clear h*;
%clear i*;
%clear ev;
%clear t*;
%clear data;
%clear Contents;

%s1 = 'y';
%s2 = 'Y';
%q = input('Save file? Y/N -> ', 's');
%save1 = strcmp (s1, q);
%save2 = strcmp (s2, q);
%if save1(1);
%    disp(s1)
%else disp('freak')
end