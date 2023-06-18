function obj = calcM3C2Precision(obj)
    % Determine the precision of each normal distance according to the plane fitting sigma and number of points on plane  
    %--------------------------------------------------------------

    % Check if normal vectors are already calculated
    if isempty(obj.corePts)
        error(['The normal vectors are not calculated yet. ' ...
                'Call the function obj.calcNormalM3C2() before.']);
    end

    for iset=1:obj.nSet
        for iface=1:2
            if isempty(obj.corePts2(iface,iset).centroid)   
                continue;
            end
            centroid2 = obj.corePts2(iface,iset).centroid;
            num_pts = size(centroid2,2); 
            disSig = zeros(1,num_pts);
            
          % Copy to local variables
           sigma2 = obj.corePts2(iface,iset).sigma;
           pt_cnt2 = obj.corePts2(iface,iset).pt_cnt;
           iset_r = obj.corePts2(iface,iset).iset_r;
           iface_r = obj.corePts2(iface,iset).iface_r;
           ids = obj.corePts2(iface,iset).id;
           
          ind1=1; 
          while ~isempty(iset_r)
              % Get corresponding values at the reference setups
              iset1= iset_r(1);
              iface1= iface_r(1);
              index = find((iset_r(:)==iset1).*(iface_r(:)==iface1));
              ids1 = ids(index);
              sigma1 = obj.corePts(iface1,iset1).sigma(ids1);
              pt_cnt1 = obj.corePts(iface1,iset1).pt_cnt(ids1);
              npt = size(index,1);
              ind2= ind1+npt-1;
              
              %Calculate sigma of M3C2
              Sig2 = (sigma1.*sigma1 + sigma2(ind1:ind2).*sigma2(ind1:ind2)).* max(120./min(pt_cnt1,pt_cnt2(ind1:ind2)),1)./8.0;
              disSig(1,ind1:ind2) = sqrt(Sig2);
              iset_r(index)=[];
              iface_r(index)=[];
              ids(index)=[];
              ind1=ind2+1;
          end
          % Store weight within property data and Remove patches with NaN weights
          indN = isnan(disSig(1,:));
          obj.corePts2(iface,iset).weight = 1./(disSig(:,~indN).^2);
          obj.corePts2(iface,iset).disSig   = disSig(:,~indN);
          obj.corePts2(iface,iset).normal(:,indN)   =[];
          obj.corePts2(iface,iset).centroid(:,indN)   =[];
          obj.corePts2(iface,iset).sigma(indN)   =[];
          obj.corePts2(iface,iset).iface_r(indN)   =[];
          obj.corePts2(iface,iset).iset_r(indN)   =[];
          obj.corePts2(iface,iset).PtsDat(indN)   =[];
          obj.corePts2(iface,iset).pt_cnt(indN)   =[];
          obj.corePts2(iface,iset).id(indN)   =[];
          obj.corePts2(iface,iset).incidence(indN)   =[]; 
        end
    end        
end
   