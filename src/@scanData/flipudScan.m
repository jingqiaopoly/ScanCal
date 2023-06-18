function [obj] = flipudScan(obj)
     % Cut out a patch of the scan data according to the starting and
     % ending rows/colums
     % Input: obj: original data to be cut
     %        iraw:      starting raw
     %        jraw:      end raw
     %        icol:      starting column
     %        jcol:      end column
     
     obj.az = flipud(obj.az);
     obj.el = flipud(obj.el);
     obj.rng = flipud(obj.rng);
     obj.intens = flipud(obj.intens);
     obj.face = flipud(obj.face);
     obj.status = flipud(obj.status);
     
end