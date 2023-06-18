function handle=cbar2(loc,axlabel)
%COLORBAR Display color bar (color scale).
%   CBAR2('vert') appends a vertical color scale to the current
%   axis. CBAR2('horz') appends a horizontal color scale.
%
%   CBAR2(H) places the colorbar in the axes H. The colorbar will
%   be horizontal if the axes H width > height (in pixels).
%
%   CBAR2(...,axlabel) adds the label axlabel to the color axis
%
%   CBAR2 without a handle or location argument either adds a
%   new vertical color scale or updates an existing colorbar.
%
%   H = CBAR2(...) returns a handle to the colorbar axis.

%   Clay M. Thompson 10-9-92
%   Copyright (c) 1984-97 by The MathWorks, Inc.
%   Modified: AW, 1999

%   If called with CBAR2(H) or for an existing colorbar, don't change
%   the NextPlot property.

% Category:    Plotten
% Description: Variante von cbar; erzwingt Darstellung der eigenen
% Description: Lookup-Tabelle


changeNextPlot = 1;

haxlabel=[];
nin=0;

if nargin < 1
   loc=[];
else
   if length(loc)~=4 | (all(loc == 'vert')~=1 & all(loc == 'horz')~=1)
      haxlabel=loc;
      loc = [];
   else
      nin = 1;
   end
end

if nargin < 2
   if isempty(haxlabel)
      axlabel=[];
   else
      axlabel=haxlabel;
   end
else
   if ~isempty(haxlabel)
      error 'Cannot decide whether first parameter is mistyped axis location or label!'
   end
end


if nin==0
   loc = 'vert';
end

ax = [];

if nin==1
    if ishandle(loc)
        ax = loc;
        if ~strcmp(get(ax,'type'),'axes'),
            error('Requires axes handle.');
        end
        units = get(ax,'units'); set(ax,'units','pixels');
        rect = get(ax,'position'); set(ax,'units',units)
        if rect(3) > rect(4), loc = 'horiz'; else loc = 'vert'; end
        changeNextPlot = 0;
    end
end

% Determine color limits by CAXIS

ch = get(gca,'children');
hasimage = 0; t = [];
cdatamapping = 'direct';

for i=1:length(ch),
    typ = get(ch(i),'type');
    if strcmp(typ,'image'),
        hasimage = 1;
        cdatamapping = get(ch(i), 'CDataMapping');
    elseif strcmp(typ,'surface') & ...
            strcmp(get(ch(i),'FaceColor'),'texturemap') % Texturemapped surf
        hasimage = 2;
        cdatamapping = get(ch(i), 'CDataMapping');
    elseif strcmp(typ,'patch') | strcmp(typ,'surface')
        cdatamapping = get(ch(i), 'CDataMapping');
    end
end

%if ( strcmp(cdatamapping, 'scaled') )
    %if hasimage,
    %    if isempty(t); 
    %        t = caxis; 
    %    end
    %else
        t = caxis;
        d = (t(2) - t(1))/size(colormap,1);
        t = [t(1)+d/2  t(2)-d/2];
    %end
%else
%    if hasimage,
%        t = [1, size(colormap,1)]; 
%    else
%        t = [1.5  size(colormap,1)+.5];
%    end
%end

h = gca;

if nin==0,
    % Search for existing colorbar
    ch = get(gcf,'children'); ax = [];
    for i=1:length(ch),
        d = get(ch(i),'userdata');
        if prod(size(d))==1 & isequal(d,h), 
            ax = ch(i); 
            pos = get(ch(i),'Position');
            if pos(3)<pos(4), loc = 'vert'; else loc = 'horiz'; end
            changeNextPlot = 0;
            break; 
        end
    end
end

origNextPlot = get(gcf,'NextPlot');
if strcmp(origNextPlot,'replacechildren') | strcmp(origNextPlot,'replace'),
    set(gcf,'NextPlot','add')
end

if loc(1)=='v', % Append vertical scale to right of current plot
    
    if isempty(ax),
        units = get(h,'units'); set(h,'units','normalized')
        pos = get(h,'Position'); 
        [az,el] = view;
        stripe = 0.075; edge = 0.02; 
        if all([az,el]==[0 90]), space = 0.05; else space = .1; end
        set(h,'Position',[pos(1) pos(2) pos(3)*(1-stripe-edge-space) pos(4)])
        rect = [pos(1)+(1-stripe-edge)*pos(3) pos(2) stripe*pos(3) pos(4)];
        
        % Create axes for stripe
        ax = axes('Position', rect);
        set(h,'units',units)
    else
        axes(ax);
    end
    
    % Create color stripe
    n = size(colormap,1);
    image([0 1],t,(1:n)','Tag','TMW_COLORBAR'); set(ax,'Ydir','normal')
    set(ax,'YAxisLocation','right')
    set(ax,'xtick',[])
    if ~isempty(axlabel), ylabel(axlabel); end;
    
elseif loc(1)=='h', % Append horizontal scale to top of current plot
    
    if isempty(ax),
        units = get(h,'units'); set(h,'units','normalized')
        pos = get(h,'Position');
        stripe = 0.075; space = 0.1;
        set(h,'Position',...
            [pos(1) pos(2)+(stripe+space)*pos(4) pos(3) (1-stripe-space)*pos(4)])
        rect = [pos(1) pos(2) pos(3) stripe*pos(4)];
        
        % Create axes for stripe
        ax = axes('Position', rect);
        set(h,'units',units)
    else
        axes(ax);
    end
    
    % Create color stripe
    n = size(colormap,1);
    image(t,[0 1],(1:n),'Tag','TMW_COLORBAR'); set(ax,'Ydir','normal')
    set(ax,'ytick',[])
    if ~isempty(axlabel), xlabel(axlabel); end;
    
else
  error('COLORBAR expects a handle, ''vert'', or ''horiz'' as input.')
end
set(ax,'userdata',h)
set(gcf,'CurrentAxes',h)
if changeNextPlot
    set(gcf,'Nextplot','ReplaceChildren')
else
    set(gcf,'NextPlot',origNextPlot)
end

if nargout>0, handle = ax; end

