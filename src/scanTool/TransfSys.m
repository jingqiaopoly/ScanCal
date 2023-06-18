% Calculate the polar coordinates of FARO 120s data (x-axis)
filename = 'J:\Bonn\Faro\Export\CalibrationRaw\Scan_007.mat';
load(filename);

pts = polar2cart(scan_data.az(:)', scan_data.el(:)',...
             scan_data.rng(:)',1);

% figure;
% plot3(pts(1,1:100:end),pts(2,1:100:end),pts(3,1:100:end),'Marker','.','LineStyle','none','MarkerSize',8);


[az, el, rg] = cart2polar(pts, ones(size(pts,2),1), 0);
scan_data.az = reshape(az, size(scan_data.az)); 
scan_data.el = reshape(el, size(scan_data.az));
scan_data.rng = reshape(rg, size(scan_data.az)); 

% pts= scan_data.pts;
% hold on
% plot3(pts(1,1:100:end),pts(2,1:100:end),pts(3,1:100:end),'Marker','.','LineStyle','none','MarkerSize',8);

save([filename(1:end-4) '_xAxis'], 'scan_data', 'meta_data', '-v7.3');

