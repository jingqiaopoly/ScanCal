% Downsample the 3mm data to 24mm
sub_samp = 8;
path = 'J:\ETHcompus\scanData';
fileList = dir(fullfile(path, '*Scan.mat'));

 for i = 1:size(fileList,1)
    filename = [fileList(i).folder,'\',fileList(i).name]; 
    load(filename)
    [scan_data] = downSampleScandata(scan_data, sub_samp);
    save([filename(1:end-4) '24mm'],'scan_data','meta_data','-v7.3');         
 end

