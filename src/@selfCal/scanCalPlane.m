function obj = scanCalPlane(obj,reuse_data, locDirectory) %

    % Check inputs
    if nargin < 2
        reuse_data = 1;
    end
    if nargin < 3
        locDirectory = [];
    end
    
    % Read all the processed dataset into obj
    if isempty(obj.data.az) || ~reuse_data
        [obj.data,  obj.meta,obj.nSet]= loadData(obj,locDirectory);
    end
   
    obj = initPara(obj);
    
    if isempty(obj.corePts(1).id)
        samp_distance = ProjectSettings.instance.normDis.sampleDistance; %distance of sampled points
        obj.corePts = selectCorepoints(obj, samp_distance);
        obj = calcNormalM3C2_unfixR(obj);

        if(ProjectSettings.instance.normDis.savePP)
            setStr='set';
            for iset=1:obj.nSet
                jobNr = obj.meta(iset).jobNr;
                setupNr = obj.meta(iset).setupNr;
                setStr =  strcat(setStr,'_',int2str(jobNr),'(',int2str(setupNr),')');
            end
          setStr = strcat(setStr,'_samp',int2str(ProjectSettings.instance.normDis.sampleDistance));
          save(strcat(ProjectSettings.instance.paths.result_folder,setStr),'obj','-v7.3');
        end
    end
    
    obj = calcM3C2Precision(obj);
    obj = selectPlaneAZ(obj);
     
    % Run scanner calibration estimator
    [p_kap, p_pos,p_cam, cof_kap,cof_pos,cof_cam,postSigma, Q, obj] = estimatorMain(obj);
    % plot and store the calibration results
    showResultErrbar(obj,p_kap,p_pos,p_cam,cof_kap,cof_pos,cof_cam,postSigma, Q);
end