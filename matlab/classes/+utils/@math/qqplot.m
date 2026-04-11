% QQPLOT makes quantile-quantile plot
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% h = qqplot(y1,[],ops) Plot a quantile-quantile plot comparing with
% theoretical model.
% 
% h = cdfplot(y1,y2,ops) Plot a quantile-quantile plot comparing two
% empirical cdfs.
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
%   - 'FontSize' -> Font size for axis. Default 22
%   - 'LineWidth' -> line width. Default 2
%   - 'axis' -> set axis properties of the plot. refer to help axis for
%   further details
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function h = qqplot(y1,y2,ops)
  
  %%% check and set imput options
  % Default input struct
  defaultparams = struct(...
    'ProbDist','Fdist',...
    'ShapeParam',1,...
    'params',[1 1],...
    'conflevel',0.95,...
    'FontSize',22,...
    'LineWidth',2,...
    'axis',[]);
  
  names = {'ProbDist','ShapeParam','params','conflevel','FontSize','LineWidth','axis'};
  
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
        % get theoretical Quantile corresponding to empirical probabilities
        tx = utils.math.Finv(eCD,dof(1),dof(2));
        CD = utils.math.Fcdf(ex,dof(1),dof(2));
      case 'normdist'
        tx = utils.math.Norminv(eCD,dof(1),dof(2));
        CD = utils.math.Normcdf(ex,dof(1),dof(2));
      case 'chi2dist'
        tx = utils.math.Chi2inv(eCD,dof(1));
        CD = utils.math.Chi2cdf(ex,dof(1));
      case 'gammadist'
        tx = gammaincinv(eCD,dof(1)).*dof(2);
        CD = gammainc(ex./dof(2),dof(1));
    end
    % get confidence levels with Kolmogorow - Smirnov test
    alp = (1-conf)/2;
    cVal = utils.math.SKcriticalvalues(numel(ex)*shp,[],alp);
    % get upper and lower bounds for x
    CDu = CD+cVal;
    CDl = CD-cVal;
    xup = interp1(CDl,ex,eCD);
    xlw = interp1(CDu,ex,eCD);
    
    figure
    h1 = plot(tx,ex);
    grid on
    hold on
    lnx = [min(tx) max(tx(1:end-1))];
    lny = [min(tx) max(tx(1:end-1))];
    h2 = line(lnx,lny,'Color','k');
    h3 = plot(tx,xup,'b--');
    h4 = plot(tx,xlw,'b--');
    xlabel('Theoretical Quantile','FontSize',fontsize);
    ylabel('Sample Quantile','FontSize',fontsize);
    set(h1(1), 'Color','r', 'LineStyle','-','LineWidth',lwidth);
    set(h2(1), 'Color','k', 'LineStyle','--','LineWidth',lwidth);
    set(h3(1), 'Color','b', 'LineStyle',':','LineWidth',lwidth);
    set(h4(1), 'Color','b', 'LineStyle',':','LineWidth',lwidth);
    legend([h1(1),h2(1),h3(1)],{'Sample Quantile','Reference','Conf. Bounds'},'Location','SouthEast')
    if ~isempty(axvect)
      axis(axvect);
    else
      % get limit for quantiles corresponding to 0 and 0.99 prob
      xlw = interp1(CD,tx,0.001,'linear');
      if isnan(xlw)
        xlw = min(CD);
      end
      xup = interp1(CD,tx,0.999,'linear');
      % get limit for quantiles corresponding to 0 and 0.99 prob
      ylw = interp1(eCD,ex,0.001,'linear');
      if isnan(ylw)
        ylw = min(eCD);
      end
      yup = interp1(eCD,ex,0.999,'linear');
      axis([xlw xup ylw yup]);
    end
    h = [h1;h2;h3;h4];
    
  else % do empirical comparison
    % get empirical distribution for input data
    [eCD1,ex1]=utils.math.ecdf(y1);
    [eCD2,ex2]=utils.math.ecdf(y2);
    
    % get confidence levels with Kolmogorow - Smirnov test
    alp = (1-conf)/2;
    cVal = utils.math.SKcriticalvalues(numel(ex1),numel(ex2),alp);
    % get confidence levels
    CDu = eCD2+cVal;
    CDl = eCD2-cVal;
    
    % get Quantile corresponding for second distribution to first empirical
    % probabilities
    tx = interp1(eCD2,ex2,eCD1);

    % get upper and lower bounds for x
    xup = interp1(CDl,ex2,eCD1);
    xlw = interp1(CDu,ex2,eCD1);

    figure
    h1 = plot(tx,ex1);
    grid on
    hold on
    lnx = [min(tx) max(tx(1:end-1))];
    lny = [min(tx) max(tx(1:end-1))];
    h2 = line(lnx,lny,'Color','k');
    h3 = plot(tx,xup,'b--');
    h4 = plot(tx,xlw,'b--');
    xlabel('Y2 Quantile','FontSize',fontsize);
    ylabel('Y1 Quantile','FontSize',fontsize);
    set(h1(1), 'Color','r', 'LineStyle','-','LineWidth',lwidth);
    set(h2(1), 'Color','k', 'LineStyle','--','LineWidth',lwidth);
    set(h3(1), 'Color','b', 'LineStyle',':','LineWidth',lwidth);
    set(h4(1), 'Color','b', 'LineStyle',':','LineWidth',lwidth);
    legend([h1(1),h2(1),h3(1)],{'Sample Quantile','Reference','Conf. Bounds'},'Location','SouthEast')
    if ~isempty(axvect)
      axis(axvect);
    else
      % get limit for quantiles corresponding to 0 and 0.99 prob
      xlw = interp1(eCD2,ex2,0.001,'linear');
      if isnan(xlw)
        xlw = min(eCD2);
      end
      xup = interp1(eCD2,ex2,0.999,'linear');
      % get limit for quantiles corresponding to 0 and 0.99 prob
      ylw = interp1(eCD1,ex1,0.001,'linear');
      if isnan(ylw)
        ylw = min(eCD1);
      end
      yup = interp1(eCD1,ex1,0.999,'linear');
      axis([xlw xup ylw yup]);
    end
    h = [h1;h2;h3;h4];
  end
  
end