% Compare raw and calibrated target centers
% RTC360 raw scanPos56: scanPos= [-0.000162000160582982,-0.00157400072882920,-1.38216747789497,-15228.490,-10498.524,0.693;
%                     -0.000407000384527294, 0.00158900113579519, 1.71120746434955,-15228.720,-10498.369,0.505];
% features = {'1','2','3','4','5','6','7','8','9','10','11','12','13','14'};

% % RTC360
% path = 'J:\Bonn\RTC360\RAW\Targets\setFace56\PP';
% 
% filePara = 'J:\Bonn\RTC360\Result\2106020936set_1(5)_1(6)_PP.mat';% 2106020936set_1(5)_1(6)_PP 2106021454set_1(5)_1(6)_TC  2106071054set_0(1)_0(2)_IF9000
% load(filePara);

% % ZF
path = 'J:\Bonn\ZF\Export_SOCS\targets\setFace34\IF_BW';
filePara = 'J:\Bonn\ZF\Export_SOCS\Result\2106192320set_0(3)_0(4)_IFestPos.mat';% 2106210942set_1(3)_1(4)_TCs34estPos  2106192320set_0(3)_0(4)_IFestPos 2106200946set_1(3)_1(4)_PPestPos
load(filePara);

% % Faro
% path = 'J:\Bonn\Faro\Targets\Calibration\s12345678Cali\PP';
% filePara = 'J:\Bonn\Faro\Result\2106152029set_0(1)_0(2)_0(3)_0(4)_0(5)_0(6)_0(7)_0(8)_PP_LichtiSys.mat';%  2106211747set_0(1)_0(2)_0(3)_0(4)_0(5)_0(6)_0(7)_0(8)_TC_LichtiSys 2106152029set_0(1)_0(2)_0(3)_0(4)_0(5)_0(6)_0(7)_0(8)_PP_LichtiSys
% load(filePara);

% Test
% % ZF
% path = 'J:\Bonn\ZF\Export_SOCS\targets\set3Test';

pointF = pointFeatures.readTCEwithface(path, 1);
features = {'1cor','2cor','3cor','4cor','5cor','6cor','7cor','8cor','9cor','10cor','11cor','12cor','13cor','14cor'};

%Merge features belong to the same setup
for iset=1:length(pointF)/2
    pointF(iset).az = [pointF(2*iset-1).az; pointF(2*iset).az ];
    pointF(iset).el = [pointF(2*iset-1).el; pointF(2*iset).el ];
    pointF(iset).rng = [pointF(2*iset-1).rng; pointF(2*iset).rng ];
%     pointF(iset).xyz = [pointF(2*iset-1).xyz; pointF(2*iset).xyz ];
    pointF(iset).face = [pointF(2*iset-1).face; pointF(2*iset).face ];
    pointF(iset).feature = [pointF(2*iset-1).feature; pointF(2*iset).feature ];
end

for iset=1:2
  [Rdum, Tdum, pointF(iset).trueGlobal]= posePara2Matrix(scanPos(iset+0,:), pointF(iset).pts);
end

for iset=1:2
    [commonF, iuf, iif]= intersect(features,pointF(iset).feature,'stable');
    pointF(iset).az = pointF(iset).az(iif);
    pointF(iset).el = pointF(iset).el(iif);
    pointF(iset).rng = pointF(iset).rng(iif);
    pointF(iset).face = pointF(iset).face(iif);
    pointF(iset).feature = pointF(iset).feature(iif);
    pointF(iset).trueGlobal= pointF(iset).trueGlobal(:,iif);
end

%1. Compare Cartesian coordinates in global system
dXYZ = pointF(2).trueGlobal - pointF(1).trueGlobal;

%2. Compare Polar coordinates in SOCS of the first scan
%2.1 Transform scan2 coordinate to scan1
[R1, T1]= posePara2Matrix(scanPos(1+0,:));
X2g = pointF(2).trueGlobal;
X21 = inv(R1)*(X2g-T1);
%2.2 Transform from cartesian1 to polar1
[az21, el21, rng21] = cart2polar(X21, pointF(1).face, ProjectSettings.instance.selfCal.y_axis);
dRHV = [rng21-pointF(1).rng';  az21-pointF(1).az';  el21-pointF(1).el'; ];
RHV = [pointF(1).rng';  pointF(1).az';  pointF(1).el'];

save('J:\Bonn\ZF\Export_SOCS\targets\setFace34\IF_BW.mat','dXYZ','dRHV','RHV');

