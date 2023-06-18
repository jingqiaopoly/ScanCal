% Output corrected coordinates
 filename = 'J:\Bonn\ZF\Wall\ExportSOCS\S1F1_wall.pcd';
 filePara = 'J:\Bonn\ZF\Export_SOCS\Result\2105121005set_0(1)_0(2)_IF_Feature20000Removedtop.mat';
 
 iset =1;
 
 ptCloud = pcread(filename); 
 load(filePara);
 
 pts = ptCloud.Location';
 cart2polar();
 
 
 raw1 = [scan_data.rng(:)'*0.001; scan_data.az(:)'; scan_data.el(:)'];
 
 cor1 = NISTModel.NIST_fwd(raw1,p_kap,'NIST8');
 clear raw1
 
 % Transform the corrected observations into Cartesian system
  X1 = polar2cart(cor1(2,:), cor1(3,:), cor1(1,:));
  clear cor1
  
% % % % %  % transform coordinates to the reference system
%   tmp= diffPos;   %
%   eul=tmp;eul(1)=tmp(3);eul(3)=tmp(1);
%   R = eul2rotm(eul,'ZYX');
%   T = diffPos(4:6)*0.001;  
%   X1 = R*X1+T;

  tmp= scanPos(1,:)';   %
  eul=tmp;eul(1)=tmp(3);eul(3)=tmp(1);
  R = eul2rotm(eul,'ZYX');
  T = tmp(4:6)*0.001;  
  X1 = R*X1+T;
                  
                  
  
  ptCloud = pointCloud(X1');
  clear X1
  
   
  pcwrite(ptCloud,[filename(1:end-4) '_Cor18fixP.ply']);


% Output corrected coordinates
 filename = 'J:\Bonn\ZF\Export_SOCS\setup3_24mm.mat';
 filePara = 'D:\Codes\Calibration_Tomislav\Target-Based Calibration CKA v2.0_GUI\2 Calibration\results\Z+F Imager xxxx_30-Apr-2021_15_06_27.mat';
 
 load(filename);
 load(filePara);
 p_kap = Results.x_ap;
 offIndex = [1 2 3 4 7 ];
 p_kap(offIndex) = p_kap(offIndex) .*1000;
 
 raw1 = [scan_data.rng(:)'*0.001; scan_data.az(:)'; scan_data.el(:)'];
 
 cor1 = NISTModel.NIST_fwd(raw1,p_kap,'NIST10');
 
 % Transform the corrected observations into Cartesian system
  X1 = polar2cart(cor1(2,:), cor1(3,:), cor1(1,:));
  
% %  % transform coordinates to the reference system
%   tmp= diffPos;   %
%   eul=tmp;eul(1)=tmp(3);eul(3)=tmp(1);
%   R = eul2rotm(eul,'ZYX');
%   T = diffPos(4:6)*0.001;  
%   X1 = R*X1+T;
%                   
                  
  
  ptCloud = pointCloud(X1');
  
   
  pcwrite(ptCloud,[filename(1:end-4) '_Cor_TCETom.ply']);