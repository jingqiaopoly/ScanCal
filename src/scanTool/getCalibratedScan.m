 filename = 'H:\Bonn\RTC360\RAW\setup1_3mm_Scan.mat';
 filePara = 'H:\Bonn\RTC360\Result\2107152222set_1(1)_1(2)_1(5)_1(6)_PP_NIST10.mat';

%  filename = 'J:\ETHcompus\scanData\setup14_2Scan1.mat';
%  filePara = 'J:\ETHcompus\Result\2108300957set_14(2)_14(2)_PP.mat'; 

% filename = 'G:\ETHcompus\scanData\setup16_1Scan1.mat';
% filePara = 'G:\ETHcompus\Result\2109121234set_16(11)_16(12)_PP.mat'; 

% filename = 'G:\DeliveryHallandRFL\scanData\setup1_f12_24mm.mat';
% filePara = 'G:\DeliveryHallandRFL\Result\2109281351set_49(11)_49(21)_49(31)_PP.mat';

 model ='NIST10';

 load(filename);
 load(filePara); 
 raw1 = [scan_data.rng(:)'*0.001; scan_data.az(:)'; scan_data.el(:)']; 
 cor1 = NISTModel.NIST_fwd(raw1,p_kap,model);
 clear raw1
 cor1(1,:) = cor1(1,:).*1000; 
 scan_data.rng = reshape(cor1(1,:), size(scan_data.rng));
 scan_data.az = reshape(cor1(2,:), size(scan_data.rng));
 scan_data.el = reshape(cor1(3,:), size(scan_data.rng));
 
 meta_data.scanPos = scanPos(1,:);
 save([filename(1:end-4) '_PP1256c.mat'],'scan_data','meta_data','-v7.3');

%  %%%%%%%%%%%%%%%%%%%%
%  % Transform the corrected observations into Cartesian system 
%  [ R, T, pts]= posePara2Matrix(scanPos(1,:), scan_data.pts);
%  ptCloud = pointCloud(pts'.*0.001);
%  pcwrite(ptCloud,[filename(1:end-4) '_PP1256c.ply'],'PLYFormat','binary');
%  %%%%%%%%%%%%%%%%%%%%%%%%

 filename = 'F:\DeliveryHallandRFL\scanData\setup12_3mm_PP123c.mat';
% filename = 'G:\ETHcompus\scanData\setup16_1Scan2.mat';
%  filename = 'G:\DeliveryHallandRFL\scanData\setup2_f12_24mm.mat';
 load(filename);
 raw1 = [scan_data.rng(:)'*0.001; scan_data.az(:)'; scan_data.el(:)']; 
 cor1 = NISTModel.NIST_fwd(raw1,p_kap,model);
 clear raw1 
 cor1(1,:) = cor1(1,:).*1000; 
 scan_data.rng = reshape(cor1(1,:), size(scan_data.rng));
 scan_data.az = reshape(cor1(2,:), size(scan_data.rng));
 scan_data.el = reshape(cor1(3,:), size(scan_data.rng));
  
 meta_data.scanPos = scanPos(2,:);
 save([filename(1:end-4) '_IP_2203231915.mat'],'scan_data','meta_data','-v7.3');
 
%  [ R, T, pts]= posePara2Matrix(scanPos(2,:), scan_data.pts);
%  ptCloud = pointCloud(pts'.*0.001);
%  pcwrite(ptCloud,[filename(1:end-4) '_PP13c.ply'],'PLYFormat','binary');



