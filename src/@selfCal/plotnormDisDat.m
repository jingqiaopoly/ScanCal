function plotnormDisDat(obj,normDisDat)
% plotnormDisDat  
% $Author: Jing $   
% $Date: 2020/05/03 $ 
% *********************************************************** 
     cmp = lines;
     nPair = size(normDisDat,2);
     setups =NaN(nPair,4);
     numPair = 0;
     
     figure;
     for iPair=1:nPair
         N = normDisDat(iPair).N;  
         if N==0
             continue;
         end
         centroid =  normDisDat(iPair).centroid1;
         iset = normDisDat(iPair).iset1;
         setups(iPair,1) = obj.meta(iset).setupNr;
         setups(iPair,2) = obj.meta(normDisDat(iPair).iset2).setupNr; 
         setups(iPair,3) = normDisDat(iPair).N;
         setups(iPair,4) = round(mean(normDisDat(iPair).point_cnt1));
         
        %transform from SOCS of iset to global
         tmp= obj.scanPos(iset,1:3);   %
         eul=tmp;eul(1)=tmp(3);eul(3)=tmp(1);
         R = eul2rotm(eul,'ZYX');
         T = obj.scanPos(iset,4:6)'; %
         centroid = R*centroid + repmat(T,1,size(centroid,2)); 
         hold on;
         plot3(centroid(1,:)*0.001,centroid(2,:)*0.001,centroid(3,:)*0.001,'Marker','.',...
             'LineStyle','none','Color',cmp(iPair,:));
         axis equal;
         numPair=numPair+1;
     end
  %   setups(setups(:,1)==0,:) =[];
    setups(isnan(setups(:,1)),:) =[];
    C = cell(numPair,1);
    for i=1:numPair
       C(i)=cellstr(sprintf('set%d-set%d (%d-%d)',setups(i, 1),setups(i, 2), setups(i,3),setups(i,4)));
    end
    legend(C);
    legend boxoff;
    xlabel('X (m)') 
    ylabel('Y (m)')
    zlabel('Z (m)')
    
    %Mark the position of setups
    pos=obj.scanPos*0.001;%-obj.m_scanPos(obj.m_refSet,:)*0.001;
    for iset=1:obj.nSet
        hold on;
        plot3(pos(iset,4), pos(iset,5),pos(iset,6), 'gp', 'MarkerFaceColor','g', 'MarkerSize',15,'HandleVisibility','off');
        text(pos(iset,4)+150*0.001, pos(iset,5)+150*0.001,pos(iset,6)+250*0.001,num2str(obj.meta(iset).setupNr),'Color','k','FontSize', 15);
    end
     axis equal
     grid on
    
end