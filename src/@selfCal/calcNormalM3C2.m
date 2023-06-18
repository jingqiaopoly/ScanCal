function obj = calcNormalM3C2(obj)
    % calcNormalVectorSOCSallEqualsize---normal distance betwwen any setups
    % calculates for each selected corepoint 
    %
    %Jing: 1. The corresponding points in other setups are searched in SOCS
    % 2. The corresponding patches have the same size: 400mmx400mm
    
    Radius = ProjectSettings.instance.normDis.radius;
    Depth  = ProjectSettings.instance.normDis.depth;
    minPt  = ProjectSettings.instance.normDis.minPt;
    maxPt  = ProjectSettings.instance.normDis.maxPt;
    maxSigma = ProjectSettings.instance.normDis.maxSigma;
    Radius2 = Radius*Radius;
    do_plot_flag1 = 0;
    do_plot_flag2 = 0;
    
    obj.corePts2(2,obj.nSet) = corePt();
    
    PTDat = struct(...  % points on one patch
         'pts',[]);
   
           
    
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
          allNum = size(allPts,2);
          num_el    = size(obj.data(iface,iset).el,1);
          % Check if points are available
          if num_pts < 1
              error('No Corepoints selected. Use the function selectCorepoints before');
          end
        
        % Initialize Variables
        obj.corePts(iface,iset).normal = zeros(3,num_pts);
        obj.corePts(iface,iset).centroid   = zeros(3,num_pts);
        obj.corePts(iface,iset).sigma      = zeros(1,num_pts);
        obj.corePts(iface,iset).pt_cnt   = zeros(1,num_pts);
        obj.corePts(iface,iset).incidence   = zeros(1,num_pts);
        obj.corePts(iface,iset).PtsDat  = PTDat;
        obj.corePts(iface,iset).PtsDat(num_pts)  = PTDat;
        

        az_scanlines = nanmean(obj.data(iface,iset).az);
        diffAZ = diff(az_scanlines);   
        dAZ= mean(abs(diffAZ(abs(diffAZ)<1)));
        slice_width = ceil(Radius/(dAZ*20000)*10);
        % Loop over all Corepoints
        fprintf('Calculate normal vector for Setup %2d Face %2d: \n',iset, iface);
        % Set up iteration variables
        slice_id    = 0;
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
%             near_id=vecnorm(repmat(pt,1,allNum)-allPts) < Radius; %norm(pt)/range_factor;
            near_id = (pt(1)-allPts(1,:)).^2+(pt(2)-allPts(2,:)).^2+(pt(3)-allPts(3,:)).^2< Radius2; %sum((pt-allPts).^2)< Radius2; %
            sub_points = allPts(:,near_id);
            
