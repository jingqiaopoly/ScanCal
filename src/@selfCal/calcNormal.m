function obj = calcNormal(obj)
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
        
%         patchDat.PT1Dat   = PT1Dat;
%         patchDat.PT1Dat(num_pts)   = PT1Dat;
%         patchDat.incidence   = zeros(1,num_pts);
        az_scanlines = nanmean(obj.data(iface,iset).az);
        diffAZ = diff(az_scanlines);   
        dAZ= mean(abs(diffAZ(abs(diffAZ)<1)));
        slice_width = ceil(Radius/(dAZ*20000)*10);
        % Loop over all Corepoints
        fprintf('Calculate normal vector for Setup %2d Face %2d: \n',iset, iface);
        % Set up iteration variables
        slice_id    = 0;
        last_print  = 0;
        for i=1:num_pts
            % Print Progress
            if round(i/num_pts*100) > last_print
                last_print = round(i/num_pts*100);
                fprintf('%3d %%\n',last_print);
            end
            % Define local iteration variable
            j = ids(i);
          % 1. Cut out slice, to increase computational speed
            current_slice_id = max(round(j/num_el/slice_width*2),1);
            if current_slice_id > slice_id
                slice_id = current_slice_id;
                from_id  = (slice_id-1)*slice_width/2*num_el+1;
                to_id    = (slice_id+1)*slice_width/2*num_el;
                pts_slice = obj.data(iface,iset).pts(:,from_id:min(to_id,size(obj.data(iface,iset).pts,2)));     
            end
          % 2. Cut out square to increase computational speed further
            el_id = mod(j,num_el);
            loc_f_id = max(1,el_id - floor(slice_width/2));
            loc_t_id = min(num_el, el_id + round(slice_width/2))-1;
            loc_id = repmat((loc_f_id:loc_t_id)',1,slice_width)+ ...
                repmat((0:slice_width-1)*num_el,loc_t_id-loc_f_id+1,1);
            pts_square = pts_slice(:,min(loc_id(:),size(pts_slice,2))); 
          % 3. Find neighbour points ,  draw a circle
            pt = pts_slice(:,j-(current_slice_id-1)*round(num_el*slice_width/2));
            near_id=vecnorm(repmat(pt,1,size(pts_square,2))-pts_square) < Radius; %norm(pt)/range_factor;
            sub_points = pts_square(:,near_id);
            [obj.corePts(iface,iset).normal(:,i), obj.corePts(iface,iset).centroid(:,i), obj.corePts(iface,iset).sigma(:,i)] = ...
                fitplane(sub_points,do_plot_flag1);
            id_iter = 0;
            while obj.corePts(iface,iset).sigma(:,i) > maxSigma && sum(near_id) > minPt && id_iter < 5
                id_iter = id_iter + 1;
                near_id=vecnorm(repmat(pt,1,size(sub_points,2))-sub_points) < Radius/(1.5^id_iter);
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
                   
                   az2_scanlines = nanmean(obj.data(iface2,iset2).az);
                   el2_scanlines = nanmean(obj.data(iface2,iset2).el,2);
                   num_el      = size(obj.data(iface2,iset2).el,1);
                   data2Pts =obj.data(iface2,iset2).pts;
                   numP = size(data2Pts,2);
                   
                   diffAZ2 = diff(az2_scanlines);   
                   dAZ2= mean(abs(diffAZ2(abs(diffAZ2)<1)));
                   slice_width = ceil(Radius/(dAZ2*20000)*10);
   
                   % Set up iteration variables
                   last_az_id  = 0;
                   last_print=0;
                   pts_slice2 =[];
                   % Loop over all patches
                   fprintf('Calculate normal vector for Setup %2d Face %2d to patches at Setup %2d Face %2d: \n',iset2, iface2, iset1, iface1);
 
                  for i=1:num_pts
                    % Print Progress
                      if round(i/num_pts*100) > last_print
                          last_print = round(i/num_pts*100);
                          fprintf('%3d %%\n',last_print);
                      end
                    % Find first rough region of corepoint in second scan
                      pt = centroid(:,i);
                      if iface2==1
                         [az2_rough, el2_rough, rg2] = cart2polar(pt, ones(1,size(pt,2)));
                      else
                         [az2_rough, el2_rough, rg2] = cart2polar(pt, ones(1,size(pt,2))*2);
                      end
                    % skip corepoints, where we have no scan points in this face
                      if min(abs(repmat(az2_rough,1,length(az2_scanlines))-az2_scanlines)) > 0.1
                          continue;
                      end
                      if isnan(el2_rough)
                          continue;
                      end
                      az_index_rough = find(abs(az2_scanlines-az2_rough)== ...
                            min(abs(az2_scanlines-az2_rough)),1,'first');
                      if isempty(pts_slice2)|| abs(last_az_id-az_index_rough)>=slice_width/4
                          from_id = max(0,az_index_rough-round(slice_width/2))*num_el+1;
                          to_id = min((az_index_rough+round(slice_width/2))*num_el,numP);
                          pts_slice2 = data2Pts(:,from_id:to_id);
                          last_az_id = az_index_rough;
                      end

                      % Cut out square to improve speed further
                        el_index_rough = find(abs(el2_rough-el2_scanlines)== ...
                            min(abs(el2_rough-el2_scanlines )),1,'first');
                        loc_f_id = max(1,el_index_rough - floor(slice_width/2));
                        loc_t_id = min(num_el, el_index_rough + round(slice_width/2))-1;
                        loc_id1 = repmat((loc_f_id:loc_t_id)',1,slice_width)+ ...
                            repmat((0:slice_width-1)*num_el,loc_t_id-loc_f_id+1,1);
                        pts_square2 = pts_slice2(:,min(loc_id1(:),size(pts_slice2,2)));

                       % Find neighbour points 
                        size_square = size(pts_square2,2);
                        q = repmat(pt,1,size_square)-pts_square2;
                        n = repmat(normal(:,i),1,size_square);
                        h = dot(q,n);
                        r = sqrt(vecnorm(q).^2-h.^2);
                        near_id= abs(h) < Depth & r < Radius; %norm(pt)/range_factor;
                        [patchDat2.normal(:,i), patchDat2.centroid(:,i), patchDat2.sigma(:,i)] = ...
                            fitplane(pts_square2(:,near_id),do_plot_flag1);
                        id_iter = 0;
                        sub_points = pts_square2(:,near_id);
                        while patchDat2.sigma(:,i) > maxSigma*2 && sum(near_id) > minPt && id_iter < 5
                            id_iter = id_iter + 1;
                            q = q(:,near_id);
                            n = n(:,near_id);
                            h = h(:,near_id);
                            r = r(:,near_id);
                            near_id= abs(h) < Depth & r < Radius/(1.5^id_iter);
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
   
   
   
    
   
   
   
   
     
%     patchStruct = struct(...          % structure holding vital information
%     'normal',[],'centroid',[],'sigma',[],'iface_r',[],'iset_r',[], ...   % iface_r iset_r: face and setup of the reference patch, [] at the reference patch
%     'PT1Dat',[],'pt_count',[],'ids',[],'hz_projection',[],'v_projection',[],'weight',[],'incidence',[]); 
%     PT1Dat = struct(...  % points on one patch
%     'pts',[]); 
%         
%     %Jing: Initialize the corept_data of different setups
%     %obj.m_r.m_corept_data = cal.selfcal.cls.cls_ndms_data(0);
%     obj.m_r.m_corept_data = cal.selfcal.cls.cls_ndms_data(0); %
%     for iset=1:obj.m_nSet
%         obj.m_r.m_corept_data(iset) = cal.selfcal.cls.cls_ndms_data(0);
%         patchDat = struct(patchStruct);
%         obj.m_r.m_corept_data(iset).m_p= patchDat;
%         obj.m_r.m_corept_data(iset).m_p(2)= patchDat;
%         obj.m_r.m_corept_data(iset).m_pr= patchDat;
%         obj.m_r.m_corept_data(iset).m_pr(2)= patchDat;
%     end  
% 
%    
%   
% 
%     % Set range_factor to select point depending on instrument type
%     if obj.m_r.m_config.m_instr_type == cmn.enumerators.enm_instr_type.COLIBRI
%         range_factor = obj.m_r.m_config.m_range_factor_colibri;
%         slice_width = 5000/range_factor;
%     else
%         range_factor = obj.m_r.m_config.m_range_factor_kazaar;
%         slice_width = 16000/range_factor;
%     end
%    %Jing: reduce the range_factor to choose enough neighbour for the corepoints
%       range_factor =range_factor/obj.m_r.m_config.m_rangefactor_scale;
% 
%     
%     % Prepair plot view if desired
%     if obj.m_r.m_config.m_plot_normal_calc
%         do_plot_flag1 = 1;
%         do_plot_flag2 = 2;
%     else
%         do_plot_flag1 = 0;
%         do_plot_flag2 = 0;
%     end
            
    
%     
%    % 1. Calculate the normal vectors of corepoints at all setups and all faces
%    face12 = obj.meta_data(obj.m_refSet).face12; 
%    for iset=1:obj.m_nSet
%        for iface=1:2
%           if face12(iface)==0
%               continue;
%           end
%           if iface==1
%               ids = obj.m_r.m_corept_ids(iset).id1;
%           elseif iface==2
%               ids = obj.m_r.m_corept_ids(iset).id2;
%           end
%           num_pts = size(ids,1);  %num_pts = nnz(obj.m_r.m_corept_ids(iset,:));
%           num_el    = size(obj.m_data0(iface,iset).m_phi_el,1);
%           % Check if points are available
%           if num_pts < 1
%               error('No Corepoints selected. Use the function selectHomogeneousCorepoints before');
%           end
%         
%         % Initialize Variables
%         patchDat.normal = zeros(3,num_pts);
%         patchDat.centroid   = zeros(3,num_pts);
%         patchDat.sigma      = zeros(1,num_pts);
%         patchDat.pt_count   = zeros(1,num_pts);
%         patchDat.PT1Dat   = PT1Dat;
%         patchDat.PT1Dat(num_pts)   = PT1Dat;
%         patchDat.incidence   = zeros(1,num_pts);
%         % Loop over all Corepoints
%         fprintf('Calculate normal vector for Setup %2d Face %2d: \n',iset, iface);
%         % Set up iteration variables
%         slice_id    = 0;
%         last_print  = 0;
%         for i=1:num_pts
%             % Print Progress
%             if round(i/num_pts*100) > last_print
%                 last_print = round(i/num_pts*100);
%                 fprintf('%3d %%\n',last_print);
%             end
%             % Define local iteration variable
%             j = ids(i);
%           % 1. Cut out slice, to increase computational speed
%             current_slice_id = max(round(j/num_el/slice_width*2),1);
%             if current_slice_id > slice_id
%                 slice_id = current_slice_id;
%                 from_id  = (slice_id-1)*slice_width/2*num_el+1;
%                 to_id    = (slice_id+1)*slice_width/2*num_el;
%                 pts_slice = obj.m_data0(iface,iset).m_pts(:,from_id:min(to_id,size(obj.m_data0(iface,iset).m_pts,2)));     
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
%             [patchDat.normal(:,i), patchDat.centroid(:,i), patchDat.sigma(:,i)] = ...
%                 cal.selfcal.func.fitplane(sub_points,do_plot_flag1);
%             id_iter = 0;
%             while patchDat.sigma(:,i) > obj.m_r.m_config.m_sigma_threshold && sum(near_id) > minPt && id_iter < 5
%                 id_iter = id_iter + 1;
%                 near_id=vecnorm(repmat(pt,1,size(sub_points,2))-sub_points) < Radius/(1.5^id_iter);
%                 sub_points = sub_points(:,near_id);
%                 [patchDat.normal(:,i), patchDat.centroid(:,i), patchDat.sigma(:,i)] = ...
%                     cal.selfcal.func.fitplane(sub_points,do_plot_flag1);
%             end
%             if size(sub_points,2)>maxPt
%                 scal = ceil(size(sub_points,2)/maxPt);
%                 sub_points = sub_points(:,1:scal:end);
%             end
%             patchDat.PT1Dat(i).pts= sub_points;
%             patchDat.pt_count(i) = size(sub_points,2);
%             patchDat.incidence(i) = acos(abs(dot(patchDat.centroid(:,i)./vecnorm(patchDat.centroid(:,i)),patchDat.normal(:,i))))*180/pi;
%         end  
%         % 4.Store the values within property values
%         %Jing
%         inz1 = find(patchDat.pt_count>minPt);
%         inz2 = find(patchDat.sigma<obj.m_r.m_config.m_sigma_threshold);
%         inz = intersect(inz1,inz2);
%         num_pts = size(inz,2);  
%         ids = ids(inz);
%         %Reduce patchDat to the vaild ones
%         patchDat.centroid = patchDat.centroid(:,inz);
%         patchDat.normal = patchDat.normal(:,inz);
%         patchDat.sigma = patchDat.sigma(inz);
%         patchDat.incidence = patchDat.incidence(inz);
%         patchDat.pt_count = patchDat.pt_count(inz);
%         patchDat.PT1Dat = patchDat.PT1Dat(inz);
%         patchDat.ids = ids; %index of corepoints at this setup
%         obj.m_r.m_corept_data(iset).m_p(iface)= patchDat;
%        end
%    end
    
%   % 2. Calculate the corresponding patches and normal distances from all other
%   % setups
%    for iset1=1:obj.m_nSet
%        fullcycle1 = obj.m_r.m_meta_data(iset1).fullcycle;
%        for iface1=1:2
%            patchDat1 = obj.m_r.m_corept_data(iset1).m_p(iface1);
%            if isempty(patchDat1.normal)
%                continue;
%            end
%            % transform centroid coordiantes from SOCS of iset1 to global
%            centroid1= patchDat1.centroid;
%            normal1= patchDat1.normal;
%            tmp= obj.m_scanPos(iset1,1:3);    
%            eul=tmp; eul(1)=tmp(3);eul(3)=tmp(1);
%            R1 = eul2rotm(eul,'ZYX');
%            T1 = obj.m_scanPos(iset1,4:6)';  
%            centroid1 =R1*centroid1+T1;
%            for iset2=iset1:obj.m_nSet
%                face12 = obj.m_r.m_meta_data(iset2).face12;
%                % transform centroid coordiantes from global to SOCS of
%                % iset2: with Xg= RX+T,  X= inv(R)*(Xg-T)
%                tmp= obj.m_scanPos(iset2,1:3);   %
%                eul=tmp;eul(1)=tmp(3);eul(3)=tmp(1);
%                R2 = eul2rotm(eul,'ZYX');
%                T2 = obj.m_scanPos(iset2,4:6)'; 
%                centroid = inv(R2)*(centroid1 - repmat(T2,1,size(centroid1,2))); 
%                normal = inv(R2)*normal1; 
%                num_pts = size(centroid,2);
%               
%                  
%                for iface2=1:2
%                    if iset1==iset2&&iface1==iface2 || iset1==iset2&&fullcycle1==0 || iset1==iset2&&iface1==2 || face12(iface2)==0
%                        continue; 
%                    end
%                 % Initialize Variables
%                    patchDat2 = struct(patchStruct);
%                    patchDat2.normal = zeros(3,num_pts);
%                    patchDat2.centroid   = zeros(3,num_pts);
%                    patchDat2.sigma      = zeros(1,num_pts);
%                    patchDat2.pt_count   = zeros(1,num_pts);
%                    patchDat2.incidence  = zeros(1,num_pts);
%                    patchDat2.PT1Dat   = PT1Dat;
%                    patchDat2.PT1Dat(num_pts)   = PT1Dat;
%                    
%                    az2_scanlines = nanmean(obj.m_data0(iface2,iset2).m_phi_az);
%                    el2_scanlines = nanmean(obj.m_data0(iface2,iset2).m_phi_el,2);
%                    num_el      = size(obj.m_data0(iface2,iset2).m_phi_el,1);
%                    data2Pts =obj.m_data0(iface2,iset2).m_pts;
%                    numP = size(data2Pts,2);
%                    % Set up iteration variables
%                    last_az_id  = 0;
%                    last_print=0;
%                    pts_slice2 =[];
%                    % Loop over all patches
%                    fprintf('Calculate normal vector for Setup %2d Face %2d to patches at Setup %2d Face %2d: \n',iset2, iface2, iset1, iface1);
%  
%                   for i=1:num_pts
%                     % Print Progress
%                       if round(i/num_pts*100) > last_print
%                           last_print = round(i/num_pts*100);
%                           fprintf('%3d %%\n',last_print);
%                       end
%                     % Find first rough region of corepoint in second scan
%                       pt = centroid(:,i);
%                       if iface2==1
%                          [az2_rough, el2_rough, rg2] = sys_cart2polar_hds(pt, cmn.enumerators.enm_face.I);
%                       else
%                          [az2_rough, el2_rough, rg2] = sys_cart2polar_hds(pt, cmn.enumerators.enm_face.II);
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
% 
%                        % Find neighbour points 
%                         size_square = size(pts_square2,2);
%                         q = repmat(pt,1,size_square)-pts_square2;
%                         n = repmat(normal(:,i),1,size_square);
%                         h = dot(q,n);
%                         r = sqrt(vecnorm(q).^2-h.^2);
%                         near_id= abs(h) < cut_out_depth & r < Radius; %norm(pt)/range_factor;
%                         [patchDat2.normal(:,i), patchDat2.centroid(:,i), patchDat2.sigma(:,i)] = ...
%                             cal.selfcal.func.fitplane(pts_square2(:,near_id),do_plot_flag1);
% %                         if sum(near_id)<10
% %                             near_id= abs(h) < cut_out_depth & r < norm(pt)/range_factor*2;
% %                             [patchDat2.normal(:,i), patchDat2.centroid(:,i), patchDat2.sigma(:,i)] = ...
% %                                 cal.selfcal.func.fitplane(pts_square2(:,near_id),do_plot_flag2);
% %                         end
%                         id_iter = 0;
%                         sub_points = pts_square2(:,near_id);
%                         while patchDat2.sigma(:,i) > obj.m_r.m_config.m_sigma_threshold*2 && sum(near_id) > minPt && id_iter < 5
%                             id_iter = id_iter + 1;
%                             q = q(:,near_id);
%                             n = n(:,near_id);
%                             h = h(:,near_id);
%                             r = r(:,near_id);
%                             near_id= abs(h) < cut_out_depth & r < Radius/(1.5^id_iter);
%                             sub_points = sub_points(:,near_id);
%                             [patchDat2.normal(:,i), patchDat2.centroid(:,i), patchDat2.sigma(:,i)] = ...
%                                 cal.selfcal.func.fitplane(sub_points,do_plot_flag2);
%                         end
%                         if size(sub_points,2)>maxPt
%                             scal = ceil(size(sub_points,2)/maxPt);
%                             sub_points = sub_points(:,1:scal:end);
%                         end
%                         patchDat2.PT1Dat(i).pts= sub_points;
%                         patchDat2.pt_count(i) = size(sub_points,2);
%                         patchDat2.incidence(i) = acos(abs(dot(patchDat2.centroid(:,i)./vecnorm(patchDat2.centroid(:,i)),patchDat2.normal(:,i))))*180/pi;
% 
%                         % Show search area and selected points
%                         if do_plot_flag2
%                             figure(35);clf;
%                             plot3(pts_square2(1,:),pts_square2(2,:),pts_square2(3,:),'.')
%                             hold on;
%                             plot3(pt(1,:),pt(2,:),pt(3,:),'Marker','+','LineStyle','none','MarkerSize',30)
%                             plot3([pt(1,:),pt(1,:)+normal(1,i)*3000],[pt(2,:), pt(2,:)+normal(2,i)*3000],[pt(3,:),pt(3,:)+normal(3,i)*3000],'LineWidth',3)
%                             axis equal
%                             ylim([pt(2)-3000,pt(2)+3000])
%                             xlim([pt(1)-3000,pt(1)+3000])
%                             zlim([pt(3)-3000,pt(3)+3000])
%                             plot3(sub_points(1,:),sub_points(2,:),sub_points(3,:),'Marker','x','LineStyle','none','MarkerSize',8)
%                         end
%                   end
%                    
%                 inz1 = find(patchDat2.pt_count>minPt);
%                 inz2 = find(patchDat2.sigma<obj.m_r.m_config.m_sigma_threshold);
%                 inz = intersect(inz1,inz2);
%                 
%                 patchDat2.ids = inz; %index of corresponding patch at reference setup(iset1, iface1)
%                % Reduce patchDat to the vaild ones
%                 patchDat2.centroid = patchDat2.centroid(:,inz);
%                 patchDat2.normal = patchDat2.normal(:,inz);
%                 patchDat2.sigma = patchDat2.sigma(inz);
%                 patchDat2.incidence = patchDat2.incidence(inz);
%                 patchDat2.pt_count = patchDat2.pt_count(inz);
%                 patchDat2.PT1Dat = patchDat2.PT1Dat(inz);
%                 patchDat2.iset_r =  repmat(iset1,1,size(inz,2));
%                 patchDat2.iface_r = repmat(iface1,1,size(inz,2));
%                 
%                 obj.m_r.m_corept_data(iset2).m_pr(iface2).centroid   = [obj.m_r.m_corept_data(iset2).m_pr(iface2).centroid   patchDat2.centroid ];
%                 obj.m_r.m_corept_data(iset2).m_pr(iface2).normal = [obj.m_r.m_corept_data(iset2).m_pr(iface2).normal patchDat2.normal];
%                 obj.m_r.m_corept_data(iset2).m_pr(iface2).sigma =      [obj.m_r.m_corept_data(iset2).m_pr(iface2).sigma      patchDat2.sigma ];
%                 obj.m_r.m_corept_data(iset2).m_pr(iface2).incidence =  [obj.m_r.m_corept_data(iset2).m_pr(iface2).incidence  patchDat2.incidence ];
%                 obj.m_r.m_corept_data(iset2).m_pr(iface2).pt_count   = [obj.m_r.m_corept_data(iset2).m_pr(iface2).pt_count   patchDat2.pt_count ];
%                 obj.m_r.m_corept_data(iset2).m_pr(iface2).PT1Dat     = [obj.m_r.m_corept_data(iset2).m_pr(iface2).PT1Dat     patchDat2.PT1Dat ];
%                 obj.m_r.m_corept_data(iset2).m_pr(iface2).iset_r     = [obj.m_r.m_corept_data(iset2).m_pr(iface2).iset_r     patchDat2.iset_r ];
%                 obj.m_r.m_corept_data(iset2).m_pr(iface2).iface_r    = [obj.m_r.m_corept_data(iset2).m_pr(iface2).iface_r    patchDat2.iface_r ];
%                 obj.m_r.m_corept_data(iset2).m_pr(iface2).ids        = [obj.m_r.m_corept_data(iset2).m_pr(iface2).ids        patchDat2.ids ];
%                end
%            end
%        end
%    end
%    
end
  
