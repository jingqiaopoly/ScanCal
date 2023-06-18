classdef selfCal
   properties
       nSet
       data0
       data
       meta
       scanPos
%        ptFeatures
       model  % calibration model name
       mdat
       corePts  %corepts at each setup
       corePts2 %with correspondence
        
       
       obsDef  %nObsx7            
            %1: type(1-coordinateDiff_Intensitymatching, 2-normalDis,3-a prior parameter info, 4-angular difference, 5-coordinateDiffFromCamereFeaturePoints, 6-equality equations )
            %2: subtype(coordinateDiff: 1-x, 2-y, 3-z; 
            %                normalDis: num of points on the plane; 
            %               prior info: 1-NIST, 2-POSE, 3-CAMERA
            %             angular diff: 1-az, 2-el
            %           
            %3: fisrt setup
            %4: second setup   
            %5: first obs face
            %6: second obs face   
            %7. Other
            %              NormalDis: patch Nr.(1,2,3,4...)
            %   prior NIST parameter:
            %       Prior scannerPos:[1-rotX,2-rotY,3-rotZ,4-dx,5-dy,6-dz]) )
            %    CamereFeaturePoints: camera Nr. (bottom-0,side-1,top-2)  
 
      parDef %nParx3
            %1: type (1-NIST8, 2-scannerPos, 3-cameraPara)
            %2: subtype:    
            %              NIST8: 
            %        ScannerPos:[1-rotX,2-rotY,3-rotZ,4-dx,5-dy,6-dz]
            %            camera: 1-x0s 2-y0s 3-z0s 4-detHZcam 5-ELcam 6-gamma 7-cx
            %            8-cy 9-fx=fy 11-m
            %3. Other
            %        scannerPos: setup index
            %            camera: camera Nr(bottom-0,side-1,top-2)
      
    parVal  %Values of all the estimated parameters
    np      %number of NIST parameters
    npos    %number of pose parameters
    ncam    %number of camera parameters
%     nm      %number of scale factor m in camera colinearity equation
    nf      %number of feature coordinates
    %add_param  % other information related calibration, e.g., tempearture, warm-up 

   
    kap_ref   %reference values of the LSM parameters
    pos_ref   %reference values of the pose parameters (initial values)
%     cam_ref   %reference values of the camera parameters (meta data)
%     fea_ref   %reference values of the feature coordinates
    kap_init
    pos_init
    cam_init
    modelIndex  %Index of the to be estimated NIST parameters 
    posIndex  %Index of the to be estimated pose parameters ([1-rotX,2-rotY,3-rotZ,4-dx,5-dy,6-dz])
    camIndex  %Index of the to be estimated cameara parameters (1-x0s 2-y0s 3-z0s 4-detHZcam 5-ELcam 6-gamma 7-cx
    %            8-cy 9-fx=fy)
    isEvalModel   % Index of the to be estimated model parameters
    isEvalcam   % Index of the to be estimated cameara parameters, e.g.,[1 1 1 1 1 1 0 0 0]
    prioriDat    % Prior dataset
    refSet

    %Observation types used for calibration
    hasNormDis
    
    y_axis
   end
   
   methods
      function obj = selfCal()
         obj.data = scanData();
         obj.meta = metaData(); %metaData()
         obj.corePts = corePt();
         obj.corePts2 = corePt();
         obj.mdat = [];
         obj.kap_init = [];   %initlize values of the LSM parameters
         obj.pos_init= [];    %initlize values of the pose parameters (initial values)
         obj.cam_init = [];   %initlize values of the camera parameters
         obj.pos_ref = [];    %reference values of the pose parameters (initial values)
