 
filename = 'I:\Bonn\ZF\Export_SOCS\setup1_3mm.mat';
filePara = 'I:\Bonn\ZF\Export_SOCS\Result\2107151632set_1(1)_1(2)_1(3)_1(4)_PP_Samp500_NIST10';
load(filename);
load(filePara); 

 model= 'NIST10';
 raw1 = [scan_data.rng(:)'*0.001; scan_data.az(:)'; scan_data.el(:)']; 
 cor1 = NISTModel.NIST_fwd(raw1,p_kap,model);
 clear raw1 
 % Transform the corrected observations into Cartesian system
 X1 = polar2cart(cor1(2,:), cor1(3,:), cor1(1,:));
 clear cor1
  
% % % % % % % % %  % transform coordinates to the reference system
  tmp= scanPos(1,:)';   %
  eul=tmp;eul(1)=tmp(3);eul(3)=tmp(1);
  R = eul2rotm(eul(1:3)','ZYX');
  T = tmp(4:6)*0.001;  
  X1 = R*X1+T;
   
  ptCloud = pointCloud(X1');
  clear X1
  ptCloud.Intensity = scan_data.intens(:);
  pcwrite(ptCloud,[filename(1:end-4) '_2107151632_PP_NIST10.ply'],'PLYFormat','binary');
  clear ptCloud

  filename = 'I:\Bonn\ZF\Export_SOCS\setup2_3mm.mat';
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
  pcwrite(ptCloud,[filename(1:end-4) '_2107151632_PP_NIST10.ply'],'PLYFormat','binary');
  clear ptCloud

  filename = 'I:\Bonn\ZF\Export_SOCS\setup3_3mm.mat';
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
  pcwrite(ptCloud,[filename(1:end-4) '_2107151632_PP_NIST10.ply'],'PLYFormat','binary');
  clear ptCloud

  filename = 'I:\Bonn\ZF\Export_SOCS\setup4_3mm.mat';
  load(filename);
%  load(filePara); 
 raw1 = [scan_data.rng(:)'*0.001; scan_data.az(:)'; scan_data.el(:)']; 
 cor1 = NISTModel.NIST_fwd(raw1,p_kap,model);
 clear raw1 
 % Transform the corrected observations into Cartesian system
 X1 = polar2cart(cor1(2,:), cor1(3,:), cor1(1,:));
 clear cor1
  
% % % % % % % % %  % transform coordinates to the reference system
  tmp= scanPos(4,:)';   %
  eul=tmp;eul(1)=tmp(3);eul(3)=tmp(1);
  R = eul2rotm(eul(1:3)','ZYX');
  T = tmp(4:6)*0.001;  
  X1 = R*X1+T;
   
  ptCloud = pointCloud(X1');
  clear X1
  ptCloud.Intensity = scan_data.intens(:);
  pcwrite(ptCloud,[filename(1:end-4) '_2107151632_PP_NIST10.ply'],'PLYFormat','binary');
  clear ptCloud