% CDFPLOT makes cumulative distribution plot
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% h = cdfplot(y1,[],ops) Plot an empirical cumulative distribution function
% against a theoretical cdf.
% 
% h = cdfplot(y1,y2,ops) Plot two empirical cumulative distribution
% functions. Cdf for y1 is compared against cdf for y2 with confidence
% bounds.
% 
% ops is a cell aray of options
%   - 'ProbDist' -> theoretical distribution. Available distributions are:
%     - 'Fdist' -> F cumulative distribution function. In this case the
%     parameter 'params' should be a vector with distribution degrees of
%     freedoms [dof1 dof2]
%     - 'Normdist' -> Normal cumulative distribution function. In this case
%     the parameter 'params' should be a vector with distribution mean and
%     standard deviation [mu sigma]
%     - 'Chi2dist' -> Chi square cumulative distribution function. In this
%     case the parameter 'params' should be a number indicating
%     distribution degrees of freedom
%     - 'GammaDist' -> Gamma distribution. 'params' should contain the
%     shape and scale parameters
%   - 'ShapeParam' -> In the case of comparison of a data series with a
%   theoretical distribution and the data series is composed of correlated
%   elements. K can be adjusted with a shape parameter in order to recover
%   test fairness. In such a case the test is performed for K* = Phi *K.
%   Phi is the corresponding Shape parameter. The shape parameter depends
%   on the correlations and on the significance value. It does not depend
%   on data length. 
%   - 'params' -> Probability distribution parameters
%   - 'conflevel' -> requiered confidence for confidence bounds evaluation.
%   Default 0.95 (95%)
%   - 'criticalvalue' -> Critical value for confidence bounds calculation.
%   When a value is provided, the choice for 'conflevel' is ignored. This
%   option is useful in case the critical value for the test is available
%   from external calculations such as a Monte Carlo.
%   - 'FontSize' -> Font size for axis. Default 22
%   - 'LineWidth' -> line width. Default 2
%   - 'axis' -> set axis properties of the plot. refer to help axis for
%   further details
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function h = cdfplot(y1,y2,ops)
  
  %%% check and set imput options
  % Default input struct
  defaultparams = struct(...
    'ProbDist','Fdist',...
    'ShapeParam',1,...
    'params',[1 1],...
    'conflevel',0.95,...
    'criticalvalue',[],...
    'FontSize',22,...
    'LineWidth',2,...
    'axis',[]);
  
  names = {'ProbDist','ShapeParam','params','conflevel','criticalvalue','FontSize','LineWidth','axis'};
  
  % collecting input and default params
  if nargin == 3
    if ~isempty(ops)
      for jj=1:length(names)
        if isfield(ops, names(jj))
          defaultparams.(names{1,jj}) = ops.(names{1,jj});
        end
      end
    end
  end
  
  pdist = defaultparams.ProbDist; % check theoretical distribution
  shp = defaultparams.ShapeParam;
  dof = defaultparams.params; % distribution parameters
  conf = defaultparams.conflevel; % confidence level for confidence bounds calculation
  criticalvalue = defaultparams.criticalvalue; % critical value for confidence bounds calculation
  if conf>1
    conf = conf/100;
  end
  fontsize = defaultparams.FontSize;
  lwidth = defaultparams.LineWidth;
  axvect = defaultparams.axis;

  
  %%% check data input
  if isempty(y2) % do theoretical comparison
    % get empirical distribution for input data
    [eCD,ex]=utils.math.ecdf(y1);
    % switch between input theoretical distributions
    switch lower(pdist)
      case 'fdist'
        CD = utils.math.Fcdf(ex,dof(1),dof(2));
      case 'normdist'
        CD = utils.math.Normcdf(ex,dof(1),dof(2));
      case 'chi2dist'
        CD = utils.math.Chi2cdf(ex,dof(1));
      case 'gammadist'
        CD = gammainc(ex./dof(2),dof(1));
    end
    % get confidence levels with Kolmogorow - Smirnov test
    if isempty(criticalvalue)
      alp = (1-conf)/2;
      cVal = utils.math.SKcriticalvalues(numel(ex)*shp,[],alp);
    else
      cVal = criticalvalue;
    end
    % get confidence levels
    CDu = CD+cVal;
    CDl = CD-cVal;
    
    figure('Name','CDF Plot - Data vs. Model');
    h = stairs(ex,[eCD CD CDu CDl]);
    grid on
    xlabel('x','FontSize',fontsize);
    ylabel('F(x)','FontSize',fontsize);
    set(h(3:4), 'Color','b', 'LineStyle',':','LineWidth',lwidth);
    set(h(1), 'Color','r', 'LineStyle','-','LineWidth',lwidth);
    set(h(2), 'Color','k', 'LineStyle','--','LineWidth',lwidth);
    legend([h(1),h(2),h(3)],{'eCDF','CDF','Conf. Bounds'},'Location','SouthEast');
    if ~isempty(axvect)
      axis(axvect);
    else
      % get limit for quantiles corresponding to 0 and 0.99 prob
      xlw = interp1(eCD,ex,0.001,'linear');
      if isnan(xlw)
        xlw = min(ex);
      end
      xup = interp1(eCD,ex,0.999,'linear');
      axis([xlw xup 0 1]);
    end
    
  else % do empirical comparison
    % get empirical distribution for input data
    [eCD1,ex1]=utils.math.ecdf(y1);
    [eCD2,ex2]=utils.math.ecdf(y2);
    
    % get confidence levels with Kolmogorow - Smirnov test
    if isempty(criticalvalue)
      alp = (1-conf)/2;
      cVal = utils.math.SKcriticalvalues(numel(ex1),numel(ex2),alp);
    else
      cVal = criticalvalue;
    end
    % get confidence levels
    CDu = eCD2+cVal;
    CDl = eCD2-cVal;
    
    figure('Name','CDF Plot - Data1 vs. Data2');
    h1 = stairs(ex1,eCD1);
    grid on
    hold on
    h2 = stairs(ex2,[eCD2 CDu CDl]);
    xlabel('x','FontSize',fontsize);
    ylabel('F(x)','FontSize',fontsize);
    set(h2(2:3), 'Color',[0 113 188]./255, 'LineStyle',':','LineWidth',lwidth);
    set(h1(1), 'Color',[216 82 26]./255, 'LineStyle','-','LineWidth',lwidth);
    set(h2(1), 'Color',[0.1 0.1 0.1], 'LineStyle','--','LineWidth',lwidth);
    legend([h1(1),h2(1),h2(2)],{'eCDF1','eCDF2','Conf. Bounds'},'Location','SouthEast');
    if ~isempty(axvect)
      axis(axvect);
    else
      % get limit for quantiles corresponding to 0 and 0.99 prob
      xlw = interp1(eCD2,ex2,0.001,'linear');
      if isnan(xlw)
        xlw = min(ex2);
      end
      xup = interp1(eCD2,ex2,0.999,'linear');
      axis([xlw xup 0 1]);
    end
    h = [h1; h2];
  end
  
end
