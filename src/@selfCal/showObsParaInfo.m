function showObsParaInfo(obj, yLimits)
%Get the obs information of normal distance

    dy=yLimits(2)-yLimits(1);
    interval =0.06;
    inter1 = 0.06;
   %Parmeter nunmber
   if obj.nf>0
       text(0.2, yLimits(2)-inter1*dy, sprintf('Unknows: %d + %d + %d', obj.np,obj.npos, obj.nf)); %obj.ncam
   else
       text(0.2, yLimits(2)-inter1*dy, sprintf('Unknows: %d + %d ', obj.np,obj.npos)); 
   end
    obsDef=obj.obsDef;
    obsNorm = obsDef(obsDef(:,1)==2,:);
    i=1; 
    
    if ~isempty(obsNorm)
       text(0.2, yLimits(2)-inter1*dy-interval*i*dy, 'nPPatch:'); 
       i=i+1;
    end
    
    while ~isempty(obsNorm)
        iset1=obsNorm(1,3);
        iset2=obsNorm(1,4);
        numObs =nnz(int8(obsNorm(:,3)==iset1).*int8(obsNorm(:,4)==iset2));
        index =find(int8(obsNorm(:,3)==iset1).*int8(obsNorm(:,4)==iset2));
        pt_num=mean(obsNorm(index,2));
        obsNorm = obsNorm(numObs+1:end,:);
        setNr1 = obj.meta(iset1).setupNr;
        setNr2 = obj.meta(iset2).setupNr;
        textNorm =sprintf('Setup %d - Setup %d : %d(%.0f) \n', setNr1, setNr2, numObs,pt_num);
        text(0.5, yLimits(2)-inter1*dy-interval*i*dy, textNorm);
        i=i+1;
    end
    
   %Get the obs information of camera feature points
    obsCam = obsDef(obsDef(:,1)==5,:);
    if ~isempty(obsCam)
        text(0.2, yLimits(2)-inter1*dy-interval*i*dy, 'camFeatObs:');
        i=i+1;
    end
    while ~isempty(obsCam)
        ic=obsCam(1,7);
        numObs =nnz(int8(obsCam(:,7)==ic));
        obsCam = obsCam(numObs+1:end,:);
        textNorm =sprintf('Camera %d: %d\n', ic, numObs);
        text(0.5, yLimits(2)-inter1*dy-interval*i*dy, textNorm);
        i=i+1;
    end
    
    %Get the obs information of intensity feature points
    obsInts = obsDef(obsDef(:,1)==1,:);
    if ~isempty(obsInts)
        text(0.2, yLimits(2)-inter1*dy-interval*i*dy, 'nPtFeature:'); %IntsFeatObs
        i=i+1;
    end
    i=i+0.5;
    while ~isempty(obsInts)
        iset1=obsInts(1,3);
        iset2=obsInts(1,4);
        iii=find(obsInts(:,3)==iset1&obsInts(:,4)==iset2);
        numObs=size(iii,1);
        obsInts(iii,:) = [];
        if iset1~=0
            setNr1 = obj.meta(iset1).setupNr;
        else
            setNr1 = 0;
        end
        if iset2~=0
           setNr2 = obj.meta(iset2).setupNr;
        else
           setNr2 = 0;
        end
        textInts =sprintf('Setup %d - Setup %d : %d\n',setNr1, setNr2, numObs/3);
        text(0.5, yLimits(2)-inter1*dy-interval*i*dy, textInts);
        i=i+1;
    end
end