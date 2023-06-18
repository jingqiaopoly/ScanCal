% filePara = 'J:\Bonn\RTC360\Result\2106020936set_1(5)_1(6)_PP.mat';% 2106021454set_1(5)_1(6)_TC  2106071054set_0(1)_0(2)_IF9000
% load(filePara);
% % Read .txt file with X Y Z Intensity and conduct calibration
% directory = 'J:\Bonn\RTC360\RAW\Targets\setFace56\s6f2';
% iface =2;


% filePara = 'J:\Bonn\ZF\Export_SOCS\Result\2106200946set_1(3)_1(4)_PPestPos.mat';% 2106210942set_1(3)_1(4)_TCs34estPos  2106192320set_0(3)_0(4)_IFestPos
% load(filePara);
% % Read .txt file with X Y Z Intensity and conduct calibration
% directory = 'J:\Bonn\ZF\Export_SOCS\targets\setFace34\s4_f2';
% iface =2;

filePara = 'J:\Bonn\Faro\Result\2106211747set_0(1)_0(2)_0(3)_0(4)_0(5)_0(6)_0(7)_0(8)_TC_LichtiSys.mat';% 2106152029set_0(1)_0(2)_0(3)_0(4)_0(5)_0(6)_0(7)_0(8)_PP_LichtiSys 2106211747set_0(1)_0(2)_0(3)_0(4)_0(5)_0(6)_0(7)_0(8)_TC_LichtiSys
load(filePara);
% Read .txt file with X Y Z Intensity and conduct calibration
directory = 'J:\Bonn\Faro\Targets\Calibration\s12345678Cali\s6f1';
iface =1;


fileList = dir(fullfile(directory, '*.txt'));
for i=1:length(fileList)
    filename = [directory '\' fileList(i).name];
    fileID = fopen(filename,'r');
    formatSpec = '%f %f %f %f';
    sizeA = [4 Inf];
% 
%     formatSpec = '%f %f %f %f %f %f %f';
%     sizeA = [7 Inf];
    A = fscanf(fileID,formatSpec, sizeA);
    fclose(fileID);
    
    raw = A(1:3,:);
    %Get polar coordinates
    [raw(2,:), raw(3,:), raw(1,:)] = cart2polar(raw, ones(size(raw,2),1).*iface, ProjectSettings.instance.selfCal.y_axis);
    %  raw1(1,:) = raw1(1,:).*0.001;   
    cor = NISTModel.NIST_fwd(raw,p_kap,ProjectSettings.instance.selfCal.model);
    % Transform the corrected observations into Cartesian system
    X1 = polar2cart(cor(2,:), cor(3,:), cor(1,:),ProjectSettings.instance.selfCal.y_axis);
    clear cor
    
    A(1:3,:) = X1;
    outfile = [filename(1:end-4) 'cor.txt'];
    fileID = fopen(outfile,'w');
    formatSpec = '%.8f %.8f %.8f %.6f \n';
    A = A(1:4,:);
    fprintf(fileID,formatSpec,A);
    fclose(fileID);
end



