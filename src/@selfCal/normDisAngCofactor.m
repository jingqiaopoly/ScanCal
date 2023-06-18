function [normDisDat] = normDisAngCofactor(obj,normDisDat,obsType)
% calculate the cofactor of the normal distance observations
   sigma = ProjectSettings.instance.normDis.sigma;
   sigAng = sec2rad(300);
   
   nPair = size(normDisDat,2);
   
   if strcmp(obsType,'normDisAng') 
       for iPair =1:nPair
           m  = normDisDat(iPair).N;
           index = 1:2*m+1:2*m*m*2;  % Indices of the main diagonal
           Q1 = zeros(2*m,2*m);

           distrib_weight = normDisDat(iPair).distrib_weight;
           Qdis =  sigma*sigma./distrib_weight;
           Qang =  sigAng*sigAng./distrib_weight;
           Q1(index(1:2:end)) = Qdis;
           Q1(index(2:2:end)) = Qang;
           normDisDat(iPair).Q0 = Q1;
           normDisDat(iPair).Q = Q1;
       end
   elseif strcmp(obsType,'normDis')
       for iPair =1:nPair
           m  = normDisDat(iPair).N;
           index = 1:m+1:m*m;  % Indices of the main diagonal
           Q1 = zeros(m,m);

%            distrib_weight = normDisDat(iPair).distrib_weight;
%            Qdis =  sigma*sigma./distrib_weight;
             Qdis = normDisDat(iPair).disSig.^2;
           
           Q1(index) = Qdis;
           normDisDat(iPair).Q0 = Q1;
           normDisDat(iPair).Q = Q1;
       end
   end
   
end