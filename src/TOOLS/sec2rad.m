function [rad] = sec2rad(sec)
%sec2rad     - Transform angle in sec into radiant
%
%  [rad] = sec2rad(sec)
%
%Input: -------------------------------------------------------------------
%sec   angle in sec ["]
%
%Output: ------------------------------------------------------------------
%rad   angle in radiant
rad = sec/3600/180 * pi;

end