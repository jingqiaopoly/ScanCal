%mat2ply
filename = 'F:\DeliveryHallandRFL\scanData\setup11_3mm.mat';


load(filename);

ptCloud = pointCloud(scan_data.pts'.*0.001);
ptCloud.Intensity = scan_data.intens(:);
pcwrite(ptCloud,[filename(1:end-4) '.ply'],'PLYFormat','binary');

%mat2ply
filename = 'F:\DeliveryHallandRFL\scanData\setup12_3mm.mat';


load(filename);

ptCloud = pointCloud(scan_data.pts'.*0.001);
ptCloud.Intensity = scan_data.intens(:);
pcwrite(ptCloud,[filename(1:end-4) '.ply'],'PLYFormat','binary');