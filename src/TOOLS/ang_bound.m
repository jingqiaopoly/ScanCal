function [ang_out] = ang_bound(ang_in)
%cmn_ang_bound     - Bound all input angles to the interval -pi < ang <= pi
%
%  [ang_out] = ang_bound(ang_in)
%
%Input: -----------------------------------------------------------------------------
%ang_in     Array of input angles [rad]
%
%Output: ----------------------------------------------------------------------------
%ang_out    Array of output angles bounded to the intervall ]-pi, pi]
%
%------------------------------------------------------------------------------------
%First adjust all angles to be between zero and 2*pi
ang_out  = mod(ang_in, 2*pi);

%Wrap angles larger than pi
idx            = ang_out > pi;
ang_out(idx)   = ang_out(idx) - 2*pi;