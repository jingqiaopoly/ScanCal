function plotResiduals(obj,normDisDat,Featurepdat,camFeatureDat,en,ef,ec)
%plotResiduals Plots the observation residuals of normal distances,
%intensity features, camera features
%
% $Author: Jing Qiao$   
% $Date: 2020/08/21 $ 

% Get the setupNr
meta_data = obj.meta;
setupNr=zeros(1, obj.nSet);
for i=1:obj.nSet
    setupNr(i)= meta_data(i).setupNr;
end
scanPos = obj.scanPos;

% Output the results in files
formatOut = 'yymmddhhMM';
timeStr = datestr(now,formatOut);
fileName = fullfile(ProjectSettings.instance.paths.result_folder,strcat(timeStr,"residualPlots"));


%Planar patches
if ~isempty(en)
     nPair = size(normDisDat,2);
     
     sumN=0;
     h1 = figure(1);
     clf;
     for iPair =1:nPair
         sumN = sumN+normDisDat(iPair).N;
     end
     if sumN<length(en)
        interval = length(en)/sumN;
        en = en(1:interval:end);
     end
     sumN = 0;
     for iPair =1:nPair
        N = normDisDat(iPair).N;
        iset1 =normDisDat(iPair).iset1; 
        centroid1 = normDisDat(iPair).centroid1; 
        %roattion matrix
        tmp= scanPos(iset1,1:3);   
        eul=tmp;eul(1)=tmp(3);eul(3)=tmp(1);
        R = eul2rotm(eul,'ZYX');
        %Translation matrix
        T = scanPos(iset1,4:6)';  
        centroid1 = R*centroid1+ repmat(T,1,size(centroid1,2));
        centroid1 = centroid1.*0.001;    
        hold on
        scatter3(centroid1(1,:),centroid1(2,:),centroid1(3,:),3,en(sumN+1:sumN+N));
        sumN=sumN+N;
     end
     %Mark the position of setups
        pos=obj.scanPos*0.001; 
        for iset=1:obj.nSet
            hold on;
            plot3(pos(iset,4), pos(iset,5),pos(iset,6), 'gp', 'MarkerFaceColor','g', 'MarkerSize',15,'HandleVisibility','off');
            text(pos(iset,4)+150*0.001, pos(iset,5)+150*0.001,pos(iset,6)+400*0.001,num2str(obj.meta(iset).setupNr),'Color','k','FontSize', 15);
        end
        axis equal
        grid on;
        std_en= std(en);
        titleText =sprintf('normalDis residuals(mm), std=%.2f mm', std_en);
        title(titleText);
        xlabel('X (m)') 
        ylabel('Y (m)')
        zlabel('Z (m)')
        colorbar
        caxis([-0.8 0.8])
        try
           savefig(h1,strcat(fileName,sprintf("_PP_%02d",h1.Number)))
        catch
            return;
        end
end


