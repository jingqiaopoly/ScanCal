function obj = calcNormalM3C2_unfixR(obj)
    % calcNormalM3C2_unfixR
    % calculate normal distance between any setups for each selected corepoint 
    % The patch radius is adjusted according to the point density
    % $Author: Jing Qiao$   
    % $Date: 2021/08/21 $ 
      
    Radius = ProjectSettings.instance.normDis.radius;
    Depth  = ProjectSettings.instance.normDis.depth; % H/2
    minPt  = ProjectSettings.instance.normDis.minPt;
    maxPt  = ProjectSettings.instance.normDis.maxPt;
    maxSigma = ProjectSettings.instance.normDis.maxSigma;
    maxDistance = maxSigma*1.5;
    Radius2 = Radius*Radius*2*2; % maximum radius of the neighbour R = Radius*2;
%     pointNum = 100; %Use number of points to confine the radius
    do_plot_flag1 = 0;
    do_plot_flag2 = 0;
    outlierThreshold = 0.25;
    
    obj.corePts2(2,obj.nSet) = corePt();
    for iset=1:obj.nSet
        obj.corePts2(1,iset) = corePt();
        obj.corePts2(2,iset) = corePt();
    end
    
    
    PTDat = struct(...  % points on one patch
         'pts',[]);
   
    % Suppress the following warning
    id = 'vision:ransac:maxTrialsReached' ;   
    warning('off',id);
    
   % 1. Calculate the normal vectors of corepoints at all setups and all faces
   for iset=1:obj.nSet
       face12 = obj.meta(iset).face12; 
       for iface=1:2
          if face12(iface)==0
              continue;
          end
          ids = obj.corePts(iface,iset).id;
          num_pts = size(ids,1); 
          allPts = obj.data(iface,iset).pts; 
         
          % 1.1 Check if points are available
          if num_pts < 1
              error('No Corepoints selected. Use the function selectCorepoints before');
          end
        
        % 1.2 Initialize Variables
        obj.corePts(iface,iset).corept = zeros(3,num_pts);
        obj.corePts(iface,iset).normal = zeros(3,num_pts);
        obj.corePts(iface,iset).centroid   = zeros(3,num_pts);
        obj.corePts(iface,iset).sigma      = zeros(1,num_pts);
        obj.corePts(iface,iset).pt_cnt   = zeros(1,num_pts);
        obj.corePts(iface,iset).incidence   = zeros(1,num_pts);
        obj.corePts(iface,iset).PtsDat  = PTDat;
        obj.corePts(iface,iset).PtsDat(num_pts)  = PTDat;
        obj.corePts(iface,iset).radius      = zeros(1,num_pts);
        
        az_scanlines = nanmean(obj.data(iface,iset).az);
        diffAZ = diff(az_scanlines);   
        dAZ= mean(abs(diffAZ(abs(diffAZ)<1)));
        
        % Loop over all Corepoints
        fprintf('Calculate normal vector for Setup %2d Face %2d: \n',iset, iface);

        % Set up iteration variables
        last_print  = 0;
        tic
        for i=1:num_pts
            % Print Progress
            if round(i/num_pts*100) > last_print
                last_print = round(i/num_pts*100);
                fprintf('%3d %%\n',last_print);
            end
            % Define local iteration variable
            j = ids(i);
            pt = allPts(:,j);
            % 1.3 Have points within a large neighbourhood
            near_id = (pt(1)-allPts(1,:)).^2+(pt(2)-allPts(2,:)).^2+(pt(3)-allPts(3,:)).^2< Radius2; %sum((pt-allPts).^2)< Radius2; %
            sub_points = allPts(:,near_id);
            if size(sub_points,2)<minPt
                continue;
            end
            [Radius, center] = scanData.calRadius(pt, sub_points,dAZ);
            if Radius>ProjectSettings.instance.normDis.radius*2
                Radius = ProjectSettings.instance.normDis.radius*2;
            end
            obj.corePts(iface,iset).radius(i) =  Radius;
            % 1.4 Reduce the number of points by new radius
            near_id = (center(1)-sub_points(1,:)).^2+(center(2)-sub_points(2,:)).^2+(center(3)-sub_points(3,:)).^2< Radius*Radius; %sum((pt-allPts).^2)< Radius2; %
            sub_points = sub_points(:,near_id);
            if size(sub_points,2)<minPt
                continue;
            end
            ptCloudIn = pointCloud(sub_points');
            [model,inlierIndices,outlierIndices] = pcfitplane(ptCloudIn,maxDistance,'MaxNumTrials',20) ;
            if length(outlierIndices)/length(inlierIndices)>outlierThreshold||length(inlierIndices)<minPt
                continue;
            end
            % 1.5 Calculate normal vector
            [obj.corePts(iface,iset).normal(:,i),obj.corePts(iface,iset).centroid(:,i) , obj.corePts(iface,iset).sigma(:,i)] = ...
                fitplane(sub_points(:,inlierIndices),do_plot_flag1);
            if norm(center-obj.corePts(iface,iset).centroid(:,i))>0.2*Radius
                continue;
            end
            obj.corePts(iface,iset).corept(:,i) = center;
            sub_points = sub_points(:,inlierIndices);

            if size(sub_points,2)>maxPt
                scal = ceil(size(sub_points,2)/maxPt);
                sub_points = sub_points(:,1:scal:end);
            end
            obj.corePts(iface,iset).PtsDat(i).pts= sub_points;
            obj.corePts(iface,iset).pt_cnt(i) = size(sub_points,2);
            obj.corePts(iface,iset).incidence(i) = acos(abs(dot(obj.corePts(iface,iset).centroid(:,i)./vecnorm(obj.corePts(iface,iset).centroid(:,i)),obj.corePts(iface,iset).normal(:,i))))*180/pi;
        end  
        toc
        % 1.6 Store the values within property values
        inz1 = find(obj.corePts(iface,iset).pt_cnt>minPt);
        inz2 = find(obj.corePts(iface,iset).sigma<maxSigma);
        inz = intersect(inz1,inz2);
 
        ids = ids(inz);
        %Reduce patchDat to the vaild ones
        obj.corePts(iface,iset).centroid = obj.corePts(iface,iset).centroid(:,inz);
        obj.corePts(iface,iset).normal = obj.corePts(iface,iset).normal(:,inz);
        obj.corePts(iface,iset).sigma = obj.corePts(iface,iset).sigma(inz);
        obj.corePts(iface,iset).incidence = obj.corePts(iface,iset).incidence(inz);
        obj.corePts(iface,iset).pt_cnt = obj.corePts(iface,iset).pt_cnt(inz);
        obj.corePts(iface,iset).PtsDat = obj.corePts(iface,iset).PtsDat(inz);
        obj.corePts(iface,iset).id = ids; %index of corepoints at this setup
        obj.corePts(iface,iset).radius = obj.corePts(iface,iset).radius(inz);
        obj.corePts(iface,iset).corept = obj.corePts(iface,iset).corept(:,inz);

       end
   end
   
  % 2. Calculate the corresponding patches and normal distances from all other
  % setups
   for iset1=1:obj.nSet
       fullcycle1 = obj.meta(iset1).fullcycle;
       for iface1=1:2
           patchDat1 = obj.corePts(iface1,iset1);
           if isempty(patchDat1.normal)
               continue;
           end
           % 
           centroid1= patchDat1.centroid;
           normal1= patchDat1.normal;
           radius1 = patchDat1.radius;
           corept1 = patchDat1.corept;
           % transform centroid coordiantes from SOCS of iset1 to global
           [R, T, centroid1]= posePara2Matrix(obj.scanPos(iset1,:), centroid1);
           corept1 = R*corept1 + repmat(T,1,size(corept1,2)); 
           normal1 = R*normal1;
           
           
           for iset2=iset1:obj.nSet
%                if iset1~=iset2
%                    continue;
%                end
               face12 = obj.meta(iset2).face12;
               % transform centroid coordiantes from global to SOCS of
               % iset2: with Xg= RX+T,  X= inv(R)*(Xg-T)
               tmp= obj.scanPos(iset2,1:3);   %
               eul=tmp;eul(1)=tmp(3);eul(3)=tmp(1);
               R2 = eul2rotm(eul,'ZYX');
               T2 = obj.scanPos(iset2,4:6)'; 
               centroid = inv(R2)*(centroid1 - repmat(T2,1,size(centroid1,2)));
               corept = inv(R2)*(corept1 - repmat(T2,1,size(corept1,2)));
               normal = inv(R2)*normal1; 
               num_pts = size(centroid,2);
              
                 
               for iface2=1:2
                   if iset1==iset2&&iface1==iface2 || iset1==iset2&&fullcycle1==0 || iset1==iset2&&iface1==2 || face12(iface2)==0
                       continue; 
                   end
                % Initialize Variables
                   patchDat2 = corePt();
                   patchDat2.normal = zeros(3,num_pts);
                   patchDat2.centroid   = zeros(3,num_pts);
                   patchDat2.sigma      = zeros(1,num_pts);
                   patchDat2.pt_cnt   = zeros(1,num_pts);
                   patchDat2.incidence  = zeros(1,num_pts);
                   patchDat2.PtsDat   = PTDat;
                   patchDat2.PtsDat(num_pts)   = PTDat;
                   

                   allPts =obj.data(iface2,iset2).pts;
            
                   

   
                   % Set up iteration variables
                   last_print=0;
                   % Loop over all patches
                   fprintf('Calculate normal vector for Setup %2d Face %2d to patches at Setup %2d Face %2d: \n',iset2, iface2, iset1, iface1);
                   tic
                  for i=1:num_pts
                    % Print Progress
                      if round(i/num_pts*100) > last_print
                          last_print = round(i/num_pts*100);
                          fprintf('%3d %%\n',last_print);
                      end
                    % Find first rough region of corepoint in second scan
                      pt = corept(:,i);

                        %First reduce the point number to increase speed
                        near_id = (pt(1)-allPts(1,:)).^2+(pt(2)-allPts(2,:)).^2+(pt(3)-allPts(3,:)).^2< radius1(i)*radius1(i); %sum((pt-allPts).^2)< Radius2;%
                        sub_points = allPts(:,near_id);
                        if size(sub_points,2)<minPt
                            continue;
                        end
                     
                        
                        % Remove outlier
                        ptCloudIn = pointCloud(sub_points');
                        [model,inlierIndices,outlierIndices] = pcfitplane(ptCloudIn,maxDistance,'MaxNumTrials',20) ;
                        if length(outlierIndices)/length(inlierIndices)>outlierThreshold||length(inlierIndices)<minPt
                            continue;
                        end
                        sub_points = sub_points(:,inlierIndices); 
                        
                        q = repmat(pt,1,size(sub_points,2))-sub_points; 
                        n = repmat(normal(:,i),1,size(sub_points,2));
                        h = dot(q,n);
                        r2 = vecnorm(q).^2-h.^2;  
                        near_id = abs(h) < Depth & r2 < radius1(i)*radius1(i); %norm(pt)/range_factor;
                        if length(near_id)<minPt
                            continue;
                        end
                     
                        [patchDat2.normal(:,i), patchDat2.centroid(:,i), patchDat2.sigma(:,i)] = ...
                            fitplane(sub_points(:,near_id),do_plot_flag1);
                        sub_points = sub_points(:,near_id);
                        % Remove the patch if the centroid distances between two setups are larger than the defined threshold
                        if norm(patchDat2.centroid(:,i)-centroid(:,i))>radius1(i)*0.25||size(sub_points,2)<minPt
                            continue;
                        end

                        if size(sub_points,2)>maxPt
                            scal = ceil(size(sub_points,2)/maxPt);
                            sub_points = sub_points(:,1:scal:end);
                        end
                        patchDat2.PtsDat(i).pts= sub_points;
                        patchDat2.pt_cnt(i) = size(sub_points,2);
                        patchDat2.incidence(i) = acos(abs(dot(patchDat2.centroid(:,i)./vecnorm(patchDat2.centroid(:,i)),patchDat2.normal(:,i))))*180/pi;

                        % Show  selected points
                        if do_plot_flag2
                            figure(35);clf;
                            plot3(pt(1,:),pt(2,:),pt(3,:),'Marker','+','LineStyle','none','MarkerSize',30)
                            hold on
                            plot3([pt(1,:),pt(1,:)+normal(1,i)*300],[pt(2,:), pt(2,:)+normal(2,i)*300],[pt(3,:),pt(3,:)+normal(3,i)*300],'LineWidth',3)
                            axis equal
                            ylim([pt(2)-300,pt(2)+300])
                            xlim([pt(1)-300,pt(1)+300])
                            zlim([pt(3)-300,pt(3)+300])
                            plot3(sub_points(1,:),sub_points(2,:),sub_points(3,:),'Marker','x','LineStyle','none','MarkerSize',8);
                            
                            hold on
                            % plot points at the first setup
                            pts = obj.corePts(iface1,iset1).PtsDat(i).pts;
                            plot3(pts(1,:),pts(2,:),pts(3,:),'Marker','.','LineStyle','none','MarkerSize',8);
                            axis equal
                        end
                  end
                  toc
                   
                inz1 = find(patchDat2.pt_cnt>minPt);
                inz2 = find(patchDat2.sigma<maxSigma);
                inz = intersect(inz1,inz2);
                
                obj.corePts2(iface2,iset2).centroid = [obj.corePts2(iface2,iset2).centroid  patchDat2.centroid(:,inz)];
                obj.corePts2(iface2,iset2).normal   = [obj.corePts2(iface2,iset2).normal  patchDat2.normal(:,inz)];
                obj.corePts2(iface2,iset2).sigma    = [obj.corePts2(iface2,iset2).sigma  patchDat2.sigma(inz)];
                obj.corePts2(iface2,iset2).incidence= [obj.corePts2(iface2,iset2).incidence  patchDat2.incidence(inz)];
                obj.corePts2(iface2,iset2).pt_cnt   = [obj.corePts2(iface2,iset2).pt_cnt  patchDat2.pt_cnt(inz)];
                obj.corePts2(iface2,iset2).PtsDat   = [obj.corePts2(iface2,iset2).PtsDat  patchDat2.PtsDat(inz)];
                obj.corePts2(iface2,iset2).id       = [obj.corePts2(iface2,iset2).id     inz];  %index of corresponding patch at reference setup(iset1, iface1)
                obj.corePts2(iface2,iset2).iset_r   = [obj.corePts2(iface2,iset2).iset_r     repmat(iset1,1,size(inz,2))];
                obj.corePts2(iface2,iset2).iface_r  = [obj.corePts2(iface2,iset2).iface_r    repmat(iface1,1,size(inz,2)) ];
               end
           end
       end
   end
end
  
