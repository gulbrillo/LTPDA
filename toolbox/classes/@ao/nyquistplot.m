% NYQUISTPLOT fits a piecewise powerlaw to the given data.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: NYQUISTPLOT plots a nyquist plot for a complex frequency
% series
%
%
% CALL:        hf = obj.nyquistplot(pl)
%              hf = nyquistplot(objs, pl)
%
% INPUTS:      pl      - a parameter list
%              obj(s)  - input fsdata object(s)
%
% OUTPUTS:     hf - figure handle(s)
%
%
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'nyquistplot')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = nyquistplot(varargin)

% Determine if the caller is a method or a user
callerIsMethod = utils.helper.callerIsMethod;

% Check if this is a call for parameters
if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
end

% Print a run-time message
import utils.const.*
utils.helper.msg(msg.PROC3, 'running %s/%s', mfilename('class'), mfilename);

% Collect input variable names for storing in the history
in_names = cell(size(varargin));
try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end

% Collect all objects of class ao
[objs, obj_invars] = utils.helper.collect_objects(varargin(:), 'ao', in_names);

% Apply defaults to plist
pl = applyDefaults(getDefaultPlist, varargin{:});

% extract plist parameters
nobjs = numel(objs);
arrangement = pl.find_core('arrangement');
hfin = pl.find_core('figure');
fignames = pl.find_core('figurenames');
legends = pl.find_core('legends');
legendlocations = pl.find_core('legendlocation');
linewidths = pl.find_core('linewidths');
linecolors = pl.find_core('linecolors');
linestyles = pl.find_core('linestyles');
markers = pl.find_core('markers');
markersizes = pl.find_core('markersizes');
legendfontsize = pl.find_core('legendfontsize');
xranges = pl.find_core('xranges');
yranges = pl.find_core('yranges');
titles = pl.find_core('titles');
xlabels = pl.find_core('xlabels');
ylabels = pl.find_core('ylabels');
latexlabels = pl.find_core('latexlabels');

% data for stability circle
phi = linspace(0,2*pi,256);
xcirc = cos(phi)-1;
ycirc = sin(phi);

% create figure(s)
hfout = [];
switch arrangement
    % all on one figure
    case 'stacked'
        if isempty(hfin), hfin = figure(); end
        hfout = figure(hfin(1));
        
        % set figure name
        figname = parseOptions(1,fignames,[]);
        if ~isempty(figname)
            set(hfout(1),'name',figname);
        end
        
        % set axes
        ha = axes();
        
        % create stability circle and -1 point
        hcirc = plot(xcirc,ycirc,'k--');
        hcirc.set('linewidth',parseOptions(1,linewidths,2))
        hold on
        hstar = plot(-1,0,'r*');
        hstar.set('markersize',parseOptions(1,markersizes,8));
        
        % set xrange
        xrange = parseOptions(1, xranges, []);
        if ~isempty(xrange), set(ha, 'XLim', xrange); end
        
        % set yrange
        yrange = parseOptions(1, yranges, []);
        if ~isempty(yrange), set(ha, 'YLim', yrange); end
        
        % set xlabels
        xlab = parseOptions(1, xlabels, '');
        hxl = xlabel(xlab);
        set(hxl,'FontSize',legendfontsize);
        
        % set ylabels
        ylab = parseOptions(1, ylabels, '');
        hyl = ylabel(ylab);
        set(hyl,'FontSize',legendfontsize);
        
        % set titles
        titl = parseOptions(1, titles, '');
        htl = title(titl);
        set(htl,'FontSize',legendfontsize);
        
        % set latex interpreter
        ltxlabel = parseOptions(1,latexlabels,1);
        if ~ltxlabel
            set(hxl,'Interpreter','none');
            set(hyl,'Interpreter','none');
            set(htl,'Interpreter','none');
        end
        
        % turn on grid and hold
        grid on
        
        % each has their own fiugre
    case 'single'
        for ii = 1:numel(hfin)
            hfout(ii) = hfin(ii);
        end
        for ii = numel(hfin)+1:nobjs
            hfout(ii) = figure();
        end
        
        % set figure names that we have
        for ii = 1:numel(hfout)
            % set figure name
            figname = parseOptions(ii,fignames,[]);
            if ~isempty(figname)
                set(hfout(ii),'name',figname);
            end
        end
        
        % set axes
        for ii = 1:nobjs
            ha(ii) = axes();
            
            % create stability circle and -1 point
            hcirc = plot(xcirc,ycirc,'k--');
            hcirc.set('linewidth',parseOptions(1,linewidths,2))
            hold on
            hstar = plot(-1,0,'r*');
            hstar.set('markersize',parseOptions(1,markersizes,8));
            
            % set ranges
            xrange = parseOptions(ii, xranges, []);
            if ~isempty(xrange), set(ha(ii), 'XLim', xrange); end
            
            yrange = parseOptions(ii, yranges, []);
            if ~isempty(yrange), set(ha(ii), 'YLim', yrange); end
            
            % set xlabels
            xlab = parseOptions(ii, xlabels, '');
            hxl = xlabel(xlab);
            set(hxl,'FontSize',legendfontsize);
            
            % set ylabels
            ylab = parseOptions(ii, ylabels, '');
            hyl = ylabel(ylab);
            set(hyl,'FontSize',legendfontsize);
            
            % set titles
            titl = parseOptions(ii, titles, '');
            htl = title(titl);
            set(htl,'FontSize',legendfontsize);
            
            % set latex interpreter
            if ~latexlabels
                set(hxl,'Interpreter','none');
                set(hyl,'Interpreter','none');
                set(htl,'Interpreter','none');
            end
            
            % turn on grid and hold
            grid on
            
        end
        
        % subplots
    case 'subplots'
        if isempty(hfin), hfin = figure('name',fignames{1}); end
        hfout = figure(hfin(1));
        
        % create axes
        Nx = max(factor(nobjs));
        Ny = nobjs/Nx;
        for ii = 1:nobjs
            ha(ii) = subplot(Nx,Ny,ii);
            
            % create stability circle and -1 point
            hcirc = plot(xcirc,ycirc,'k--');
            hcirc.set('linewidth',parseOptions(1,linewidths,2))
            hold on
            hstar = plot(-1,0,'r*');
            hstar.set('markersize',parseOptions(1,markersizes,8));
            
            % set ranges
            xrange = parseOptions(ii, xranges, []);
            if ~isempty(xrange), set(ha(ii), 'XLim', xrange); end
            
            yrange = parseOptions(ii, yranges, []);
            if ~isempty(yrange), set(ha(ii), 'YLim', yrange); end
            
            % set xlabels
            xlab = parseOptions(ii, xlabels, '');
            hxl = xlabel(xlab);
            set(hxl,'FontSize',legendfontsize);
            
            % set ylabels
            ylab = parseOptions(ii, ylabels, '');
            hyl = ylabel(ylab);
            set(hyl,'FontSize',legendfontsize);
            
            % set titles
            titl = parseOptions(ii, titles, '');
            htl = title(titl);
            set(htl,'FontSize',legendfontsize);
            
            % set latex interpreter
            if ~latexlabels
                set(hxl,'Interpreter','none');
                set(hyl,'Interpreter','none');
                set(htl,'Interpreter','none');
            end
            
            % turn on grid and hold
            grid on
        end
