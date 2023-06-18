function obj = calcPlaneWeight(obj, do_plot)
    % Determine the weight of each corepoint according to 
    % intensity, plane hit angle, flatness, point
    % number, normal orientation, ...
    % Input:
    %     do_plot        falg: if true, for each sub-weight a plot
    %                    is drawn (default: false)
    %--------------------------------------------------------------

    % Check if normal vectors are already calculated
    if isempty(obj.corePts)
        error(['The normal vectors are not calculated yet. ' ...
                'Call the function obj.calcNormalM3C2() before.']);
    end

    % Check input
    if nargin < 2
       do_plot = false; 
    end

    for iset=1:obj.nSet
        for iface=1:2
            if isempty(obj.corePts2(iface,iset).centroid)   
                continue;
            end
            centroid2 = obj.corePts2(iface,iset).centroid;
            num_pts = size(centroid2,2); 
            weight_cp   = zeros(3,num_pts);
            
          % Copy to local variables
           sigma2 = obj.corePts2(iface,iset).sigma;
           pt_cnt2 = obj.corePts2(iface,iset).pt_cnt;
           normal2 = obj.corePts2(iface,iset).normal;
           iset_r = obj.corePts2(iface,iset).iset_r;
           iface_r = obj.corePts2(iface,iset).iface_r;
           ids = obj.corePts2(iface,iset).id;
           
          ind1=1; ind2=1;
          while ~isempty(iset_r)
              % Get corresponding values at the reference setups
              iset1= iset_r(1);
              iface1= iface_r(1);
              index = find((iset_r(:)==iset1).*(iface_r(:)==iface1));
              ids1 = ids(index);
              sigma1 = obj.corePts(iface1,iset1).sigma(ids1);
              pt_cnt1 = obj.corePts(iface1,iset1).pt_cnt(ids1);
              normal1 = obj.corePts(iface1,iset1).normal(:,ids1);
              centroid1 = obj.corePts(iface1,iset1).centroid(:,ids1);
              npt = size(index,1);
              ind2= ind1+npt-1;
              % Calculate weight
%               w_sigma = min(1./(sigma1+sigma2(ind1:ind2))/2,1,'includenan');
              w_sigma = min(2./(sigma1+sigma2(ind1:ind2)),1,'includenan');
             %  w_count = min(pt_count2(ind1:ind2),20)/20;
              w_count = min(min(pt_cnt1, pt_cnt2(ind1:ind2)),20)/20;
             
             % normal vectors at two different setups should be transformed to a common one
              if iset~=iset1
                  tmp= obj.scanPos(iset,1:3);   %
                  eul=tmp;eul(1)=tmp(3);eul(3)=tmp(1);
                  R = eul2rotm(eul,'ZYX');
                  normal2c = R*normal2; 
                  T = obj.scanPos(iset,4:6)';  
                  centroid2c = R*centroid2+T;
                  
                  tmp= obj.scanPos(iset1,1:3);   %
                  eul=tmp;eul(1)=tmp(3);eul(3)=tmp(1);
                  R = eul2rotm(eul,'ZYX');
                  normal1c = R*normal1; 
                  T = obj.scanPos(iset1,4:6)';  
                  centroid1c = R*centroid1+T;
              else
                  normal1c=normal1;
                  normal2c=normal2;
                  centroid1c =centroid1;
                  centroid2c =centroid2;
              end 
              
              w_normal= abs(asind(dot(normal1c,normal2c(:,(ind1:ind2))))/90); 
              %jing: w_normal= abs(1-asind(dot(normal1c,normal2c(:,(ind1:ind2))))/90);   %1- acosd(abs(dot(normal_vec1c,normal_vec2c(:,(ind1:ind2)))))/90;
              w_normal(w_normal< 0.2) = nan;
              
              w_proj  =1-abs(abs(dot(centroid1./vecnorm(centroid1),normal1))-sqrt(2)/2);
              
%               w_intens = min((intens1+intens2(ind1:ind2))/2.0 ,0.4)/0.4;% ones(size(w_sigma)); %
%               %Jing: add weight related to distance between centroids
              w_distance = 1-vecnorm(centroid1c-centroid2c(:,(ind1:ind2)),2)/400;
              w_distance(w_distance<0)= nan;
%               w_distance = zeros(size(w_sigma));
              
              %inc1  = acos(abs(dot(centroid1./vecnorm(centroid1),normal_vec1)))*180/pi;
              %inc2  = acos(abs(dot(centeroid2./vecnorm(centeroid2),normal_vec2)))*180/pi;
              
              % I) Overall sum
              % -------------------------------------------------------------------------
              weight_cp(1,ind1:ind2) = w_sigma+w_count+w_normal+w_proj+w_distance;
            
              % II) Optimized combination
              % -------------------------------------------------------------------------
              weight_cp(2,ind1:ind2) = w_count.*w_normal.*(w_sigma+w_proj+w_distance);

              % III) Final Weightness Combination
              % -------------------------------------------------------------------------  
             % weight_cp(3,ind1:ind2) = w_count.^2.*w_normal.^4.*(w_sigma+2*w_proj+0.5*w_intens+w_distance);
            % weight_cp(3,ind1:ind2) = w_count.^6.*w_normal.^4.*(w_sigma+2*w_proj+0.5*w_intens)*0.5;
               weight_cp(3,ind1:ind2) = w_count.^6.*w_normal.^4.*(w_sigma+2*w_proj)/3.0;
              
              iset_r(index)=[];
              iface_r(index)=[];
              ids(index)=[];
              ind1=ind2+1;
          end
          % Store weight within property data and Remove patches with NaN weights
          indN = isnan(weight_cp(1,:));
%           obj.corePts2(iface,iset).weight = weight_cp(:,~indN);
          obj.corePts2(iface,iset).weight = weight_cp(3,~indN);
          obj.corePts2(iface,iset).normal(:,indN)   =[];
          obj.corePts2(iface,iset).centroid(:,indN)   =[];
          obj.corePts2(iface,iset).sigma(indN)   =[];
          obj.corePts2(iface,iset).iface_r(indN)   =[];
          obj.corePts2(iface,iset).iset_r(indN)   =[];
          obj.corePts2(iface,iset).PtsDat(indN)   =[];
          obj.corePts2(iface,iset).pt_cnt(indN)   =[];
          obj.corePts2(iface,iset).id(indN)   =[];
          obj.corePts2(iface,iset).incidence(indN)   =[]; 
          
%           obj.corePts2(iface,iset).hz_projection(indN)   =[];
%           obj.corePts2(iface,iset).v_projection(indN)   =[];
%           obj.corePts2(iface,iset).hz_projection   = zeros(1, size( obj.corePts2(iface,iset).id,2));
%           obj.corePts2(iface,iset).v_projection   = zeros(1, size( obj.corePts2(iface,iset).id,2));
                   
          
        end
    end
        
end
   