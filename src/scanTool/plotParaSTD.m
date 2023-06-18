%plotParaSTD

% % PP and TC estimation using two stations
% filePP = 'J:\Bonn\RTC360\Result\2107152222set_1(1)_1(2)_1(5)_1(6)_PP_NIST10.mat';
% fileTC = 'J:\Bonn\RTC360\Result\2107151821set_1(1)_1(2)_1(5)_1(6)_TC_NIST10.mat';

filePP = 'J:\Bonn\ZF\Export_SOCS\Result\2107151632set_1(1)_1(2)_1(3)_1(4)_PP_Samp500_NIST10.mat';
fileTC = 'J:\Bonn\ZF\Export_SOCS\Result\2107161138set_1(1)_1(2)_1(3)_1(4)_TC_NIST10.mat';


model = 'NIST10';
name_kap = {'x10','x2', 'x1z','x3','x7','x6','x1n','x4','x5n','x5z'};
unit_kap_sec = {'mm','mm','mm', 'mm','''''','''''',    'mm','''''','''''',''''''};
unit_kap_mm =  {'mm','mm','mm', 'mm','mm@10m','mm@10m','mm','mm@10m','mm@10m','mm@10m'};
angIndex = [ 5 6 8 9 10 ]; % h_ang  
figure_handles = [];        
        
load(fileTC);
index = find(parDef(:,1)==1);
[C,iAngle,ib] = intersect(index,angIndex);
std_kap_mm = std_kap; kap_mm = p_kap;
std_kap_mm(iAngle)  =  std_kap_mm(iAngle)*10000;
kap_mm(iAngle)  =  kap_mm(iAngle)*10000;
X1 = kap_mm ;
STD1 = std_kap_mm;

load(filePP);
index = find(parDef(:,1)==1);
[C,iAngle,ib] = intersect(index,angIndex);
std_kap_mm = std_kap; kap_mm = p_kap;
std_kap_mm(iAngle)  =  std_kap_mm(iAngle)*10000;
kap_mm(iAngle)  =  kap_mm(iAngle)*10000;
X2 = kap_mm;
STD2 = std_kap_mm ;

dX1 = X1-X1;%(X1+X2)/2;
dX2 = X2-X1;%(X1+X2)/2;


%1. Plot the std of model parameters
figure_handles = [figure_handles,figure(11)];
clf;
np = length(X1);
x = 1:np;
y = dX1;
err = STD1;
e = errorbar(x,y,err.*3,'o','MarkerSize',3,...
'MarkerEdgeColor','black','MarkerFaceColor','black','LineWidth',2);
e.Color = 'black';
set(gca,'xtick',[1:np],'xticklabel',name_kap);
ylabel( [model,' dX (mm/mm@10m)' ]);
grid on
xtickName = name_kap';

hold on
y = dX2;
err = STD2;
e= errorbar(x,y,err.*3,'o','MarkerSize',3,...
'MarkerEdgeColor','red','MarkerFaceColor','red','LineWidth',2);
e.Color = 'red';
ylim([-1.5 1.5]);
 xlim([0 11])
legend('TC12','PP12');

        
        
% % F-test
% load(filePP);
% Qxx1 = Q.*sigma*sigma;
% index = find(parDef(:,1)==1);
% index = parDef(index,2);
% X1 = [p_kap(index); p_pos];
% r1 = size(obsDef,1) - length(X1);
% 
% load(fileTC);
% Qxx2 = Q.*sigma*sigma;
% X2 = [p_kap(index); p_pos];
% r2 = size(obsDef,1) - length(X2);
% 
% dX = X2 - X1;
% QdX = Qxx1 + Qxx2;
% 
% h = rank(QdX);
% F_test_value = dX'*inv(QdX)*dX/h;
% 
% F = finv(0.99,h,r1+r2);
% % F =Finv(1,2,3);
% % 1 - significance factor (0.95 or 0.99);
% % 2 - number of parameters (h);
% % 3 - cumulative redundancy of both network adjustments (nr1 +nr2) =approx.Inf
% 
% if F_test_value > F
%     disp('SIGNIFICANTLY DIFFERENT');
% else
%     disp('NOT SIGNIFICANTLY DIFFERENT');
% end


