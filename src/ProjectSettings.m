classdef ProjectSettings < handle
    %SETTINGS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(SetAccess=immutable,GetAccess=public)
               
        %CHANGE the base path according to system
        paths = struct(...
            'base','/Users/jingqiao/Documents/ScanCal/src/',...    %base path of this calibration software
            'result_folder','/Users/jingqiao/Documents/ScanCal/Result/'); %result path: the estimated parameters and plots are stored here   
        
       
    
       % To be used observations and paths for calibration
        selfCal = struct(...
            'model','NIST10',... % define the to be used calibration model, such as NIST8, NIST10....
             ... % The definations below define the to be estimated parameter of the models, reference values, initial values, sigmas 
             ... % 1) Define NIST2 related input
            'isEvalNIST2',[  1 ...    x1n       mm    beam offset along n
                             1 ...    x1z       mm    beam offset along z
                             1 ...    x2        mm    transit offset (horizontal)
                             1 ...    x3        mm    mirror offset
                             1 ...    x4        rad   vertical index offset
                             1 ...    x5n9n     rad   combination of beam tilt along n and vert. encoder ecc. along n 
                             1 ...    x5z7      RAD    combination of beam tilt along z and transit tilt
                             1 ...    x5z9z     rad   combination of beam tilt along z and vert. encoder ecc. along z
                             1 ...    x6        RAD    mirror tilt
                             1 ...    x8x       rad   horizontal encoder eccentricity along x
                             1 ...    x8y       rad   horizontal encoder eccentricity along y
                             1 ...    x10       mm    constant error in range
                             1 ...    X11a      rad   second order scale error in horizontal encoder 
                             1 ...    X11b      rad   second order scale error in horizontal encoder 
                             1 ...    X12a      rad   second order scale error in vertical encoder 
                             1],...   X12b      rad   second order scale error in vertical encoder 
            'kap_ref_NIST2', [-0.36 0.06 0.06 0.45 -0.0000130 -0.0005726 -0.0006857 0.0002704 -0.0000806 -0.0000272 -0.0000298 -0.04 0.0000029 0.0000092 -0.0000195 -0.0000335]',...
            'initNIST2', zeros(1,16),...
            'sigmaNIST2',[Inf Inf Inf Inf Inf Inf Inf Inf Inf Inf Inf Inf Inf Inf Inf Inf ],...
            ... % 2) Define NIST3 related input
            'isEvalNIST3',[ 1 1 1 1 1 1 1 1 1 1 1],...  %index of estimated NIST3 parameters 
            'kap_ref_NIST3', [-0.2 -0.2 -0.2 -0.2 -3.878509e-05 -3.878509e-05 -3.878509e-05 -3.878509e-05 -7.757019e-05 -2 -0.4]',...
            'initNIST3', zeros(1,11),...
            'sigmaNIST3',[Inf Inf Inf Inf Inf Inf Inf Inf Inf Inf Inf ],...
            ... % 3) Define NIST8 related input
            'isEvalNIST8',[ 1 1 1 1 1 1 1 1],...  %index of estimated NIST parameters 
            'kap_ref_NIST8', [0 0 0 0 0 0 0 0 ]',...
            'initNIST8', zeros(1,8),...
            'sigmaNIST8',[Inf Inf Inf Inf Inf Inf Inf Inf],...
            ... % 4) Define NIST9 related input
            'isEvalNIST9',[ 1 1 1 1 1 1 1 1 1],...  %index of estimated NIST parameters 
            'kap_ref_NIST9', [0 0 0 0 0 0 0 0 0 ]',...
            'initNIST9', zeros(1,9),...
            'sigmaNIST9',[Inf Inf Inf Inf Inf Inf Inf Inf Inf],...
            ... % 5) Define NIST10 related input
            'isEvalNIST10',[ 1 1 1 1 1 1 1 1 1 1],...  %index of estimated NIST parameters [ 1 0 1 0 1 1 0 1 1 1]
            'kap_ref_NIST10', [0 0 0 0 0 0 0 0 0 0]',...
            'initNIST10', zeros(1,10),...
            'sigmaNIST10',[Inf Inf Inf Inf Inf Inf Inf Inf Inf Inf],...
            ... % 6) Define Lichti related input
            'isEvalLichti',[ 1 0 1 1 1 0 0 1 1 1 1 1 1 1 1 1 1 0 1 1 1],...  %index [ 1 0 1 1 1 0 0 1 1 1 1 1 1 1 1 1 1 0 1 1 1 ] 
            'kap_ref_Lichti', [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 ]',...
            'initLichti', zeros(1,21),...
            'sigmaLichti',[Inf Inf Inf Inf Inf Inf Inf Inf Inf Inf Inf Inf Inf Inf Inf Inf Inf Inf Inf Inf Inf],...
            ...% I) Camera parameters: ignored for this PP-based scanner calibration
            'isEvalcam', [1 1 1 1 1 1 0 0 0],... %index of estimated camera parameters: x0s y0s z0s detHZcam ELcam gamma cx cy fx=fy
            'sigmaCam',[Inf Inf Inf Inf Inf Inf Inf Inf 10 ],...
            ...% II) Pose parameters
            'isEvalpos', [1 1 1 1 1 1],... % index of the estimated pose paramters at each station 3 angles and 3 offsets [1 1 1 1 1 1]  [0 0 0 0 0 0]
            'sigmaPos',[1/3600/180*pi 1/3600/180*pi Inf Inf Inf Inf],...
            'refSet',1,...            % reference setup index
            'hasNormDis',true,...     % whether to use normal distances of plane patches
            'y_axis', 1);             % y_axis=1 Azimuth angle is defined against y-axis and positive clock-wise 
                                      % y_axis=0, azimuth is defined against x-axis
       
        % Hyperparameters of normal distances between plane patches
       normDis = struct(...
            'use_dualface', true,... % whether to use the normal distance between two-face observations at one setup
            'sampleDistance',400,... % Distance of the sampled corepoints in mm 100  400
            'radius',200,...         % radius of the spherical neighbourhood in mm 200
            'depth',250,...          % max depth of points wrt the corepoint in mm
            'minPt',40,...           % minimum number of points on each patch  40
            'maxPt',800,...          % maxmium number of points on each patch
            'maxSigma',2,...         % maxmium sigma of plane fitting   2
            'savePP',true,...        % whether to save the obj with plane patches cached
            'sigma',0.13,...         % prior sigma of normal distance in mm%        0.13mm for ZF/RTC  0.5 for Faro
            'maxDistance',40000,...  % maximum distance of corepoint to the scanner in mm
            'gridSize',40,...        % size of grid for plane selection 
            'minEL',-1.0472,...      % minimum elevation of corepoint
            'maxEL', 1.5708,...      % Maximum elevation of corepoint
            'azCut' , [0 180]);      % Azimuths range of the to be used point cloud, default [], or sth like [0 30; 60 90; 120 150]     
            
    end
    
    methods(Static)
        function obj = instance()
            persistent uniqueInstance
            if isempty(uniqueInstance) || ~isvalid(uniqueInstance)
                obj = ProjectSettings();
                uniqueInstance = obj;
            else
                obj = uniqueInstance;
            end
        end
         
    end
    
    methods(Access=private)
        function obj = ProjectSettings()
            
        end
 
    end
end

