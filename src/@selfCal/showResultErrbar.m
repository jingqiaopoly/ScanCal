function showResultErrbar(obj,p_kap,p_pos,p_cam,cof_kap,cof_pos,cof_cam,postSigma, Q)
% showResultErrbar  plot the bar with 3sigma of the estimated parameters
% and errors of the parameters if the true values are given
% $Author: Jing $   
% $Date: 2020/06/01 $ 
% *********************************************************** 

    isPlot =1;
    % check for used features
    feature_suffix = "";
    if obj.hasNormDis
        feature_suffix = strcat(feature_suffix,"_PP");
    end
%     % the follow two features to be ignored for PP_algorithm
%     if obj.hasFeature
%         feature_suffix = strcat(feature_suffix,"_IF");
%     end
%     if obj.hasCamFeature
%         feature_suffix = strcat(feature_suffix,"_CF");
%     end
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    figure_handles = [];
    
    std_kap = cof_kap.*postSigma;
    std_pos = cof_pos.*postSigma;
    std_cam = cof_cam.*postSigma;
    std_kap_mm = std_kap; std_kap_sec = std_kap;

    diff_kap= p_kap - obj.kap_ref;
    diff_kap = diff_kap(obj.modelIndex);
    diff_kap_mm = diff_kap; diff_kap_sec = diff_kap; 
    
    % Transform angle units to mm@10m and get estimated parameter names
    if strcmp(obj.model,'NIST2')
         name_kap = {'x1n','x1z','x2', 'x3','x4','x5n9n','x5z7','x5z9z','x6','x8x','x8y','x10','x11a','x11b','x12a','x12b'};
         unit_kap_sec = {'mm','mm','mm', 'mm','''''','''''','''''','''''','''''','''''','''''','mm','''''','''''','''''',''''''};
         unit_kap_mm = {'mm','mm','mm', 'mm','mm@10m','mm@10m','mm@10m','mm@10m','mm@10m','mm@10m','mm@10m','mm','mm@10m','mm@10m','mm@10m','mm@10m'};
         angIndex = [5 6 7 8 9 10 11 13 14 15 16]; % h_ang for x4, x5n9n...
         [C,iAngle,ib] = intersect(obj.modelIndex,angIndex);
         diff_kap_mm(iAngle) =  diff_kap_mm(iAngle)*10000; 
         diff_kap_sec(iAngle)=  rad2sec(diff_kap_sec(iAngle)); 
         std_kap_mm(iAngle)  =  std_kap_mm(iAngle)*10000;
         std_kap_sec(iAngle) =  rad2sec(std_kap_sec(iAngle)); 
    elseif strcmp(obj.model,'NIST3')
        name_kap = {'x1n','x1z','x2', 'x3','x4','x5n','x5z','x6','x5z7','x10','x1n2'};
        unit_kap_sec = {'mm','mm','mm', 'mm','''''','''''','''''','''''','''''','mm','mm'};
        unit_kap_mm = {'mm','mm','mm', 'mm','mm@10m','mm@10m','mm@10m','mm@10m','mm@10m','mm','mm'};
        angIndex = [5 6 7 8 9]; % h_ang for x4, x5n9n...
        [C,iAngle,ib] = intersect(obj.modelIndex,angIndex);
        diff_kap_mm(iAngle) =  diff_kap_mm(iAngle)*10000; 
        diff_kap_sec(iAngle)=  rad2sec(diff_kap_sec(iAngle)); 
        std_kap_mm(iAngle)  =  std_kap_mm(iAngle)*10000;
        std_kap_sec(iAngle) =  rad2sec(std_kap_sec(iAngle)); 
    elseif strcmp(obj.model,'NIST8')
        name_kap = {'x1z','x2', 'x3','x4','x5n','x6','x5z7','x1n2'};
        unit_kap_sec = {'mm','mm','mm', '''''','''''','''''','''''','mm',};
        unit_kap_mm = {'mm','mm','mm','mm@10m','mm@10m','mm@10m','mm@10m','mm'};
        angIndex = [4 5 6 7 ]; % h_ang for x4, x5n9n...
        [C,iAngle,ib] = intersect(obj.modelIndex,angIndex);
        diff_kap_mm(iAngle) =  diff_kap_mm(iAngle)*10000; 
        diff_kap_sec(iAngle)=  rad2sec(diff_kap_sec(iAngle)); 
        std_kap_mm(iAngle)  =  std_kap_mm(iAngle)*10000;
        std_kap_sec(iAngle) =  rad2sec(std_kap_sec(iAngle)); 
    elseif strcmp(obj.model,'NIST9')
        name_kap = {'x1z','x2', 'x3','x4','x5n','x6','x5z7','x1n2','x10'};
        unit_kap_sec = {'mm','mm','mm', '''''','''''','''''','''''','mm','mm'};
        unit_kap_mm = {'mm','mm','mm','mm@10m','mm@10m','mm@10m','mm@10m','mm','mm'};
        angIndex = [4 5 6 7 ]; % h_ang for x4, x5n9n...
        [C,iAngle,ib] = intersect(obj.modelIndex,angIndex);
        diff_kap_mm(iAngle) =  diff_kap_mm(iAngle)*10000; 
        diff_kap_sec(iAngle)=  rad2sec(diff_kap_sec(iAngle)); 
        std_kap_mm(iAngle)  =  std_kap_mm(iAngle)*10000;
        std_kap_sec(iAngle) =  rad2sec(std_kap_sec(iAngle)); 
    elseif strcmp(obj.model,'NIST10')
        name_kap = {'x10','x2', 'x1z','x3','x7','x6','x1n','x4','x5n','x5z'};
        unit_kap_sec = {'mm','mm','mm', 'mm','''''','''''',    'mm','''''','''''',''''''};
        unit_kap_mm =  {'mm','mm','mm', 'mm','mm@10m','mm@10m','mm','mm@10m','mm@10m','mm@10m'};
        angIndex = [ 5 6 8 9 10 ]; % h_ang  
        [C,iAngle,ib] = intersect(obj.modelIndex,angIndex);
        diff_kap_mm(iAngle) =  diff_kap_mm(iAngle)*10000; 
        diff_kap_sec(iAngle)=  rad2sec(diff_kap_sec(iAngle)); 
        std_kap_mm(iAngle)  =  std_kap_mm(iAngle)*10000;
        std_kap_sec(iAngle) =  rad2sec(std_kap_sec(iAngle)); 
    elseif strcmp(obj.model,'Lichti')
        name_kap =     {'a0','a1', 'a2','a3','a4','a5','a6','a7','a8','b1','b2','b3', 'b4','b5','b6','b7','c0','c1','c2','c3','c4'};
        unit_kap_sec = {'mm','1','mm', 'mm','mm','mm','mm','mm','mm','''''','''''','''''','''''','1','''''','''''','''''','1','''''','''''',''''''};
        unit_kap_mm =  {'mm','1','mm', 'mm','mm','mm','mm','mm','mm','mm@10m','mm@10m','mm@10m','mm@10m','1','mm@10m','mm@10m','mm@10m','1','mm@10m','mm@10m','mm@10m'};
        angIndex = [ 10 11 12 13 15 16 17 19 20 21 ]; % h_ang  
        [C,iAngle,ib] = intersect(obj.modelIndex,angIndex);
        diff_kap_mm(iAngle) =  diff_kap_mm(iAngle)*10000; 
        diff_kap_sec(iAngle)=  rad2sec(diff_kap_sec(iAngle)); 
        std_kap_mm(iAngle)  =  std_kap_mm(iAngle)*10000;
        std_kap_sec(iAngle) =  rad2sec(std_kap_sec(iAngle));
    end
    name_kap = name_kap(obj.modelIndex);
    unit_kap_sec = unit_kap_sec(obj.modelIndex);
    unit_kap_mm = unit_kap_mm(obj.modelIndex);
    
    fprintf('\n Model parameter Differences (Estimation vs. Nominal)\n');
    for i=1:obj.np
        fprintf( [char(name_kap(i)) ,':\t %12.2f','\t',char(unit_kap_sec(i)),'\n'], diff_kap_sec(i));
    end
      
    fprintf(' Pos parameters: \n');
    for i=1:obj.nSet %initial values of the translation parameters
        a=0;b=0;c=0;dx=0;dy=0;dz=0;%a,b,c--rotation angle around x,y,z axis; dx,dy,cz---offsets

        if(i<obj.refSet)
            a = p_pos(6*i-5);   b = p_pos(6*i-4);   c = p_pos(6*i-3);
            dx= p_pos(6*i-2);   dy= p_pos(6*i-1);   dz= p_pos(6*i-0);
        elseif(i>obj.refSet)
            a = p_pos(6*i-5-6); b = p_pos(6*i-4-6); c = p_pos(6*i-3-6);
            dx= p_pos(6*i-2-6); dy= p_pos(6*i-1-6); dz= p_pos(6*i-0-6);
        end

        if(i~=obj.refSet)
            fprintf(' Setup %d: \t  %11.2f \t   %11.2f\t   %11.2f\t ('''')  \t %11.2f \t   %11.2f\t   %11.2f \t (mm)\n',...
            i,  rad2sec(a),rad2sec(b),rad2sec(c),dx,dy,dz);
        end
     end
     
    
     diffPos = zeros(obj.nSet-1,6);
     for iset=1:obj.nSet-1
        diffPos(iset,:) = p_pos(iset*6-5: iset*6)'-obj.pos_ref(iset*6-5: iset*6)';
     end
    


    if isPlot
        %1. Plot the std of LSM parameters
        figure_handles = [figure_handles,figure(11)];
        clf;
        x = 1:obj.np;
        y = diff_kap_mm;
        err = std_kap_mm;
        errorbar(y,err.*3,'*','MarkerSize',10,...
        'MarkerEdgeColor','red','MarkerFaceColor','red','LineWidth',2);
        set(gca,'xtick',[1:obj.np],'xticklabel',name_kap);
        ylabel( [obj.model,' correction (mm/mm@10m)' ]);
        grid on
        xtickName = name_kap';


        ylim([-1.5 1.5]);
        yLimits = get(gca,'YLim');
        for i=1:obj.np
           top = sprintf('%.2f', y(i));
           text(x(i)-0.2, yLimits(2)-(yLimits(2)-yLimits(1))*0.02, top); 
        end

        for i=1:length(iAngle)
           top = sprintf('%.2f''''', diff_kap_sec(iAngle(i)));
           text(x(iAngle(i))-0.2, yLimits(2)+(yLimits(2)-yLimits(1))*0.05, top);
        end

        showObsParaInfo(obj, yLimits);
        xlim([0 obj.np+1]);
        grid on;


        %2. Plot the std of pose parameters 
        std_pos_sec = std_pos;  diff_pos_sec = diffPos;
        if ~isempty(cof_pos)         
            figure_handles = [figure_handles,figure(21)];
            clf;
            y=reshape(diffPos',(obj.nSet-1)*6,1);
            x=zeros(obj.npos,1);
            x(1:obj.npos)=1:obj.npos;
            err = std_pos;
            %pose parameters
            parDef = obj.parDef(obj.parDef(:,1)==2,:);
            iRot = parDef(:,2)<4;
            err(iRot) = err(iRot)*10*1000;%mm@10m 
            std_pos_sec(iRot)  = std_pos_sec(iRot)/pi*180*3600;
            diff_pos_sec=reshape(diff_pos_sec',(obj.nSet-1)*6,1);
            diff_pos_sec(iRot) = diff_pos_sec(iRot)/pi*180*3600;
            y=y(obj.posIndex);
            y0=y;
            y(iRot) = y(iRot)*10*1000;%mm@10m 
           errorbar(y,err.*3,'*','MarkerSize',10,...
        'MarkerEdgeColor','red','MarkerFaceColor','red','LineWidth',2);        
            names='';
            for i=1:obj.npos
                ii=parDef(i,2);
                setupNr = obj.meta(parDef(i,3)).setupNr;
                switch ii
                    case 1
                        name=sprintf(' rotX_{%d}',setupNr);
                    case 2
                        name=sprintf(' rotY_{%d}',setupNr);
                    case 3
                        name=sprintf(' rotZ_{%d}',setupNr);
                    case 4
                        name=sprintf(' dX_{%d}', setupNr);
                    case 5
                        name=sprintf(' dY_{%d}',setupNr);
                    case 6
                        name=sprintf(' dZ_{%d}',setupNr);
                end
                names =strcat(names,name);
            end
            names=split(names);
            names(1)=[];
            xtickName = [xtickName; names];
            set(gca,'xtick',[1:obj.npos],'xticklabel',names);
            ylabel('Pose correction (mm/mm@10m)');
            ylim([-1.5 1.5]);
            yLimits = get(gca,'YLim');
            for i=1:obj.npos
               top = sprintf('%.2f', y(i));
               text(x(i)-0.5, yLimits(2)-(yLimits(2)-yLimits(1))*0.05, top); 

               if(iRot(i))
                   top = sprintf('%.2f''''', rad2sec(y0(i)));
                   text(x(i)-0.5, yLimits(2)+(yLimits(2)-yLimits(1))*0.05, top);
               end
            end
            xlim([0 size(err,1)+1]);
            grid on;
        end

        %% 3.  Plot std and cof of camera parameters
        diff_cam=[];
        if ~isempty(std_cam)
            nC = obj.ncam/length(obj.camIndex);
            nCam = nnz(obj.isEvalcam)*nC;
            diff_cam=p_cam-obj.cam_ref;
            isEvalCamAll = repmat(obj.isEvalcam,1,nC);
            diff_cam = diff_cam(find(isEvalCamAll));
            figure_handles = [figure_handles,figure(31)];
            clf;
            x=zeros(nCam,1);
            x(1:nCam)=1:nCam;
            err = std_cam(1:nCam);
            %camera parameters defination
            parDef = obj.parDef(obj.parDef(:,1)==3,:);
            parDef = parDef(parDef(:,2)<11,:);
            iRot = parDef(:,2)>3&parDef(:,2)<7;
            err(iRot) = sec2rad(err(iRot))*10*1000;%mm@10m 
            y = diff_cam;
            y(iRot) = y(iRot)*10*1000;%mm@10m 
            % bar(x,err);
              errorbar(y,err.*3,'*','MarkerSize',10,...
        'MarkerEdgeColor','red','MarkerFaceColor','red','LineWidth',2);        
            names='';
            for i=1:nCam
                ii=parDef(i,2);
                iCam = parDef(i,3);
                switch ii
                    case 1
                        name=sprintf(' x0s_{%d}',iCam);
                    case 2
                        name=sprintf(' y0s_{%d}',iCam);
                    case 3
                        name=sprintf(' z0s_{%d}',iCam);
                    case 4
                        name=sprintf(' dHz_{%d}',iCam);
                    case 5
                        name=sprintf(' El_{%d}',iCam);
                    case 6
                        name=[' \gamma' sprintf('_{%d}',iCam) ] ;
                end
                names =strcat(names,name);
            end
            names=split(names);
            names(1)=[];
            xtickName = [xtickName; names];
            set(gca,'xtick',[1:nCam],'xticklabel',names);
            ylabel('Camera correction (mm/mm@10m)');
    %         ylim([0 0.3]);
            yLimits = get(gca,'YLim');
            for i=1:nCam
               top = sprintf('%.2f', y(i));
               text(x(i)-0.5, yLimits(2)-(yLimits(2)-yLimits(1))*0.05, top); 

               if(iRot(i))
                   top = sprintf('%.2f''''', rad2sec(diff_cam(i)));
                   text(x(i)-0.5, yLimits(2)+(yLimits(2)-yLimits(1))*0.05, top);
               end
            end
            showObsParaInfo(obj, yLimits);
            xlim([0 size(err,1)+1]);
            grid on;
        end

    %    % 4. Plot Correlation matrix
        Q1=Q(1:obj.np+obj.npos+obj.ncam, 1:obj.np+obj.npos+obj.ncam);
        [C,qii]=Q2Corr(Q1);   
        
        figure_handles = [figure_handles,figure(3)];
        clf;
        %Set the values within threshold as 0
%         C(abs(C)<0.5)=0;
        ShowMatrixHere(C);
        xtickNames = xtickName;
        xticks(1:size(xtickNames,1));
        xticklabels(xtickNames);
        yticks(1:size(xtickNames,1));
        yticklabels(xtickNames);
        hold on
        line([0 obj.np+obj.npos+obj.ncam+0.5],[obj.np+0.5 obj.np+0.5] );
        line([0 obj.np+obj.npos+obj.ncam+0.5],[obj.np+obj.npos+0.5 obj.np+obj.npos+0.5] );
        line([obj.np+0.5 obj.np+0.5],[0 obj.np+obj.npos+obj.ncam+0.5] );
        line([obj.np+obj.npos+0.5 obj.np+obj.npos+0.5],[0 obj.np+obj.npos+obj.ncam+0.5] );
    end
%     
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Output the results in files
    formatOut = 'yymmddhhMM';
    timeStr = datestr(now,formatOut);
    setStr='set';
    for iset=1:obj.nSet
        jobNr = obj.meta(iset).jobNr;
        setupNr = obj.meta(iset).setupNr;
        setStr =  strcat(setStr,'_',int2str(jobNr),'(',int2str(setupNr),')');
    end
    fileName = strcat(timeStr,setStr);
    fileName = fullfile(ProjectSettings.instance.paths.result_folder,strcat(fileName,feature_suffix));
    parDef = obj.parDef;
    sigma = postSigma;
    obsDef=obj.obsDef;
    diffPos = diffPos';
    %
    scanPos = obj.scanPos;
    for iset=1:obj.nSet
        if iset>obj.refSet
            scanPos(iset,:) = p_pos(iset*6-12+1:iset*6-12+6)';
        elseif iset<obj.refSet
            scanPos(iset,:) = p_pos(iset*6-6+1:iset*6-6+6)';
        end
    end
    Xf = obj.parVal;
    save(fileName,'p_kap', 'p_pos','p_cam','std_kap','std_pos','std_cam','cof_kap','cof_pos','cof_cam','diff_kap','diffPos','diff_cam','parDef','Q','sigma','obsDef','scanPos','Xf','diff_kap_sec','std_kap_sec'); 
    
    
    save_fig = true;
    % Save figures
    if save_fig
        formatOut = 'yymmddhhMM';
        timeStr = datestr(now,formatOut);
        fileName = fullfile(ProjectSettings.instance.paths.result_folder,strcat(timeStr,"_showResultErrbar"));
        for h = figure_handles
            savefig(h,strcat(fileName,sprintf("_%02d",h.Number)))
        end
    end
end