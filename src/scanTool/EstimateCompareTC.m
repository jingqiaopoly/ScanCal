% Estimate and Compare TC from different methods
function EstimateCompareTC(path)
% path containing the calibrated scan files and the initial target center
   % get all the to be processed point clouds in .pcd
   path ='G:\RTC360_Bonn\Targets_Calibration\IP_mat\';
   
   %% Parameter setting
    % (stochastic) information about the scanner
   sig.std_r_c = 1/1000;
   sig.std_r_p = 1/1000;
   sig.std_h = 0.9/3600/180*pi;
   sig.std_v = 0.9/3600/180*pi;
   sig.omega = 0.0035;
   sig.gamma = 0.0003;
   type = '8fold';
   targetSize = 270;
   maxDistance = 20;
   Radius = targetSize*3/4;
    
   %import the inital target coordinates in global system
   data=importdata([path, 'TCEglobal.txt']);
   targetNames = data.textdata;
   nTarget = size(iniTC,1);
   fileList = dir(fullfile(path, '*.mat'));
   
   for i=1:length(fileList)
       filename = [fileList(i).folder,'\',fileList(i).name]; 
       load(filename);
       %output file
       index_ = strfind(filename, '\'); 
       eIndex = index_(end)+4;
       targetFile = [filename(1:eIndex) '_TCE.txt'];
       targetfileID = fopen(targetFile,'w');
       TCEall = [];
        
       pts = scan_data.pts; 
       intens = scan_data.intens;   
       iniTC = data.data.*1000;
       % Transform the initial TC into SOCS
       [ Rdum, Tdum, iniTC]= posePara2MatrixInv(meta_data.scanPos, iniTC');
       
       for it=1:nTarget
            % get points in the neighour
            near_id = (iniTC(1,it)-pts(1,:)).^2+(iniTC(2,it)-pts(2,:)).^2+(iniTC(3,it)-pts(3,:)).^2< Radius*Radius;
            pts1 = pts(:,near_id);
            intens1 = intens(near_id);

            % get points on the plane and the approx center
            ptCloudIn = pointCloud(pts1');
            [model,inlierIndices,outlierIndices] = pcfitplane(ptCloudIn,maxDistance,'MaxNumTrials',20) ;
            pts1 = pts1(:,inlierIndices);
            intens1 = intens1(inlierIndices);
            center1 = median(pts1,2);
            near_id1 = (center1(1)-pts1(1,:)).^2+(center1(2)-pts1(2,:)).^2+(center1(3)-pts1(3,:)).^2< targetSize*targetSize/2; %sum((pt-allPts).^2)< Radius2; %
            intens1 = intens1(near_id1); 
            pts1 = double(pts1(:,near_id1));
            ap_center = mean(pts1,2);

            % TCE = tce(pts1'.*0.001, intens1, A(it,2:4).*0.001, targetSize*0.707*0.001, sig, type);
            TCE = tce(pts1'.*0.001, intens1', ap_center'.*0.001, targetSize*0.707*0.001, sig, type);
            TCEall = [TCEall TCE];
            fprintf(targetfileID,'%4s, %4.6f, %4.6f, %4.6f\n',string(targetNames(it)),TCE.tc3D(1),TCE.tc3D(2),TCE.tc3D(3));
       end
       save(targetFile(1:end-4),'TCEall','-v7.3');
       fclose(targetfileID); 
       
   end

end