function corePts = selectCorepoints(obj, samp_distance, isplot)
% SELECTHCOREPOINTS Select corepoints for each setup

    % Check inputs
    if nargin < 3
        isplot = 0;
    end
    if isplot
        figure(1);
        clf;
    end
    cmp = lines;
    corePts(2,obj.nSet)  = corePt();
    %calculte the corepts for each face of each setup
    for iset=1:obj.nSet
        face =obj.meta(iset).face12;
        for iface=1:2
            if(~face(iface))
                continue;
            end
            
            xyzPoints = obj.data(iface,iset).pts; 
            ptCloud = pointClouduser(xyzPoints');
            ptCloud.select('UniformSampling', samp_distance);
            index = find(ptCloud.act);
            pts = xyzPoints(:,index);
            indexNaN = find(isnan(pts(1,:)));
            index(indexNaN)=[];            
            corePts(iface,iset).id = index; 
        end        
    end
    
    % plot selcted corepoints
    if isplot
       figure(1);clf;
       numPair = 0;
       setFace=zeros(obj.nSet*2,5);
       for iset=1:obj.nSet
           for iface=1:2
               index = corePts(iface,iset).id;
               centroid = obj.data(iface,iset).pts(:,index)*0.001;
               % transform from SOCS of iset to global
               tmp= obj.scanPos(iset,1:3);   %
               eul=tmp;eul(1)=tmp(3);eul(3)=tmp(1);
               R = eul2rotm(eul,'ZYX');
               T = obj.scanPos(iset,4:6)'*0.001; %
               centroid = R*centroid + repmat(T,1,size(centroid,2));  
               hold on;
               plot3(centroid(1,:),centroid(2,:),centroid(3,:),'Marker','.',...
                   'LineStyle','none','Color',cmp((iset-1)*2+iface,:));
               numPair=numPair+1;
               setFace(numPair, 1)=  obj.meta(iset).setupNr; 
               setFace(numPair, 2)=  iface;
               setFace(numPair, 3)= size(centroid,2);
               axis equal;
           end
       end
       setFace(setFace(:,3)==0,:)=[];
       numPair = size(setFace,1);
       C = cell(numPair,1);
       for i=1:numPair
           C(i)=cellstr(sprintf('corePts: s%df%d(%d)',setFace(i, 1),setFace(i, 2),setFace(i, 3)));
       end
        legend(C);
        legend boxoff;
        xlabel('X (m)') 
        ylabel('Y (m)')
        zlabel('Z (m)')
    end
end