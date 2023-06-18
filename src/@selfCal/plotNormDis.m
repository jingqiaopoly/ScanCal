function plotNormDis(obj, normDisDat, iset1, iset2,L1) %
%plot normal distance

% Get the setupNr
meta_data = obj.meta;
setupNr=zeros(1, obj.nSet);
for i=1:obj.nSet
    setupNr(i)= meta_data(i).setupNr;
end
setNr1 = setupNr(iset1);
setNr2 = setupNr(iset2);







% figure(9);clf;
centroid1 = normDisDat.centroid1; %in SOCS
%roattion matrix
scanPos = obj.scanPos;
tmp= scanPos(iset1,1:3);   
eul=tmp;eul(1)=tmp(3);eul(3)=tmp(1);
R = eul2rotm(eul,'ZYX');
%Translation matrix
T = scanPos(iset1,4:6)';  
centroid1 = R*centroid1+ repmat(T,1,size(centroid1,2));
tmp= scanPos(iset2,1:3);   
eul=tmp;eul(1)=tmp(3);eul(3)=tmp(1);
R = eul2rotm(eul,'ZYX');
%Translation matrix
T = scanPos(iset2,4:6)';  
centroid2 = normDisDat.centroid2; 
centroid2 = R*centroid2+ repmat(T,1,size(centroid2,2));
ddd = vecnorm(centroid2-centroid1,2);
figure(3);clf; plot(ddd, L1,'.'); %plot(1:size(ddd,2), ddd,'.');
xlabel('centeroid distace (mm)') ;
ylabel('normal distance (m)');

figure(12);clf;
subplot(1,2,1);
plot(1:size(L1,1), L1,'.');
xlim([1  size(L1,1)]);
ylabel('normDis (mm)');
label = sprintf('setup%d - setup%d', setNr1, setNr2);
xlabel(label);
figure(12);subplot(1,2,2);
centroid1 = centroid1.*0.001;            
% plot3(centroid1(1,:),centroid1(2,:),centroid1(3,:),'.');
scatter3(centroid1(1,:),centroid1(2,:),centroid1(3,:),3,L1);
%Mark the position of setups
pos=obj.scanPos*0.001;%-obj.m_scanPos(obj.m_refSet,:)*0.001;
for iset=1:obj.nSet
    hold on;
    plot3(pos(iset,4), pos(iset,5),pos(iset,6), 'gp', 'MarkerFaceColor','g', 'MarkerSize',15,'HandleVisibility','off');
    text(pos(iset,4)+150*0.001, pos(iset,5)+150*0.001,pos(iset,6)+2550*0.001,num2str(obj.meta(iset).setupNr),'Color','k','FontSize', 15);
end
axis equal
grid on;
titleText =sprintf('Distribution of planar patches: setup%d - setup%d', setNr1, setNr2);
title(titleText);
xlabel('X (m)') 
ylabel('Y (m)')
zlabel('Z (m)')
colorbar
caxis([-1 1])

centroid1_g= centroid1;
filename = sprintf('setup%d_setup%d', setNr1, setNr2);
% save(filename,'normDisDat','scanPos','centroid1_g','L1','setupNr' );


%plot incidences
incidence1 = normDisDat.incidence1;
incidence2 = normDisDat.incidence2;
figure(712);
subplot(1,2,1);
plot(incidence1, L1,'.');
ylabel('normDis (mm)');
xlabel('incidence1 (deg)');
subplot(1,2,2);
plot(incidence2, L1,'.');
ylabel('normDis (mm)');
xlabel('incidence2 (deg)');

%plot sigma
sigma1 = normDisDat.sigma1;
sigma2 = normDisDat.sigma2;
figure(812);
subplot(1,2,1);
plot(sigma1, L1,'.');
ylabel('normDis (mm)');
xlabel('sigma1 (mm)');
subplot(1,2,2);
plot(sigma2, L1,'.');
ylabel('normDis (mm)');
xlabel('sigma2 (mm)');

%plot pt number
pcnt1 = normDisDat.point_cnt1;
pcnt2 = normDisDat.point_cnt2;
figure(912);
subplot(1,2,1);
plot(pcnt1, L1,'.');
ylabel('normDis (mm)');
xlabel('pointCnt1');
subplot(1,2,2);
plot(pcnt2, L1,'.');
ylabel('normDis (mm)');
xlabel('pointCnt2');

%plot points on each patch
isplot = 0;
if isplot
    for i=1:normDisDat.N
        pts1 = normDisDat.pt1(i).pts;
        centroid1 = normDisDat.centroid1(:,i);
        normal1  = normDisDat.normal1(:,i);
        %roattion matrix
        tmp= scanPos(iset1,1:3);   
        eul=tmp;eul(1)=tmp(3);eul(3)=tmp(1);
        R = eul2rotm(eul,'ZYX');
        %Translation matrix
        T = scanPos(iset1,4:6)';  
        pts1 = R*pts1+ repmat(T,1,size(pts1,2));
        centroid1 = R*centroid1+T;
        normal1   = R*normal1;

        pts2 = normDisDat.pt2(i).pts;
        centroid2 = normDisDat.centroid2(:,i);
        %roattion matrix
        tmp= scanPos(iset2,1:3);   
        eul=tmp;eul(1)=tmp(3);eul(3)=tmp(1);
        R = eul2rotm(eul,'ZYX');
        %Translation matrix
        T = scanPos(iset2,4:6)';  
        pts2 = R*pts2+ repmat(T,1,size(pts2,2));
        centroid2 = R*centroid2+T;
       
        figure(913)
        clf
        plot3(pts1(1,:)*0.001,pts1(2,:)*0.001,pts1(3,:)*0.001,'.');
        hold on
        plot3(pts2(1,:)*0.001,pts2(2,:)*0.001,pts2(3,:)*0.001,'.');
        axis equal
        
        hold on
        t=-0:50;
        plot3(centroid1(1)*0.001+t*normal1(1)*0.001,centroid1(2)*0.001+t*normal1(2)*0.001,centroid1(3)*0.001+t*normal1(3)*0.001);
        hold on
        plot3(centroid2(1)*0.001,centroid2(2)*0.001,centroid2(3)*0.001,'*');
    end
end

end
