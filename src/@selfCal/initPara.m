function obj=initPara(obj)
% Define the to be estimated ASM and pose parameters and initilize them
% Output in obj: 
%      parDef --- descriptor of the parameters: 
%                 parDef(:,1)--parameter type, 1-LSM, 2-Pose, 3-Camera;
%                 parDef(:,2)--parameter sub-type:
%                                  for NIST
%                                  for Pose (1-rotX, 2-rotY, 3-rotZ,4-dx, 5-dy, 6-dz)
%                                  for Camera (1-x0s 2-y0s 3-z0s 4-detHZcam 5-ELcam 6-gamma 7-cx 8-cy 9-fx 10-fy ...)
%                 parDef(:,3)-- for pose,setup index of scanner pos parameters; For camera, icamera of the camera
%      parVal --- initial parameter values 
%      p_kap_ref --- reference LSM parameter values
%      p_pos_ref --- reference pose parameter values
%      add_param --- add parameter inforamtion
%      npos --- number of pose paramters
%$Author: Jing $   
%$Date: 2020/01/14 $ 

   %%Define initial Model parameters
    if strcmp(obj.model,'NIST2')
        p_kap =  ProjectSettings.instance.selfCal.initNIST2;  %p_kap = zeros(1,16);
        sig_kap = ProjectSettings.instance.selfCal.sigmaNIST2;
    elseif strcmp(obj.model,'NIST3')
        p_kap =  ProjectSettings.instance.selfCal.initNIST3;  %zeros(1,11);
        sig_kap = ProjectSettings.instance.selfCal.sigmaNIST3;
    elseif strcmp(obj.model,'NIST8')
        p_kap =  ProjectSettings.instance.selfCal.initNIST8;  %zeros(1,11);
        sig_kap = ProjectSettings.instance.selfCal.sigmaNIST8;
    elseif strcmp(obj.model,'NIST9')
        p_kap =  ProjectSettings.instance.selfCal.initNIST9;  %zeros(1,11);
        sig_kap = ProjectSettings.instance.selfCal.sigmaNIST9;
    elseif strcmp(obj.model,'NIST10')
        p_kap =  ProjectSettings.instance.selfCal.initNIST10;  %zeros(1,11);
        sig_kap = ProjectSettings.instance.selfCal.sigmaNIST10;
    elseif strcmp(obj.model,'Lichti')
        p_kap =  ProjectSettings.instance.selfCal.initLichti;  %zeros(1,11);
        sig_kap = ProjectSettings.instance.selfCal.sigmaLichti;
    end
    obj.np = nnz(obj.isEvalModel);
    parDef = zeros(obj.np, 3);
    parDef(1:obj.np,1) = 1;
    parDef(1:obj.np,2)= find(obj.isEvalModel); 
    parVal = p_kap(parDef(1:obj.np,2))';
    obj.modelIndex = parDef(1:obj.np,2); %parDef(find(parDef(:,1)==1),2) 
    pkapIndex = find(~isinf(sig_kap));
    
    %Define scanner pos parameters%%%%%%%%%%
    p_pos=zeros(6*obj.nSet-6,1);
    obj.pos_ref = zeros(6*obj.nSet-6,1);
    posDef = zeros(6*obj.nSet-6,3);
    isEvalPos = ProjectSettings.instance.selfCal.isEvalpos;
    isEvalPos = repmat(isEvalPos,obj.nSet-1,1);
% %     isEvalPos =ones(obj.nSet-1,6);%Estimate all the pose except the refSet by default
% % %    %  Manually Define to be estimated setup pose, 0 denote fixed ones 
%    isEvalPos =[ 1 1 1 1 1 1     %  0 0 0 0 0 0
%                  0 0 0 0 0 0
%                  1 1 1 1 1 1
%                 ];   % 1 1 1 1 1 1
    obj.scanPos = zeros(obj.nSet,6);
    
    sig_pos = ProjectSettings.instance.selfCal.sigmaPos;   
    ipri_pos = find(~isinf(sig_pos));
    pposIndex =[];% priori pose index
    
    j=0;
    for i=1:obj.nSet
       obj.scanPos(i,:) = obj.meta(i).scanPos;
       obj.scanPos(i,1:3) = obj.scanPos(i,1:3);
       obj.scanPos(i,4:6) = obj.scanPos(i,4:6);
      if(i~=obj.refSet)
            p_pos(6*j+1:6*j+3) = obj.scanPos(i,1:3); %+ randn(1,3).*sec2rad(200);
            p_pos(6*j+4:6*j+6) = obj.scanPos(i,4:6);% + randn(1,3).*50; 
            obj.pos_ref(6*j+1:6*j+6) =obj.scanPos(i,1:6);
            posDef(6*j+1:6*j+6,1) = 2;% type=2 represents scanner pos parameter
            posDef(6*j+1:6*j+6,2) = [1 2 3 4 5 6];%subtype 1-rotX, 2-rotY, 3-rotZ,4-dx, 5-dy, 6-dz
            posDef(6*j+1:6*j+6,3) = i;% setup index   obj.m_r.m_meta_data(i).setupNr; %setup Nr
            pposIndex = [pposIndex 6*j+ipri_pos];
            j=j+1;
      end
    end
    tmp = isEvalPos';
    iPos = find(tmp(:));
    posDef=posDef(iPos,:);
    obj.npos = size(posDef, 1);
    obj.posIndex = zeros(obj.npos,1);
    for i=1:obj.npos
        if(posDef(i,3)<obj.refSet)
            obj.posIndex(i)= posDef(i,2)+6*posDef(i,3)-6;
        else
            obj.posIndex(i)= posDef(i,2)+6*posDef(i,3)-12;
        end
    end
      
    
%     %Define which camera parameters to be estimated if camera data are used
%     obj.camIndex = find(obj.isEvalcam==1)';  %x0s y0s z0s detHZcam ELcam gamma cx cy fx=fy ....
%     obj.ncam = 0;                            %m_ncam will be updated in initCamFeature
%     obj.nm=0;

    obj.parDef = [parDef; posDef];
    obj.parVal = [parVal; p_pos(iPos)];
    
    obj.kap_init= p_kap';
    obj.pos_init= p_pos;
    
%     % prioriDat
%     prioriDat = struct(...          %  
%     'p_kap',[],    'p_pos',[],   'p_cam',[], ...    
%     'std_kap',[],  'std_pos',[], 'std_cam',[],...
%     'kapIndex',[], 'posIndex',[],'camIndex',[]);   
%     sig_cam =ProjectSettings.instance.selfCal.sigmaCam;
%     prioriDat.p_kap=p_kap;
%     prioriDat.p_pos=p_pos;
%     prioriDat.p_cam=[];
%     prioriDat.std_kap=sig_kap;
%     prioriDat.std_pos=sig_pos;
%     prioriDat.std_cam=sig_cam;
%     prioriDat.kapIndex=pkapIndex;
%     prioriDat.posIndex=pposIndex;
%     prioriDat.camIndex=[];%find(~isinf(sig_cam)); %the camera related prior info will be modified in initCamera
%     obj.prioriDat = prioriDat;

end