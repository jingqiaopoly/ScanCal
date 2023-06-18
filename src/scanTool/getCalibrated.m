% Output corrected coordinates
filename = 'H:\DeliveryHallandRFL\scanData\setup22_3mm_PP123c.mat';
filePara = 'H:\DeliveryHallandRFL\Result\2208102156set_49(1)_49(2)_49(3)_IF.mat';
load(filename);
load(filePara);
%  p_kap = zeros(10,1);
 model = 'NIST10';
 
 raw1 = [scan_data.rng(:)'*0.001; scan_data.az(:)'; scan_data.el(:)'];

 cor1 = NISTModel.NIST_fwd(raw1,p_kap,model);
 clear raw1
 
 % Transform the corrected observations into Cartesian system
 X1 = polar2cart(cor1(2,:), cor1(3,:), cor1(1,:));
 clear cor1
  
% % % % % % % %  % transform coordinates to the reference system
  tmp= scanPos(2,:)';   %
  eul=tmp;eul(1)=tmp(3);eul(3)=tmp(1);
  R = eul2rotm(eul(1:3)','ZYX');
  T = tmp(4:6)*0.001;  
  X1 = R*X1+T;
% 
  ptCloud = pointCloud(X1');
  clear X1
  ptCloud.Intensity = scan_data.intens(:);
  pcwrite(ptCloud,[filename(1:end-4) '_2208102156.ply'],'PLYFormat','binary');
 
filename = 'H:\DeliveryHallandRFL\scanData\setup32_3mm_PP123c.mat';
load(filename);
%  load(filePara); 

 raw1 = [scan_data.rng(:)'*0.001; scan_data.az(:)'; scan_data.el(:)']; 
 cor1 = NISTModel.NIST_fwd(raw1,p_kap,model);
 clear raw1 
 % Transform the corrected observations into Cartesian system
 X1 = polar2cart(cor1(2,:), cor1(3,:), cor1(1,:));
 clear cor1
  
% % % % % % % % %  % transform coordinates to the reference system
  tmp= scanPos(3,:)';   %
  eul=tmp;eul(1)=tmp(3);eul(3)=tmp(1);
  R = eul2rotm(eul(1:3)','ZYX');
  T = tmp(4:6)*0.001;  
  X1 = R*X1+T;
   
  ptCloud = pointCloud(X1');
  clear X1
  ptCloud.Intensity = scan_data.intens(:);
  pcwrite(ptCloud,[filename(1:end-4) '_2208102156.ply'],'PLYFormat','binary');
  clear ptCloud

  filename = 'H:\DeliveryHallandRFL\scanData\setup21_3mm_PP123c.mat';
  load(filename);
%  load(filePara); 
 raw1 = [scan_data.rng(:)'*0.001; scan_data.az(:)'; scan_data.el(:)']; 
 cor1 = NISTModel.NIST_fwd(raw1,p_kap,model);
 clear raw1 
 % Transform the corrected observations into Cartesian system
 X1 = polar2cart(cor1(2,:), cor1(3,:), cor1(1,:));
 clear cor1
  
% % % % % % % % %  % transform coordinates to the reference system
  tmp= scanPos(2,:)';   %
  eul=tmp;eul(1)=tmp(3);eul(3)=tmp(1);
  R = eul2rotm(eul(1:3)','ZYX');
  T = tmp(4:6)*0.001;  
  X1 = R*X1+T;
   
  ptCloud = pointCloud(X1');
  clear X1
  ptCloud.Intensity = scan_data.intens(:);
  pcwrite(ptCloud,[filename(1:end-4) '_2208102156.ply'],'PLYFormat','binary');
  clear ptCloud


  filename = 'H:\DeliveryHallandRFL\scanData\setup31_3mm_PP123c.mat';
load(filename);
%  load(filePara); 
 raw1 = [scan_data.rng(:)'*0.001; scan_data.az(:)'; scan_data.el(:)']; 
 cor1 = NISTModel.NIST_fwd(raw1,p_kap,model);
 clear raw1 
 % Transform the corrected observations into Cartesian system
 X1 = polar2cart(cor1(2,:), cor1(3,:), cor1(1,:));
 clear cor1
  
% % % % % % % % %  % transform coordinates to the reference system
  tmp= scanPos(3,:)';   %
  eul=tmp;eul(1)=tmp(3);eul(3)=tmp(1);
  R = eul2rotm(eul(1:3)','ZYX');
  T = tmp(4:6)*0.001;  
  X1 = R*X1+T;
   
  ptCloud = pointCloud(X1');
  clear X1
  ptCloud.Intensity = scan_data.intens(:);
  pcwrite(ptCloud,[filename(1:end-4) '_2208102156.ply'],'PLYFormat','binary');
  clear ptCloud






  
  
  
  
  
  








