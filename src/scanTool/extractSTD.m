% extract std of TCE
% directory = 'J:\Bonn\Faro\Targets\Wall_new\Scan_1001';

directory = 'J:\Bonn\ZF\Wall\Targets\S1F1';

% directory = 'J:\Bonn\RTC360\RAW\Targets\setup1';
directory = 'J:\Bonn\ZF\Export_SOCS\targets\setup1';
directory = 'J:\Bonn\Faro\Targets\Calibration\Scan_000';



fileList = dir(fullfile(directory, '*.mat'));

nFile = size(fileList,1);
sigma = zeros(nFile,1);

for i=1:nFile
    load([directory '\' fileList(i).name]);
    sigma(i) = std(TCE.GHM.v)*1000;
end

figure;
hold on
plot(sigma,'*');
ylabel('plane fitting sigma (mm)');
xlabel('target ID');

legend('RTC360', 'ZF Imager','Faro 120s');