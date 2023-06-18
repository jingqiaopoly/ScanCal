%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load('D:\Codes\Calibration_Tomislav\Target-Based Calibration CKA v2.0_GUI\2 Calibration\results\Z+F Imager xxxx_30-Apr-2021_15_06_27.mat');
np = length(Results.x_ap);
npos = length(Results.ImpactFactors.EOP);
nPara = size(Results.Qxx,1);
Q0 = Results.Qxx;
% Rearrange the covariance matrix as: AP, Pose, OP_xyz
index = [npos+1:npos+np  4:6 1:3 np+npos+1:nPara ];
Qxx1 = Q0(index,:);
Qxx1 = Qxx1(:,index);  
X1 = Results.Xf;
X1 = X1(index);
% Change units from m to mm
offIndex = [1 2 3 4 7  np+4:np+6 np+npos+1:nPara ];
Qxx1(offIndex,:) = Qxx1(offIndex,:)*1000*1000;
Qxx1(:,offIndex) = Qxx1(:,offIndex)*1000*1000;
iDiagonal= 1:nPara+1:nPara*nPara;
index = iDiagonal(offIndex);
Qxx1(index) = Qxx1(index)*0.001*0.001;
Qxx1 = Qxx1.*Results.postSigma*Results.postSigma;
X1(offIndex) = X1(offIndex)*1000 ;
r1= 110;






load('J:\Bonn\ZF\Export_SOCS\Result\2105110941set_0(1)_0(2)_IF.mat');
Qxx2 = Q.*sigma*sigma;
X2 = Xf;
r2 = size(obsDef,1) - size(parDef,1);

dX = X2 - X1;
QdX = Qxx1 + Qxx2;

h = rank(QdX);
F_test_value = dX'*inv(QdX)*dX/h;

F = finv(0.99,h,r1+r2);
% F =Finv(1,2,3);
% 1 - significance factor (0.95 or 0.99);
% 2 - number of parameters (h);
% 3 - cumulative redundancy of both network adjustments (nr1 +nr2) =approx.Inf

if F_test_value > F
    disp('SIGNIFICANTLY DIFFERENT');
else
    disp('NOT SIGNIFICANTLY DIFFERENT');
end