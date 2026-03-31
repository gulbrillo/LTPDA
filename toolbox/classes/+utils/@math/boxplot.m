% BOXPLOT draw box plot on data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% DESCRIPTION: Boxplot is a convenient way of graphically depicting groups
% of numerical data. The bottom and top of the box are always the 25th and
% 75th  percentile (the lower and upper quartiles, respectively), and the
% band near the middle of the box is always the 50th percentile (the
% median). The ends of the whiskers are the percentiles corresponding to
% the confidence level defined by the user.
% 
% CALL:       boxplot(d1,...,dn, ops)
% 
% INPUT:      - d1,...dn, are column vectors. Different data must be input
%               as different columns.
%             - ops, a struct containing input parameters
%               - PlotData. Decide to plot all data or only the data
%               outside the confidence levels. Default true
%               - xData. A column vector with the x values for the plot.
%               - ConfLevel. Confidence level for box whiskers. Default 95%
%               - FontSize. Font size for x and y labels. Default 22
%               - LineWidth. Box line width. Default 2
%               - BoxWidth. the width of the box. Default 1
%               - Marker. Data marker type. Default '.'
%               - MarkerSize. Data marker size. Default 1
%               - XTickLabel. A cell containing a cell aray of x tick
%               labels. Default {{''}}
% 
% acknowledgements
% A special thanks to Shane Lin who submitted the boxPlot function in
% Matlab Central to which the present function is inspired
% 
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function boxplot(varargin)

  %%% check and set imput options
  % Default input struct
  defaultparams = struct(...
    'PlotData',true,...
    'xData',[],...
    'ConfLevel',0.95,...
    'FontSize',22,...
    'LineWidth',2,...
    'BoxWidth',1,...
    'Marker','.',...
    'MarkerSize',6,...
    'XTickLabel',{{''}});
  
  
  names = {'PlotData','xData','ConfLevel','FontSize','LineWidth','BoxWidth',...
    'Marker','MarkerSize','XTickLabel'};
  
    
  N = numel(varargin);
  if isstruct(varargin{N})
    ops = varargin{N};
    Nloop = N-1;
  else
    ops = {};
    Nloop = N;
  end
  
  % cope with multidimensional array
  if Nloop == 1
    Nin = size(varargin{1},2);
  else
    Nin = Nloop;
  end
  
  
  % collecting input and default params
  if ~isempty(ops)
    for jj=1:length(names)
      if isfield(ops, names(jj))
        defaultparams.(names{1,jj}) = ops.(names{1,jj});
      end
    end
  end
  
  conf = defaultparams.ConfLevel; % confidence level for confidence bounds calculation
  if conf>1
    conf = conf/100;
  end
  plotdata = defaultparams.PlotData;
  xvals = defaultparams.xData;
  fontsize = defaultparams.FontSize;
  lwidth = defaultparams.LineWidth;
  bwidth = defaultparams.BoxWidth;
  mark = defaultparams.Marker;
  mksize = defaultparams.MarkerSize;
  xticklabel = defaultparams.XTickLabel;
  
  % reorder data
  if Nloop > 1
    for ii=1:Nloop
      data(:,ii) = varargin{ii};
    end
  else
    data = varargin{1};
  end
  
  
  %%% draw the plot
  drawBox(data,xvals,Nin,conf,plotdata,lwidth,bwidth,mark,mksize)
  
  % set ylabel
  ylabel('Values','FontSize',fontsize)
  % set xlabel
  xlabel('Experiment','FontSize',fontsize)
    
  % set XTickLabel
  if ~isempty(xticklabel{1})
    set(gca,'XTickLabel',xticklabel)
  end

end

function drawBox(data,xvals,Nloop,conf,plotdata,lwidth,bwidth,mark,mksize)
  
  % define box width
  if isempty(xvals)
    unit = (1-1/(1+Nloop))/(1+9/(bwidth+3));
  else
    unit = xvals(1)*(1-1/(1+Nloop))/(1+9/(bwidth+3));
  end
  
  figure;
  hold on;
  v = zeros(5,1);
  for ii = 1:Nloop
    % sort data acsending
    sdata = sort(data(:,ii));
    % get data median
    v(1) = median(sdata);
    
    % get cdf
    [F,x] = utils.math.ecdf(sdata);
    % set box lower and upper limit, corresponding to a 25% and 75%
    % probability
    v(2) = interp1(F,x,0.25); % 25% limit
    v(3) = interp1(F,x,0.75); % 75% limit
    % set wisker limits
    alpm = (1-conf)/2;
    v(4) = interp1(F,x,alpm); % lower limit
    v(5) = interp1(F,x,1-alpm); % upper limit
    
    % draw data
    if plotdata % plot all data
      if isempty(xvals)
        stddata = std(sdata);
        % set x for data
        uunit = unit.*exp(-1.*((sdata-v(1)).^2)./(stddata).^2).*9./10;
        xdat = ii-uunit + 2*uunit.*rand(size(sdata));
      else
        stddata = std(sdata);
        % set x for data
        uunit = unit.*exp(-1.*((sdata-v(1)).^2)./(stddata).^2).*9./10;
        xdat = xvals(ii)-uunit + 2*uunit.*rand(size(sdata));
      end
      plot(xdat,sdata,[mark 'b'], 'MarkerSize', mksize);
    else % plot only data outside confidence levels
      if isempty(xvals)
        idx1 = find(sdata<v(4));
        idx2 = find(sdata>v(5));
        idx = [idx1;idx2];
        xdat = ii.*ones(size(idx));
      else
        idx1 = find(sdata<v(4));
        idx2 = find(sdata>v(5));
        idx = [idx1;idx2];
        xdat = xvals(ii).*ones(size(idx));
      end
      plot(xdat,sdata(idx),[mark 'b'], 'MarkerSize', mksize);
    end
    
    if isempty(xvals)
      % draw the min line
      plot([ii-unit, ii+unit], [v(4), v(4)], 'k', 'LineWidth', lwidth);
      % draw the max line
      plot([ii-unit, ii+unit], [v(5), v(5)], 'k', 'LineWidth', lwidth);
      % draw middle line
      plot([ii-unit, ii+unit], [v(1), v(1)], 'r', 'LineWidth', lwidth);
      % draw vertical line
      plot([ii, ii], [v(4), v(2)], '--k', 'LineWidth', lwidth);
      plot([ii, ii], [v(3), v(5)], '--k', 'LineWidth', lwidth);
      % draw box
      plot([ii-unit, ii+unit, ii+unit, ii-unit, ii-unit], [v(3), v(3), v(2), v(2), v(3)], 'k', 'LineWidth', lwidth);
    else
      % draw the min line
      plot([xvals(ii)-unit, xvals(ii)+unit], [v(4), v(4)], 'k', 'LineWidth', lwidth);
      % draw the max line
      plot([xvals(ii)-unit, xvals(ii)+unit], [v(5), v(5)], 'k', 'LineWidth', lwidth);
      % draw middle line
      plot([xvals(ii)-unit, xvals(ii)+unit], [v(1), v(1)], 'r', 'LineWidth', lwidth);
      % draw vertical line
      plot([xvals(ii), xvals(ii)], [v(4), v(2)], '--k', 'LineWidth', lwidth);
      plot([xvals(ii), xvals(ii)], [v(3), v(5)], '--k', 'LineWidth', lwidth);
      % draw box
      plot([xvals(ii)-unit, xvals(ii)+unit, xvals(ii)+unit, xvals(ii)-unit, xvals(ii)-unit], [v(3), v(3), v(2), v(2), v(3)], 'k', 'LineWidth', lwidth);
    end
      
    
    

  end

end
