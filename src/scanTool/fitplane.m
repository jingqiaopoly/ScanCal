function [normal_vec, centroid, sigma] = fitplane(pts, plot_variant)
  % FITPLANE Fits a plane into the passed 3d data and returns the normal 
  % vector, the centroidal point and the standard deviation (sigma)
  % Input:
  %   pts           (3xn) matrix containing the points as column vectors
  %   plot_variant  (1x1) 0: no plot
  %                       1: create new plot and clear old values
  %                       2: add new data into existing plot
  % 
  % Output:
  %   normal_vec    (3x1) normal vector to the fitted plane
  %   centroid      (3x1) Center point on the plane
  %   sigma         (1x1) Standard deviation from the points towards the
  %                       plane
  
  % Check input variables
    if nargin < 2
      plot_variant = 0;
    end
    
  % Check nuber of input points
    if size(pts,2) < 3
        centroid = [NaN NaN NaN]';
        normal_vec = [NaN NaN NaN]';
        sigma = NaN;
      return;
    end
  
  % Calculate the centroidal point
    centroid = mean(pts,2);
    r = pts - repmat(centroid,1,size(pts,2));
    xx = vecnorm(r(1,:),2,2)^2;
    yy = vecnorm(r(2,:),2,2)^2;
    zz = vecnorm(r(3,:),2,2)^2;
    xy = sum(r(1,:).*r(2,:));
    xz = sum(r(1,:).*r(3,:));
    yz = sum(r(2,:).*r(3,:));

  % Calculate determinants
    det_x = yy*zz - yz*yz;
    det_y = xx*zz - xz*xz;
    det_z = xx*yy - xy*xy;
    
  % Maximum determinant defines, which is the correct normal vector
    max_det = max([det_x,det_y,det_z]);
    normal_vec = zeros(3,1);
    switch max_det
      case det_x
        normal_vec = [det_x; xz*yz - xy*zz; xy*yz - xz*yy];
      case det_y
        normal_vec = [xz*yz - xy*zz; det_y; xy*xz - yz*xx];
      case det_z
        normal_vec = [xy*yz - xz*yy; xy*xz - yz*xx; det_z];
    end
    normal_vec = normal_vec/norm(normal_vec);
    
  % Calucalte the standard devations from the points
    dist_to_plane = dot(repmat(normal_vec,1,size(r,2)),r);
    sigma = std(dist_to_plane);
      
    if plot_variant>0
      figure(105);
      if plot_variant == 1
        clf;
      elseif plot_variant == 2
        hold on;
      end
      plot3(pts(1,:)*0.001,pts(2,:)*0.001,pts(3,:)*0.001,'.');
      hold on;
      plot3(centroid(1)*0.001,centroid(2)*0.001,centroid(3)*0.001,'x');
      t=-0:50;
      plot3(centroid(1)*0.001+t*normal_vec(1)*0.001,centroid(2)*0.001+t*normal_vec(2)*0.001,centroid(3)*0.001+t*normal_vec(3)*0.001);
      axis equal
      grid on;
      xlabel('X(m)')
        ylabel('Y(m)')
        zlabel('Z(m)')
    end
end