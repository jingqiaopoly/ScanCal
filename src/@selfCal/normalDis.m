function [dist_2_to_1, cp1, cp2, normal1] = normalDis(p_kap,p_pos, pt1, pt2, ...
                    iface1,iface2 ,iset1,iset2, obj)        
  % normalDis 
  % Calculate the normal distances between two point clouds
  % Input:
  % p_kap         Array with scanner calibration parameters
  % p_pos         Array with scanner pose parameters
  % pt1           Struct with point coordinates on each PP from point cloud 1
  % pt2           Struct with point coordinates on each PP from point cloud 2 
  % iface1        Array with face information of PP from point cloud 1            
  % iface2        Array with face information of PP from point cloud 2 
  % iset1         setup number of point cloud 1
  % iset2         setup number of point cloud 2
  % obj           Instance of selfCal
  % 
  % Output:
  %   dist_2_to_1  normal distances between two corresponding patches 
  %   cp1          centroid of each patch of PC1
  %   cp2          centroid of each patch of PC2
  %   normal1      normal vectors of plane patches
  % $Author: Jing Qiao $  
  % $Contact: jingqiao@connect.polyu.hk 
  % $Date: 2021/02/14 $ 
  % -----------------------------------------------------------------------
 
  nPlane = size(pt1,2);
  P_B_1 = zeros(3,nPlane);
  P_B_2 = zeros(3,nPlane);
  normal1 = zeros(3,nPlane);
  normal2 = zeros(3,nPlane);
  sigma1 = zeros(1,nPlane);
  sigma2 = zeros(1,nPlane);
  for iplane=1:nPlane
      % 1. Transform coordinates from cartesian to polar
      corept1 = pt1(iplane).pts;  
      [az1,el1,rng1] =  cart2polar(corept1,ones(1,size(corept1,2))*iface1(iplane), ProjectSettings.instance.selfCal.y_axis);
      raw1 = [rng1*0.001; az1; el1];

      corept2 = pt2(iplane).pts;  
      [az2,el2,rng2] =  cart2polar(corept2,ones(1,size(corept2,2))*iface2(iplane),ProjectSettings.instance.selfCal.y_axis);
      raw2 = [rng2*0.001; az2; el2];

      % 2. Perform forward point projection to correct the observations
      cor1 = NISTModel.NIST_fwd(raw1,p_kap,obj.model);
      cor2 = NISTModel.NIST_fwd(raw2,p_kap,obj.model);
      
      % 3. Transform the corrected observations back to cartesian
      X1 = polar2cart(cor1(2,:), cor1(3,:), cor1(1,:),ProjectSettings.instance.selfCal.y_axis);
      X1 = X1*1000;
      X2 = polar2cart(cor2(2,:), cor2(3,:), cor2(1,:),ProjectSettings.instance.selfCal.y_axis);
      X2 = X2*1000;
            
      %4. Calculate the normal vector1
      [normal1(:,iplane), P_B_1(:,iplane), sigma1(iplane)] = ...
                    fitplane(X1,0);
      %4. Calculate the normal vector2
      [normal2(:,iplane), P_B_2(:,iplane), sigma2(iplane)] = ...
                    fitplane(X2,0);
  end
  
    cp1=P_B_1;
    cp2=P_B_2;
  
  % Convert the point coordinates at the setupS to the ref system  
  if(iset1~=iset2) %iset1=refSet
      if iset1~= obj.refSet
         if(iset1<obj.refSet)
            k=1;
         else
            k=2;
         end
        %Roattion matrix
        tmp = p_pos(6*iset1-6*k+1:6*iset1-6*k+3); 
        eul=tmp;eul(1)=tmp(3);eul(3)=tmp(1);
        R = eul2rotm(eul,'ZYX');
        %Translation matrix
        T = p_pos(6*iset1+4-6*k:6*iset1+6-6*k);
        n_pts = size(P_B_1,2);
        P_B_1= R*P_B_1 + repmat(T,1,n_pts);
        normal1 = R*normal1;
      else
        %Roattion matrix
        tmp = obj.scanPos(obj.refSet,1:3); 
        eul=tmp;eul(1)=tmp(3);eul(3)=tmp(1);
        R = eul2rotm(eul,'ZYX');
        %Translation matrix
        T =obj.scanPos(obj.refSet,4:6)';
        n_pts = size(P_B_1,2);
        P_B_1= R*P_B_1 + repmat(T,1,n_pts);
        normal1 = R*normal1;
      end
      
      
      if iset2~=obj.refSet
         if(iset2<obj.refSet)
            k=1;
         else
            k=2;
         end
        %Roattion matrix
        tmp = p_pos(6*iset2-6*k+1:6*iset2-6*k+3); %The roation angles may later from IMU 
        eul=tmp;eul(1)=tmp(3);eul(3)=tmp(1);
        R = eul2rotm(eul','ZYX');
        %Translation matrix
        T = p_pos(6*iset2+4-6*k:6*iset2+6-6*k);
        n_pts = size(P_B_2,2);
        P_B_2= R*P_B_2 + repmat(T,1,n_pts);
        normal2 = R*normal2;
      else
        %Roattion matrix
        tmp = obj.scanPos(obj.refSet,1:3); %The roation angles may later from IMU 
        eul=tmp;eul(1)=tmp(3);eul(3)=tmp(1);
        R = eul2rotm(eul','ZYX');
        %Translation matrix
        T =obj.scanPos(obj.refSet,4:6)';
        n_pts = size(P_B_2,2);
        P_B_2= R*P_B_2 + repmat(T,1,n_pts); 
        normal2 = R*normal2;
      end  
  end

% Calculate distance along normal vector between Cloud1 and Cloud2
  index =  find(sigma2<sigma1);
  normal1(:,index)= normal2(:,index);
  dist_2_to_1 = dot(P_B_2-P_B_1,normal1);

end