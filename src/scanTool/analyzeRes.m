% Analyze normal distance residuals
M3C2= Dis_p(:,ip);
normDisDat1 = normDisDat(iPair);
iset1 = normDisDat1.iset1;
iset2 = normDisDat1.iset2;

% range of centroid to scanner
d1 = vecnorm(normDisDat1.centroid1);
d2 = vecnorm(normDisDat1.centroid2);
figure; scatter(d1, M3C2,[],d2);
xlabel('Range_1(mm)');
ylabel('M3C2 (mm)');

%AOI
x = normDisDat1.incidence1;
c = normDisDat1.incidence2;
figure; scatter(x, M3C2,[],c);
xlabel('AOI_1 (deg)');
ylabel('M3C2 (mm)');

%pt number on each plane
x = normDisDat1.point_cnt1;
c = normDisDat1.point_cnt2;
figure; scatter(x, M3C2,[],c);
xlabel('n_{pt1}');
ylabel('d (mm)');

%plane fitting sigma
x = normDisDat1.sigma1;
c = normDisDat1.sigma2;
figure; scatter(x, M3C2,[],c);
xlabel('\sigma_1 (mm)');
ylabel('d (mm)');

% Distance of corresponding centroids
scanPos = obj.scanPos;
[ R1, T1, centroid1]= posePara2Matrix(scanPos(iset1,:),normDisDat1.centroid1);
[ R2, T2, centroid2]= posePara2Matrix(scanPos(iset2,:),normDisDat1.centroid2);
x = vecnorm(centroid1-centroid2);
d1 = vecnorm(normDisDat1.centroid1);
figure; scatter(x, M3C2,[],d1);
xlabel('centroid Distance(mm)');
ylabel('M3C2 (mm)');

% Divengence of corresponding normals
n1 = R1*normDisDat1.normal1;
n2 = R2*normDisDat1.normal2;
ang = acosd(abs(dot(n1,n2)));
x = ang;
y = (normDisDat1.point_cnt1+normDisDat1.point_cnt2)/2;
figure; scatter(x, M3C2,[],y);
xlabel('Angle between n1 and n2(deg)');
ylabel('M3C2 (mm)');

% Study the precision of M3C2
n_ref = 120;
Sig2 = (normDisDat1.sigma1.*normDisDat1.sigma1 + normDisDat1.sigma2.*normDisDat1.sigma2)/2.0 .* max((n_ref./min(normDisDat1.point_cnt1,normDisDat1.point_cnt2)),1).^2./4;
% sigDis = min(   20000./max( vecnorm(normDisDat1.centroid1),  vecnorm(normDisDat1.centroid2) ),   1);
% Sig2 = Sig2.*sigDis.*sigDis;
Sig = sqrt(Sig2);
Mabs = abs(M3C2);
figure; qqplot(M3C2);
figure; qqplot(Mabs, Sig);
figure; qqplot(M3C2'./Sig);
ylabel('Quantiles of M3C2/sigma');
title('QQ Plot of M3C2/sigma versus Standard Normal');
 ylim([-5,5]);


% iset1 = normDisDat(1).iset1;
% centroid1 = [];
% 
% 
% for i=1:size(normDisDat,2)
%     if iset1 == normDisDat(i).iset1
%         centroid1 = [centroid1 normDisDat(i).centroid1];
%     end
% end
% N = size(centroid1,2);
% res = V_n(1:N);
% [az, el, rg] = cart2polar(centroid1, ones(N,1), ProjectSettings.instance.selfCal.y_axis);



