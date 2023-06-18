function [data_f12,Meta,numSetup] = loadData(obj,locDirectory, sub_samp)
    % LOADDATA load the .mat scan file with scan_data and meta_data
    % These data are seperated into face1 and face2
    % data are spit into data_f12
    %     success = loadData(file_path, job_nr, setup_nr, sub_samp);
    %     success = loadData(file_path, virtual_scan_name, sub_samp);
    % Input:
    %    sub_samp      Sub sampling factor, if not all points
    %                  should be imported (default: 1)
    %
    % Output:
    %    success       returns true, if the import workflow was
    %                  successfull otherwise false
    %--------------------------------------------------------------

  % Check inputs
    if nargin < 2
        locDirectory = [];
    end
    if nargin < 3
        sub_samp = 1;
    end
 
  % Check Scanner Type
  instr_type = 'TMP1';
  if strcmp(instr_type,'TMP1')
      % Import "Double-Face" Scan Data
        if isempty(locDirectory)
           locDirectory = uigetdir('','Select Folder with .mat scan data');
           [FileName,PathName] = uigetfile('*.mat','Open Virtual Scan ...',...
                    locDirectory,'MultiSelect', 'on');
        else
            fileList  = dir(fullfile(locDirectory, '*.mat'));
            FileName = {fileList.name};
        end
        if ischar(FileName)
            numSetup = 1;
            Data(numSetup) = scanData(); %initalize scanData and metaData
            Meta(numSetup) = metaData(); %initalize scanData and metaData
            load([locDirectory,'/',FileName],'meta_data','scan_data');
            Data(1) = scan_data;
            Meta(1) = meta_data;
        else
            numSetup = size(FileName,2);
            Data(numSetup) = scanData(); %initalize scanData and metaData
            Meta(numSetup) = metaData(); %initalize scanData and metaData
            for i=1:numSetup
                load([locDirectory,'/',char(FileName(i))],'meta_data','scan_data');
                Data(i) = scan_data;
                Meta(i) = meta_data;
            end
        end
        
        
       [Data]= downSampleScandata(Data, sub_samp);
       
      % Split DoubleFace Scan into two separate datasets
       data_f12(2,numSetup)= scanData();
       for i=1:numSetup
            face12 = Meta(i).face12;
            if(face12(1)*face12(2)==1) %both faces
               [data_f12(1,i), data_f12(2,i)] = scanData.divideScanCyclone(Data(i));  %extractDoubleScan
            elseif(face12(1)==1) %only face1 data, may have seldom errorous face2
                data_f12(1,i)= Data(i);
            else %only face2 data
                data_f12(2,i)= Data(i);
            end
       end  
  end
  
end
  
  
  
  
  
  
  
  
  
  
  
  
  
  