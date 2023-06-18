function [p_kap, p_pos,p_cam, cof_kap,cof_pos,cof_cam,postSigma, Q, obj] = estimatorMain(obj)
% estimatorMain  estimate the parameters with different types of
% observations
% $Author: Jing Qiao $   
% $Date: 2020/05/03  $ 
% *********************************************************** 

    hasNormDis = obj.hasNormDis;
    normDisDat = [];

    % the following two dat are for other observations, ignored for PP based calibration here 
    Featurepdat=[];
    camFeatureDat=[];
    p_cam =[]; 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


    %1. Initilization process %
    if(hasNormDis)
        [normDisDat]= initNormDis(obj);
    end

    p_kap = obj.kap_init; % to get the values of models parameters, the estimated ones are updated in each estimator
    p_pos = obj.pos_init;
    p_kap_new = obj.kap_init;
    
    modelIndex = obj.modelIndex;
    posIndex = obj.posIndex;
    np = obj.np;
    npos = obj.npos;
    
   % 2. Estimation Process%%
   global_test = 'failed'; Iter_test = 0;
   while strcmp(global_test,'failed')
       Iter_test= Iter_test+1;
       V_n=[]; %V_c=[];V_f=[];  ec = [];ef = [];
       nIter=10; 
       for iter=1:nIter
        nPar = size(obj.parDef,1);
        BTPB = zeros(nPar,nPar); 
        BTPL = zeros(nPar,1); 
        obj.obsDef = [];
        mObs=0;
        %update p_kap p_pos with the estimated ones
        p_kap(modelIndex) = obj.parVal(1:np);
        p_pos(posIndex) = obj.parVal(np+1:np+npos);
        
        % Calculate normal equations for each type of observations, then estimate the parameters using their combination  
        % Normal distance
        if(hasNormDis)
           [B_n,P_n,L_n, obj.obsDef,p_kap, p_pos,normDisDat]= estimatorNormDis(obj, p_kap, p_pos, normDisDat,obj.obsDef, iter, V_n);
            BTPB_n = B_n'*P_n*B_n;  BTPL_n = B_n'*P_n*L_n; 
            BTPB =  BTPB + BTPB_n;  BTPL =  BTPL + BTPL_n;
            mObs = mObs + length(L_n);
        end
        
        dX = inv(BTPB)*(BTPL);
        obj.parVal = obj.parVal+ dX;
        
       % Condition to end the iteration
        p_kap_new(modelIndex) = obj.parVal(1:np);
        dKap = p_kap_new-p_kap;
        % transform the corrections to mm/ mm@10m
        if strcmp(obj.model,'NIST2')
             angIndex = [5 6 7 8 9 10 11 13 14 15 16]; % h_ang for x4, x5n9n...
             dKap(angIndex) =   dKap(angIndex)*10000; %mu eps detEL
        elseif strcmp(obj.model,'NIST3')
             angIndex = [5 6 7 8 9]; % h_ang for x4, ...
             dKap(angIndex) =   dKap(angIndex)*10000; %mu eps detEL
        elseif strcmp(obj.model,'NIST8')
             angIndex = [4 5 6 7 ]; % h_ang for x4, x5n9n...
             dKap(angIndex) =   dKap(angIndex)*10000; %
        elseif strcmp(obj.model,'NIST10')
             angIndex = [ 5 6 8 9 10 ]; % h_ang for x4, x5n9n...
             dKap(angIndex) =   dKap(angIndex)*10000; %
        elseif strcmp(obj.model,'Lichti')
             angIndex = [10 11 12 13 14 15 16 17 18 19 20 21]; % h_ang
             dKap(angIndex) =   dKap(angIndex)*10000; %
        end
    
        mean_dKap = sum(abs(dKap))/np;
        
        eTPe = 0;m_Obs = 0; ef=[]; ec=[];
        if (mean_dKap<1e-2)||iter==nIter %stop==true&
            if(hasNormDis)
               en = B_n*dX-L_n;
               V_n = B_n*dX-L_n;
               VTPV_n = V_n'*P_n*V_n;
               eTPe = eTPe + en'*P_n*en;
               m_Obs = m_Obs+size(L_n,1);
            end
            plotResiduals(obj, normDisDat,Featurepdat, camFeatureDat, V_n, ef, ec);
            break;
        end
    
    
        %3. Outlier removal %%
        %3.1 Normal distance
        if(hasNormDis)
            V_n = B_n*dX-L_n;
            nPair = size(normDisDat,2);
            [values, originalpos] = sort (abs(V_n), 'descend' );
            outlier = mad(V_n)*3*1.84
            nRemove=size(find(values>outlier),1);
            fprintf(' Removed outliers: %d\n', nRemove);        
            inRemove = originalpos(1:nRemove);
            V_n(inRemove)=[];
            N0=zeros(nPair,1);
            for iPair=1:nPair
                N0(iPair) = normDisDat(iPair).N;     
            end
            
            for iPair=1:nPair
               sum0 = sum(N0(1:iPair));
               index = find(inRemove<sum0+1);
               if ~isempty(index)
                   sum0 = sum0 - N0(iPair);
                   ind = inRemove(index)-sum0;
                   normDisDat(iPair).centroid1(:,ind)=[];
                   normDisDat(iPair).centroid2(:,ind)=[];
                   normDisDat(iPair).sigma1(ind)=[];
                   normDisDat(iPair).sigma2(ind)=[];
                   normDisDat(iPair).incidence1(ind)=[];
                   normDisDat(iPair).incidence2(ind)=[];
                   normDisDat(iPair).normal1(:,ind) = [];
                   normDisDat(iPair).iface1(ind) = [];
                   normDisDat(iPair).iface2(ind) = [];
    %                normDisDat(iPair).distrib_weight(ind) = [];
                   normDisDat(iPair).ipatch(ind) = [];
                   normDisDat(iPair).N = normDisDat(iPair).N-size(ind,1);
                   normDisDat(iPair).pt1(ind) = [];
                   normDisDat(iPair).pt2(ind) = [];
                   normDisDat(iPair).point_cnt1(ind) = [];
                   normDisDat(iPair).point_cnt2(ind) = [];
                   normDisDat(iPair).Q0(ind,:) = [];normDisDat(iPair).Q0(:,ind) = [];
                   normDisDat(iPair).Q(ind,:) = []; normDisDat(iPair).Q(:,ind) = [];
                   inRemove(index)=[];
               end
            end
        end
       end
       % global test 
       Qxx = inv(BTPB);
       if hasNormDis
           Q = diag(1./diag(P_n));
           Qll = B_n*Qxx*B_n';
           Qvv = Q - Qll;
           R = Qvv*P_n;
           QvvP = diag(R);
           robust_redundancy = sum(QvvP);
           % VCE - Variance component analysis
           obsType = 'normDis';
           vce_var = VCE_analysis(obj,'MAD',obsType,QvvP,V_n,diag(Q),'combined','no',[]);
           % GLOBAL TEST:
           gl_test_type = 'F_separate';
           [global_test_plane,s0] = globalTest(obj,gl_test_type,VTPV_n,robust_redundancy,vce_var,global_test); 
           disp(['Plane patch Global test: ',global_test_plane]);
           %update variance of observations
           for iPair =1:nPair
               normDisDat(iPair).Q = normDisDat(iPair).Q*vce_var.dis2;
               normDisDat(iPair).Q0 = normDisDat(iPair).Q;
           end
       end
       %%
       if strcmp(global_test_plane,'passed')
          global_test = 'passed';
          disp(['Global test: ',global_test]);
       end
   end
    
  %4. update p_kap p_pos  with the estimated ones%% 
   p_kap(modelIndex) = obj.parVal(1:np);
   p_pos(posIndex) = obj.parVal(np+1:np+npos);  
   
  %5. Calculate the std of the estimated parameters%%
   nPar = size(obj.parDef,1);
   VTPV =0;
   m=0;
   if(hasNormDis)
       V_n = B_n*dX-L_n;
       VTPV =V_n'*P_n*V_n;
       for iPair=1:size(normDisDat,2)
          m = m + normDisDat(iPair).N;     
       end
   end
   postSigma = sqrt(VTPV/(mObs-nPar));

   Q=inv(BTPB);
   cof = zeros(nPar,1);
   for i=1:nPar
       cof(i)=sqrt(Q(i,i));
   end
   cof_kap = cof(1:np);
   cof_pos = cof(np+1:np+npos);
   cof_cam =[]; % cof(np+npos+1:np+npos+ncam);
end