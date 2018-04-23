clear all
data = zip_load('c:/test_ml/beauty_Fri14June.zip');
for ii = 1:length(data.c3d)
end
    L1 = data.c3d(ii).CALIBRATION.(['RIGHT_L1']);
    L2 = data.c3d(ii).CALIBRATION.(['RIGHT_L2']);
	L2PtrOffset = data.c3d(ii).CALIBRATION.(['RIGHT_PTR_ANTERIOR']);
	L1Ang = data.c3d(ii).('Right_L1Ang');
	L2Ang = data.c3d(ii).('Right_L2Ang');
	L1Vel = data.c3d(ii).('Right_L1Vel');
	L2Vel = data.c3d(ii).('Right_L2Vel');
	L1Acc = data.c3d(ii).('Right_L1Acc');
	L2Acc = data.c3d(ii).('Right_L2Acc');
    sinL1 = sin(L1Ang);
    cosL1 = cos(L1Ang);
    sinL2 = sin(L2Ang);
    cosL2 = cos(L2Ang);
    sinL2ptr = cosL2;
    cosL2ptr = -sinL2;

hx = data.c3d(ii).Right_HandX;%doesn't work!
hy = data.c3d(ii).Right_HandY;%doesn't work!
hvx = -L1*sinL1.*L1Vel - L2*sinL2.*L2Vel - L2PtrOffset*sinL2ptr.*L2Vel;
hvy = L1*cosL1.*L1Vel + L2*cosL2.*L2Vel + L2PtrOffset*cosL2ptr.*L2Vel;
hax = -L1 * (cosL1.*L1Vel.^2 + sinL1.*L1Acc) - L2 * ( cosL2.*L2Vel.^2 + sinL2.*L2Acc) - L2PtrOffset * ( cosL2ptr.*L2Vel.^2 + sinL2ptr.*L2Acc);
hay = L1 * (-sinL1.*L1Vel.^2 + cosL1.*L1Acc) + L2 * (-sinL2.*L2Vel.^2 + cosL2.*L2Acc) + L2PtrOffset * (-sinL2ptr.*L2Vel.^2 + cosL2ptr.*L2Acc);

    filtered.c3d(ii).('Right_HandX') = hx;
    filtered.c3d(ii).('Right_HandY') = hy;
    filtered.c3d(ii).('Right_HandXVel') = hvx;
    filtered.c3d(ii).('Right_HandYVel') = hvy;
    filtered.c3d(ii).('Right_HandXAcc') = hax;
    filtered.c3d(ii).('Right_HandYAcc') = hay;

clear L*;
clear s*;
clear c*;
clear h*;
