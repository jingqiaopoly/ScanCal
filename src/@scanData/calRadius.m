function  [Radius,centroid] = calRadius(pt, points,dAZ,numPtLine)
% Calculate the radius for plane patches
% setups:  pixelSize=maxSpace/10; R=sqrt(2)/2*gridSize*pixelSize
%
    % 
    % Check input
    if nargin < 4
       numPtLine = 20; %number of point on each line 
    end 
    numPtR = floor(numPtLine*sqrt(2)/2); % number of point on the length of a radius
    
    % To calculate the suitable radius for this corepoint
    % 1. Narrow down the radius temperaly to have a better plane
    near_id = (pt(1)-points(1,:)).^2+(pt(2)-points(2,:)).^2+(pt(3)-points(3,:)).^2< 100*100;
    sub_points = points(:,near_id);
    % 2. PCA to calculate incidence of the plane
    [coeff,score,latent]  = pca(sub_points');
    centroid   = mean(sub_points,2);
    distance = norm(centroid);
    try
       incidence = acos(abs(dot(centroid./distance,coeff(:,3))))*180/pi;
       spaceV = distance*dAZ/cos(incidence/180*pi);
       spaceH = distance*dAZ*norm(pt(1:2))/norm(pt);
       space = (spaceV +spaceH)/2.0;
       Radius = space*numPtR;
    catch
%        disp('Radius calculation failed, use default'); 
       Radius = 200;
    end
       
end