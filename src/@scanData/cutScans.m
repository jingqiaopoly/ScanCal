function [cut_data] = cutScans(obj, iraw,jraw, icol, jcol)
     % Cut out a patch of the scan data according to the starting and
     % ending rows/colums
     % Input: obj: original data to be cut
     %        iraw:      starting raw
     %        jraw:      end raw
     %        icol:      starting column
     %        jcol:      end column
     
     cut_data = scanData();
     
     cut_data.az = obj.az(iraw:jraw, icol:jcol);
     cut_data.el = obj.el(iraw:jraw, icol:jcol);
     cut_data.rng = obj.rng(iraw:jraw, icol:jcol);
     cut_data.intens= obj.intens(iraw:jraw, icol:jcol);
     cut_data.face = obj.face(iraw:jraw, icol:jcol);
     cut_data.status = obj.status(iraw:jraw, icol:jcol);
     
end