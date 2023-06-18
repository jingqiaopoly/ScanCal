function transMAT2PLY(filename)

    %filename = 'J:\Bonn\RTC360\RAW\setup1_3mm_Scan_PP1256c.mat';

    load(filename);
    cor1 = [scan_data.rng(:)'*0.001; scan_data.az(:)'; scan_data.el(:)'];
    X1 = polar2cart(cor1(2,:), cor1(3,:), cor1(1,:));
    clear cor1

%     tmp= meta_data.scanPos(1,:)';   %
%     eul=tmp;eul(1)=tmp(3);eul(3)=tmp(1);
%     R = eul2rotm(eul(1:3)','ZYX');
%     T = tmp(4:6)*0.001;  
%     X1 = R*X1+T;

    ptCloud = pointCloud(X1');
    clear X1
    ptCloud.Intensity = scan_data.intens(:);
    pcwrite(ptCloud,[filename(1:end-4) 'SOCS.ply'],'PLYFormat','binary');
end