%           % 1. Cut out slice, to increase computational speed
%             current_slice_id = max(round(j/num_el/slice_width*2),1);
%             if current_slice_id > slice_id
%                 slice_id = current_slice_id;
%                 from_id  = (slice_id-1)*slice_width/2*num_el+1;
%                 to_id    = (slice_id+1)*slice_width/2*num_el;
%                 pts_slice = obj.data(iface,iset).pts(:,from_id:min(to_id,size(obj.data(iface,iset).pts,2)));     
%             end
%           % 2. Cut out square to increase computational speed further
%             el_id = mod(j,num_el);
%             loc_f_id = max(1,el_id - floor(slice_width/2));
%             loc_t_id = min(num_el, el_id + round(slice_width/2))-1;
%             loc_id = repmat((loc_f_id:loc_t_id)',1,slice_width)+ ...
%                 repmat((0:slice_width-1)*num_el,loc_t_id-loc_f_id+1,1);
%             pts_square = pts_slice(:,min(loc_id(:),size(pts_slice,2))); 
%           % 3. Find neighbour points ,  draw a circle
%             pt = pts_slice(:,j-(current_slice_id-1)*round(num_el*slice_width/2));
%             near_id=vecnorm(repmat(pt,1,size(pts_square,2))-pts_square) < Radius; %norm(pt)/range_factor;
%             sub_points = pts_square(:,near_id);


            [obj.corePts(iface,iset).normal(:,i), obj.corePts(iface,iset).centroid(:,i), obj.corePts(iface,iset).sigma(:,i)] = ...
                fitplane(sub_points,do_plot_flag1);
            id_iter = 0;
            while obj.corePts(iface,iset).sigma(:,i) > maxSigma && sum(near_id) > minPt && id_iter < 5
                id_iter = id_iter + 1;
                near_id= (pt(1)-sub_points(1,:)).^2+(pt(2)-sub_points(2,:)).^2+(pt(3)-sub_points(3,:)).^2< Radius2/(1.5^id_iter)^2; %vecnorm(repmat(pt,1,size(sub_points,2))-sub_points) < Radius/(1.5^id_iter);
                sub_points = sub_points(:,near_id);
                [obj.corePts(iface,iset).normal(:,i), obj.corePts(iface,iset).centroid(:,i), obj.corePts(iface,iset).sigma(:,i)] = ...
                    fitplane(sub_points,do_plot_flag1);
            end
            if size(sub_points,2)>maxPt
                scal = ceil(size(sub_points,2)/maxPt);
                sub_points = sub_points(:,1:scal:end);
            end
            obj.corePts(iface,iset).PtsDat(i).pts= sub_points;
            obj.corePts(iface,iset).pt_cnt(i) = size(sub_points,2);
            obj.corePts(iface,iset).incidence(i) = acos(abs(dot(obj.corePts(iface,iset).centroid(:,i)./vecnorm(obj.corePts(iface,iset).centroid(:,i)),obj.corePts(iface,iset).normal(:,i))))*180/pi;
        end  
        toc
        % 4.Store the values within property values
        inz1 = find(obj.corePts(iface,iset).pt_cnt>minPt);
        inz2 = find(obj.corePts(iface,iset).sigma<maxSigma);
        inz = intersect(inz1,inz2);
%         num_pts = size(inz,2);  
        ids = ids(inz);
        %Reduce patchDat to the vaild ones
        obj.corePts(iface,iset).centroid = obj.corePts(iface,iset).centroid(:,inz);
        obj.corePts(iface,iset).normal = obj.corePts(iface,iset).normal(:,inz);
        obj.corePts(iface,iset).sigma = obj.corePts(iface,iset).sigma(inz);
        obj.corePts(iface,iset).incidence = obj.corePts(iface,iset).incidence(inz);
        obj.corePts(iface,iset).pt_cnt = obj.corePts(iface,iset).pt_cnt(inz);
        obj.corePts(iface,iset).PtsDat = obj.corePts(iface,iset).PtsDat(inz);
        obj.corePts(iface,iset).id = ids; %index of corepoints at this setup
        
%         obj.corePts(iface,iset).hz_projection   = zeros(1, size( ids,2));
%         obj.corePts(iface,iset).v_projection    = zeros(1, size( ids,2));
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
           % transform centroid coordiantes from SOCS of iset1 to global
           centroid1= patchDat1.centroid;
           normal1= patchDat1.normal;
%            tmp= obj.scanPos(iset1,1:3);    
%            eul=tmp; eul(1)=tmp(3);eul(3)=tmp(1);
%            R1 = eul2rotm(eul,'ZYX');
%            T1 = obj.scanPos(iset1,4:6)';  
%            centroid1 =R1*centroid1+T1;
           [ Rdum, Tdum, centroid1]= posePara2Matrix(obj.scanPos(iset1,:), centroid1);
           
           for iset2=iset1:obj.nSet
               face12 = obj.meta(iset2).face12;
               % transform centroid coordiantes from global to SOCS of
               % iset2: with Xg= RX+T,  X= inv(R)*(Xg-T)
               tmp= obj.scanPos(iset2,1:3);   %
               eul=tmp;eul(1)=tmp(3);eul(3)=tmp(1);
               R2 = eul2rotm(eul,'ZYX');
               T2 = obj.scanPos(iset2,4:6)'; 
               centroid = inv(R2)*(centroid1 - repmat(T2,1,size(centroid1,2))); 
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
                   
%                    az2_scanlines = nanmean(obj.data(iface2,iset2).az);
%                    el2_scanlines = nanmean(obj.data(iface2,iset2).el,2);
%                    num_el      = size(obj.data(iface2,iset2).el,1);
                   allPts =obj.data(iface2,iset2).pts;
                   allNum = size(allPts,2);
                   
%                    diffAZ2 = diff(az2_scanlines);   
%                    dAZ2= mean(abs(diffAZ2(abs(diffAZ2)<1)));
%                    slice_width = ceil(Radius/(dAZ2*20000)*10);
   
                   % Set up iteration variables
                   last_az_id  = 0;
                   last_print=0;
                   pts_slice2 =[];
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
                      pt = centroid(:,i);
%                       near_id=vecnorm(repmat(pt,1,allNum)-allPts) < Radius;
                      
%                       
%                       if iface2==1
%                          [az2_rough, el2_rough, rg2] = cart2polar(pt, ones(1,size(pt,2)));
%                       else
%                          [az2_rough, el2_rough, rg2] = cart2polar(pt, ones(1,size(pt,2))*2);
%                       end
%                     % skip corepoints, where we have no scan points in this face
%                       if min(abs(repmat(az2_rough,1,length(az2_scanlines))-az2_scanlines)) > 0.1
%                           continue;
%                       end
%                       if isnan(el2_rough)
%                           continue;
%                       end
%                       az_index_rough = find(abs(az2_scanlines-az2_rough)== ...
%                             min(abs(az2_scanlines-az2_rough)),1,'first');
%                       if isempty(pts_slice2)|| abs(last_az_id-az_index_rough)>=slice_width/4
%                           from_id = max(0,az_index_rough-round(slice_width/2))*num_el+1;
%                           to_id = min((az_index_rough+round(slice_width/2))*num_el,numP);
%                           pts_slice2 = data2Pts(:,from_id:to_id);
%                           last_az_id = az_index_rough;
%                       end
% 
%                       % Cut out square to improve speed further
%                         el_index_rough = find(abs(el2_rough-el2_scanlines)== ...
%                             min(abs(el2_rough-el2_scanlines )),1,'first');
%                         loc_f_id = max(1,el_index_rough - floor(slice_width/2));
%                         loc_t_id = min(num_el, el_index_rough + round(slice_width/2))-1;
%                         loc_id1 = repmat((loc_f_id:loc_t_id)',1,slice_width)+ ...
%                             repmat((0:slice_width-1)*num_el,loc_t_id-loc_f_id+1,1);
%                         pts_square2 = pts_slice2(:,min(loc_id1(:),size(pts_slice2,2)));

                       % Find neighbour points 
%                         size_square = size(pts_square2,2);
%                         q = repmat(pt,1,size_square)-pts_square2;
%                         n = repmat(normal(:,i),1,size_square);
                        %First reduce the point number to increase speed
                        near_id = (pt(1)-allPts(1,:)).^2+(pt(2)-allPts(2,:)).^2+(pt(3)-allPts(3,:)).^2< Radius2; %sum((pt-allPts).^2)< Radius2;%
                        sub_points = allPts(:,near_id);
                        
                        q = repmat(pt,1,size(sub_points,2))-sub_points; 
                        n = repmat(normal(:,i),1,size(sub_points,2));
                        h = dot(q,n);
                        r2 = vecnorm(q).^2-h.^2;  
                        near_id= abs(h) < Depth & r2 < Radius2; %norm(pt)/range_factor;
                        [patchDat2.normal(:,i), patchDat2.centroid(:,i), patchDat2.sigma(:,i)] = ...
                            fitplane(sub_points(:,near_id),do_plot_flag1);
                        id_iter = 0;
                        sub_points = sub_points(:,near_id);
                        while patchDat2.sigma(:,i) > maxSigma && sum(near_id) > minPt && id_iter < 5
                            id_iter = id_iter + 1;
                            q = q(:,near_id);
                            n = n(:,near_id);
                            h = h(:,near_id);
                            r2 = r2(:,near_id);
                            near_id= abs(h) < Depth/(1.5^id_iter) & r2 < Radius2/(1.5^id_iter)^2;
                            sub_points = sub_points(:,near_id);
                            [patchDat2.normal(:,i), patchDat2.centroid(:,i), patchDat2.sigma(:,i)] = ...
                                 fitplane(sub_points,do_plot_flag2);
                        end
                        if size(sub_points,2)>maxPt
                            scal = ceil(size(sub_points,2)/maxPt);
                            sub_points = sub_points(:,1:scal:end);
                        end
                        patchDat2.PtsDat(i).pts= sub_points;
                        patchDat2.pt_cnt(i) = size(sub_points,2);
                        patchDat2.incidence(i) = acos(abs(dot(patchDat2.centroid(:,i)./vecnorm(patchDat2.centroid(:,i)),patchDat2.normal(:,i))))*180/pi;

                        % Show search area and selected points
                        if do_plot_flag2
                            figure(35);clf;
                            plot3(pts_square2(1,:),pts_square2(2,:),pts_square2(3,:),'.')
                            hold on;
                            plot3(pt(1,:),pt(2,:),pt(3,:),'Marker','+','LineStyle','none','MarkerSize',30)
                            plot3([pt(1,:),pt(1,:)+normal(1,i)*3000],[pt(2,:), pt(2,:)+normal(2,i)*3000],[pt(3,:),pt(3,:)+normal(3,i)*3000],'LineWidth',3)
                            axis equal
                            ylim([pt(2)-3000,pt(2)+3000])
                            xlim([pt(1)-3000,pt(1)+3000])
                            zlim([pt(3)-3000,pt(3)+3000])
                            plot3(sub_points(1,:),sub_points(2,:),sub_points(3,:),'Marker','x','LineStyle','none','MarkerSize',8)
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
  