%Intensity features
if ~isempty(ef)
     Niu = Featurepdat.Niu;
     index = Niu(:,1); %observation index of the fisrt setup in each eqaution
     rng0 =  Featurepdat.rng0(index);
     az0 =  Featurepdat.az0(index);
     el0 =  Featurepdat.el0(index);
     face =  Featurepdat.face(index);
     iSet =  Featurepdat.iSet(index);
     
     % only plot the residuals of the first setup for each pair
     e_rng = ef(1:3:end); std_rng = std(e_rng); e_rng = e_rng(index);
     e_az = ef(2:3:end);  std_az = std(rad2sec(e_az));   e_az = rad2sec(e_az(index));
     e_el = ef(3:3:end);  std_el = std(rad2sec(e_el));   e_el = rad2sec(e_el(index));
   
     X = polar2cart(az0', el0', rng0',ProjectSettings.instance.selfCal.y_axis);
     sumN=0;
     h2=figure(2);
     clf;
     while find(~isnan(iSet))
         iset1 = iSet(find(~isnan(iSet), 1)); %iSet(sumN+1);
         ii =  find(iSet==iset1);
         N= size(ii,1);
         centroid1 = X(:,ii);
        %roattion matrix
        tmp= scanPos(iset1,1:3);   
        eul=tmp;eul(1)=tmp(3);eul(3)=tmp(1);
        R = eul2rotm(eul,'ZYX');
        %Translation matrix
        T = scanPos(iset1,4:6)';  
        centroid1 = R*centroid1+ repmat(T,1,size(centroid1,2));
        centroid1 = centroid1.*0.001; 
        subplot(1,3,1)
        hold on
        scatter3(centroid1(1,:),centroid1(2,:),centroid1(3,:),3,e_rng(sumN+1:sumN+N));
        subplot(1,3,2)
        hold on
        scatter3(centroid1(1,:),centroid1(2,:),centroid1(3,:),3,e_az(sumN+1:sumN+N));
        subplot(1,3,3)
        hold on
        scatter3(centroid1(1,:),centroid1(2,:),centroid1(3,:),3,e_el(sumN+1:sumN+N));
        sumN=sumN+N;
        iSet(ii)=NaN;
     end
     %Mark the position of setups
     pos=obj.scanPos*0.001; 
     subplot(1,3,1)
     hold on
     for iset=1:obj.nSet
        hold on;
        plot3(pos(iset,4), pos(iset,5),pos(iset,6), 'gp', 'MarkerFaceColor','g', 'MarkerSize',15,'HandleVisibility','off');
        text(pos(iset,4)+150*0.001, pos(iset,5)+150*0.001,pos(iset,6)+400*0.001,num2str(obj.meta(iset).setupNr),'Color','k','FontSize', 15);
     end
    axis equal
    grid on;
    xlabel('X (m)') 
    ylabel('Y (m)')
    zlabel('Z (m)')
    colorbar;
    caxis([-0.8 0.8]);
    titleText =sprintf('RNG residuals (mm), std=%.2f mm',std_rng);
    title(titleText);
    subplot(1,3,2)
    hold on
    for iset=1:obj.nSet
        hold on;
        plot3(pos(iset,4), pos(iset,5),pos(iset,6), 'gp', 'MarkerFaceColor','g', 'MarkerSize',15,'HandleVisibility','off');
        text(pos(iset,4)+150*0.001, pos(iset,5)+150*0.001,pos(iset,6)+400*0.001,num2str(obj.meta(iset).setupNr),'Color','k','FontSize', 15);
     end
    axis equal
    grid on;
    xlabel('X (m)') 
    ylabel('Y (m)')
    zlabel('Z (m)')
    colorbar;
    caxis([-20 20]);
    titleText =sprintf('AZ residuals (''''), std=%.2f''''',std_az);
    title(titleText);
    subplot(1,3,3)
     hold on
     for iset=1:obj.nSet
        hold on;
        plot3(pos(iset,4), pos(iset,5),pos(iset,6), 'gp', 'MarkerFaceColor','g', 'MarkerSize',15,'HandleVisibility','off');
        text(pos(iset,4)+150*0.001, pos(iset,5)+150*0.001,pos(iset,6)+400*0.001,num2str(obj.meta(iset).setupNr),'Color','k','FontSize', 15);
     end
    axis equal
    grid on;
    xlabel('X (m)') 
    ylabel('Y (m)')
    zlabel('Z (m)')
    colorbar;
    caxis([-20 20]);
    titleText =sprintf('EL residuals (''''), std=%.2f''''',std_el);
    title(titleText);
    try
        savefig(h2,strcat(fileName,sprintf("_IF_%02d",h2.Number)))
    catch
        return;
    end
end


%%Camera features
if ~isempty(ec)
     nC = size(camFeatureDat,2);
     e_rng0 = ec(1:5:end);  
     e_az0 = rad2sec(ec(2:5:end));  
     e_el0 = rad2sec(ec(3:5:end)); 
     e_cx0 = ec(4:5:end); 
     e_cy0 = ec(5:5:end); 
     
     sumN=0;
     h3=figure(3);
     clf;
     for iPair =1:nC
        N =camFeatureDat(iPair).N; 
        e_rng =e_rng0(1+sumN:N+sumN);
        e_az =e_az0(1+sumN:N+sumN);
        e_el =e_el0(1+sumN:N+sumN);
        e_cx =e_cx0(1+sumN:N+sumN);
        e_cy =e_cy0(1+sumN:N+sumN);
        iSet =camFeatureDat(iPair).setup; 
        XYZ = camFeatureDat(iPair).XYZ; 
        while find(~isnan(iSet))
             setNr = iSet(find(~isnan(iSet),1)); %iSet(sumN+1);
             ii =  find(iSet==setNr);
             centroid1 = XYZ(:,ii);
             iset1 =  find(setupNr==setNr);
            %roattion matrix
            tmp= scanPos(iset1,1:3);   
            eul=tmp;eul(1)=tmp(3);eul(3)=tmp(1);
            R = eul2rotm(eul,'ZYX');
            %Translation matrix
            T = scanPos(iset1,4:6)';  
            centroid1 = R*centroid1+ repmat(T,1,size(centroid1,2));
            centroid1 = centroid1.*0.001; 
            subplot(2,3,1)
            hold on
            scatter3(centroid1(1,:),centroid1(2,:),centroid1(3,:),3,e_rng(ii));
            subplot(2,3,2)
            hold on
            scatter3(centroid1(1,:),centroid1(2,:),centroid1(3,:),3,e_az(ii));
            subplot(2,3,3)
            hold on
            scatter3(centroid1(1,:),centroid1(2,:),centroid1(3,:),3,e_el(ii));
            subplot(2,3,4)
            hold on
            scatter3(centroid1(1,:),centroid1(2,:),centroid1(3,:),3,e_cx(ii));
            subplot(2,3,5)
            hold on
            scatter3(centroid1(1,:),centroid1(2,:),centroid1(3,:),3,e_cy(ii));
            iSet(ii)=NaN;
        end
       sumN=sumN+N;
     end
     %Mark the position of setups
     pos=obj.scanPos*0.001; 
    subplot(2,3,1)
    for iset=1:obj.nSet
        hold on;
        plot3(pos(iset,4), pos(iset,5),pos(iset,6), 'gp', 'MarkerFaceColor','g', 'MarkerSize',15,'HandleVisibility','off');
        text(pos(iset,4)+150*0.001, pos(iset,5)+150*0.001,pos(iset,6)+400*0.001,num2str(obj.meta(iset).setupNr),'Color','k','FontSize', 15);
     end
    axis equal
    grid on;
    xlabel('X (m)') 
    ylabel('Y (m)')
    zlabel('Z (m)')
    colorbar;
    caxis([-0.8 0.8]);
    titleText =sprintf('RNG residuals (mm), std=%.2fmm',std(e_rng0));
    title(titleText);
    subplot(2,3,2)
    for iset=1:obj.nSet
        hold on;
        plot3(pos(iset,4), pos(iset,5),pos(iset,6), 'gp', 'MarkerFaceColor','g', 'MarkerSize',15,'HandleVisibility','off');
        text(pos(iset,4)+150*0.001, pos(iset,5)+150*0.001,pos(iset,6)+400*0.001,num2str(obj.meta(iset).setupNr),'Color','k','FontSize', 15);
    end
    axis equal
    grid on;
    xlabel('X (m)') 
    ylabel('Y (m)')
    zlabel('Z (m)')
    colorbar;
    caxis([-20 20]);
    titleText =sprintf('AZ residuals (''''), std=%.2f''''',std(e_az0));
    title(titleText);
    subplot(2,3,3)
    for iset=1:obj.nSet
        hold on;
        plot3(pos(iset,4), pos(iset,5),pos(iset,6), 'gp', 'MarkerFaceColor','g', 'MarkerSize',15,'HandleVisibility','off');
        text(pos(iset,4)+150*0.001, pos(iset,5)+150*0.001,pos(iset,6)+400*0.001,num2str(obj.meta(iset).setupNr),'Color','k','FontSize', 15);
    end
    axis equal
    grid on;
    xlabel('X (m)') 
    ylabel('Y (m)')
    zlabel('Z (m)')
    colorbar;
    caxis([-20 20]);
    titleText =sprintf('EL residuals (''''), std=%.2f''''',std(e_el0));
    title(titleText);
    subplot(2,3,4)
    for iset=1:obj.nSet
        hold on;
        plot3(pos(iset,4), pos(iset,5),pos(iset,6), 'gp', 'MarkerFaceColor','g', 'MarkerSize',15,'HandleVisibility','off');
        text(pos(iset,4)+150*0.001, pos(iset,5)+150*0.001,pos(iset,6)+400*0.001,num2str(obj.meta(iset).setupNr),'Color','k','FontSize', 15);
    end
    axis equal
    grid on;
    xlabel('X (m)') 
    ylabel('Y (m)')
    zlabel('Z (m)')
    colorbar;
    caxis([-0.5 0.5]);
    titleText =sprintf('cx residuals (pix), std=%.2fpix',std(e_cx0));
    title(titleText);
    subplot(2,3,5)
    for iset=1:obj.nSet
        hold on;
        plot3(pos(iset,4), pos(iset,5),pos(iset,6), 'gp', 'MarkerFaceColor','g', 'MarkerSize',15,'HandleVisibility','off');
        text(pos(iset,4)+150*0.001, pos(iset,5)+150*0.001,pos(iset,6)+400*0.001,num2str(obj.meta(iset).setupNr),'Color','k','FontSize', 15);
    end
    axis equal
    grid on;
    xlabel('X (m)') 
    ylabel('Y (m)')
    zlabel('Z (m)')
    colorbar;
    caxis([-0.5 0.5]);
    titleText =sprintf('cy residuals (pix), std=%.2fpix',std(e_cy0));
    title(titleText);
    try
        savefig(h3,strcat(fileName,sprintf("_CF_%02d",h3.Number)))
    catch
        return;
    end
    
end


end
