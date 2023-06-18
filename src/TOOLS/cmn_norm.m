function [v_norm] = cmn_norm(matrix)
%cmn_norm     - Calculat the 2-norm of each column vector in the input matrix
%
%  [v_norm] = cmn_norm(matrix)
%
%Input: -----------------------------------------------------------------------------
%Matrix     Matrix of column vectors
%
%Output: ----------------------------------------------------------------------------
%v_norm     2-norm of each column vector of matrix
%
%Remark: ----------------------------------------------------------------------------
%Calculation:
%                 v_norm = sqrt( sum(matrix.^2) );
%
%
%------------------------------------------------------------------------------------
%Calculate the 2-norm
v_norm = sqrt( sum(matrix.^2) );
