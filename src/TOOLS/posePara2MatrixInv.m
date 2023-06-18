function [ R, T, X]= posePara2MatrixInv(pose, X0)
%%
% INPUT: pose 6x1 array with rotation(rad) and offset parameters
%        X0    3xN array with point cartesian coordinate
% output: 
%        R roation matrix
%        T translation matrix
%        X  Transformed coordinates, X = inv(R)*(X0-T);


    tmp= pose(1:3);   
    eul=tmp;eul(1)=tmp(3);eul(3)=tmp(1);
    R = eul2rotm(eul,'ZYX');
   %Translation matrix
    T = pose(4:6)'; 
    
    if nargin>1
       X= inv(R)*(X0-T); %R*X0 + repmat(T,1,size(X0,2)); 
    end
end