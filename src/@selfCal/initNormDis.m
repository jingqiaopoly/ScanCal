function  [normDisDat_new] = initNormDis(obj)  %,normDisDat
% initNormDis: Store the dataset related to normal distance 
% 
% $Author: Jing Qiao $   
% $Date: 2020/05/03  $ 
% ***********************************************************

%  structure of normal distance observations
    normDisDat = struct(...          
    'sigma1',[],'sigma2',[],'centroid1',[],'centroid2',[], ...  
    'normal1',[],'normal2',[], 'iface1',[],'iface2',[],'distrib_weight',[],'disSig',[],...
    'iset1',0, 'iset2',0, 'ipatch',[], 'ipatch1',[],'ipatch2',[],'N',0,'pt1',[],'pt2',[],'point_cnt1',[],'point_cnt2',[],'incidence1',[],'incidence2',[],...
    'Q0',[],'Q',[]);  %'Q'---cofactor of obsrvations


    normDisDat_new = normDisDat;
    iPair = 0; %sequence of the formed dataset pair
    
    for iset=1:obj.nSet
        for iface=1:2
            if isempty(obj.corePts2(iface,iset).centroid)   
                continue;
            end
            
            sigma2     =     obj.corePts2(iface,iset).sigma;
            incidence2 =     obj.corePts2(iface,iset).incidence;
            centroid2  =     obj.corePts2(iface,iset).centroid;
            normal2    =     obj.corePts2(iface,iset).normal;
            distrib_weight = obj.corePts2(iface,iset).weight(1,:);  
            disSig =         obj.corePts2(iface,iset).disSig;
            pt2        =     obj.corePts2(iface,iset).PtsDat;
            point_cnt2 =     obj.corePts2(iface,iset).pt_cnt;
            ids        =     obj.corePts2(iface,iset).id;
            iface_r    =     obj.corePts2(iface,iset).iface_r; 
            iset_r     =     obj.corePts2(iface,iset).iset_r;
             
            
            iset0=0;
            while ~isempty(iset_r)
               % Get corresponding values at the reference setups
                iset1= iset_r(1);
                iface1= iface_r(1);
                index = find((iset_r(:)==iset1).*(iface_r(:)==iface1));
                ids1 = ids(index);
                npt = size(index,1);
                centroid1 = obj.corePts(iface1,iset1).centroid(:,ids1);
                sigma1    = obj.corePts(iface1,iset1).sigma(ids1);
                incidence1= obj.corePts(iface1,iset1).incidence(ids1);
                normal1    = obj.corePts(iface1,iset1).normal(:,ids1);
                pt1        = obj.corePts(iface1,iset1).PtsDat(ids1);
                point_cnt1 = obj.corePts(iface1,iset1).pt_cnt(ids1);
                 
                if iset1~=iset0
                    iPair = iPair+1;
                    normDisDat(iPair).sigma1 = sigma1;
                    normDisDat(iPair).sigma2 = sigma2(index);
                    normDisDat(iPair).incidence1 = incidence1;
                    normDisDat(iPair).incidence2 = incidence2(index);
                    normDisDat(iPair).centroid1 = centroid1;
                    normDisDat(iPair).centroid2 = centroid2(:,index);
                    normDisDat(iPair).normal1 = normal1;
                    normDisDat(iPair).normal2 = normal2(:,index);
                    normDisDat(iPair).iface1 = iface_r(index);
                    normDisDat(iPair).iface2 = repmat(iface, 1,npt);
                     normDisDat(iPair).distrib_weight = distrib_weight(index);
                    normDisDat(iPair).disSig = disSig(index);
                    normDisDat(iPair).iset1 = iset1;
                    normDisDat(iPair).iset2 = iset;
                    normDisDat(iPair).ipatch = ids1;
                    normDisDat(iPair).N = npt;
                    normDisDat(iPair).pt1 = pt1;
                    normDisDat(iPair).pt2 = pt2(index);
                    normDisDat(iPair).point_cnt1= point_cnt1;
                    normDisDat(iPair).point_cnt2= point_cnt2(index);
                else
                    normDisDat(iPair).sigma1 = [normDisDat(iPair).sigma1 sigma1];
                    normDisDat(iPair).sigma2 = [normDisDat(iPair).sigma2 sigma2(index)];
                    normDisDat(iPair).incidence1 =[normDisDat(iPair).incidence1 incidence1];
                    normDisDat(iPair).incidence2 = [normDisDat(iPair).incidence2 incidence2(index)];
                    normDisDat(iPair).centroid1 = [normDisDat(iPair).centroid1 centroid1];
                    normDisDat(iPair).centroid2 = [normDisDat(iPair).centroid2 centroid2(:,index)];
                    normDisDat(iPair).normal1 = [normDisDat(iPair).normal1 normal1];
                    normDisDat(iPair).normal2 = [normDisDat(iPair).normal2 normal2(:,index)];
                    normDisDat(iPair).iface1 = [normDisDat(iPair).iface1 iface_r(index)];
                    normDisDat(iPair).iface2 = [normDisDat(iPair).iface2 repmat(iface, 1,npt)];
                    normDisDat(iPair).distrib_weight = [normDisDat(iPair).distrib_weight distrib_weight(index)];
                    normDisDat(iPair).disSig = [normDisDat(iPair).disSig disSig(index)];
                    normDisDat(iPair).ipatch = [normDisDat(iPair).ipatch ids1];
                    normDisDat(iPair).N = normDisDat(iPair).N+npt;
                    normDisDat(iPair).pt1 = [normDisDat(iPair).pt1 pt1];
                    normDisDat(iPair).pt2 = [normDisDat(iPair).pt2 pt2(index)];
                    normDisDat(iPair).point_cnt1= [normDisDat(iPair).point_cnt1 point_cnt1];
                    normDisDat(iPair).point_cnt2= [normDisDat(iPair).point_cnt2 point_cnt2(index)];
                end
                 iset_r(index)=[];
                 iface_r(index)=[];
                 ids(index)=[];
                 
                 sigma2(index)=[];
                 centroid2(:,index)=[];
                 incidence2(index)=[];
                 normal2(:,index)=[];
                   distrib_weight(index)=[];
                 disSig(index)=[];
                 pt2(index)=[];
                 point_cnt2(index) = [];
                 
                 iset0=iset1;
            end
            
        end
    end
   
    % Merge pair with the same setups
    nPair = size(normDisDat,2);
    iset12 = zeros(nPair,2);
    for i=1:nPair
        iset12(i,1) = normDisDat(i).iset1;
        iset12(i,2) = normDisDat(i).iset2;
    end
    [u,I,J] = unique(iset12, 'rows');

    nPair = size(u,1);
    for i=1:nPair
        normDisDat_new(i).iset1 = u(i,1);
        normDisDat_new(i).iset2 = u(i,2);
        normDisDat_new(i).N = 0;
        ip0 = find(J==i);
        for j=1:size(ip0,1) 
           normDisDat_new(i).sigma1 = [normDisDat_new(i).sigma1 normDisDat(ip0(j)).sigma1 ];
           normDisDat_new(i).sigma2 = [normDisDat_new(i).sigma2 normDisDat(ip0(j)).sigma2 ];
           normDisDat_new(i).incidence1 = [normDisDat_new(i).incidence1 normDisDat(ip0(j)).incidence1 ];
           normDisDat_new(i).incidence2 = [normDisDat_new(i).incidence2 normDisDat(ip0(j)).incidence2 ];
           normDisDat_new(i).centroid1 = [normDisDat_new(i).centroid1 normDisDat(ip0(j)).centroid1 ];
           normDisDat_new(i).centroid2 = [normDisDat_new(i).centroid2 normDisDat(ip0(j)).centroid2 ];
           normDisDat_new(i).normal1 = [normDisDat_new(i).normal1 normDisDat(ip0(j)).normal1 ];
           normDisDat_new(i).normal2 = [normDisDat_new(i).normal2 normDisDat(ip0(j)).normal2 ];
           normDisDat_new(i).iface1 = [normDisDat_new(i).iface1 normDisDat(ip0(j)).iface1 ];
           normDisDat_new(i).iface2 = [normDisDat_new(i).iface2 normDisDat(ip0(j)).iface2 ];
           normDisDat_new(i).distrib_weight = [normDisDat_new(i).distrib_weight normDisDat(ip0(j)).distrib_weight ];
           normDisDat_new(i).disSig = [normDisDat_new(i).disSig normDisDat(ip0(j)).disSig ];
           normDisDat_new(i).ipatch = [normDisDat_new(i).ipatch normDisDat(ip0(j)).ipatch ];
           normDisDat_new(i).pt1 = [normDisDat_new(i).pt1 normDisDat(ip0(j)).pt1 ];
           normDisDat_new(i).pt2 = [normDisDat_new(i).pt2 normDisDat(ip0(j)).pt2 ];
           normDisDat_new(i).point_cnt1 = [normDisDat_new(i).point_cnt1 normDisDat(ip0(j)).point_cnt1 ];
           normDisDat_new(i).point_cnt2 = [normDisDat_new(i).point_cnt2 normDisDat(ip0(j)).point_cnt2 ];
           normDisDat_new(i).N = normDisDat_new(i).N + normDisDat(ip0(j)).N;
        end
    end
    
     if obj.hasNormDis
         obsType = 'normDis';
     else
         obsType = 'normDisAng';
     end
     
     normDisDat_new = normDisAngCofactor(obj,normDisDat_new,obsType);
     plotnormDisDat(obj,normDisDat_new);

end