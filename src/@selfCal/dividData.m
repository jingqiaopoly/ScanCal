function [dataSeg] = dividData(obj, nSeg)

% Divide point clouds into nSeg segments
    data_seg = struct( ...
    'seg', scanData());
    dataSeg(2,obj.nSet) =  data_seg();
    
   % Check if points are available
    if mod(nSeg,2)~=0
         error('The number of segments should be an even number!');
    end
          
    nSeghalf = nSeg/2;
    
    for iset=1:obj.nSet
       for iface =1:2
            data = obj.data(iface,iset);
            if ~isempty(data)
                dataSeg(iface,iset) = data_seg();
                dataSeg(iface,iset).seg(nSeg) = scanData();
                % Divid into two parts above and below horizon
                data = obj.data(iface,iset);
                el = nanmean(data.el,2);
                az = nanmean(data.az,1);
                if iface==1
                    [ diff, index0 ] = min( abs( el-0 ) );
                else
                    [ diff, index0 ] = min( abs( el-pi ) );
                end
                [ diff, index180az ] = min( abs( az-pi ) );
                
                [nRow,nCol]= size(data.el);
                nC = floor(nCol/nSeghalf);
                for i=1:nSeghalf
                    icol = (i-1)*nC + 1;
                    jcol = i*nC ;
                    if i==nSeghalf
                        jcol = nCol;
                    end                    
                    % data above horizon
                    iraw = 1;
                    jraw = index0;
                    dataSeg(iface,iset).seg(i) = cutScans(data, iraw,jraw, icol, jcol); 
%                     if (icol-index180az)*(jcol-index180az)<0
%                         if abs(icol-index180az)>abs(jcol-index180az)
%                            dataSeg(iface,iset).seg(i) = cutScans(data, iraw,jraw, icol, index180az); 
%                         else
%                            dataSeg(iface,iset).seg(i) = cutScans(data, iraw,jraw, index180az,jcol); 
%                         end
%                     end
                    % data below horizon
                    iraw = index0+1;
                    jraw = nRow;
                    dataSeg(iface,iset).seg(i+nSeghalf) = cutScans(data, iraw,jraw, icol, jcol);
%                     if (icol-index180az)*(jcol-index180az)<0
%                         if abs(icol-index180az)>abs(jcol-index180az)
%                            dataSeg(iface,iset).seg(i+36) = cutScans(data, iraw,jraw, icol, index180az); 
%                         else
%                            dataSeg(iface,iset).seg(i+36) = cutScans(data, iraw,jraw, index180az,jcol); 
%                         end
%                     end
                    
                end
            end
       end
    end
    
end