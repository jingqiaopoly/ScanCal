function [B, P, L, obsDef, p_kap, p_pos,normDisDat]= estimatorNormDis(obj,p_kap,p_pos,normDisDat,obsDef, iter, en)
%estimatorNormDis Prepares the matrice for least-squares estimation related
%                 to normal distances
%  
% $Author: Jing Qiao $   
% $Date: 2020/05/03  $ 
% *********************************************************** 

    % Check pre-calculations
    if isempty(normDisDat)
        print('No normal distance related data available. Call cal.selfcal.func.initNormDis() before.');
    end
   
    h_ang = 0.000000001;
    h_off = 0.000001;
    if strcmp(obj.model,'NIST2')
         angIndex = [5 6 7 8 9 10 11 13 14 15 16]; % h_ang for x4, x5n9n...
         offIndex = [1 2 3 4 12 ]; %h_off for  x1n, x1z, x2, x3...
         eps = ones(1,16);
         eps(angIndex) = eps(angIndex).*h_ang;
         eps(offIndex) = eps(offIndex).*h_off;
    elseif strcmp(obj.model,'NIST3')
         angIndex = [5 6 7 8 9 ]; % h_ang for x4, x5n9n...
         offIndex = [1 2 3 4 10 11 ]; %h_off for  x1n, x1z, x2, x3...
         eps = ones(1,11);
         eps(angIndex) = eps(angIndex).*h_ang;
         eps(offIndex) = eps(offIndex).*h_off;
    elseif strcmp(obj.model,'NIST8')
         angIndex = [4 5 6 7 ]; % h_ang for x4, x5n9n...
         offIndex = [1 2 3 8 ]; %h_off for  x1n, x1z, x2, x3...
         eps = ones(1,8);
         eps(angIndex) = eps(angIndex).*h_ang;
         eps(offIndex) = eps(offIndex).*h_off;
    elseif strcmp(obj.model,'NIST9')
         angIndex = [4 5 6 7  ]; % h_ang for x4, x5n9n...
         offIndex = [1 2 3 8 9]; %h_off for  x1n, x1z, x2, x3...
         eps = ones(1,9);
         eps(angIndex) = eps(angIndex).*h_ang;
         eps(offIndex) = eps(offIndex).*h_off;
    elseif strcmp(obj.model,'NIST10')
         angIndex = [5 6 8 9 10 ]; % h_ang for x4, x5n9n...
         offIndex = [1 2 3 4 7 ]; %h_off for  x1n, x1z, x2, x3...
         eps = ones(1,10);
         eps(angIndex) = eps(angIndex).*h_ang;
         eps(offIndex) = eps(offIndex).*h_off;
    elseif strcmp(obj.model,'Lichti')
         angIndex = [10 11 12 13 14 15 16 17 18 19 20 21]; % h_ang
         offIndex = [1 2 3 4 5 6 7 8 ]; %h_off 
         eps = ones(1,21);
         eps(angIndex) = eps(angIndex).*h_ang;
         eps(offIndex) = eps(offIndex).*h_off;
    end
    
   %sigma = ProjectSettings.instance.normDis.sigma;

   posIndex =  obj.posIndex;
   isEval = obj.isEvalModel;
   nPar = size(obj.parDef,1);
   np = obj.np;
   npos = obj.npos;
   nPair = size(normDisDat,2);
  
   N=0;
   for iPair =1:nPair
       N = N + normDisDat(iPair).N;%size(normDisDat(iPair).corept1,2);
   end
   B = zeros(N, nPar); %nPar=np+npos+ncam
   L = zeros(N,1); %L=O-C=0-C
   P = zeros(N,N);
   
   N0=0; 
   for iPair =1:nPair
      %Copy to local variables
       iface1 = normDisDat(iPair).iface1;
       iface2 = normDisDat(iPair).iface2;
       %distrib_weight = normDisDat(iPair).distrib_weight;
       iset1 = normDisDat(iPair).iset1;
       iset2 = normDisDat(iPair).iset2;
       ipatch = normDisDat(iPair).ipatch;
       m = normDisDat(iPair).N;
       pt1 = normDisDat(iPair).pt1;
       pt2 = normDisDat(iPair).pt2;
       
       point_cnt1= normDisDat(iPair).point_cnt1;
       %point_cnt2= normDisDat(iPair).point_cnt2;
     
       obsDef1 = zeros(m,7);
        %1: type(1-coordinateDiff, 2-normalDis, 3-a prior NIST parameter, 4- a prior scannerPosParameter )
        %2: subtype(coordinateDiff: 1-x, 2-y, 3-z; NISTparameter:[1-...]; scannerPosParameter:[1-rotX,2-rotY,3-rotZ,4-dx,5-dy,6-dz]) ) 
        %3: fisrt setup
        %4: second setup  3&4:([1,2],[1,1]...) 
        %5: first obs face
        %6: second obs face 5&6:([2,2],[1,2] ) 
        %7. patch index(1,2,3,4...)at the first setup in face1 and face2
      
       obsDef1(:,1)= 2;         %type-2: normalDis
       obsDef1(:,2)= point_cnt1; 
       obsDef1(:,3)= iset1;
       obsDef1(:,4)= iset2;
       obsDef1(:,5)= iface1;    % 2-is_face1_1;
       obsDef1(:,6)= iface2;    % 2-is_face1_2;
       obsDef1(:,7)= ipatch;    %[ipatch1 ipatch2];

       %Matrix B: Partial derivative of observation equation to the
       %parameters (NIST parameters and (numSetup-1)*6 pos parameters)
       B1 = zeros(m, np+(obj.nSet-1)*6); %nPar=np+npos

       % L1: Initial estimate of the observation equation with
       % current parameters
       L1 = zeros(m,1); %F=O-C=0-C
       
       %1.1 Derivatives to model parameters
       Dis_p = zeros(m,np);
       Dis_m = zeros(m,np);
       ip = 0;
       eps_new=zeros(np,1);
       for i = 1:size(eps,2)          % loop over all parameters
         if(isEval(i)==1)
           p_kap_p = p_kap;
           p_kap_p(i) = p_kap(i)+ eps(i);
           p_kap_m = p_kap;
           p_kap_m(i) = p_kap(i)- eps(i);

           ip = ip+1;
           [Dis_p(:,ip), dum1, dum2, norm1_dum] = normalDis(p_kap_p,p_pos, pt1, pt2, iface1,iface2, iset1,iset2, obj);
           [Dis_m(:,ip), dum1, dum2, norm1_dum] = normalDis(p_kap_m,p_pos, pt1, pt2, iface1,iface2, iset1,iset2, obj);
           eps_new(ip)=eps(i);
         end
       end 

       for ip=1:np
           B1(:,ip)= (Dis_p(:,ip)-Dis_m(:,ip))/(2*eps_new(ip));  
       end
        
     %1.2 Derivatives to scanner pos parameters: only normDis formed
     %between two setups can be used for pos parameters estimation
     %dDisda= dot(dR/da*cp2,n2), dDis/dTx= nx
     [L1, Xc1, Xc2, normal1]=normalDis(p_kap,p_pos, pt1, pt2, iface1,iface2, iset1,iset2, obj);
     Xc12= [Xc1; Xc2];
     if iset1~=iset2
         iset12= [iset1 iset2];
         for ii=1:2
             iset = iset12(ii);
             if iset==obj.refSet
                 continue;
             elseif iset<obj.refSet
                 k = 1;
             else
                 k = 2;
             end
            a = p_pos(6*iset-6*k+1); b = p_pos(6*iset-6*k+2);c = p_pos(6*iset-6*k+3);
            ca=cos(a); sa=sin(a); cb=cos(b); sb=sin(b);  cc=cos(c); sc=sin(c);
            dRda = [0   sa*sc+ca*sb*cc   ca*sc-sa*sb*cc;
                     0  -sa*cc+ca*sb*sc  -ca*cc-sa*sb*sc;
                     0         ca*cb             -sa*cb   ];
            dRdb = [-sb*cc   sa*cb*cc   ca*cb*cc;
                     -sb*sc   sa*cb*sc   ca*cb*sc;
                     -cb     -sa*sb     -ca*sb];
            dRdc = [-cb*sc   -ca*cc-sa*sb*sc   sa*cc-ca*sb*sc;
                      cb*cc   -ca*sc+sa*sb*cc   sa*sc+ca*sb*cc;
                        0            0               0];
            if ii==1
                isign = -1;
            else
                isign = 1;
            end
            apt = dRda * Xc12(3*(ii-1)+1:3*(ii-1)+3,:);
            bpt = dRdb * Xc12(3*(ii-1)+1:3*(ii-1)+3,:);
            cpt = dRdc * Xc12(3*(ii-1)+1:3*(ii-1)+3,:);
            for i=1:m
             B1(i,np+6*iset-6*k+1)= isign*dot(apt(:,i),normal1(:,i));
             B1(i,np+6*iset-6*k+2)= isign*dot(bpt(:,i),normal1(:,i));
             B1(i,np+6*iset-6*k+3)= isign*dot(cpt(:,i),normal1(:,i));
             B1(i,np+6*iset-6*k+4)= isign*normal1(1,i);
             B1(i,np+6*iset-6*k+5)= isign*normal1(2,i);
             B1(i,np+6*iset-6*k+6)= isign*normal1(3,i);
            end
         end
     end
     B1 = B1(:,[1:np np+posIndex']);
       
    %2. Observation matrix 
    L1 = -L1.';
    index = 1:m+1:m*m;  % Indices of the main diagonal
    if iter<3
        P1 = diag(1./diag(normDisDat(iPair).Q0));
    else %Use Danish method
        sig0 = sqrt(diag(normDisDat(iPair).Q0));
        scal = ones(1,m);
        ii = find(abs(en(N0+1:N0+m))>3.*sig0);
        scal(ii) = exp(en(ii).^2./(3*sig0(ii)).^2);   %(exp(-en(ii).^2./(3*sig0(ii)).^2)).^(-1);
        scal(find(scal>1e4|isinf(scal)))= 1e4;
        normDisDat(iPair).Q(index) = normDisDat(iPair).Q0(index).*scal;
        P1 = diag(1./diag(normDisDat(iPair).Q));
    end

     B(N0+1:N0+m,1:np+npos) = B1;
     L(N0+1:N0+m) = L1;
     P(N0+1:N0+m,N0+1:N0+m)= P1;
     obsDef = [obsDef; obsDef1];
     N0=N0+m;
   end 
 end