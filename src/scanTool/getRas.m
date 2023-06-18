function [Ras] = getRas(hz, eps)
% Ras: rotation matrix from the S-frame to the Aframe


Rhz = [ cos(hz) sin(hz) 0;
       -sin(hz) cos(hz) 0;
          0       0     1];
      
Reps = [ sin(eps)  0  -cos(eps);
            0      1      0    ;
         cos(eps)  0   sin(eps)];
     
Ras = Rhz*Reps;
end