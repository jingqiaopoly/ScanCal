function [Data, Meta] = mergeScans()

     
      locDirectory = uigetdir('','Select Folder with .mat scan data');
      [FileName,PathName] = uigetfile('*.mat','Open Virtual Scan ...',...
                    locDirectory,'MultiSelect', 'on');
                
      numSetup = size(FileName,2);
      if numSetup~=2
            error(['Invalid scan number. Put two scans at the same setup with 180deg hz difference']);
      end
      

    Data = scanData(); %initalize scanData and metaData
    data_f12(2,2)= scanData();
    for i=1:2
        load([locDirectory,'/',char(FileName(i))],'meta_data','scan_data');
        [data_f12(1,i), data_f12(2,i)] = scanData.divideScanCyclone(scan_data);
    end
    
    %TODO: Judge whether the two scans have the same row, if not, remove the
    %extra rows in one of the scans
    
%     %rearrange the face1/2 data
%     Data.az = [data_f12(1,1).az  data_f12(1,2).az data_f12(2,2).az data_f12(2,1).az];
%     Data.el = [data_f12(1,1).el  data_f12(1,2).el data_f12(2,2).el data_f12(2,1).el];
%     Data.rng = [data_f12(1,1).rng  data_f12(1,2).rng data_f12(2,2).rng data_f12(2,1).rng];
%     Data.intens = [data_f12(1,1).intens  data_f12(1,2).intens data_f12(2,2).intens data_f12(2,1).intens];
%     Data.face = [data_f12(1,1).face  data_f12(1,2).face data_f12(2,2).face data_f12(2,1).face];
%     Data.status = [data_f12(1,1).status  data_f12(1,2).status data_f12(2,2).status data_f12(2,1).status];

 %rearrange the face1/2 data
    Data.az = [data_f12(1,1).az  data_f12(1,2).az data_f12(2,1).az data_f12(2,2).az];
    Data.el = [data_f12(1,1).el  data_f12(1,2).el data_f12(2,1).el data_f12(2,2).el];
    Data.rng = [data_f12(1,1).rng  data_f12(1,2).rng data_f12(2,1).rng data_f12(2,2).rng];
    Data.intens = [data_f12(1,1).intens  data_f12(1,2).intens data_f12(2,1).intens data_f12(2,2).intens];
    Data.face = [data_f12(1,1).face  data_f12(1,2).face data_f12(2,1).face data_f12(2,2).face];
    Data.status = [data_f12(1,1).status  data_f12(1,2).status data_f12(2,1).status data_f12(2,2).status];
 
    Meta = meta_data;
    Meta.fullcycle = 1;
end