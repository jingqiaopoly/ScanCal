function [scan_data, meta_data] = loadPtx(filepath, read_rgb, sample, twoFace)
% Transform the .ptx format point clouds into the format of the calibration program: scan_data, meta_data      
     if nargin<4
         twoFace = 1; %whether the scan contains two-face observations
     end
     if nargin<3
        sample = 1; % sample interval of the raw data
     end
     if nargin<2
        read_rgb = 0; %whether contain rgb info
     end
    
     % Opens a ptx file in preparation of partly data import and reads the header
     file = fopen(filepath, 'r');

     %Read PTX header
     %No. of scan lines
     no_l = str2num(fgetl(file));
     %No. of points per line
     no_p = str2num(fgetl(file));
     
     for i=1:4
        line_ex = fgetl(file);  % read line excluding newline character
     end
     T1 = zeros(4,4);
     for i=1:4
         line_ex = fgetl(file);
         group = strsplit(line_ex);
         T1(i,:)=[str2num(group{1})    str2num(group{2})  str2num(group{3}) str2num(group{4})   ];
     end

     T= T1';
        % % %T=[   R11 R12 R13 dX;
        % % %      R21 R22 R23 dY;
        % % %      R31 r32 r33 dz;
        % % %      0    0   0   1]
     R=T(1:3,1:3);
     dX=T(1,4)*1000;dY=T(2,4)*1000;dZ=T(3,4)*1000;

     eulZYX = rotm2eul(R,'ZYX'); % c = eulZYX(1)  b = eulZYX(2)  a = eulZYX(3)
     p_pos =[eulZYX(3),eulZYX(2),eulZYX(1), dX,dY,dZ]; %a b c tx ty tz   
    

     scan_data = scanData();
     %Initialize object of class cmn.data.cls_hds_scan_meas()
     scan_data.az            = zeros(no_p, no_l);
     scan_data.el            = zeros(no_p, no_l);
     scan_data.rng           = zeros(no_p, no_l);
     scan_data.intens        = zeros(no_p, no_l);
     scan_data.status        = zeros(no_p, no_l);
          
     if read_rgb
         frmt_str = '%f %f %f %f %d %d %d';
         rgb = uint8(zeros(no_p, no_l, 3));
     else                                        
         frmt_str = '%f %f %f %f %*[^\n]';
         rgb = [];
     end
          
      for i_l = 1:round(no_l/2)
          try
              lines = textscan(file, frmt_str, no_p);
              data = cell2mat(lines(1:4));
              nan_idx = (cmn_norm(data(:, 1:3)') < 1e-9);
              data(nan_idx, 1:3) = NaN;
              data(nan_idx, 4)   = 0.5;
              if read_rgb
                 rgb(:, i_l, :) = uint8(cell2mat(lines(5:7)));
                 rgb(nan_idx, i_l, :) = 0;
              end
              [az, el, rg] = cart2polar((data(:, 1:3)' * 1000.0), ones(1,size(data,1)),ProjectSettings.instance.selfCal.y_axis );

              scan_data.az(:, i_l)     = az;
              scan_data.el(:, i_l)     = el;
              scan_data.rng   (:, i_l)     = rg;
              scan_data.intens(:, i_l) = data(:, 4);
              scan_data.face(:, i_l) = ones(size(data,1),1);
              scan_data.status(:, i_l)     = 1;
              clear lines data nan_idx az el rg;
          catch
              warning('Cannot read this part of ptx file!');
              scan_data.az(:, i_l)     = zeros(no_p, 1);
              scan_data.el(:, i_l)     = zeros(no_p, 1);
              scan_data.rng   (:, i_l)     = zeros(no_p, 1);
              scan_data.intens(:, i_l) = 0.5 * ones(no_p, 1);
              scan_data.status(:, i_l)     = zeros(no_p, 1);
          end
      end
     
      if twoFace ==1
          face = 2;
      else
          face = 1;
      end

      for i_l = round(no_l/2)+1:no_l
          try
              lines = textscan(file, frmt_str, no_p);
              data = cell2mat(lines(1:4));
              nan_idx = (cmn_norm(data(:, 1:3)') < 1e-9);
              data(nan_idx, 1:3) = NaN;
              data(nan_idx, 4)   = 0.5;
              if read_rgb
                 rgb(:, i_l, :) = uint8(cell2mat(lines(5:7)));
                 rgb(nan_idx, i_l, :) = 0;
              end
              [az, el, rg] = cart2polar((data(:, 1:3)' * 1000.0), ones(1,size(data,1)).*face,ProjectSettings.instance.selfCal.y_axis);

              scan_data.az(:, i_l)     = az;
              scan_data.el(:, i_l)     = el;
              scan_data.rng   (:, i_l)     = rg;
              scan_data.intens(:, i_l) = data(:, 4);
              scan_data.face(:, i_l) = ones(size(data,1),1).*face;
              scan_data.status(:, i_l)     = 1;
              clear lines data nan_idx az el rg ;
          catch
              warning('Cannot read this part of ptx file!');
              scan_data.az(:, i_l)     = zeros(no_p, 1);
              scan_data.el(:, i_l)     = zeros(no_p, 1);
              scan_data.rng   (:, i_l)     = zeros(no_p, 1);
              scan_data.intens(:, i_l) = 0.5 * ones(no_p, 1);
              scan_data.status(:, i_l)     = zeros(no_p, 1);
          end
      end
      fclose(file);

      % sample data
      scan_data.az = scan_data.az(1:sample:end, 1:sample:end) ;
      scan_data.el = scan_data.el(1:sample:end, 1:sample:end) ;
      scan_data.rng = scan_data.rng(1:sample:end, 1:sample:end) ;
      scan_data.intens = scan_data.intens(1:sample:end, 1:sample:end) ;
      scan_data.status = scan_data.status(1:sample:end, 1:sample:end) ;
      scan_data.face = scan_data.face(1:sample:end, 1:sample:end) ;
      
      % Filter data
      index = find(scan_data.rng(:)>80*1000);
      scan_data.rng(index) =  NaN;
      
      
      
      % Upside down if from P50
      EL = scan_data.el(:,1);
      sumEL = nansum(diff(EL));
      if sumEL>0
          scan_data = flipudScan(scan_data);
      end
      
      
    %metadata
    meta_data = metaData();
    meta_data.scanPos = p_pos; %p_pos=[0 0 0 0 0 0];
    %Judge whehter the data has two-face observations and rotate for 360
    %Assuming the largest angle space is 1 degree
    if twoFace ==1
        meta_data.face12 = [1 1];
        meta_data.fullcycle = 0;%
    else
        meta_data.face12 = [1 0];
        meta_data.fullcycle = 1;%
    end

end