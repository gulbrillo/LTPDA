% MCMCPLOT.M - Tool to visualise results of a MCMC sampling.
%
% DESCRIPTION:  Simple tool that plots results from mcmc pest objects.
%               Plots the traces of the chains and th PDFs of the
%               parameters.
%
% CALL: 
%       >> mcmcPlot(pest_obj,pl)
%
%       >> pest_obj.mcmcPlot(pl)
%
%
% PARAMETERS: - pest_obj: pest object
%             - pl:       plist
%
%    EXAMPLE: - mcmcPlot(p,plist('plotmatrix',true,'burnin',5000,'pdfs',[2 4 5]))
%
%<a href="matlab:utils.helper.displayMethodInfo('pest', 'mcmcPlot')">ParametersDescription</a>
%
% Nikos Oct 2011
%
%

function varargout = mcmcPlot(varargin)
  
  %%% Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  import utils.const.*
  utils.helper.msg(msg.PROC3, 'running %s/%s', mfilename('class'), mfilename);
  
  % Collect input variable names
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
  
  % Collect all AOs and plists
  [pests, ~] = utils.helper.collect_objects(varargin(:), 'pest', in_names);
  pl         = utils.helper.collect_objects(varargin(:), 'plist', in_names);
  
  % Decide on a deep copy or a modify
  p = copy(pests, nargout);
  
  % combine plists
  pl            = applyDefaults(getDefaultPlist(), pl);
  BurnIn        = find_core(pl, 'burnin');
  nbins         = find_core(pl, 'nbins');
  paramarray    = find_core(pl, 'chains');
  colorpdfs     = find_core(pl, 'colorpdfs');
  colormp       = find_core(pl, 'colormap');
  pnames        = find_core(pl, 'param names');
  PFC           = find_core(pl, 'Plot fit curves');
  plotPDFs      = find_core(pl, 'pdfs');
  chcol         = find_core(pl, 'chain color');
  faccol        = find_core(pl, 'face color');
  edgecol       = find_core(pl, 'edge color');
  errcol        = find_core(pl, 'error color');
  histtype      = find_core(pl, 'hist type');
  ELIPS         = find_core(pl, 'plot ellipsoid');
  tic           = find_core(pl, 'ticks');
  PLOTSC        = find_core(pl, 'plot cumsum');
  fntsize       = find_core(pl, 'fontsize');
  truevals      = find_core(pl, 'true values');
  SAVEFIG       = find_core(pl, 'savefig');
  
  % Collect chains, without the likelihood/SNR values
  whole_chain = p.chain;
  
  if isempty(whole_chain)
    error('The chain field of the pest object is empty. Cannot proceed.')
  end
  
  pchain      = whole_chain(:,4:size(p.chain,2));
  names       = cell(size(p.chain(1,:)));
  totparams   = size(whole_chain(1,:),2);
  nparams     = totparams - 3; % All parameters minus the logP, logL and SNR
  pchpped_chn = pchain(BurnIn:end,:);
  whole_chain = whole_chain(BurnIn:end,:);
  
  % Assign the names of the parameters
  names{1} = 'Log-posterior';
  names{2} = 'Log-likelihood';
  names{3} = 'SNR';
  if ~isempty(pnames)
    for ii = 1:size(p.chain(1,:),2)-3
      names{ii+3} = pnames{ii};
    end
  elseif isempty(pnames) && ~isempty(p.names)
    for ii = 1:numel(p.names)
      names{3+ii} = p.names{ii};
    end
  else
    for ii = 1:size(p.chain(1,:),2)-3
      names{ii+3} = sprintf('p%d',ii);
    end
  end
  
  % Check if errors are computed
  if ~isempty(p.y)
    if isempty(p.dy)
      p.setDy(zeros(size(p.y)));
    end
  end
  
  if ~all(isa(pests, 'pest'))
    error('### mcmcPlot must be only applied to mcmc pest objects.');
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  outfigs = [];
  N       = numel(p);
  
  if N ~= 1
    error('### mcmcPlot can be applied only to a single pest object.')
  end
  
  if (BurnIn == 1 && ((find_core(pl, 'plotmatrix')))) || (BurnIn == 1 && plotPDFs)
    warning('LTPDA:mcmcPlot',['The burn-in field is left empty or equal to one. For '...
      'better and more accurate display the burn-in section of the chains should be discarded.']);
  end
  
  p.computePdf(plist('BurnIn',BurnIn,'nbins',nbins));
  
  % Plot chains
  if isempty(paramarray)
    
    outfigs = utils.helper.plotTraces(outfigs, totparams, whole_chain, names, p.y, colorpdfs, chcol);
        
  elseif paramarray == 0
    % do nothing / do not plot chains
  else
    
    ch      = whole_chain(:,paramarray);
    outfigs = utils.helper.plotTraces(outfigs, numel(ch(1,:)), ch, names(paramarray), double(p), colorpdfs, chcol);
  
  end
  
  % Plot cumulative sum
  if PLOTSC
    
    Nsamples = numel(pchpped_chn(:,1));
    cmean    = zeros(Nsamples,totparams-3);
    
    for ii = 1:totparams-3;
      if(mod(ii,4)==1);
        ind = 1;
        outfigs = [outfigs ; figure];
        
        % put title
        annotation('textbox',   [0 0.9 1 0.1], ...
                   'String',    'Cumulative mean for the MCMC chains', ...
                   'EdgeColor', 'none', ...
                   'FontSize',   18,...
                   'HorizontalAlignment', 'center');           
      end % plot 4 chains per figure
      
      subplot(4,1,ind)

      cmean(:,ii) = cumsum(pchpped_chn(:,ii)).'./(1:Nsamples);

      fig = plot(cmean(:,ii), 'color', chcol, 'LineWidth', 1.2);
      set(gca, 'fontsize', fntsize)
      xlim([1, Nsamples]);
      
      ylabel(names{ii+3})
      grid on
      set(gca, 'GridLineStyle', '-');
      grid(gca,'minor')
      
      % put xlabel only for the last sublot
      % put xlabel only for the last sublot
      if ind == 4 || ii == totparams-2
        xlabel('Steps');
      end
      
      ind = ind+1;
    end
  
  end
  
  % check if the true values have been imported
  if ~isempty(truevals)
    vals = truevals;
  else
    vals = double(p);
  end
  
  % Plotmatrix
  if (find_core(pl, 'plotmatrix'));
    
    outfigs = [outfigs ; figure];
    
    % Plotmatrix
    [~,AX,~,~,~,~] = plotmatrixB(faccol, edgecol, pchpped_chn, nbins, vals, colorpdfs, histtype, ELIPS, tic, fntsize);
    
    for jj = 1:nparams
      xlabel(AX(jj*nparams),names{jj+3}, 'interpreter', 'none')
    end
    for jj = 1:nparams
      ylabel(AX(jj,1),names{jj+3}, 'interpreter', 'none')
    end
  end
  
  % Print estimated parameters
  if (find_core(pl, 'results'));
    
    fprintf('Estimated parameters: \n');
    table(p)
  end
  
  % Plot PDFs
  if plotPDFs
    
    for kk =1:size(pchpped_chn,2)
      
      if(mod(kk,6)==1);
        ind = 1;
        outfigs = [outfigs ; figure];
      end % plot 6 PDFs per figure
      
      % handle the subplots in case of plotting the normal fits
      if ind == 4 && PFC
        ind = 7;
      end
      
      % get the bin errors
      [nel, binpos] = hist(pchpped_chn(:,kk), nbins);
      
      % in case of fitting a Gaussian, re-arrange the sizes
      if PFC
        hh    = subplot(4,3,ind, 'fontsize', fntsize);
        ax    = get(hh,'Position');
        ax(2) = ax(2)-0.05; % put it lower
        ax(4) = ax(4)+0.05; % enlarge
        set(hh,'Position',ax);
      else
        subplot(2,3,ind);
      end
      
      % check histogram type
      if strcmpi(histtype, 'hist')
        dx = diff(binpos(1:2));
        nel  = nel/sum(nel*dx);
        h = bar(binpos, nel, 'BarWidth', 1);
        set(h,'EdgeColor',edgecol,'FaceColor',faccol);
        set(gca, 'fontsize', fntsize)
      else
        dx = diff(binpos(1:2));
        nel  = nel/sum(nel*dx);
        h = stairs(binpos, nel);
      end
      
      % getting rid of the first y-tick (easier to read)
      fix_yticks(true, fntsize);
      
      % set x-limits (two bins at each side on the x-axis)
      dx = abs(binpos(1)-binpos(2));
      xlim([min(binpos)-2*dx, max(binpos)+2*dx]);
      
      % plot a line idicating the estimated value
      if ~isempty(p.y) && numel(p.y) >= kk
        xPos    = vals(kk);
        hold on
        plot([xPos xPos], get(gca,'ylim'), colorpdfs); % Adapts to y limits of current axes
        if ~isempty(p.dy) && numel(p.dy) >= kk && isempty(truevals)
          hold on
          plot([xPos-p.dy(kk) xPos-p.dy(kk)], get(gca,'ylim'), errcol); % Adapts to y limits of current axes
          hold on
          plot([xPos+p.dy(kk) xPos+p.dy(kk)], get(gca,'ylim'), errcol); % Adapts to y limits of current axes
        end
        hold off
      end
      
      % Add a nice colormap
      if ~isempty(colormp) && strcmpi(histtype, 'hist')
        
        try
          
          shading interp          % Needed to graduate colors
          ch       = get(h,'Children');
          fvd      = get(ch,'Faces');
          fvcd     = get(ch,'FaceVertexCData');
          n        = nbins;
          [~, izs] = sortrows(nel.',1);
          k        = 128;
          colormap(colormp);
          shading interp

          for ii = 1:n

            color            = floor(k*ii/n);
            row              = izs(ii);
            fvcd(fvd(row,1)) = 1;
            fvcd(fvd(row,4)) = 1;
            fvcd(fvd(row,2)) = color;
            fvcd(fvd(row,3)) = color;

          end
          set(ch,'FaceVertexCData', fvcd);
          set(ch,'EdgeColor','k')
          
        catch Me
          warning('### Could not produce colormap histograms. Error: [%s]', Me.message)
        end
      end
      
      % Plot a fit of a Gaussian curve
      if PFC
        
        % in case of plotting the fit, we remove the x-ticks
        % of the histogram plot
        hold on;
        set(gca,'xtick',[])
        set(gca,'xticklabel',[])
        
        % try to fit a normal curve to the data
        [xx, yy, x, y] = fit_normal_to_hist(binpos, nel, nbins, pchpped_chn, kk);
        
        % plot it here
        plot(xx, yy, colorpdfs, 'LineWidth', 1);
        
        subplot(4,3,ind+3, 'fontsize', fntsize)
        
        % plot the residuals
        plot_normal_residual(x, y, binpos, nel, edgecol, dx, fntsize);
        
        % fix the ticks again
        fix_yticks(false, fntsize);
        
        hold off;
        
      end
      
      % add the parameter names
      if (~isempty(names))
        xlabel(names{3+kk},'Interpreter', 'none');
      end
      
      ind = ind+1;
      
      % delete the edges
      if strcmpi(histtype, 'hist')
        set(h,'EdgeColor','none')
      else
        set(h,'Color',edgecol,'linewidth',1.3)
      end
    end
  end
  
  if pl.find('py cplot')
    try
      % First write txt file of the chains into disk
      dlmwrite('chain.txt',pchpped_chn,'delimiter',' ','precision',25);
      
      % create string with the parameter names and values to import 
      str_pnames = '[';
      for jj=1:numel(names)-3
        str_pnames = [str_pnames, sprintf('"$%s$",',names{jj+3})];
      end
      str_pnames(end) = [];
      str_pnames      = [str_pnames, ']'];
      str_vals = '[';
      for jj=1:numel(vals)
        str_vals = [str_vals, sprintf('%15.35f,',vals(jj))];
      end
      str_vals(end) = [];
      str_vals      = [str_vals, ']'];
      
      % Define string to write into the python script
      stmt = sprintf(['#!/usr/bin/env python\n' ...
                      'import matplotlib.pyplot as plt\n'...
                      'import sys\n' ...
                      'import numpy as np\n' ...
                      'import triangle\n' ...
                      'from numpy import *\n' ...
                      'samples = loadtxt("chain.txt")\n' ...
                      'figure = triangle.corner(samples,labels=%s, truths=%s, quantiles=[0.16, 0.5, 0.84],top_ticks=False)\n' ...
                      'figure.savefig("triangle_plot.png")\n'...
                      'figure.savefig("triangle_plot_transparent.png",transparent=True)\n'], str_pnames, str_vals);
      
      % write into the script               
      fileID = fopen('py_script.py','w');
      fprintf(fileID,stmt);
      fclose(fileID);
      
      % Run it
      system('python py_script.py');
      
      % delete files
      delete('py_script.py');
      delete('chain.txt');

      % Print success
      fprintf('\n *** The python script was executed successfully *** \n ');
    catch Me
      fprintf('\n ### Could not produce the python triangle plot. Error: [%s] \n \n ', Me.message)
    end
  end
  
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  % Add provenance
  addProv(p, outfigs, pl)
      
  if nargout == 0
    out = outfigs;
  else
    error('### mcmcPlot cannot be used as a modifier!');
  end
  
  if SAVEFIG
    fprintf('\n * Saving figures ...')
    for kk=1:numel(outfigs)
      stoc.plot.savePlot(plist('figure handle', outfigs(kk), 'outdir', './', 'name', sprintf('mcmcplot_fig_%d', kk),'figfile', true));
    end
    fprintf('done.\n')
  end
  
  % Set outputs
  if nargout > 0
    varargout{1} = out;
  end
  
end

% add provenance to each figure
function addProv(p, hfig, pl) 
  if pl.find_core('show provenance')
    reqs = p.requirements(plist('hashes', true));
    for jj=1:numel(hfig)
      utils.plottools.addPlotProvenance(hfig(jj), reqs{:});
    end
  end
end

% Utils function to fix the Yticks format and font sizes
function fix_yticks(SKIPFIRST, fntsz)

  set(gca,     'fontsize',fntsz)
  %set(gca,     'YTickLabel',sprintf('%2.0e\n',get(gca, 'YTick')'));
  
  if SKIPFIRST
    Q = get(gca, 'ytick');
    R = get(gca, 'yticklabel');
    set(gca,     'ytick',Q(2:end))
    set(gca,     'yticklabel',R(2:end,:))
  end

end

% Utils function to fit a normal PDF to the histograms
function  [xx, yy, x, y] = fit_normal_to_hist(binpos, nel, nbins, chn, kk)
        
  xx = linspace(min(binpos),max(binpos), 10.*nbins);
  yy = utils.math.normalPDF(xx,mean(chn(:,kk)),std(chn(:,kk)));
  
  % the same with the correct dimension
  x  = linspace(min(binpos),max(binpos), nbins);
  y  = utils.math.normalPDF(x,mean(chn(:,kk)),std(chn(:,kk)));

  % scale to the histogram
  c  = trapz(binpos,nel);
  yy = c.*yy;
  y  = c.*y;

end

% Utils function to plot the residuals of the fit
function plot_normal_residual(xx, yy, binpos, nel, edgecol, dx, fntsize)

  err = sqrt(nel); %nel.*(1-nel./sum(nel))./s;
  
  % draw the residuals
  h = errorbar(xx, yy-nel, err, '.');
  
  set(h, 'Color', edgecol);
  set(gca,     'fontsize', fntsize)
  
  % set the correct limits
  xlim([min(binpos)-2*dx, max(binpos)+2*dx]);

end

% PLOTMATRIX Scatter plot matrix. It's the matlab
% standard plotmatrix function but we are able to set
% the number of bins for the histograms, and having more
% plotting options. 
function [h,ax,BigAx,patches,pax, H] = plotmatrixB(faccol, edgecol, varargin)
  
  % Parse possible Axes input
  [cax,args,nargs] = axescheck(varargin{:});
  nin              = nargs;
  
  sym = '.'; % Default scatter plot symbol.
  
  if nin==1, % plotmatrix(y)
    rows = size(args{1},2); cols = rows;
    x = args{1}; y = args{1};
    dohist = 1;
  elseif nin==2, % plotmatrix(x,Nbins)
    rows = size(args{1},2); cols = rows;
    x = args{1}; y = args{1};
    dohist = 1;
    Nbins  = args{2};
  elseif nin==3, % plotmatrix(x,Nbins,trueValues)
    rows = size(args{1},2); cols = rows;
    x = args{1}; y = args{1};
    dohist = 1;
    Nbins  = args{2};  
    vals   = args{3}; 
  elseif nin==4, % plotmatrix(x,Nbins,trueValues,color)
    rows = size(args{1},2); cols = rows;
    x = args{1}; y = args{1};
    dohist = 1;
    Nbins  = args{2};  
    vals   = args{3}; 
    valCol = args{4};  
  elseif nin==5
    rows = size(args{1},2); cols = rows;
    x = args{1}; y = args{1};
    dohist   = 1;
    Nbins    = args{2};  
    vals     = args{3}; 
    valCol   = args{4}; 
    histtype = args{5};
  elseif nin==6
    rows = size(args{1},2); cols = rows;
    x = args{1}; y = args{1};
    dohist   = 1;
    Nbins    = args{2};  
    vals     = args{3}; 
    valCol   = args{4}; 
    histtype = args{5}; 
    ellips   = args{6}; 
  elseif nin==7
    rows = size(args{1},2); cols = rows;
    x = args{1}; y = args{1};
    dohist   = 1;
    Nbins    = args{2};  
    vals     = args{3}; 
    valCol   = args{4}; 
    histtype = args{5}; 
    ellips   = args{6};   
    tic      = args{7};
  elseif nin==8
    rows = size(args{1},2); cols = rows;
    x = args{1}; y = args{1};
    dohist   = 1;
    Nbins    = args{2};  
    vals     = args{3}; 
    valCol   = args{4}; 
    histtype = args{5}; 
    ellips   = args{6};   
    tic      = args{7};
    fz       = args{8};
  else  
    error(message('MATLAB:plotmatrix:InvalidLineSpec'));
  end
  
  % Don't plot anything if either x or y is empty
  patches = [];
  pax     = [];
  H       = {};
  if isempty(rows) || isempty(cols),
    if nargout>0, h = []; ax = []; BigAx = []; end
    return
  end
  
  if ~ismatrix(x) || ~ismatrix(y),
    error(message('MATLAB:plotmatrix:InvalidXYMatrices'))
  end
  if size(x,1)~=size(y,1) || size(x,3)~=size(y,3),
    error(message('MATLAB:plotmatrix:XYSizeMismatch'));
  end
  
  % Create/find BigAx and make it invisible
  BigAx = newplot(cax);
  fig = ancestor(BigAx,'figure');
  hold_state = ishold(BigAx);
  set(BigAx,'Visible','off','color','none')
  
  if any(sym=='.'),
    units = get(BigAx,'units');
    set(BigAx,'units','pixels');
    pos = get(BigAx,'Position');
    set(BigAx,'units',units);
    % markersize = max(1,min(15,round(15*min(pos(3:4))/max(1,size(x,1))/max(rows,cols))));
  else
    % markersize = get(0,'DefaultLineMarkerSize');
  end
  
  % Create and plot into axes
  ax = zeros(rows,cols);
  pos = get(BigAx,'Position');
  width = pos(3)/cols;
  height = pos(4)/rows;
  space = .02; % 2 percent space between axes
  pos(1:2) = pos(1:2) + space*[width height];
  m = size(y,1);
  k = size(y,3);
  xlim = zeros([rows cols 2]);
  ylim = zeros([rows cols 2]);
  BigAxHV = get(BigAx,'HandleVisibility');
  BigAxParent = get(BigAx,'Parent');
  paxes = findobj(fig,'Type','axes','tag','PlotMatrixScatterAx');
  for i=rows:-1:1,
    for j=cols:-1:1,
      axPos = [pos(1)+(j-1)*width pos(2)+(rows-i)*height ...
        width*(1-space) height*(1-space)];
      findax = findaxpos(paxes, axPos);
      if isempty(findax),
        ax(i,j) = axes('Position',axPos,'HandleVisibility',BigAxHV,'parent',BigAxParent);
        set(ax(i,j),'visible','on');
      else
        ax(i,j) = findax(1);
      end
      if ellips && i~=j
        % draw error ellipsoids on 1,2,3 sigmas
        sigcol = [0.843 0.819 0.370 ; 0.607 0.908 0.601 ; 0.167 0.564 0.988 ];
        for kk = 3:-1:1
          [r_ellipse, X0, Y0] = drawellipsoid([reshape(x(:,j,:),[m k]), ...
                                             reshape(y(:,i,:),[m k])], kk);
          hh(i,j,:) = plot(r_ellipse(:,1) + X0,r_ellipse(:,2) + Y0,'-');
          set(hh(i,j,:),'Color',sigcol(kk,:));
          hold on;
        end
        hold off;
      else
        hh(i,j,:) = plot(reshape(x(:,j,:),[m k]), ...
          reshape(y(:,i,:),[m k]),sym,'parent',ax(i,j))';
        markersize = 3;
        set(hh(i,j,:),'markersize',markersize, 'Color',faccol);
      end
      set(ax(i,j),'xlimmode','auto','ylimmode','auto','xgrid','off','ygrid','off')
      xlim(i,j,:) = get(ax(i,j),'xlim');
      ylim(i,j,:) = get(ax(i,j),'ylim');
      set(gca, 'fontsize',fz)
      if ~tic
        set(ax(i,j),'xticklabel','');
        set(ax(i,j),'yticklabel','');
      end
    end
  end
  
  xlimmin = min(xlim(:,:,1),[],1); xlimmax = max(xlim(:,:,2),[],1);
  ylimmin = min(ylim(:,:,1),[],2); ylimmax = max(ylim(:,:,2),[],2);
  
  % Try to be smart about axes limits and labels.  Set all the limits of a
  % row or column to be the same and inset the tick marks by 10 percent.
  inset = .15;
  for i=1:rows,
    set(ax(i,1),'ylim',[ylimmin(i,1) ylimmax(i,1)])
    dy = diff(get(ax(i,1),'ylim'))*inset;
    set(ax(i,:),'ylim',[ylimmin(i,1)-dy ylimmax(i,1)+dy])
  end
  dx = zeros(1,cols);
  for j=1:cols,
    set(ax(1,j),'xlim',[xlimmin(1,j) xlimmax(1,j)])
    dx(j) = diff(get(ax(1,j),'xlim'))*inset;
    set(ax(:,j),'xlim',[xlimmin(1,j)-dx(j) xlimmax(1,j)+dx(j)])
  end
  
  set(ax(1:rows-1,:),'xticklabel','')
  set(ax(:,2:cols),'yticklabel','')
  set(BigAx,'XTick',get(ax(rows,1),'xtick'),'YTick',get(ax(rows,1),'ytick'), ...
    'userdata',ax,'tag','PlotMatrixBigAx')
  set(ax,'tag','PlotMatrixScatterAx');
  
  if dohist, % Put a histogram on the diagonal for plotmatrix(y) case
    paxes = findobj(fig,'Type','axes','tag','PlotMatrixHistAx');
    pax = zeros(1, rows);
    for i=rows:-1:1,
      axPos = get(ax(i,i),'Position');
      findax = findaxpos(paxes, axPos);
      if isempty(findax),
        histax = axes('Position',axPos,'HandleVisibility',BigAxHV,'parent',BigAxParent);
        set(histax,'visible','on');
      else
        histax = findax(1);
      end
      
      % do histogram
      [nn,xx] = hist(reshape(y(:,i,:),[m k]), Nbins);
      
      % check histogram type
      if strcmpi(histtype, 'hist')
        patches(i,:) = bar(histax,xx,nn,'hist');
      else
        patches(i,:) = stairs(xx, nn);
      end
      
      set(histax,'xtick',[],'ytick',[],'xgrid','off','ygrid','off');
      set(histax,'xlim',[xlimmin(1,i)-dx(i) xlimmax(1,i)+dx(i)])
      set(histax,'tag','PlotMatrixHistAx');
      if ~isempty(vals)
        xPos    = vals(i);
        hold on
        plot([xPos xPos], get(gca,'ylim'), valCol); % Adapts to y limits of current axes
        hold off
      end
      pax(i) = histax;  % ax handles for histograms
    end
    patches = patches';
  end
  
  % Make BigAx the CurrentAxes
  set(fig,'CurrentAx',BigAx)
  if ~hold_state,
    set(fig,'NextPlot','replace')
  end
  
  % Also set Title and X/YLabel visibility to on and strings to empty
  set([get(BigAx,'Title'); get(BigAx,'XLabel'); get(BigAx,'YLabel')], ...
    'String','','Visible','on')
  
  if nargout~=0,
    h = hh;
  end
  
  if strcmpi(histtype, 'hist')
    for ii = 1:size(hh,1)
      set(hh(ii,ii),'Color',faccol);
    end
    set(patches(:),'EdgeColor',edgecol,'FaceColor',faccol);
  else
    for ii = 1:size(hh,1)
      set(hh(ii,ii),'Color',faccol);
    end
    set(patches(:),'Color',edgecol, 'linewidth',1.5);
  end
  
end

function [r_ellipse, X0, Y0] = drawellipsoid(chain, sigmas)

  % Calculate the eigenvectors and eigenvalues
  covariance = cov(chain);
  conf       = 2*utils.math.Normcdf(sigmas,0,1)-1;
  scale      = utils.math.Chi2inv(conf,2);
  [eigenvec, eigenval] = eig(scale.*covariance);

  % Get the index of the largest eigenvector
  [largest_eigenvec_ind_c, ~] = find(eigenval == max(max(eigenval)));
  largest_eigenvec = eigenvec(:, largest_eigenvec_ind_c);

  % Get the largest eigenvalue
  largest_eigenval = max(max(eigenval));

  % Get the smallest eigenvector and eigenvalue
  if(largest_eigenvec_ind_c == 1)
      smallest_eigenval = max(eigenval(:,2));
  else
      smallest_eigenval = max(eigenval(:,1));
  end

  % Calculate the angle between the x-axis and the largest eigenvector
  angle = atan2(largest_eigenvec(2), largest_eigenvec(1));

  % Get the coordinates of the data mean
  avg        = mean(chain);
  theta_grid = linspace(0,2*pi);
  phi        = angle;
  X0         = avg(1);
  Y0         = avg(2);
  a          = sqrt(largest_eigenval);
  b          = sqrt(smallest_eigenval);

  % the ellipse in x and y coordinates 
  ellipse_x_r  = a*cos( theta_grid );
  ellipse_y_r  = b*sin( theta_grid );

  %Define a rotation matrix
  R = [ cos(phi) sin(phi); -sin(phi) cos(phi) ];

  %let's rotate the ellipse to some angle phi
  r_ellipse = [ellipse_x_r;ellipse_y_r]' * R;

end

function findax = findaxpos(ax, axpos)
  tol = eps;
  findax = [];
  for i = 1:length(ax)
    axipos = get(ax(i),'Position');
    diffpos = axipos - axpos;
    if (max(max(abs(diffpos))) < tol)
      findax = ax(i);
      break;
    end
  end
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
    pl   = getDefaultPlist;
  end
  % Build info object
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.helper, '', sets, pl);
end


%--------------------------------------------------------------------------
% Get Default Plist
%--------------------------------------------------------------------------
function plout = getDefaultPlist()
  persistent pl;
  if exist('pl', 'var')==0 || isempty(pl)
    pl = buildplist();
  end
  plout = pl;
end

function pl = buildplist()
  pl = plist();
  
  p = param({'chains',['Insert an array containing the parameters to plot. If left empty,'...
    'then by default will plot the chains of every parameter. If set to zero then no chains are plotted. (note: The loglikelihood is stored '...
    'in the first column)']}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
  p = param({'chain color', 'A 3x1 vector defining the color of the chains.'}, paramValue.DOUBLE_VALUE([0.167 0.564 0.988]));
  pl.append(p);
  
  p = param({'face color', 'A 3x1 vector defining the color of the faces of the bar graphs. It also applies to plotmatrix.'}, paramValue.DOUBLE_VALUE([0.167 0.564 0.988]));
  pl.append(p);
  
  p = param({'edge color', 'A 3x1 vector defining the color of the edges. It also applies to plotmatrix.'}, paramValue.DOUBLE_VALUE([0.167 0.564 0.988]));
  pl.append(p);
  
  p = param({'BurnIn',['Number of samples (of the chains) to be discarded for the computation of the PDFs of the parameters. Also used'...
                       'for producing the plotmatrix figure.']}, paramValue.DOUBLE_VALUE(1));
  pl.append(p);
  
  p = param({'nbins','Number of bins of the pdf histogram computed for every parameter (used again for the computation of the PDFs of the parameters)'}, paramValue.DOUBLE_VALUE(25));
  pl.append(p);
  
  p = param({'plotmatrix','Flag to determine if a plotmatrix is desired'}, {1, {false,true}, paramValue.OPTIONAL});
  pl.append(p);
  
  p = param({'ticks',['In case where the ''PLOTMATRIX'' is set to true, and the dimensionality is high, sometimes it is convenient '...
                      'to not draw the x and y-ticks. This flag takes care of this. ']}, {1, {false,true}, paramValue.OPTIONAL});
  pl.append(p);
  
  p = param({'pdfs','Determine if a plot of the PDFs of each parameter is desired. The same as the ''CHAINS'' option but for plotting the PDFs of the paramters.'}, paramValue.TRUE_FALSE);
  pl.append(p);
  
  p = param({'Plot fit curves','Set to true to attempt to plot Gaussian fit curves to parameters histograms.'}, ...
    paramValue.TRUE_FALSE);
  pl.append(p);
  
  p = param({'param names',['Cell array of names of the parameters to be assigned to each plot. If left empty '...
                            'the default values from the pest object will be used. If the ''NAMES'' field of the '...
                            'pest object is empty, some default names will be used.']}, {1, {[]}, paramValue.OPTIONAL});
  pl.append(p);
  
  p = param({'true values','If the parameter values are known and provided, they will be drawn on the histogram plots. '}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
  p = param({'hist type','The histogram type.'}, {1, {'hist', 'stairs'}, paramValue.OPTIONAL});
  pl.append(p);
  
  p = param({'plot ellipsoid',['True false flag, to plot ellipsoids at different confidence levels, '...
                               'intead of the data. Applies if ''Plotmatrix'' is set to true.']}, {1, {false,true}, paramValue.OPTIONAL});
  pl.append(p);
  
  p = param({'colorpdfs','Choose a color for the fitted Gaussians on the PDFs. Used also to point the estimated parameters on the PDFs.'}, {1, {'r-'}, paramValue.OPTIONAL});
  pl.append(p);
  
  p = param({'error color','Choose a color for the estimated errors on the PDFs.'}, {1, {'r--'}, paramValue.OPTIONAL});
  pl.append(p);
  
  p = param({'colormap',['Choose a colormap for the PDF histograms (as a string). By default colormaps are not used. Note: '...
    'For best results it is recomended to use this option with less than 25 ''NBINS''. For the available colormaps type ''doc colormap'''...
    'in the terminal.']}, paramValue.EMPTY_STRING);
  pl.append(p);
  
  p = param({'results',['Set to "true" if a table of the results of the estimated parameters is desired.'...
    'The results are printed on screen in 2 columns: the 1st contains the mean value'....
    'and the second the sigma.']}, {1, {false,true}, paramValue.OPTIONAL});
  pl.append(p);
  
  p = param({'fontsize','The font size for all the cases of the plots.'}, paramValue.DOUBLE_VALUE(10));
  pl.append(p);
  
  p = param({'plot cumsum','True-False flag to plot hte cumulative mean of the chains.'}, paramValue.TRUE_FALSE);
  pl.append(p);
  
  % python corner plot
  p = param({'python corner plot', 'A flag to enable/disable the python corner plot. Works only if the ''triangle'' python module has been imported. Saves the figure under the name ''triangle_plot'' in current directory.'}, paramValue.FALSE_TRUE);
  p.addAlternativeKey('py cplot');
  pl.append(p);
  
  % include provenance patch
  p = param({'show provenance', 'A flag to enable/disable the provenance text patch.'}, paramValue.TRUE_FALSE);
  pl.append(p);
  
  % save figure
  p = param({'savefig', 'FALSE-TRUE flag to save the figures on disk. If set to true, the PDF and FIG files are going to be saved under the name ''mcmcplot_fig_#'' in the currect directory. The stoc.plot.savePlot function is used.'}, paramValue.FALSE_TRUE);
  pl.append(p);
  
end

% END
