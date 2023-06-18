function obj = selectPlaneAZ(obj )
    %selectPlaneAZ Select the plane patches within the defined azimuth angle range

    azCut = ProjectSettings.instance.normDis.azCut; % e.g., azCut = [0 30; 150 180];
    if (azCut ==[0 180])
        return;
    end
    %initialize 
    cmp = lines;
    plot =1;
    numPair=0;
    setFace=zeros(obj.nSet*2+1,5);
    if plot
        figure(8);clf;
    end

    azCut = azCut/180*pi;
    azCut2 = azCut-pi;
    azCut = [azCut; azCut2];
      for iset=1:obj.nSet
         for iface=1:2
            if isempty(obj.corePts2(iface,iset).centroid)   
                continue;
            end
            % Define local variables
            centroid = obj.corePts2(iface,iset).centroid;   
            % Transfrom to polar and select patches only by the az of the
            % second setup
            [az, el, rg] = cart2polar(centroid, ones(size(centroid,2),1).*iface,ProjectSettings.instance.selfCal.y_axis);
            ind =[];
            for i=1:size(azCut,1)
                if azCut(i,1)<azCut(i,2)
                   index1 = find(az>azCut(i,1)&az<azCut(i,2));
                else
                   index1 = find(az>azCut(i,1)|az<azCut(i,2));
                end
                ind = [ind index1];
            end
            
            % plot selcted corepoints
            if plot
               figure(8);
               hold on;
               centroid = obj.corePts2(iface,iset).centroid(:,ind)*0.001;
               %transform from SOCS of iset to global
               tmp= obj.scanPos(iset,1:3);   %
               eul=tmp;eul(1)=tmp(3);eul(3)=tmp(1);
               R = eul2rotm(eul,'ZYX');
               T = obj.scanPos(iset,4:6)'*0.001; %
               centroid = R*centroid + repmat(T,1,size(centroid,2));           
               plot3(centroid(1,:),centroid(2,:),centroid(3,:),'Marker','.',...
                   'LineStyle','none','Color',cmp((iset-1)*2+iface,:));
               numPair=numPair+1;
               setFace(numPair, 2)=  obj.meta(iset).setupNr;
               setFace(numPair, 3)=  iface;
               setFace(numPair, 4)= size(centroid,2);
               setFace(numPair, 5)= int64(mean(obj.corePts2(iface,iset).pt_cnt(ind)));
               setFace(numPair, 6)= 0;
               axis equal;
            end
            
            obj.corePts2(iface,iset).centroid = obj.corePts2(iface,iset).centroid(:,ind);
            obj.corePts2(iface,iset).normal = obj.corePts2(iface,iset).normal(:,ind);
            obj.corePts2(iface,iset).weight = obj.corePts2(iface,iset).weight(:,ind);
            obj.corePts2(iface,iset).sigma = obj.corePts2(iface,iset).sigma(ind);
            obj.corePts2(iface,iset).iface_r = obj.corePts2(iface,iset).iface_r(ind);
            obj.corePts2(iface,iset).iset_r = obj.corePts2(iface,iset).iset_r(ind);
            obj.corePts2(iface,iset).PtsDat = obj.corePts2(iface,iset).PtsDat(ind);
            obj.corePts2(iface,iset).pt_cnt = obj.corePts2(iface,iset).pt_cnt(ind);
            obj.corePts2(iface,iset).id = obj.corePts2(iface,iset).id(ind);
            obj.corePts2(iface,iset).incidence = obj.corePts2(iface,iset).incidence(ind);
            
         end
      end

   
    C = cell(numPair,1);
    for i=1:numPair
        if setFace(i, 3)
            if setFace(i, 6)
                C(i)=cellstr(sprintf('all    s%d-s%df%d(%d-%d)', ...
                    setFace(i, 1),setFace(i, 2),setFace(i, 3),setFace(i, 4),setFace(i, 5)));
            else
                C(i)=cellstr(sprintf('select s%df%d(%d-%d)', ...
                   setFace(i, 2),setFace(i, 3),setFace(i, 4),setFace(i, 5)));
            end
        else
          C(i)=cellstr(sprintf('s%d-s%d  (%d-%d)',setFace(i, 1),setFace(i, 2),setFace(i, 4),setFace(i, 5)));
        end
    end
    legend(C);
    legend boxoff;
    xlabel('X (m)') 
    ylabel('Y (m)')
    zlabel('Z (m)')
    
    % Mark the position of setups
    pos=obj.scanPos*0.001;%-obj.m_scanPos(obj.m_refSet,:)*0.001;
    for iset=1:obj.nSet
        hold on;
        plot3(pos(iset,4), pos(iset,5),pos(iset,6), 'gp', 'MarkerFaceColor','g', 'MarkerSize',15,'HandleVisibility','off');
        text(pos(iset,4)+150*0.001, pos(iset,5)+150*0.001,pos(iset,6)+150*0.001,num2str(obj.meta(iset).setupNr),'Color','k','FontSize', 15);
    end
end