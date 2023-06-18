function hand=ShowMatrixHere(C,XYRange,CRange,col,addcbar,cbarlocation,cbarlabel)

% function ShowMatrixHere(C,XYRange,CRange,col,addcbar,cbarlocation,cbarlabel)
%
% Plot 2-dimensional matrix as image on figure or subplot
% (must be opened before)
%
% C           (real valued) matrix
% XYRange     (optional) [4x1] vector: [xmin xmax ymin ymax], default: []
% CRange      (optional) minimum, maximum value to be plotted
%             values are truncated to the interval [CRange(1),CRange(2)]
% col         (optional) colormap to be used. Can be created
%             with makecolormap.
% addcbar     1 : add color bar (default), 0: do not add color bar
% cbarlocation 'vert' or 'horz' for vertical or horizontal colorbar
% cbarlabel    text used to label the color bar            

% Category:    Plotten
% Description: Matrix als Bild ausgeben mit freier Farbskalierung
if nargin <7
   cbarlabel=[];
   if nargin < 6
      cbarlocation = [];
      if nargin < 5
         addcbar = [];
         if nargin < 4
            col = [];
            if nargin < 3
               CRange = [];
               if nargin < 2
                   XYRange = [];
               end    
            end   
         end   
      end
   end
end      
if isempty( addcbar )
   addcbar = 1;
end
if addcbar
   if isempty(cbarlocation)
      cbarlocation = 'vert';
   end
end

if isempty(CRange)
   %CRange = [nanmin(C(:)),nanmax(C(:))];   % nanmin is obsolete in new
   %MATLAB versions; replaced by min/max aw, 2013-08-16
   CRange = [min(C(:)),max(C(:))];
else
   if length(CRange)~=2
      error 'CRange must be 1x2 vector'; 
   end    
end

if isempty(col)
%    col = MakeColormap([0 1 1 1;0.5 1 1 0; 1 1 0 0]);
%      col = MakeColormap([0 0 1 0;0.5 1 1 1; 1 1 0 0]);  % g w r
%       col = MakeColormap([0 0 0 1;0.5 1 1 1; 1 1 0 1]);  % b w m
    col = MakeColormap([0 0 0 1;0.5 1 1 1; 1 1 0 0]);  % b w m
end

if isempty(XYRange)
   XYRange=[1 size(C,2) 1 size(C,1)];
else
   if length(XYRange) ~= 4
      error 'XYRange must be 1x4 vector'; 
   end    
end


if diff(CRange)==0                      % avoid colorbar with just 1 color
   CRange = CRange(1)+[-1 1]; 
end   
%Jing
CRange(1)=-1;
Cmin=CRange(1);
Cmax=CRange(2);


% shift such that Cmin corresponds to 0 in new matrix
C=C-Cmin;

% trunacte small and large values such that minimum is 0 and maximum is
% Cmax-Cmin
h = size(C);
if length(h) > 2
   error 'This function can only display 2 dimensional matrices.';
end   
%C = reshape(  nanmin(nanmax(C(:),0),Cmax-Cmin), h(1), h(2) ); % replaced
%by min/max due to new MATLAB version, aw, 2013-08-16
C = reshape(  min(max(C(:),0),Cmax-Cmin), h(1), h(2) );

%h=sign(sign(C)+1);
%C=C.*h;
%h=abs(sign(sign(C-Cmax+Cmin)-1));
%C=C.*h;
%h=abs(h-1);
%C=C+h*Cmax;

% now scale such that the values range from 0 to 255 (for simple
% colorcoding)
if Cmax ~= Cmin
   f = 255/(Cmax-Cmin);
else
   f = 0;
end
B = f*C;

hand=image(XYRange(1:2),XYRange(3:4),B);
axis xy;

colormap(col);
caxis([Cmin Cmax]);

if addcbar == 1
   cbar2(cbarlocation,cbarlabel);
end


%title('Korrelation zwischen den Parametern');
%set(gca,'YTick',(1:n)');
%set(gca,'XTick',(1:n)');
%set(gca,'XTickLabel',ParText);
%set(gca,'XAxisLocation','top');
%set(gca,'TickLength',[0 0]);

%Y = n;
