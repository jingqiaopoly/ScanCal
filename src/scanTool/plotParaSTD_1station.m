% %plotParaSTD
% % 
% % % PP and TC and IF estimation using 1 station
% fileIF2 = 'J:\Bonn\RTC360\Result\2107191232set_1(1)_1(2)_IF10000.mat';
% fileTC2 = 'J:\Bonn\RTC360\Result\2107152102set_1(1)_1(2)_TC.mat';
% filePP2 = 'J:\Bonn\RTC360\Result\2107160915set_1(1)_1(2)_PP.mat';
% fileIF1 = 'J:\Bonn\RTC360\Result\2106071054set_1(5)_1(6)_IF9000.mat';
% fileTC1 = 'J:\Bonn\RTC360\Result\2107152032set_1(5)_1(6)_TC.mat';
% filePP1 = 'J:\Bonn\RTC360\Result\2107160905set_1(5)_1(6)_PP.mat';

fileIF2 = 'J:\Bonn\ZF\Export_SOCS\Result\2107191151set_1(1)_1(2)_IF_28000.mat';
fileTC2 = 'J:\Bonn\ZF\Export_SOCS\Result\2107161547set_1(1)_1(2)_TC.mat';
filePP2 = 'J:\Bonn\ZF\Export_SOCS\Result\2107161723set_1(1)_1(2)_PP_sampl500.mat';
fileIF1 = 'J:\Bonn\ZF\Export_SOCS\Result\2106180824set_0(3)_0(4)_IF20000_NIST8.mat';
fileTC1 = 'J:\Bonn\ZF\Export_SOCS\Result\2107161543set_1(3)_1(4)_TC.mat';
filePP1 = 'J:\Bonn\ZF\Export_SOCS\Result\2107151257set_1(3)_1(4)_PP_Samp500.mat';

model = 'NIST8';
name_kap = {'x1z','x2', 'x3','x4','x5n','x6','x5z7','x1n2'};
unit_kap_sec = {'mm','mm','mm', '''''','''''','''''','''''','mm',};
unit_kap_mm = {'mm','mm','mm','mm@10m','mm@10m','mm@10m','mm@10m','mm'};
angIndex = [4 5 6 7 ]; % h_ang for x4, x5n9n...
figure_handles = [];        
        
load(fileIF1);
index = find(parDef(:,1)==1);
[C,iAngle,ib] = intersect(index,angIndex);
std_kap_mm = std_kap; kap_mm = p_kap;
std_kap_mm(iAngle)  =  std_kap_mm(iAngle)*10000;
kap_mm(iAngle)  =  kap_mm(iAngle)*10000;
X_IF1 = kap_mm ;
STD_IF1 = std_kap_mm;

load(fileTC1);
std_kap_mm = std_kap; kap_mm = p_kap;
std_kap_mm(iAngle)  =  std_kap_mm(iAngle)*10000;
kap_mm(iAngle)  =  kap_mm(iAngle)*10000;
X_TC1 = kap_mm;
STD_TC1 = std_kap_mm ;

load(filePP1);
std_kap_mm = std_kap; kap_mm = p_kap;
std_kap_mm(iAngle)  =  std_kap_mm(iAngle)*10000;
kap_mm(iAngle)  =  kap_mm(iAngle)*10000;
X_PP1 = kap_mm;
STD_PP1 = std_kap_mm ;

load(fileIF2);
std_kap_mm = std_kap; kap_mm = p_kap;
std_kap_mm(iAngle)  =  std_kap_mm(iAngle)*10000;
kap_mm(iAngle)  =  kap_mm(iAngle)*10000;
X_IF2 = kap_mm ;
STD_IF2 = std_kap_mm;

load(fileTC2);
std_kap_mm = std_kap; kap_mm = p_kap;
std_kap_mm(iAngle)  =  std_kap_mm(iAngle)*10000;
kap_mm(iAngle)  =  kap_mm(iAngle)*10000;
X_TC2 = kap_mm;
STD_TC2 = std_kap_mm ;

load(filePP2);
std_kap_mm = std_kap; kap_mm = p_kap;
std_kap_mm(iAngle)  =  std_kap_mm(iAngle)*10000;
kap_mm(iAngle)  =  kap_mm(iAngle)*10000;
X_PP2 = kap_mm;
STD_PP2 = std_kap_mm ;

dX_IF1 = X_IF1-X_TC1;
dX_TC1 = X_TC1-X_TC1;
dX_PP1 = X_PP1-X_TC1;
dX_IF2 = X_IF2-X_TC1;
dX_TC2 = X_TC2-X_TC1;
dX_PP2 = X_PP2-X_TC1;


%1. Plot the std of LSM parameters
figure_handles = [figure_handles,figure(11)];
clf;
np = length(kap_mm);
x = 1:np;
y = dX_TC1;
err = STD_TC1;
e = errorbar(x,y,err.*3,'o','MarkerSize',3,...
'MarkerEdgeColor','black','MarkerFaceColor','black','LineWidth',2);
e.Color = 'black';
set(gca,'xtick',[1:np],'xticklabel',name_kap);
ylabel( [model,' dX (mm/mm@10m)' ]);
grid on
xtickName = name_kap';

hold on
y = dX_IF1;
err = STD_IF1;
e= errorbar(x,y,err.*3,'o','MarkerSize',3,...
'MarkerEdgeColor','green','MarkerFaceColor','green','LineWidth',2);
e.Color = 'green';

hold on
y = dX_PP1;
err = STD_PP1;
e= errorbar(y,err.*3,'o','MarkerSize',3,...
'MarkerEdgeColor','red','MarkerFaceColor','red','LineWidth',2);
e.Color = 'red';


hold on
y = dX_TC2;
err = STD_TC2;
e= errorbar(x+0.2,y,err.*3,'o','MarkerSize',3,...
'MarkerEdgeColor','[0.50,0.50,0.50]','MarkerFaceColor','[0.50,0.50,0.50]','LineWidth',2);
e.Color = [0.50,0.50,0.50];

hold on
y = dX_IF2;
err = STD_IF2;
e= errorbar(x+0.2,y,err.*3,'o','MarkerSize',3,...
'MarkerEdgeColor','[0.29,0.62,0.06]','MarkerFaceColor','[0.29,0.62,0.06]','LineWidth',2);
e.Color = '[0.29,0.62,0.06]';

hold on
y = dX_PP2;
err = STD_PP2;
e= errorbar(x+0.2,y,err.*3,'o','MarkerSize',3,...
'MarkerEdgeColor','[1.00,0.41,0.16]','MarkerFaceColor','[1.00,0.41,0.16]','LineWidth',2);
e.Color = '[1.00,0.41,0.16]';

ylim([-1.5 1.5]);
xlim([0 9]);
legend('TC1','IF1','PP1', 'TC2', 'IF2', 'PP2');












        
        
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