%          obj.cam_ref = [];    %reference values of the camera parameters
         %obj.add_param = [];
         obj.np=0; obj.npos=0; obj.ncam=0;  obj.nf=0;    
         
         
         obj.model = ProjectSettings.instance.selfCal.model;
         if strcmp(obj.model,'NIST2')
             obj.isEvalModel = ProjectSettings.instance.selfCal.isEvalNIST2;
             obj.kap_ref = ProjectSettings.instance.selfCal.kap_ref_NIST2;
         elseif strcmp(obj.model,'NIST3')
             obj.isEvalModel = ProjectSettings.instance.selfCal.isEvalNIST3;
             obj.kap_ref = ProjectSettings.instance.selfCal.kap_ref_NIST3;
         elseif strcmp(obj.model,'NIST8')
             obj.isEvalModel = ProjectSettings.instance.selfCal.isEvalNIST8;
             obj.kap_ref = ProjectSettings.instance.selfCal.kap_ref_NIST8;
         elseif strcmp(obj.model,'NIST9')
             obj.isEvalModel = ProjectSettings.instance.selfCal.isEvalNIST9;
             obj.kap_ref = ProjectSettings.instance.selfCal.kap_ref_NIST9;
         elseif strcmp(obj.model,'NIST10')
             obj.isEvalModel = ProjectSettings.instance.selfCal.isEvalNIST10;
             obj.kap_ref = ProjectSettings.instance.selfCal.kap_ref_NIST10;
         elseif strcmp(obj.model,'Lichti')
             obj.isEvalModel = ProjectSettings.instance.selfCal.isEvalLichti;
             obj.kap_ref = ProjectSettings.instance.selfCal.kap_ref_Lichti;
         end
       
         obj.refSet = ProjectSettings.instance.selfCal.refSet;
         
        %Observation types used for calibration
         obj.hasNormDis = ProjectSettings.instance.selfCal.hasNormDis;
         obj.y_axis = ProjectSettings.instance.selfCal.y_axis;
      end
      
      [obj]= initPara(obj)
      [obj,Featurepdat] = initFeature(obj)
      [p_kap, p_pos,p_cam, cof_kap,cof_pos,cof_cam,postSigma, Q, obj] = estimatorMain(obj);
      [X] = corrUnify(obj, p_kap, p_pos,   rng, az, el,iSet,nSet,refSet,scanPos,  params)
      [X] = correct(obj, p_kap,rng, az, el,  params)
      showResultErrbar(obj,p_kap,p_pos,p_cam,cof_kap,cof_pos,cof_cam,postSigma, Q)
      showObsParaInfo(obj, yLimits)
      plotPtFeature(obj);
      corePts = selectCorepoints(obj, samp_distance, isplot)
      obj = calcNormal(obj)
      obj = calcNormalM3C2(obj)
      obj = calcNormalM3C2_unfixR(obj)
      obj = calcPlaneWeight(obj, do_plot)
      obj = selectPlaneAZ(obj,azCut )
      obj = calcM3C2Precision(obj, do_plot)

      plotPatches(obj)
      [normDisDat]= initNormDis(obj)
%       [dist_2_to_1, diffVec, cp1, cp2, normal1] = normalDisVec(p_kap,p_pos, pt1, pt2,point_cnt1,point_cnt2, ...
%                     iface1,iface2 , params,iset1,iset2, obj) 
%       [dist_2_to_1, diffAng, cp1, cp2, normal1] = normalDisAng(p_kap,p_pos, pt1, pt2,point_cnt1,point_cnt2, ...
%                     iface1,iface2 , params,iset1,iset2, obj)
      
%       scanCalTCE(obj, locDirectory, subSampInc) %
%       scanCalTCEFaro(obj, locDirectory, subSampInc, isplot) %
%       scanCalTCERTC(obj, locDirectory, subSampInc, isplot)
%       scanCalRoomFeature(obj, filePara) 
%       obj = scanCalPlane(obj,reuse_data, locDirectory) %
%       obj = scanCalForstnerFeature(obj,reuse_data, locDirectory) %
%       obj = scanCalMult(obj_file, TC_Directory)
%       obj = scanCalCom(obj,reuse_data, locDirectory) 
      
%       [ obsDef, p_kap, p_pos,Featurepdat] = estimatorFeature(obj,params,p_kap,p_pos,Featurepdat, obsDef, iter, ef,Iter_test)
%       [ obsDef, p_kap, p_pos,Featurepdat] = estimatorFeatureOP(obj,params,p_kap,p_pos,Featurepdat, obsDef, iter, ef,Iter_test)
%       [B_p, P_p, L_p, obsDef,prioriDat ]= estimatorPriori(obj, p_kap, p_pos, p_cam, prioriDat,obsDef)
%       [B_c, P_c, L_c, obsDef,p_kap, p_cam, Qc, Ac,camFeatureDat]= estimatorCamFeature(obj,params, p_kap, p_cam, camFeatureDat,obsDef, iter, ec)
       
%       function scanCalHeliosPtFeature(obj) %, locDirectory, subSampInc
      
      plotResiduals(obj, normDisDat,Featurepdat, camFeatureDat, V_n, ef, ec);
      plotNormDis(obj, normDisDat, iset1, iset2,L1);
      [dataSeg] = dividData(obj, nSeg)
      [dataSeg] = dividInterpolateData(obj, resAngle,deltAngle)
      
      [vce_var] = VCE_analysis(obj,VCE_type,obsType,QvvP,V,Q_diag,std_h_v,high_separate,ht)
      [global_test,s0] = globalTest(obj,gl_test_type,VTPV,robust_redundancy,vce_var,global_test)
      [normDisDat] = normDisAngCofactor(obj,normDisDat,obsType)
      
%       obj = extractIntensityMatching(obj)
%       obj = extractForstnerPlane(obj)
%       obj = extractCameraIntensityMatching(obj)
%       plotcamFeatureDat(obj,camFeatureDat);

%       end
   end
   
%    methods(Static)
%        [pass]=  hypoTest(diffPara, Cov)
%    end

end