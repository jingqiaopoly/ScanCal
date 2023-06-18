% Transform the coordinates of IF back to the raw data
locDirectory1= 'J:\Bonn\RTC360\RAW\IntensityFeatures\s56PPascRaw\';
filePara = 'J:\Bonn\RTC360\Result\2107160905set_1(5)_1(6)_PP.mat';
load(filePara);
 
 
 
subFolders = dir(locDirectory1);
%.mat files are within the subfolders
if subFolders(3).isdir
    for k=3:size(subFolders,1)
      dirk = [locDirectory1, subFolders(k,:).name,'\'];
      list = ls(dirk);
      for i = 3:size(list,1)
           load([dirk, list(i,:)],'offsets','max_cs','incidence2','distance2','nNeighborPt2','planarity2','stdIntensity2','relaStdIntensity2',...
            'setupNr1','setupNr2','iface1','iface2','ipt','azimuth2_s','elevation2_s','range2_s','pixelSize_s','Radius_s');    

            index = find(~isnan(range2_s(2,:)));

            dis = [dis distance2(:,index)];
            inc = [inc incidence2(:,index)];
            coef = [coef max_cs(index)];

            stdInt = [stdInt stdIntensity2(:,index)];
            relaStdInt = [relaStdInt relaStdIntensity2(:,index)];
            plan = [plan planarity2(:,index)];
            pixelSize =[pixelSize pixelSize_s(index) ];
            Radius =[Radius Radius_s(index) ];

            nPt = [nPt nNeighborPt2(:,index)];
            offX = [offX  offsets(1,index)];
            offY = [offY  offsets(2,index)];

            AZ2 = [AZ2 azimuth2_s(:,index)];
            EL2 = [EL2 elevation2_s(:,index)];
            RG2= [RG2 range2_s(:,index)];

            nP=size(index,2);
            face2 = [repmat(iface1,1,nP) ; repmat(iface2,1,nP)];
            FC2 = [FC2 face2];
            set2 = [repmat(setupNr1,1,nP) ; repmat(setupNr2,1,nP)];
            ST2 = [ST2 set2];
            ipts = [ipts ipt(index)+0.1*setupNr1+0.01*iface1];

      end
   end
else
    % .mat files are within locDirectory1
    list = ls(locDirectory1);
    for i = 3:size(list,1)
        load([locDirectory1, list(i,:)],'offsets','max_cs','incidence2','distance2','nNeighborPt2','planarity2','stdIntensity2','relaStdIntensity2',...
                    'setupNr1','setupNr2','iface1','iface2','ipt','azimuth2_s','elevation2_s','range2_s','pixelSize_s','Radius_s');    
        index = find(~isnan(range2_s(2,:)));
        nP=size(index,2);
        cor1 = [range2_s(1,index).*0.001;azimuth2_s(1,index);elevation2_s(1,index)] ;
        raw1 = NISTModel.NIST_bwd(cor1,p_kap,'NIST8');
        range2_s(1,index) = raw1(1,:).*1000;
        azimuth2_s(1,index) = raw1(2,:);
        elevation2_s(1,index) = raw1(3,:);
        
        cor2 = [range2_s(2,index).*0.001;azimuth2_s(2,index);elevation2_s(2,index)] ;
        raw2 = NISTModel.NIST_bwd(cor2,p_kap,'NIST8');
        range2_s(2,index) = raw2(1,:).*1000;
        azimuth2_s(2,index) = raw2(2,:);
        elevation2_s(2,index) = raw2(3,:);

        save([locDirectory1, list(i,:)],'offsets','max_cs','incidence2','distance2','nNeighborPt2','planarity2','stdIntensity2','relaStdIntensity2',...
                    'setupNr1','setupNr2','iface1','iface2','ipt','azimuth2_s','elevation2_s','range2_s','pixelSize_s','Radius_s');    
    
       
    end
end


    
    
 