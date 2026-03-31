% PPPLOT makes probability-probability plot
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% h = ppplot(y1,[],ops) Plot a probability-probability plot comparing with
% theoretical model.
% 
% h = cdfplot(y1,y2,ops) Plot a probability-probability plot comparing two
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
%   - 'params' -> Probability distribution parameters
%   - 'conflevel' -> requiered confidence for confidence bounds evaluation.
%   Default 0.95 (95%)
%   - 'FontSize' -> Font size for axis. Default 22
%   - 'LineWidth' -> line width. Default 2
%   - 'axis' -> set axis properties of the plot. refer to help axis for
%   further details
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function h = ppplot(y1,y2,ops)
  
  %%% check and set imput options
  % Default input struct
  defaultparams = struct('ProbDist','Fdist',...
    'params',[1 1],...
    'conflevel',0.95,...
    'FontSize',22,...
    'LineWidth',2,...
    'axis',[]);
  
  names = {'ProbDist','params','conflevel','FontSize','LineWidth','axis'};
  
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
    [ep,ex]=utils.math.ecdf(y1);
    % switch between input theoretical distributions
    switch lower(pdist)
      case 'fdist'
        % get theoretical probabilities corresponding to empirical quantiles
        tp = utils.math.Fcdf(ex,dof(1),dof(2));
      case 'normdist'
        tp = utils.math.Normcdf(ex,dof(1),dof(2));
      case 'chi2dist'
        tp = utils.math.Chi2cdf(ex,dof(1));
    end
    % get confidence levels with Kolmogorow - Smirnov test
    alp = (1-conf)/2;
    cVal = utils.math.SKcriticalvalues(numel(ex),numel(ex),alp);
    % get upper and lower bounds for x
    pup = CD+cVal;
    plw = CD-cVal;
    
    figure
    h1 = plot(tp,ep);
    grid on
    hold on
    lnx = [min(tp) max(tp(1:end-1))];
    lny = [min(tp) max(tp(1:end-1))];
    h2 = line(lnx,lny,'Color','k');
    h3 = plot(tp,pup,'b--');
    h4 = plot(tp,plw,'b--');
    xlabel('Theoretical Probability','FontSize',fontsize);
    ylabel('Sample Probability','FontSize',fontsize);
    set(h1(1), 'Color','r', 'LineStyle','-','LineWidth',lwidth);
    set(h2(1), 'Color','k', 'LineStyle','--','LineWidth',lwidth);
    set(h3(1), 'Color','b', 'LineStyle',':','LineWidth',lwidth);
    set(h4(1), 'Color','b', 'LineStyle',':','LineWidth',lwidth);
    legend([h1(1),h2(1),h3(1)],{'Sample Probability','Reference','Conf. Bounds'},'Location','SouthEast')
    if ~isempty(axvect)
      axis(axvect);
    else
      axis([0 0.99 0 0.99])
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
    
    % get probabilities corresponding for second distribution to first empirical
    % probabilities
    tp = interp1(ex2,eCD2,ex1);

    % get upper and lower bounds for p
    pup = interp1(ex2,CDu,ex1);
    plw = interp1(ex2,CDl,ex1);

    % empirical probabilities
    ep = eCD1;

    figure
    h1 = plot(tp,ep);
    grid on
    hold on
    lnx = [min(tp) max(tp(1:end-1))];
    lny = [min(tp) max(tp(1:end-1))];
    h2 = line(lnx,lny,'Color','k');
    h3 = plot(tp,pup,'b--');
    h4 = plot(tp,plw,'b--');
    xlabel('Y2 Probability','FontSize',fontsize);
    ylabel('Y1 Probability','FontSize',fontsize);
    set(h1(1), 'Color','r', 'LineStyle','-','LineWidth',lwidth);
    set(h2(1), 'Color','k', 'LineStyle','--','LineWidth',lwidth);
    set(h3(1), 'Color','b', 'LineStyle',':','LineWidth',lwidth);
    set(h4(1), 'Color','b', 'LineStyle',':','LineWidth',lwidth);
    legend([h1(1),h2(1),h3(1)],{'Sample Probability','Reference','Conf. Bounds'},'Location','SouthEast')
    if ~isempty(axvect)
      axis(axvect);
    else
      axis([0 0.99 0 0.99])
    end
    h = [h1;h2;h3;h4];
  end
  
end