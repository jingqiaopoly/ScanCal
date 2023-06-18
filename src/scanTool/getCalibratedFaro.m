% Output corrected coordinates
  filename = 'J:\Bonn\Faro\Export\CalibrationRaw\Scan000_3mm.ply';
%  filePara = 'J:\Bonn\Faro\Result\2106091227set_0(1)_0(2)_0(3)_0(4)_0(5)_0(6)_0(7)_0(8)_PP.mat';
%  filePara = 'J:\Bonn\Faro\Result\2106080905set_0(1)_0(2)_0(3)_0(4)_0(5)_0(6)_0(7)_0(8)_IF.mat';

% filename = 'J:\Bonn\Faro\Export\Faro120s_wall_new\S001.ply';
filePara = 'J:\Bonn\Faro\Result\2106211747set_0(1)_0(2)_0(3)_0(4)_0(5)_0(6)_0(7)_0(8)_TC_LichtiSys.mat';
 
 load(filePara);
 ptCloud = pcread(filename);
 pts = ptCloud.Location';
 clear ptCloud
 raw1 = zeros(3,size(pts,2)); 
 
 
 %Get polar coordinates
 [raw1(2,:), raw1(3,:), raw1(1,:)] = cart2polar(pts, ones(size(pts,2),1), ProjectSettings.instance.selfCal.y_axis);
%  raw1(1,:) = raw1(1,:).*0.001;   
 cor1 = NISTModel.NIST_fwd(raw1,p_kap,ProjectSettings.instance.selfCal.model);
 clear raw1
 
 % Transform the corrected observations into Cartesian system
 X1 = polar2cart(cor1(2,:), cor1(3,:), cor1(1,:),ProjectSettings.instance.selfCal.y_axis);
 clear cor1
  
% % % % %  % transform coordinates to the reference system
  tmp= scanPos(1,:)';   %
  eul=tmp;eul(1)=tmp(3);eul(3)=tmp(1);
  R = eul2rotm(eul,'ZYX');
  T = tmp(4:6)*0.001;  
  X1 = R*X1+T;

  ptCloud = pointCloud(X1');
  clear X1
%   ptCloud.Intensity = scan_data.intens(:);
  pcwrite(ptCloud,[filename(1:end-4) '_TCs12345678Lichti.ply'],'PLYFormat','binary');
  
 filename = 'J:\Bonn\Faro\Export\CalibrationRaw\Scan001_3mm.ply'; 
%  filename = 'J:\Bonn\Faro\Export\Faro120s_wall_new\S002.ply';
 ptCloud = pcread(filename);
 pts = ptCloud.Location';
 clear ptCloud
 raw1 = zeros(3,size(pts,2)); 
 
 %Get polar coordinates
 [raw1(2,:), raw1(3,:), raw1(1,:)] = cart2polar(pts, ones(size(pts,2),1), ProjectSettings.instance.selfCal.y_axis);
%  raw1(1,:) = raw1(1,:).*0.001;   
 cor1 = NISTModel.NIST_fwd(raw1,p_kap,ProjectSettings.instance.selfCal.model);
 clear raw1
 % Transform the corrected observations into Cartesian system
 X1 = polar2cart(cor1(2,:), cor1(3,:), cor1(1,:),ProjectSettings.instance.selfCal.y_axis);
 clear cor1

  tmp= scanPos(2,:)';   %
  eul=tmp;eul(1)=tmp(3);eul(3)=tmp(1);
  R = eul2rotm(eul,'ZYX');
  T = tmp(4:6)*0.001;  
  X1 = R*X1+T;
%                
   
  ptCloud = pointCloud(X1');
  clear X1
%   ptCloud.Intensity = scan_data.intens(:);
%   pcwrite(ptCloud,[filename(1:end-4) '_Cor0524.ply']);
  pcwrite(ptCloud,[filename(1:end-4) '_TCs12345678Lichti.ply'],'PLYFormat','binary');
  
  
 % Use Tom\s results
 filename = 'J:\Bonn\Faro\Export\CalibrationRaw\Scan004_3mm.ply';
 filePara = 'D:\Codes\Calibration_Tomislav\Target-Based Calibration CKA v2.0_GUI\2 Calibration\results\Faro Focus 3D_07-Jun-2021_19_12_32.mat';
 
 ptCloud = pcread(filename);
 pts = ptCloud.Location';
 clear ptCloud
 %Get polar coordinates
 raw1 = zeros(3,size(pts,2)); 
 [raw1(2,:), raw1(3,:), raw1(1,:)] = cart2polar(pts, ones(size(pts,2),1), ProjectSettings.instance.selfCal.y_axis);
 cor1 = NISTModel.NIST_fwd(raw1,p_kap,ProjectSettings.instance.selfCal.model);
 clear raw1
 % Transform the corrected observations into Cartesian system
 X1 = polar2cart(cor1(2,:), cor1(3,:), cor1(1,:),ProjectSettings.instance.selfCal.y_axis);
 clear cor1

  tmp= scanPos(6,:)';   %
  eul=tmp;eul(1)=tmp(3);eul(3)=tmp(1);
  R = eul2rotm(eul,'ZYX');
  T = tmp(4:6)*0.001;  
  X1 = R*X1+T;
%                
   
  ptCloud = pointCloud(X1');
  clear X1
%   ptCloud.Intensity = scan_data.intens(:);
%   pcwrite(ptCloud,[filename(1:end-4) '_Cor0524.ply']);
  pcwrite(ptCloud,[filename(1:end-4) '_TCs12345678.ply'],'PLYFormat','binary');
  
  
  
  
 
 p_kap = Results.x_ap;
 offIndex = [1 2 3 4 7 ];
 p_kap(offIndex) = p_kap(offIndex) .*1000;
 
 raw1 = [scan_data.rng(:)'*0.001; scan_data.az(:)'; scan_data.el(:)'];
 cor1 = NISTModel.NIST_fwd(raw1,p_kap,'NIST10');
 
 % Transform the corrected observations into Cartesian system
  X1 = polar2cart(cor1(2,:), cor1(3,:), cor1(1,:),ProjectSettings.instance.selfCal.y_axis);
  
% %  % transform coordinates to the reference system
%   tmp= diffPos;   %
%   eul=tmp;eul(1)=tmp(3);eul(3)=tmp(1);
%   R = eul2rotm(eul,'ZYX');
%   T = diffPos(4:6)*0.001;  
%   X1 = R*X1+T;
%                   
  
  ptCloud = pointCloud(X1');
  ptCloud.Intensity = scan_data.intens(:);
  pcwrite(ptCloud,[filename(1:end-4) '_Cor0430.ply']);
  
  filename = 'J:\Bonn\ZF\Wall\ExportSOCS\S1F2_3mm.mat';
  load(filename);
  raw1 = [scan_data.rng(:)'*0.001; scan_data.az(:)'; scan_data.el(:)'];
  cor1 = NISTModel.NIST_fwd(raw1,p_kap,'NIST10');
 % Transform the corrected observations into Cartesian system
  X1 = polar2cart(cor1(2,:), cor1(3,:), cor1(1,:),ProjectSettings.instance.selfCal.y_axis);
  ptCloud = pointCloud(X1');
  ptCloud.Intensity = scan_data.intens(:);
  pcwrite(ptCloud,[filename(1:end-4) '_Cor0430.ply']);
  

  