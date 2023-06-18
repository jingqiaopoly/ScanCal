%STARTUP_CUSTOM  - Sets the path variables for selected sub-modules and 
%                  calls the intialization functions
%
%  Script: startup_custom
%
%--------------------------------------------------------------------------

          
%% Get settings & set paths
settings = ProjectSettings.instance;


base_path = settings.paths.base;

%% Add paths
% Actual path
a_path = pwd;

addpath(genpath([base_path,'TOOLS']));
addpath(genpath([base_path,'scanTool']));
addpath(genpath([base_path,'Pointcloudtools']));
%addpath(fullfile(base_path,'significanceTest'));

cd(a_path);
% -------------------------------------------------------------------------
% ====================================================== END startup_custom