end



% Loop over input objects
for jj = 1 : nobjs
    
    % split by frequencies
    freqs = pl.find_core('frequencies');
    if ~isempty(freqs)
        objs(jj) = objs(jj).split(pl.subset('frequencies'));
    end
    
    % create cartesian output
    objy = double(objs(jj));
    xout = abs(objy).*cos(angle(objy));
    yout = abs(objy).*sin(angle(objy));
    
    % set axes
    if strcmpi(arrangement,'stacked')
        axes(ha);
    else
        axes(ha(ii));
    end
    
    % plot
    hp = plot(xout,yout);
    hp.set('linewidth',parseOptions(ii,linewidths,2))
    hp.set('linestyle',parseOptions(ii,linestyles,'-'))
    lc = parseOptions(ii,linecolors,[]);
    if ~isempty(lc)
        hp.set('linecolor',lc);
    end
    hp.set('Marker',parseOptions(ii,markers,'none'));
    hp.set('MarkerSize',parseOptions(ii,markersizes,6));
    
end

% build legends
switch arrangement
    case 'stacked'
        axes(ha(1))
        lgnd = parseOptions(1,legends,[]);
        if ~isempty(lgnd)
            hl = legend(lgnd);
            lgndloc = parseOptions(1,legendlocations,[]);
            if ~isempty(lgndloc)
                hl.set('Position',lgndloc);
            end
        end
        
    case {'single','subplots'}
        for ii = 1:numel(ha)
            axes(ha(ii));
            lgnd = parseOptions(ii,legends,[]);
            if ~isempty(lgnd)
                hl = legend(lgnd);
                lgndloc = parseOptions(ii,legendlocations,[]);
                if ~isempty(lgndloc)
                    hl.set('Position',lgndloc);
                end
            end
        end
end

% Set output
varargout = utils.helper.setoutputs(nargout, hfout);
end

%--------------------------------------------------------------------------
% Get Info Object
%--------------------------------------------------------------------------
function ii = getInfo(varargin)
if nargin == 1 && strcmpi(varargin{1}, 'None')
    sets = {};
    pl   = [];
else
    sets = {'Default'};
    pl   = getDefaultPlist();
end
% Build info object
ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.sigproc, '', sets, pl);
end

%--------------------------------------------------------------------------
% Get Default Plist
%--------------------------------------------------------------------------
function plout = getDefaultPlist()
persistent pl;
if ~exist('pl', 'var') || isempty(pl)
    pl = buildplist();
end
plout = pl;
end

function pl = buildplist()

% Create empty plsit
pl = plist();

% copy useful parameters from iplot
ipl = ao.getInfo('iplot', 'frequency-series plot').plists;

pl.append(ipl.subset(...
    'figure',...
    'arrangement',...
    'linewidths',...
    'linecolors',...
    'linestyles',...
    'markers',...
    'markersizes',...
    'legends',...
    'legendlocation',...
    'legendfontsize',...
    'figurenames',...
    'xranges',...
    'yranges',...
    'titles',...
    'latexlabels',...
    'xlabels',...
    'ylabels'));

pl.pset('xlabels','Real Part');
pl.pset('ylabels','Imaginary Part');

% split frequencies
pl.append(ao.getInfo('split','by frequencies').plists);
end

% END
function opt = parseOptions(varargin) %jj, opts, dopt

jj    = varargin{1};
opts = varargin{2};
dopt = varargin{3};
opt   = dopt;

if ~iscell(opts)
    opts = {opts};
end
Nopts = numel(opts);

% First look for the 'all' keyword
if Nopts == 2 && strcmpi(opts{1}, 'all')
    opt = opts{2};
else
    if jj <= Nopts && ~isempty(opts{jj})
        opt = opts{jj};
    end
end

end
