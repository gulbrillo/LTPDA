% XFIT fit a function of x to data.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: XFIT performs a non-linear fit of a function of x to data.
% smodels fitting is also supported.
% 
% ALGORITHM: XFIT does a chi-squared minimization by means of different
% algorithms (see details in the default plist). Covariance matrix is also
% computed from the Fisher's Information Matrix. In case the Information
% Matrix is not positive-definite, uncertainties will not be stored in the
% output. 
%
% CALL:        b = xfit(a, pl)
%
% INPUTS:      a  - input AO to fit to
%              pl - parameter list (see below)
%
% OUTPUTs:     b  - a pest object containing the best-fit parameters,
%                   goodness-of-fit reduced chi-squared, fit degree-of-freedom
%                   covariance matrix and uncertainties. Additional
%                   quantities, like the Information Matrix, are contained 
%                   within the procinfo. The best-fit model can be evaluated
%                   from pest\eval.
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'xfit')">Parameters Description</a>
%
% EXAMPLES:
%
% % 1) Fit to a frequency-series
%
%   % Create a frequency-series
%   datapl = plist('fsfcn', '0.01./(0.0001+f) + 5*abs(randn(size(f))) ', 'f1', 1e-5, 'f2', 5, 'nf', 1000, ...
%      'xunits', 'Hz', 'yunits', 'N/Hz');
%   data = ao(datapl);
%   data.setName;
% 
%   % Do fit
%   fitpl = plist('Function', 'P(1)./(P(2) + Xdata) + P(3)', ...
%     'P0', [0.1 0.01 1]);
%   params = xfit(data, fitpl)
% 
%   % Evaluate model
%   BestModel = eval(params,plist('type','fsdata','xdata',data,'xfield','x'));
%   BestModel.setName;
%   
%   % Display results
%   iplot(data,BestModel)
%
% % 2) Fit to a noisy sine-wave
%
%   % Create a noisy sine-wave
%   fs    = 10;
%   nsecs = 500;
%   datapl = plist('waveform', 'Sine wave', 'f', 0.01, 'A', 0.6, 'fs', fs, 'nsecs', nsecs, ...
%     'xunits', 's', 'yunits', 'm');
%   sw = ao(datapl);
%   noise = ao(plist('tsfcn', '0.01*randn(size(t))', 'fs', fs, 'nsecs', nsecs));
%   data = sw+noise;
%   data.setName;
% 
%   % Do fit
%   fitpl = plist('Function', 'P(1).*sin(2*pi*P(2).*Xdata + P(3))', ...
%     'P0', [1 0.01 0]);
%   params = xfit(data, fitpl)
% 
%   % Evaluate model
%   BestModel = eval(params,plist('type','tsdata','xdata',sw,'xfield','x'));
%   BestModel.setName;
%   
%   % Display results
%   iplot(data,BestModel)
%
% % 3) Fit an smodel of a straight line to some data
%
%   % Create a noisy straight-line
%   datapl = plist('xyfcn', '2.33 + 0.1*x + 0.01*randn(size(x))', 'x', 0:0.1:10, ...
%     'xunits', 's', 'yunits', 'm');
%   data = ao(datapl);
%   data.setName;
% 
%   % Model to fit
%   mdl = smodel('a + b*x');
%   mdl.setXvar('x');
%   mdl.setParams({'a', 'b'}, {1 2});
% 
%   % Fit model
%   fitpl = plist('Function', mdl, 'P0', [1 1]);
%   params = xfit(data, fitpl)
% 
%   % Evaluate model
%   BestModel = eval(params,plist('xdata',data,'xfield','x'));
%   BestModel.setName;
%   
%   % Display results
%   iplot(data,BestModel)
%
% % 4) Fit a chirp-sine firstly starting from an initial guess (quite close
% % to the true values) (bad convergency) and secondly by a Monte Carlo
% % search (good convergency)
%
%   % Create a noisy chirp-sine
%   fs    = 10;
%   nsecs = 1000;
%   
%   % Model to fit and generate signal
%   mdl = smodel(plist('name', 'chirp', 'expression', 'A.*sin(2*pi*(f + f0.*t).*t + p)', ...
%     'params', {'A','f','f0','p'}, 'xvar', 't', 'xunits', 's', 'yunits', 'm'));
% 
%   % signal
%   s = mdl.setValues({10,1e-4,1e-5,0.3});
%   s.setXvals(0:1/fs:nsecs-1/fs);
%   signal = s.eval;
%   signal.setName;
% 
%   % noise
%   noise = ao(plist('tsfcn', '1*randn(size(t))', 'fs', fs, 'nsecs', nsecs));
% 
%   % data
%   data = signal + noise;
%   data.setName;
% 
%   % Fit model from the starting guess
%   fitpl_ig = plist('Function', mdl, 'P0',[8,9e-5,9e-6,0]);
%   params_ig = xfit(data, fitpl_ig);
% 
%   % Evaluate model
%   BestModel_ig = eval(params_ig,plist('xdata',data,'xfield','x'));
%   BestModel_ig.setName;
%   
%   % Display results
%   iplot(data,BestModel_ig)
%   
%   % Fit model by a Monte Carlo search
%   fitpl_mc = plist('Function', mdl, ...
%     'MonteCarlo', true, 'Npoints', 1000, 'LB', [8,9e-5,9e-6,0], 'UB', [11,3e-4,2e-5,2*pi]);
%   params_mc = xfit(data, fitpl_mc)
%   
%   % Evaluate model
%   BestModel_mc = eval(params_mc,plist('xdata',data,'xfield','x'));
%   BestModel_mc.setName;
%   
%   % Display results
%   iplot(data,BestModel_mc)
%
% % 5) Multichannel fit of smodels
%
%   % Ch.1 data
%   datapl = plist('xyfcn', '0.1*x + 0.01*randn(size(x))', 'x', 0:0.1:10, 'name', 'channel 1', ...
%     'xunits', 'K', 'yunits', 'Pa');
%   a1 = ao(datapl);
%   % Ch.2 data
%   datapl = plist('xyfcn', '2.5*x + 0.1*sin(2*pi*x) + 0.01*randn(size(x))', 'x', 0:0.1:10, 'name', 'channel 2', ...
%     'xunits', 'K', 'yunits', 'T');
%   a2 = ao(datapl);
%   
%   % Model to fit
%   mdl1 = smodel('a*x');
%   mdl1.setXvar('x');
%   mdl1.setParams({'a'}, {1});
%   mdl1.setXunits('K');
%   mdl1.setYunits('Pa');
%   
%   mdl2 = smodel('b*x + a*sin(2*pi*x)');
%   mdl2.setXvar('x');
%   mdl2.setParams({'a','b'}, {1,2});
%   mdl2.setXunits('K');
%   mdl2.setYunits('T');
%   
%   % Fit model
%   params = xfit(a1,a2, plist('Function', [mdl1,mdl2]));
%   
%   % evaluate model
%   b = eval(params, plist('index',1,'xdata',a1,'xfield','x'));
%   b.setName('fit Ch.1');
%   r = a1-b;
%   r.setName('residuals');
%   iplot(a1,b,r)
%   
%   b = eval(params, plist('index',2,'xdata',a2,'xfield','x'));
%   b.setName('fit Ch.2');
%   r = a2-b;
%   r.setName('residuals');
%   iplot(a2,b,r)
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'xfit')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = xfit(varargin)

  % global variables
  global Pidx Ydata weights modelFuncs dFcns hFcns lb ub  Nch Ndata estimator

  
  % Check if this is a call for parameters
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
  [as, ao_invars] = utils.helper.collect_objects(varargin(:), 'ao', in_names);
  pl              = utils.helper.collect_objects(varargin(:), 'plist', in_names);
  
  if nargout == 0
    error('### xfit cannot be used as a modifier. Please give an output variable.');
  end
  
  % combine plists
  pl = applyDefaults(getDefaultPlist(), pl);
  
  % Extract necessary parameters
  targetFcn = pl.find_core('Function');
  P0        = pl.find_core('P0');
%   ADDP      = pl.find_core('ADDP');
  userOpts  = pl.find_core('OPTSET');
  weights   = pl.find_core('WEIGHTS');
  FitUnc    = pl.find_core('FitUnc');
  UncMtd    = pl.find_core('UncMtd');
  linUnc    = pl.find_core('LinUnc');
  FastHess  = pl.find_core('FastHess');
  SymDiff   = pl.find_core('SymDiff');
  SymGrad   = pl.find_core('SymGrad');
  SymHess   = pl.find_core('SymHess');
  DiffOrder = pl.find_core('DiffOrder');
  lb        = pl.find_core('LB');
  ub        = pl.find_core('UB');
  MCsearch  = pl.find_core('MonteCarlo');
  Npoints   = pl.find_core('Npoints');
  Noptims   = pl.find_core('Noptims');
%   SVDsearch = pl.find_core('SVD');
%   nSVD      = pl.find_core('nSVD');
  Algorithm = pl.find_core('Algorithm');
%   AdpScale  = pl.find_core('AdpScale');
  % only for function handle fitting
  pnames    = pl.find_core('pnames');
%   pvalues   = pl.find_core('pvalues');
  estimator = pl.find_core('estimator');
  
  % Convert yes/no, true/false, etc. to booleans
  FitUnc    = utils.prog.yes2true(FitUnc);
  linUnc    = utils.prog.yes2true(linUnc);
  FastHess  = utils.prog.yes2true(FastHess);
  SymDiff  = utils.prog.yes2true(SymDiff);
  MCsearch  = utils.prog.yes2true(MCsearch);
%   SVDsearch = utils.prog.yes2true(SVDsearch);
%   AdpScale = utils.prog.yes2true(AdpScale);
  
  % Check the fitting algorithm
%   AlgoCheck = ~strcmpi(Algorithm,'fminsearch') & ~strcmpi(Algorithm,'fminunc') & ~isempty(Algorithm);
  
  if isempty(Algorithm)
    Algorithm = 'fminsearch';
    utils.helper.msg(msg.IMPORTANT, 'using %s as the fitting algorithm', upper(Algorithm));
  elseif ischar(Algorithm)
    Algorithm = lower(Algorithm);
    switch Algorithm
      case 'fminsearch'
        utils.helper.msg(msg.IMPORTANT, 'using %s as the fitting algorithm', upper(Algorithm));
        Algorithm = 'fminsearch';      
      case 'fminunc'
        if exist('fminunc','file')==2
          utils.helper.msg(msg.IMPORTANT, 'using %s as the fitting algorithm', upper(Algorithm));
          Algorithm = 'fminunc';
        else
          error('### you must install Optimization Toolbox in order to use %s', upper(Algorithm))
        end
      case 'fmincon'
        if exist('fmincon','file')==2
          utils.helper.msg(msg.IMPORTANT, 'using %s as the fitting algorithm', upper(Algorithm));
          Algorithm = 'fmincon';
        else
          error('### you must install Optimization Toolbox in order to use %s', upper(Algorithm))
        end
      case 'patternsearch'
        if exist('patternsearch','file')==2
          utils.helper.msg(msg.IMPORTANT, 'using %s as the fitting algorithm', upper(Algorithm));
          Algorithm = 'patternsearch';
        else
          error('### you must install Genetic Algorithm and Direct Search Toolbox in order to use %s', upper(Algorithm))
        end
      case 'ga'
        if exist('ga','file')==2
          utils.helper.msg(msg.IMPORTANT, 'using %s as the fitting algorithm', upper(Algorithm));
          Algorithm = 'ga';
        else
          error('### you must install Genetic Algorithm and Direct Search Toolbox in order to use %s', upper(Algorithm))
        end
      case 'simulannealbnd'
        if exist('simulannealbnd','file')==2
          utils.helper.msg(msg.IMPORTANT, 'using %s as the fitting algorithm', upper(Algorithm));
          Algorithm = 'simulannealbnd';
        else
          error('### you must install Genetic Algorithm and Direct Search Toolbox in order to use %s', upper(Algorithm))
        end
      otherwise
        error('### unknown fitting algorithm')
    end
  else
    error('### unknown format for ALGORITHM parameter')
  end
  
  % Estimator
  if isempty(estimator)
    estimator = 'chi2';
  elseif ~strcmp(estimator,{'chi2','abs','log','median'})
    error('### unknown name of the estimator')
  end
  
  
  % Data we will fit to
  Xdata = as.x;
  Ydata = as.y;
%   dYdata = as.dy;
  
  % Number of data point per each channel
  Ndata = numel(as(1).x);
    
  % Number of channels
  Nch = numel(as);
  multiCh = Nch-1;

  % Number of models
  if all(isa(targetFcn, 'smodel'))
    Nmdls = numel(targetFcn);
  elseif iscell(targetFcn)
    Nmdls = numel(targetFcn);
  else
    Nmdls = 1;
  end
  
  % consistency check on the data units
  Xunits = as.xunits;
%   Xunits = as(1).xunits.strs;
  if Nch>1
    XunitsCheck = Xunits(1).strs;
    for kk=2:Nch
      if ~strcmp(Xunits(kk).strs,XunitsCheck)
        error('### in multi-channel fitting the xunits of all data objects must be the same')
      end
    end
  end
  Xunits = as(1).xunits;
  Yunits = as.yunits;
  
  % consistency check on the inputs
  
  if isempty(targetFcn)
    error('### please specify at least a model');
  end
  
  if Nch~=Nmdls
    error('### number of data channels and models do not match')
  end
  
  for kk=1:Nch
    if any(numel(as(kk).x)~=Ndata)
      error('### the number of data is not self-consistent: please check that all channels have the same length')
    end
  end
  
  for kk=1:Nch
    for kkk=1:Nch
      if any(Xdata(:,kk)~=Xdata(:,kkk))
        error('### in multi-channel fitting the x-field of all data objects must be the same')
      end
    end
  end
  
  cellMdl = iscell(targetFcn);
      
  if multiCh
    if cellMdl
      for kk=1:Nmdls
        if ~isa(targetFcn{kk}, 'function_handle')
          error('### please use a cell array of function handles')
        end      
      end      
    else
    for kk=1:Nmdls
      if ~isa(targetFcn(kk), 'smodel')
        error('### multi-channel fitting is only possible with smodels')
      end
      if isempty(targetFcn(kk).expr)
        error('### please specify a target function for all smodels');
      end
      if ~isempty(targetFcn(kk).values) & size(targetFcn(kk).values)~=size(targetFcn(kk).params)
        error('### please give an initial value for each parameter')
      end
    end
    if ~isempty(P0)
      error('in multi-channel fitting the initial values for the parameters must be within each smodel')
    end    
    checkExistAllParams = 0;
    for kk=1:Nch
      checkExistAllParams = checkExistAllParams + ~isempty(targetFcn(kk).values);
    end
    if checkExistAllParams==0 && ~MCsearch
      error('### please give initial values for all parameters or use Monte Carlo instead')
    end
    end
  end
  
  % check P0
  if isempty(P0) && ~MCsearch
    for kk=1:Nmdls
      if isa(targetFcn(kk), 'smodel') && isempty(targetFcn(kk).values)
        error('### please give initial values for all parameters or use Monte Carlo instead')
      elseif ischar(targetFcn)
        error('### please give initial values for all parameters or use Monte Carlo instead')
%       elseif cellMdl
%         error('### please give initial values for all parameters or use Monte Carlo instead')
      end
    end
  end  
  
  % Extract anonymous functions
  
  if multiCh   
    
    if ~cellMdl
      % concatenate models and parameters
      [params,mdl_params,Pidx] = cat_mdls(targetFcn);
    else%if iscell(P0)
      [params,mdl_params,Pidx] = cat_mdls_cell(targetFcn, pnames);
%     else      
%       params = pnames;
%       Pidx = cell(1,Nch);
%       mdl_params = pnames;
%       for ii=1:Nch
%         Pidx{ii} = ones(1,numel(pnames));
%       end
    end
    
    % create the full initial value array
    if ~MCsearch && ~cellMdl
      P0 = zeros(1,numel(params));
      for ii=1:numel(params)
        for kk=1:Nmdls
          for jj=1:numel(targetFcn(kk).params)
            if strcmp(params{ii},targetFcn(kk).params{jj})
              P0(ii) = targetFcn(kk).values{jj};
            end
          end
        end
      end
    elseif cellMdl
      if isempty(P0)% || ~iscell(pvalues)
        error('### please give initial values')
      end
      if isempty(pnames) || ~iscell(pnames)
        error('### please give parameter names in a cell array')
      end
      if size(P0)~=size(pnames)
        error('### the size of pnames and pvalues does not match')
      end
%       P0 = zeros(1,numel(params));
%       for ii=1:numel(P0)
%         P0(ii) = pvalues{ii};
%       end
      if iscell(P0) && ~MCsearch
        for ii=1:numel(P0)
          if isempty(P0{ii})
            error('### please give initial values for all parameters or use Monte Carlo instead');
          end
        end        
      for ii=1:numel(params)
        for kk=1:Nmdls
          for jj=1:numel(pnames{kk})
            if strcmp(params{ii},pnames{kk}{jj})
              P0new(ii) = P0{kk}(jj);
            end
          end
        end
      end
      P0 = P0new;
      end
    end
    
    if all(isa(targetFcn,'smodel'))
      % anonymous fcns
      modelFuncs = cell(1,Nch);
      for kk=1:Nch
        targetFcn(kk).setXvals(Xdata(:,kk));
        modelFuncs{kk} = targetFcn(kk).fitfunc;
      end
    end
%     if cellMdl
%       for kk=1:Nch
%         modelFuncs{kk} = targetFcn{kk};
%       end
%     end   
  
  else
    
    % Check parameters
    if isempty(P0)
      if isa(targetFcn, 'smodel')
        P0 = [targetFcn.values{:}];
      elseif isempty(P0) && ~MCsearch
        error('### please give initial values for all parameters or use Monte Carlo instead');
      end
    end
    if size(P0)~=[1 numel(P0)]
      P0 = P0';
    end

    % convert input regular expression to anonymous function only for
    % single-channel fitting
    % create anonymouse function from user input expression
    if ischar(targetFcn)
      checkFcn = regexp(targetFcn, 'Xdata');
      if isempty(checkFcn)
        error('### when using a string expression for the input model, the independent variable must be named as Xdata')
      end
%       tfunc = eval(['@(P,Xdata,ADDP) (',targetFcn,')']);
      tfunc = eval(['@(P,Xdata) (',targetFcn,')']);
      % now create another anonymous function that only depends on the
      % parameters
%       modelFunc = @(x)tfunc(x, Xdata, ADDP);
      modelFuncs{1} = @(x)tfunc(x, Xdata);
    elseif isa(targetFcn,'smodel')
      targetFcn.setXvals(Xdata);
      modelFuncs{1} = targetFcn.fitfunc;
%     elseif isa(targetFcn,'function_handle')
%       modelFunc = targetFcn; 
    end
  
  end
  
  if cellMdl
    for kk=1:Nch
      modelFuncs{kk} = targetFcn{kk};
    end
%     if ~multiCh
%       modelFunc = modelFuncs{1};
%     end
  end  
  
  
  
  % check lb and ub
  
  % constrained search or not
  conSearch = ~isempty(lb) || ~isempty(ub);
  
  if MCsearch || conSearch
    if isempty(lb) || isempty(ub)
      error('### please give LB and UB')
    end
    if multiCh && (~iscell(lb) || ~iscell(ub))
      error('### in multi-channel fitting upper and lower bounds must be cell array')
    end
    if size(lb)~=size(ub) % | size(lb)~=size(P0) | size(ub)~=size(P0)
      error('### LB and UB must be of the same size');
    end
    if multiCh && numel(lb)~=Nch && numel(ub)~=Nch
      error('### in multi-channel fitting LB and UB must be cell array whose number of elements is equal to the number of models');
    end
    if ~multiCh && ~all(lb<=ub)
      error('### UB must me greater equal to LB');
    end
    if multiCh
      for kk=1:Nmdls
        if numel(lb{kk})~=numel(mdl_params{kk})
          error('### please give the proper number of values for LB for each model')
        end
        if numel(ub{kk})~=numel(mdl_params{kk})
          error('### please give the proper number of values for UB for each model')
        end
        if ~all(lb{kk}<=ub{kk})
          error('### UB must me greater equal to LB for all parameters and models');
        end
        if size(lb{kk})~=[1 numel(lb{kk})]
          lb{kk} = lb{kk}';
          ub{kk} = ub{kk}';
        end
      end
    end
    if ~multiCh
      if size(lb)~=[1 numel(lb)]
        lb = lb';
        ub = ub';
      end
    end
  end
  
  
  % create the full bounds array
  if (MCsearch || conSearch) && multiCh && ~cellMdl
    lb_full = zeros(1,numel(params));
    ub_full = zeros(1,numel(params));
    for ii=1:numel(params)
      for kk=1:Nmdls
        for jj=1:numel(targetFcn(kk).params)
          if strcmp(params{ii},targetFcn(kk).params{jj})
            lb_full(ii) = lb{kk}(jj);
            ub_full(ii) = ub{kk}(jj);
          end
        end
      end
    end
    lb = lb_full;
    ub = ub_full;
  elseif (MCsearch || conSearch) && multiCh && cellMdl
    lb_full = zeros(1,numel(params));
    ub_full = zeros(1,numel(params));
    for ii=1:numel(params)
      for kk=1:Nmdls
        for jj=1:numel(mdl_params{kk})
          if strcmp(params{ii},mdl_params{kk}(jj))
            lb_full(ii) = lb{kk}(jj);
            ub_full(ii) = ub{kk}(jj);
          end
        end
      end
    end
    lb = lb_full;
    ub = ub_full;
%   elseif cellMdl
%     lb = lb;
%     ub = ub;
  end
  
%   if ~iscell(ADDP)
%     ADDP = {ADDP};
%   end
  
  % Get input options
  switch Algorithm
    case 'fminsearch'
      opts = optimset(@fminsearch);
      if isstruct(userOpts)
        opts = optimset(opts, userOpts);
      else
        for j=1:2:numel(userOpts)
          opts = optimset(opts, userOpts{j}, userOpts{j+1});
        end
      end
    case 'fminunc'
      opts = optimset(@fminunc);
      if isstruct(userOpts)
        opts = optimset(opts, userOpts);
      else
        for j=1:2:numel(userOpts)
          opts = optimset(opts, userOpts{j}, userOpts{j+1});
        end
      end
     case 'fmincon'
      opts = optimset(@fmincon);
      if isstruct(userOpts)
        opts = optimset(opts, userOpts);
      else
        for j=1:2:numel(userOpts)
          opts = optimset(opts, userOpts{j}, userOpts{j+1});
        end
      end
    case 'patternsearch'
      opts = psoptimset(@patternsearch);
      if isstruct(userOpts)
        opts = psoptimset(opts, userOpts);
      else
        for j=1:2:numel(userOpts)
          opts = psoptimset(opts, userOpts{j}, userOpts{j+1});
        end
      end
    case 'ga'
      opts = gaoptimset(@ga);
      if isstruct(userOpts)
        opts = gaoptimset(opts, userOpts);
      else
        for j=1:2:numel(userOpts)
          opts = gaoptimset(opts, userOpts{j}, userOpts{j+1});
        end
      end
    case 'simulannealbnd'
      opts = saoptimset(@simulannealbnd);
      if isstruct(userOpts)
        opts = saoptimset(opts, userOpts);
      else
        for j=1:2:numel(userOpts)
          opts = saoptimset(opts, userOpts{j}, userOpts{j+1});
        end
      end
  end

  
  % compute the right weights 
 [weights,unweighted] = find_weights(as,weights);
  
  
  % define number of free parameters
  if ~MCsearch
    Nfreeparams = length(P0);
  else
    Nfreeparams = length(lb);
  end
  
   if Nch==1
      Pidx{1}=1:Nfreeparams;
%       modelFuncs{1}=modelFunc;
   end
  
  % Check for user-supplied analytical gradient as cell-array of function
  % handles
  if ~isempty(SymGrad)
    dFcns = cell(Nmdls,1);
    for kk=1:Nmdls
      for ii=1:numel(SymGrad{kk})
        dFcns{kk}{ii} = SymGrad{kk}{ii};
      end
    end
  end
  
  % Check for user-supplied analytical hessian as cell-array of function
  % handles
  if ~isempty(SymGrad) && ~isempty(SymHess)
    hFcns = cell(Nmdls,1);
    for kk=1:Nmdls
      for jj=1:numel(dFcns{kk})
        for ii=1:jj
          hFcns{kk}{ii,jj} = SymHess{kk}{ii,jj};
        end
      end
    end
  end
  
  % If requested, compute the analytical gradient
  if SymDiff || linUnc && isempty(SymGrad)
    utils.helper.msg(msg.IMPORTANT, 'evaluating symbolic derivatives');
    if ~isa(targetFcn,'smodel')
      error('### smodel functions must be used in order to do symbolic differentiation')
    end
    % compute symbolic 1st-order differentiation
    dFcnsSmodel = cell(Nmdls,1);
    for kk=1:Nmdls
      p = targetFcn(kk).params;
      for ii=1:numel(p)
        dFcnsSmodel{kk}(ii) = diff(targetFcn(kk),p{ii});
      end
    end
    % extract anonymous function
    dFcns = cell(Nmdls,1);
    for kk=1:Nmdls
      for ii=1:numel(dFcnsSmodel{kk})
        dFcns{kk}{ii} = dFcnsSmodel{kk}(ii).fitfunc;
      end
    end
    if DiffOrder==2;
      % compute symbolic 2nd-order differentiation
      hFcnsSmodel = cell(Nmdls,1);
      for kk=1:Nmdls
        p = targetFcn(kk).params;
        for jj=1:numel(p)
          for ii=1:jj
            hFcnsSmodel{kk}(ii,jj) = diff(dFcnsSmodel{kk}(ii),p{jj});
          end
        end
      end
      % extract anonymous function
      hFcns = cell(Nmdls,1);
      for kk=1:Nmdls
        for jj=1:numel(dFcnsSmodel{kk})
          for ii=1:jj
            hFcns{kk}{ii,jj} = hFcnsSmodel{kk}(ii,jj).fitfunc;
          end
        end
      end
    end
  end
  
  % Set optimset in order to take care of eventual symbolic differentiation
  if ~isempty(dFcns) && any(strcmp(Algorithm,{'fminunc','fmincon'}))
    opts = optimset(opts, 'GradObj', 'on');
  end
  if ~isempty(hFcns) && any(strcmp(Algorithm,{'fminunc','fmincon'}))
    opts = optimset(opts, 'Hessian', 'on');
  end
  
  % Start the best-fit search
  
  if MCsearch
    
    utils.helper.msg(msg.IMPORTANT, 'performing a Monte Carlo search');
    
    % find best-fit by a Monte Carlo search       
    [P,chi2,exitflag,output,h,MChistory] = ...
      find_bestfit_montecarlo(lb, ub, Npoints, Noptims, opts, Algorithm, FastHess);
        
  else
        
    utils.helper.msg(msg.IMPORTANT, 'looking for a best-fit from the initial guess');
    
    % find best-fit starting from an initial guess
    [P,chi2,exitflag,output,h,chainHistory] = ...
      find_bestfit_guess(P0, opts, Algorithm, FastHess);
    
  end
  
  
  % degrees of freedom in the problem
%   dof = Nch * (Ndata - Nfreeparams);
  dof = Nch * Ndata - Nfreeparams;
  
  % redefine MChistory's column to put the reduced chi2s
  if MCsearch
    MChistory(:,1) = MChistory(:,1)./dof;
  end
  
  % redefine history to put the reduced chi2s
  if ~MCsearch && ~isempty(chainHistory)
    chainHistory.fval = chainHistory.fval./dof;
  end
  
  % Confidence intervals contruction
  
  if FitUnc
    
    utils.helper.msg(msg.IMPORTANT, 'estimating confidence intervals');
    
    % find best-fit errors
    [se,Sigma,Corr,I,H,errH,J,errJ] = ...
      find_errors(modelFuncs, P, chi2, dof, UncMtd, FastHess, h,  weights, unweighted, linUnc, dFcns);
      
        
    % report issue on covariance matrix in case of
    % degeneracy/quasi-singularity/ill-conditioning, etc.
    posDef = all(diag(Sigma)>=0);
    if ~posDef
      % analysis of information matrix in order to cancel out un-important
      % parameters
      Inorm=I./norm(I);
      pnorms = zeros(1,size(Inorm,2));
      for ii=1:size(I,2);
        pnorms(ii) = norm(Inorm(:,ii));
      end
      [pnorms_sort,IX] = sort(pnorms,'descend');
      if Nmdls>1
        pnames_sort = params(IX);
      elseif isa(targetFcn,'smodel') && Nmdls==1%&& ~isempty(targetFcn.params)
        params = targetFcn.params;
        pnames_sort = params(IX);
      elseif isa(targetFcn,'function_handle') %&& ~isempty(targetFcn.params)
        pnames_sort = pnames(IX);
      end
      utils.helper.msg(msg.IMPORTANT, ['Information matrix is quasi-singular due to degeneracy or ill-conditioning: \n'...
        'consider eliminating the parameters with low information.']); % ...'In the following, parameters are reported in descending order of information']);
      for ii=1:numel(pnorms_sort);
        if exist('pnames_sort','var')
          utils.helper.msg(msg.IMPORTANT, 'param %s: %g ', pnames_sort{ii}, pnorms_sort(ii));
        else
          utils.helper.msg(msg.IMPORTANT, 'param %d: %g ', IX(ii), pnorms_sort(ii));
        end
      end
      
    end
    
  end
  
  utils.helper.msg(msg.IMPORTANT, 'final best-fit found at reduced chi2, dof: %g %d ', chi2/dof, dof);
  
  if FitUnc && ~isempty(se)
    for kk=1:numel(P)
      utils.helper.msg(msg.IMPORTANT, 'best-fit param %d: %g +- %2.1g ', kk, P(kk), se(kk));
    end
  else
    for kk=1:numel(P)
      utils.helper.msg(msg.IMPORTANT, 'best-fit param %d: %g ', kk, P(kk));
    end
  end
  
  
  % check the existence of all variables
  if ~exist('se','var');         se = [];         end
  if ~exist('Sigma','var');      Sigma = [];      end
  if ~exist('Corr','var');       Corr = [];       end
  if ~exist('I','var');          I = [];          end
  if ~exist('H','var');          H = [];          end
  if ~exist('errH','var');       errH = [];       end
  if ~exist('J','var');          J = [];          end
  if ~exist('errJ','var');       errJ = [];       end
  if ~exist('Sigma','var');      Sigma = [];      end
  if ~exist('MChistory','var');  MChistory = [];  end
%   if ~exist('SVDhistory','var'); SVDhistory = [];  end
  if ~exist('output','var');     output = [];     end
  
  
  % Make output pest
  out = pest;
  if Nch>1 %exist('params')
    out.setNames(params);
  elseif Nch==1 && isa(targetFcn, 'smodel')
    out.setNames(targetFcn.params);
  end
  out.setY(P');
  out.setDy(se');
  out.setCov(Sigma);
  out.setCorr(Corr);
  out.setChi2(chi2/dof);
  out.setDof(dof);
  if ~MCsearch && ~isempty(chainHistory)
    out.setChain([chainHistory.fval,chainHistory.x]);
  end
  
  % add the output best-fit models
  outFcn = targetFcn;
  if isa(targetFcn, 'smodel') && Nmdls>1
     for kk=1:Nmdls
       p = P(Pidx{kk});
       outFcn(kk).setValues(p);
%        outFcn(kk).setXvals(Xdata(:,1));
       outFcn(kk).setXunits(Xunits);
       outFcn(kk).setYunits(Yunits(kk));
       outFcn(kk).setName(['Best-fit model ' num2str(kk)]);
     end
     out.setModels(outFcn);
  elseif isa(targetFcn, 'smodel') && Nmdls==1
    outFcn.setValues(P');
%     outFcn.setXvals(Xdata(:,1));
    outFcn.setXunits(Xunits);
    outFcn.setYunits(Yunits);
    outFcn.setName('Best-fit model');
    out.setModels(outFcn);
  elseif ischar(targetFcn)
    % convert regular expression into smodel
    targetFcn = regexprep(targetFcn, 'Xdata', 'x');
    for ii=1:Nfreeparams
      targetFcn = regexprep(targetFcn, ['P\(' num2str(ii) '\)'], ['P' num2str(ii)]);
    end
    outFcn = smodel((targetFcn));
    pnames = cell(1,Nfreeparams);
    for ii=1:Nfreeparams
      pnames{ii} = ['P' num2str(ii)];
    end
    outFcn.setParams(pnames, P');
    outFcn.setXvar('x');
%     outFcn.setXvals(Xdata);
    outFcn.setXunits(Xunits);
    outFcn.setYunits(Yunits);
    outFcn.setName('Best-fit model');
    out.setModels(outFcn);
    out.setNames(pnames);
  end
  
  
  % Set Name, History and Procinfo
  if ~cellMdl
    mdlname = char(targetFcn);
    if numel(mdlname)>20
      mdlname = mdlname(1:20);
    end
    out.name = sprintf('xfit(%s)', mdlname);
  else
    mdlname = func2str(targetFcn{1});
    for kk=2:Nch
      mdlname = strcat(mdlname,[',' func2str(targetFcn{kk})]);
    end
    out.name = sprintf('xfit(%s)', mdlname);
  end
  out.addHistory(getInfo('None'), pl, ao_invars(:), [as(:).hist]);
  out.procinfo = plist('algorithm', Algorithm, 'exitflag', exitflag, 'output', output, ...
    'InfoMatrix', I,...
    'MChistory', MChistory);
    % 'SVDhistory', SVDhistory, 'res', res, 'hess', H, 'errhess', errH, 'jac', J, 'errjac', errJ);
  
  % Set outputs
  if nargout > 0
    varargout{1} = out;
  end
  
  clear global Pidx Ydata weights modelFuncs dFcns hFcns lb ub scale Nch Ndata estimator
  
end

%--------------------------------------------------------------------------
% Included Functions
%--------------------------------------------------------------------------

function [chi2,g,H] = fit_chi2(x)

  global Pidx Ydata weights modelFuncs dFcns hFcns lb ub scale estimator

  Nfreeparams = numel(x);
  Nmdls = numel(modelFuncs);
  Ndata = numel(Ydata(:,1)); 
  
    mdldata = zeros(Ndata,Nmdls);
    for kk=1:Nmdls
      p = x(Pidx{kk}).*scale(Pidx{kk});
      mdldata(:,kk) = modelFuncs{kk}(p);
    end  
    res = (mdldata-Ydata).*sqrt(weights);
  if all(x>=lb & x<=ub) % all(p>=lb & p<=ub) % all(x.*scale>=lb & x.*scale<=ub) % 
%     chi2 = res'*res;
%     chi2 = sum(diag(chi2)); 
    if strcmp(estimator,'chi2')
      chi2 = sum(sum(res.^2));
    elseif strcmp(estimator,'abs')
      chi2 = sum(sum(abs(res)));
    elseif strcmp(estimator,'log')
      chi2 = sum(sum(log(1+res.^2/2)));
    elseif strcmp(estimator,'median')
      dof = Ndata*Nmdls - Nfreeparams;
      res = reshape(res,numel(res),1);
      chi2 = median(abs(res))*dof;
    end
  else
    chi2 = 10e50;
  end
  
  if nargout > 1 % gradient required
%     if all(x.*scale>=lb & x.*scale<=ub)
      grad = cell(Nmdls,1);
      g = zeros(Nmdls,Nfreeparams);
      for kk=1:Nmdls
        p = x(Pidx{kk}).*scale(Pidx{kk});
        Np = numel(p);
        grad{kk} = zeros(Ndata,Np);
        for ii=1:Np        
          grad{kk}(:,ii) = dFcns{kk}{ii}(p);
          g(kk,Pidx{kk}(ii)) = 2.*res(:,kk)'*grad{kk}(:,ii);
  %         dF=dFcns{kk}{ii}(p);
  %         g(kk,Pidx{kk}(ii)) = 2.*sum(res(:,kk)'*dF);
        end
      end
      if Nmdls>1
        g = sum(g);
      end
%     elseif any(x.*scale<lb)
%       g = repmat(-10e50,[1 Nfreeparams]);
%     elseif any(x.*scale>ub)
%       g = repmat(10e50,[1 Nfreeparams]);
%     end
  end
  
  if nargout > 2 % hessian required
%     hess = cell(Nmdls,1);
    H = zeros(Nmdls,Nfreeparams,Nfreeparams);
    for kk=1:Nmdls
      p = x(Pidx{kk}).*scale(Pidx{kk});
      Np = numel(p);
%       hess{kk} = zeros(Ndata,Np);
      for jj=1:Np
        for ii=1:jj        
          hF = hFcns{kk}{ii,jj}(p);
          H1 = sum(res(:,kk)'*hF);
          H2 = sum(weights(:,kk).*grad{kk}(:,ii).*grad{kk}(:,jj));
          H(kk,Pidx{kk}(ii),Pidx{kk}(jj)) = 2*(H1+H2);
        end
      end
    end
    H = squeeze(sum(H,1));
%     if Nmdls>1
%       H = sum(H);
%     end
    H = H+triu(H,1)';
  end
  
end

%--------------------------------------------------------------------------

% function chi2 = fit_chi2(P, ydata, weights, fcn)
%   
%   % evaluate model
%   mdldata = fcn(P);
% %   if ~isequal(size(mdldata), size(ydata))
% %     ydata = ydata.';
% %   end
%   
%   chi2 = sum((abs((mdldata-ydata)).^2).*weights);
%   
% end

%--------------------------------------------------------------------------

% function chi2 = fit_chi2_bounds(P, ydata, weights, fcn, LB, UB)
%   
%   % evaluate model
%   mdldata = fcn(P);
% %   if ~isequal(size(mdldata), size(ydata))
% %     ydata = ydata.';
% %   end
%   
%   if all(P>=LB & P<=UB)
%     chi2 = sum((abs((mdldata-ydata)).^2).*weights);
%   else
%     chi2 = 10e50;
%   end
%   
% end

%--------------------------------------------------------------------------

% function g = scaling(f, x, scale)
%   
%   g = f(x.*scale);
%   
% end

%--------------------------------------------------------------------------

function scale = find_scale(P0, LB, UB)
  
  if ~isempty(P0)
    Nfreeparams = numel(P0);
  else
    Nfreeparams = numel(LB);
  end
  
  % define parameter scale
%   scale = ones(1,Nfreeparams);
  
%   if ~isempty(LB) & ~isempty(UB)
%     for ii=1:Nfreeparams
%       if ~(LB(ii)==0 & UB(ii)==0)
%         if LB(ii)==0 | UB(ii)==0
%           scale(ii) = max(abs(LB(ii)),abs(UB(ii)));
%         elseif abs(LB(ii))==abs(UB(ii))
%           scale(ii) = abs(UB);
%         elseif LB(ii)~=UB(ii)
%           scale(ii) = sqrt(abs(LB(ii)) * abs(UB(ii))); % (abs(lb(ii)) + abs(ub(ii)))/2;
%         end
%       end
%     end
%   end
  if ~isempty(LB) && ~isempty(UB)
    scale = sqrt(abs(LB) .* abs(UB));
    for ii=1:Nfreeparams
      if scale(ii)==0
        scale(ii) = max(abs(LB(ii)),abs(UB(ii)));
      end
    end
  else
    scale = abs(P0);
    for ii=1:Nfreeparams
      if scale(ii)==0
        scale(ii) = 1;
      end
    end
  end
  
end

%--------------------------------------------------------------------------

function [weightsOut,unweighted] = find_weights(as,weightsIn)
  
  Ydata = as.y;
  dYdata = as.dy;
  
  noWeights = isempty(weightsIn);
  noDY = isempty(dYdata);
  
  unweighted = noWeights & noDY;
  
  % check data uncertainties
  if any(dYdata==0) && ~noDY
    error('### some of the data uncertainties are zero: cannot fit')
  end
  
  if length(dYdata)~=length(Ydata) && ~noDY
    error('### length of Y fields and dY fields do not match')
  end
  
  if noWeights
    % The user did not input weights.
    % Looking for the dy field of the input data
    if noDY
      % Really no input from user
      weightsOut = ones(size(Ydata));
    else
      % Uses uncertainties in Ydata to evaluate data weights
      weightsOut = 1./dYdata.^2;
    end
%   elseif isnumeric(weightsIn)
%     if size(weightsIn)~=size(Ydata)
%       weightsOut = weightsIn';
%     end   
  elseif numel(weightsIn) == 1
    if isnumeric(weightsIn)
      weightsOut = weightsIn .* ones(size(Ydata));
    elseif isa(weightsIn, 'ao')
      if isequal(weightsIn.yunits, as.yunits)
        weightsOut = weightsIn.y;
      elseif size(weightsIn.data.getY)~=size(Ydata)
        error('### size of data ao and weights ao do not match')
      else
        error('### units for data and uncertainties do not match')
      end
    else
      error('### unknown format for weights parameter');
    end
  else
    weightsOut = weightsIn;
  end
    
end
  
%--------------------------------------------------------------------------  

function [params,mdl_params,paramidx] = cat_mdls(mdls)
  
  % This function concatenates the parameter names and values for 
  % all the input models to construct the new parameter list.
  
  Nmdls = numel(mdls);
  
  % create the full parameter name array
  params_cat = horzcat(mdls(:).params);
  params_new = cell(1);
  for ii=1:numel(params_cat)
    if ~strcmp(params_cat{ii},params_new)
      params_new = [params_new params_cat{ii}];
    end
  end
  params = params_new(2:numel(params_new));

  % create the parameter list for each model
  for kk=1:Nmdls
    mdl_params{kk} = mdls(kk).params;
  end
  
  % create a cell array of indeces which map the parameter vector of each
  % model to the full one
  paramidx = cell(1,Nmdls);
  for kk=1:Nmdls
    for jdx=1:length(mdl_params{kk})
      for idx=1:length(params)
        if (strcmp(params{idx}, mdl_params{kk}(jdx)))
          paramidx{kk}(jdx) = idx;
          break;
        else
          paramidx{kk}(jdx) = 0;
        end
      end
    end
  end
  
end

%--------------------------------------------------------------------------  

function [params,mdl_params,paramidx] = cat_mdls_cell(mdls, pnames)
  
  % This function concatenates the parameter names and values for 
  % all the input models to construct the new parameter list.
  
  Nmdls = numel(mdls);
  
  % create the full parameter name array
  params_cat = horzcat(pnames{:});
  params_new = cell(1);
  for ii=1:numel(params_cat)
    if ~strcmp(params_cat{ii},params_new)
      params_new = [params_new params_cat{ii}];
    end
  end
  params = params_new(2:numel(params_new));

  % create the parameter list for each model
  for kk=1:Nmdls
    mdl_params{kk} = pnames{kk};
  end
  
  % create a cell array of indeces which map the parameter vector of each
  % model to the full one
  paramidx = cell(1,Nmdls);
  for kk=1:Nmdls
    for jdx=1:length(mdl_params{kk})
      for idx=1:length(params)
        if (strcmp(params{idx}, mdl_params{kk}(jdx)))
          paramidx{kk}(jdx) = idx;
          break;
        else
          paramidx{kk}(jdx) = 0;
        end
      end
    end
  end
  
end

%--------------------------------------------------------------------------

% function chi2 = fit_chi2_multich(P, Pidx, ydata, weights, fcns)
%   
%   Nmdls = numel(fcns);
%   Ndata = numel(ydata(:,1));
%   
%   mdldata = zeros(Ndata,Nmdls);
%   for kk=1:Nmdls
%     p = P(Pidx{kk});
%     mdldata(:,kk) = fcns{kk}(p);
%   end
%   
%   res = (ydata-mdldata).*weights;
%     
%   chi2 = res'*res;
%   chi2 = sum(diag(chi2));
%   
% end

%--------------------------------------------------------------------------
  
% function chi2 = fit_chi2_multich_bounds(P, Pidx, ydata, weights, fcns, LB, UB)
%   
%   if all(P>=LB & P<=UB)
%     
%     Nmdls = numel(fcns);
%     Ndata = numel(ydata(:,1));
%   
%     mdldata = zeros(Ndata,Nmdls);
%     for kk=1:Nmdls
%       p = P(Pidx{kk});
%       mdldata(:,kk) = fcns{kk}(p);
%     end
%   
%     res = (ydata-mdldata).*weights;
%     
%     chi2 = res'*res;
%     chi2 = sum(diag(chi2));
%      
%   else
%     chi2 = 10e50;
%   end
%   
% end

%--------------------------------------------------------------------------

function chi2_guesses = montecarlo(func, LB, UB, Npoints)
  
  Nfreeparams = numel(LB);
  
  % construct the guess matrix: each rows contain the chi2 and the
  % parameter guess
  guesses = zeros(Npoints,Nfreeparams);
  for jj=1:Nfreeparams
    guesses(:,jj) = LB(jj)+(UB(jj)-LB(jj))*rand(1,Npoints);
  end
    
  % evaluate the chi2 at each guess
  chi2_guesses = zeros(1,Nfreeparams+1);
  for ii=1:Npoints
%     check = ii-1/Npoints*100;
%     if rem(fix(check),10)==0 && check==fix(check)
%       
%       disp(sprintf('%d%% done',check));
%     end
    chi2_guess = func(guesses(ii,:));
    chi2_guesses = cat(1,chi2_guesses,[chi2_guess,guesses(ii,:)]);
  end
  chi2_guesses(1,:) = [];
  
  % sort the guesses for ascending chi2
  chi2_guesses = sortrows(chi2_guesses);
    
end
    
%-------------------------------------------------------------------------- 

function [x,fval,exitflag,output,h,MChistory] = ...
    find_bestfit_montecarlo(LB, UB, Npoints, Noptims, opts, algorithm, FastHess)
  
  global scale
  
  Nfreeparams = length(LB);
  
  % check Npoints
  if isempty(Npoints)
    Npoints = 100000;
  end
  % check Noptims
  if isempty(Noptims)
    Noptims = 10;
  end
  
  if Npoints<Noptims
    error('### Npoints must be at least equal to Noptims')
  end
  
  % define parameter scale
  scale = find_scale([], LB, UB);
  
  % scale function to minimize
%   func = @(x)scaling(func, x, scale);
  
  % scale bounds
  LB = LB./scale;
  UB = UB./scale;
  
  % do a Monte Carlo search
  chi2_guesses = montecarlo(@fit_chi2, LB, UB, Npoints);
    
  % minimize over the first guesses
  fitresults = zeros(Noptims,Nfreeparams+1);
  exitflags = {};
  outputs = {};
  hs = {};
  for ii=1:Noptims
    P0 = chi2_guesses(ii,2:Nfreeparams+1);
    if strcmpi(algorithm,'fminunc')
      [x,fval,exitflag,output,dummy,h] = fminunc(@fit_chi2, P0, opts);
    elseif strcmpi(algorithm,'fmincon')
      [x,fval,exitflag,output,dummy,dummy,h] = fmincon(@fit_chi2, P0, [], [], [], [], LB, UB, [], opts);
    elseif strcmpi(algorithm,'patternsearch')
      [x,fval,exitflag,output] = patternsearch(@fit_chi2, P0, [], [], [], [], LB, UB, [], opts);
    elseif strcmpi(algorithm,'ga')
      [x,fval,exitflag,output] = ga(@fit_chi2, numel(P0), [], [], [], [], LB, UB, [], opts);
    elseif strcmpi(algorithm,'simulannealbnd')
      [x,fval,exitflag,output] = simulannealbnd(@fit_chi2, P0, LB, UB, opts);
    else
      [x,fval,exitflag,output] = fminsearch(@fit_chi2, P0, opts);
    end
    fitresults(ii,1) = fval;
    fitresults(ii,2:Nfreeparams+1) = x;
    exitflags{ii} = exitflag;
    outputs{ii} = output;
    if FastHess && ~exist('h','var')
      h = fastHessian(@fit_chi2,x,fval);
    end
    if exist('h','var')
      hs{ii} = h;
    end
  end
  
  % sort the results
  [dummy, ix] = sort(fitresults(:,1));
  fitresults = fitresults(ix,:);
  
%   % refine fit over the first bestfit
%   P0 = fitresults(1,2:Nfreeparams+1);
%   if strcmpi(algorithm,'fminunc')
%     [x,fval,exitflag,output] = fminunc(func, P0, opts);
%   elseif strcmpi(algorithm,'fmincon')
%     [x,fval,exitflag,output] = fmincon(func, P0, [], [], [], [], LB, UB, [], opts);
%   elseif strcmpi(algorithm,'patternsearch')
%     [x,fval,exitflag,output] = patternsearch(func, P0, [], [], [], [], LB, UB, [], opts);
%   elseif strcmpi(algorithm,'ga')
%     [x,fval,exitflag,output] = ga(func, numel(P0), [], [], [], [], LB, UB, [], opts); % ga does not improve the bestfit
%   elseif strcmpi(algorithm,'simulannealbnd')
%     [x,fval,exitflag,output] = simulannealbnd(func, P0, LB, UB, opts);    
%   else
%     [x,fval,exitflag,output] = fminsearch(func, P0, opts);
%   end
  
  % set the best-fit
  fval = fitresults(1,1);
  x = fitresults(1,2:Nfreeparams+1);

  % scale best-fit
  x = x.*scale;
  
  % scale hessian
  if exist('hs','var')
    for kk=1:numel(hs)
      for ii=1:numel(x)
        for jj=1:numel(x)
          hs{kk}(ii,jj) = hs{kk}(ii,jj)/scale(ii)/scale(jj);
        end
      end
    end
%   else
%     h = [];
  end
    
  % scale fit results
  MChistory = fitresults;
  for ii=1:size(MChistory,1)
    MChistory(ii,2:Nfreeparams+1) = MChistory(ii,2:Nfreeparams+1).*scale;
  end
  
  % set the proper exitflag & output
  exitflags = exitflags(ix);
  outputs = outputs(ix);
  if exist('hs','var') && ~(isempty(hs))
    hs = hs(ix);
    h = hs{1};
  else
    h = [];
  end
  exitflag = exitflags{1};
  output = outputs{1};
  
  clear global scale
   
end

%-------------------------------------------------------------------------- 

function [x,fval,exitflag,output,h,outHistory] = ...
    find_bestfit_guess(P0, opts, algorithm, FastHess)
  
  global lb ub scale chainHistory

  if isempty(lb)
    lb = -Inf;
  end
  if isempty(ub)
    ub = Inf;
  end
  
  % define parameter scale
  scale = find_scale(P0, [], []);
  
  % scale initial guess
  P0 = P0./scale;
  
  % scale bounds
  lb = lb./scale;
  ub = ub./scale;
  
  % initialize history
  chainHistory.x = [];
  chainHistory.fval = [];
      
  % minimize over the initial guess
  if strcmpi(algorithm,'fminunc')
    opts = optimset(opts,'outputfcn',@outfun);
    [x,fval,exitflag,output,dummy,h] = fminunc(@fit_chi2, P0, opts);
  elseif strcmpi(algorithm,'fmincon')
    opts = optimset(opts,'outputfcn',@outfun);
    [x,fval,exitflag,output,dummy,dummy,h] = fmincon(@fit_chi2, P0, [], [], [], [], lb, ub, [], opts);
  elseif strcmpi(algorithm,'patternsearch')
%     opts = psoptimset(opts,'outputfcn',@outfun);
    [x,fval,exitflag,output] = patternsearch(@fit_chi2, P0, [], [], [], [], lb, ub, [], opts);
  elseif strcmpi(algorithm,'ga')
%     opts = gaoptimset(opts,'outputfcn',@outfun);
    [x,fval,exitflag,output] = ga(@fit_chi2, numel(P0), [], [], [], [], lb, ub, [], opts);
  elseif strcmpi(algorithm,'simulannealbnd')
%     opts = saoptimset(opts,'outputfcn',@outfun);
    [x,fval,exitflag,output] = simulannealbnd(@fit_chi2, P0, lb, ub, opts);
  else
    opts = optimset(opts,'outputfcn',@outfun);
    [x,fval,exitflag,output] = fminsearch(@fit_chi2, P0, opts);
  end
  
  if FastHess && ~exist('h','var')
    h = fastHessian(@fit_chi2,x,fval);
  end
   
  % scale best-fit
  x = x.*scale;
  
  % scale hessian
  if exist('h','var')
    for ii=1:numel(x)
        for jj=1:numel(x)
          h(ii,jj) = h(ii,jj)/scale(ii)/scale(jj);
        end
    end
  else
    h = [];
  end
  
  if ~isempty(chainHistory.x)
    outHistory = chainHistory;
    outHistory.x = chainHistory.x.*repmat(scale,size(chainHistory.x,1),1);
  else
    outHistory = [];
  end
  
  clear global lb ub scale chainHistory
  
end

%--------------------------------------------------------------------------

 function stop = outfun(x,optimvalues,state)
 
 global chainHistory
 
  stop = false;
  if strcmp(state,'iter')
    chainHistory.fval = [chainHistory.fval; optimvalues.fval];
    chainHistory.x = [chainHistory.x; x];
  end
  
 end

%--------------------------------------------------------------------------

function hess = fastHessian(fun,x0,fx0) 
% fastHessian calculates the numerical Hessian of fun evaluated at x
% using finite differences.

nVars = numel(x0);

hess = zeros(nVars);

  % Define stepsize  
  stepSize = eps^(1/4)*sign(x0).*max(abs(x0),1);
  
  % Min e Max change
  DiffMinChange = 1e-008;
  DiffMaxChange = 0.1;
  
  % Make sure step size lies within DiffMinChange and DiffMaxChange
  stepSize = sign(stepSize+eps).*min(max(abs(stepSize),DiffMinChange),DiffMaxChange);
  % Calculate the upper triangle of the finite difference Hessian element 
  % by element, using only function values. The forward difference formula 
  % we use is
  %
  % Hessian(i,j) = 1/(h(i)*h(j)) * [f(x+h(i)*ei+h(j)*ej) - f(x+h(i)*ei) 
  %                          - f(x+h(j)*ej) + f(x)]                   (2) 
  % 
  % The 3rd term in (2) is common within each column of Hessian and thus
  % can be reused. We first calculate that term for each column and store
  % it in the row vector fplus_array.
  fplus_array = zeros(1,nVars);
  for j = 1:nVars
    xplus = x0;
    xplus(j) = x0(j) + stepSize(j);
    % evaluate  
    fplus = fun(xplus);       
    fplus_array(j) = fplus;
  end
  
  for i = 1:nVars
    % For each row, calculate the 2nd term in (4). This term is common to
    % the whole row and thus it can be reused within the current row: we
    % store it in fplus_i.
    xplus = x0;
    xplus(i) = x0(i) + stepSize(i);
    % evaluate  
    fplus_i = fun(xplus);        
 
    for j = i:nVars   % start from i: only upper triangle
      % Calculate the 1st term in (2); this term is unique for each element
      % of Hessian and thus it cannot be reused.
      xplus = x0;
      xplus(i) = x0(i) + stepSize(i);
      xplus(j) = xplus(j) + stepSize(j);
      % evaluate  
      fplus = fun(xplus);        

      hess(i,j) = (fplus - fplus_i - fplus_array(j) + fx0)/(stepSize(i)*stepSize(j)); 
    end 
  end
  
  % Fill in the lower triangle of the Hessian
  hess = hess + triu(hess,1)';
    
end

%--------------------------------------------------------------------------

% function [x,fval,exitflag,output,h,SVDhistory] = ...
%     find_bestfit_guess_SVD(P0, lb, ub, opts, algorithm, FastHess, nSVD) 
%   
%   if isempty(lb)
%     lb = -Inf;
%   end
%   if isempty(ub)
%     ub = Inf;
%   end
%   
%   % define parameter scale
%   scale = find_scale(P0, [], []);
%   
% %   % scale function to minimize
% %   func = @(x)scaling(func, x, scale);
%   
%   % scale initial guess
%   P0 = P0./scale;
%   
%   % scale bounds
%   if ~isempty(lb)
%     lb = lb./scale;
%   end
%   if ~isempty(ub)
%     ub = ub./scale;
%   end
%   
%   % set the guess for 0-iteration
%   x = P0;
%   
%   Nfreeparams = numel(P0);
%   
%   fitresults = zeros(nSVD,Nfreeparams+1);
%   exitflags = {};
%   outputs = {};
%   hs = {};
%   
%   % start SVD loop
%   for ii=1:nSVD
%     
%      % minimize over the old parameter space
%     if strcmpi(algorithm,'fminunc')
%       [x,fval,exitflag,output,grad,h] = fminunc(@fit_chi2, x, opts);
%     elseif strcmpi(algorithm,'fmincon')
%       [x,fval,exitflag,output,lambda,grad,h] = fmincon(@fit_chi2, x, [], [], [], [], lb, ub, [], opts);
%     elseif strcmpi(algorithm,'patternsearch')
%       [x,fval,exitflag,output] = patternsearch(@fit_chi2, P0, [], [], [], [], lb, ub, [], opts);
%     elseif strcmpi(algorithm,'ga')
%       [x,fval,exitflag,output] = ga(@fit_chi2, numel(P0), [], [], [], [], lb, ub, [], opts);
%     elseif strcmpi(algorithm,'simulannealbnd')
%       [x,fval,exitflag,output] = simulannealbnd(@fit_chi2, P0, lb, ub, opts);
%     else
%       [x,fval,exitflag,output] = fminsearch(@fit_chi2, P0, opts);
%     end
%   
%     if FastHess && ~exist('h','var')
%       h = fastHessian(func,x,fval);
%     end
%     
%     % compute Jacobian
%     J = zeros(Nch*Ndata,Np);
%     for kk=1:Nch
%       for ll=1:Np
%         J(((ii-1)*Ndata+1):ii*Ndata,ll) = dFcns{kk}{ll}(x.*scale);
%       end
%     end
%     
%     % take SVD decomposition of hessian
%     [U,S,V] = svd(J);
%      
%     % cancel out column with very low information
%     thresh = 100*eps;
%     idx = (diag(S)./norm(diag(S)))<=thresh;
%     pos = find(idx~=0);
%     
%     % reduced matrix
%     Sred = S;
%     Ured = U;
%     Vred = V;    
%     Sred(:,pos) = [];
%     Sred(pos,:) = [];
%     Ured(:,pos) = [];
%     Ured(pos,:) = [];
%     Vred(:,pos) = [];
%     Vred(pos,:) = [];
%     
%         
%     % start from here inserting norm-rescaling... also in funcSVD!
%   
%     % guess in the new parameter space
%     % pay attention because here x is row-vector and xSVD ic column-vector 
%     xSVD = U'*x';
%     xSVD(pos) = [];
%     
% %     % bounds in the new parameter space
% %     if ~isempty(lb) && ~isempty(ub) 
% %       lbSVD = U'*lb';
% %       ubSVD = U'*ub';
% %     end
%         
%     % do the change in the variables
%     funcSVD = @(xSVD)func_SVD(func,xSVD,U,pos);
%     
%     % minimize over the new parameter space
%     if strcmpi(algorithm,'fminunc')
%       [xSVD,fvalSVD,exitflag,output,grad,hSVD] = fminunc(funcSVD, xSVD, opts);
%     elseif strcmpi(algorithm,'fmincon')
%       [xSVD,fvalSVD,exitflag,output,lambda,grad,hSVD] = fmincon(funcSVD, xSVD, [], [], [], [], [], [], [], opts);
%     elseif strcmpi(algorithm,'patternsearch')
%       [xSVD,fvalSVD,exitflag,output] = patternsearch(funcSVD, xSVD, [], [], [], [], [], [], [], opts);
%     elseif strcmpi(algorithm,'ga')
%       [xSVD,fvalSVD,exitflag,output] = ga(funcSVD, numel(xSVD), [], [], [], [], [], [], [], opts);
%     elseif strcmpi(algorithm,'simulannealbnd')
%       [xSVD,fvalSVD,exitflag,output] = simulannealbnd(funcSVD, xSVD, [], [], opts);
%     else
%       [xSVD,fvalSVD,exitflag,output] = fminsearch(funcSVD, xSVD, opts);
%     end
%     
%     if FastHess && ~exist('hSVD','var')
%       hSVD = fastHessian(funcSVD,xSVD,fvalSVD);
%     end
%     
% %     if fvalSVD<fval
% %       % take the new
% %       x = (U'*xSVD)';
% %       fval = fvalSVD;
% %       % trasformare la nuova h nella vecchia
% %       h = U'*hSVD;
% %     else
% %       % take the old
% %     end
% 
%     % return to the full parameter vector
%     xSVDfull = zeros(numel(xSVD)+numel(pos),1);
%     setVals = setdiff(1:numel(xSVDfull),pos);
%     xSVDfull(setVals) = xSVD;
% %     x = xb;
%     
%     % back to the old parameter space
%     x = (U*xSVDfull)';
%     fval = fvalSVD;
%     hRed = Ured*hSVD*Vred';
%     h = hRed;
%     for kk=1:numel(pos)
%       h(pos(kk),:) = zeros(1,size(h,2));
%       h(:,pos(kk)) = zeros(size(h,1),1);
%     end    
%     
%     fitresults(ii,1) = fval;
%     fitresults(ii,2:Nfreeparams+1) = x;
%     exitflags{ii} = exitflag;
%     outputs{ii} = output;
%     hs{ii} = h;
%         
%   end
%   
%   % sort the results
%   [chi2s, ix] = sort(fitresults(:,1));
%   fitresults = fitresults(ix,:);
%   
%   % set the best-fit
%   fval = fitresults(1,1);
%   x = fitresults(1,2:Nfreeparams+1);
%   
%   % scale best-fit
%   x = x.*scale;
%     
%   % scale hessian
%   for ii=1:numel(x)
%     for jj=1:numel(x)
%       h(ii,jj) = h(ii,jj)/scale(ii)/scale(jj);
%     end
%   end
%       
%   % scale fit results
%   SVDhistory = fitresults;
%   for ii=1:size(SVDhistory,1)
%     SVDhistory(ii,2:Nfreeparams+1) = SVDhistory(ii,2:Nfreeparams+1).*scale;
%   end
%   
%   % set the proper exitflag & output
%   exitflags = exitflags(ix);
%   outputs = outputs(ix);
%   hs = hs(ix);
%   exitflag = exitflags{1};
%   output = outputs{1};
%   h = hs{1};
%    
% end

%--------------------------------------------------------------------------

% function z = func_SVD(func,y,U,pos)
% 
%   yFull = zeros(numel(y)+numel(pos),1);
%   setVals = setdiff(1:numel(yFull),pos);
%   yFull(setVals) = y;    
% 
%   x = (U*yFull)';  
%   
%   z = func(x);
% 
% end

%--------------------------------------------------------------------------

% function adaptive_scaling(P0, scaleIn, func, Niter, opts, algorithm)
%    
%   Nfreeparams = numel(P0);
%   
%   for ii=1:Niter
%     
%     % new guess
%     P0_new = P0;
%     % new scale
%     scale = find_scale(P0, [], []);
%    
%     % scale bounds
%     LB = LB./scale;
%     UB = UB./scale;
%      
% %       if ~multiCh
%         % rescale model
%         modelFunc = @(x)scaling(modelFunc, x, scale_new./scale);
%             
%       % define function to minimize
%       if isempty(lb) & isempty(ub)        
%         func = @(x)fit_chi2(x, Ydata, weights, modelFunc);
%       else
%         lb = lb.*scale./scale_new;
%         ub = ub.*scale./scale_new;
%         func = @(x)fit_chi2_bounds(x, Ydata, weights, modelFunc, lb, ub);
%       end
%       
% %       else
% % %         func = @(x)fit_chi2_multich(params, x, Ydata, mdl_params, modelFuncs);
% %         func = @(x)scaling(func, x, scale_new/scale);
% %       end
%       
%       % Make new fit
%       [x,fval_new,exitflag,output] = fminsearch(func, P0_new./scale_new, opts);
%       % stopping criterion
%       if abs(fval_new-fval) <= 3*eps(fval_new-fval) 
%         fval = fval_new;
%         scale = scale_new;
%         break
%       end
%       fval = fval_new;
%       scale = scale_new;
%     end
%    end
% 
% end

%--------------------------------------------------------------------------

function [se,Sigma,Corr,I,H,errH,J,errJ] = find_errors(modelFcn, x, fval, dof, UncMtd, FastHess, h, weights, unweighted, linUnc, dFcns)
  
  global scale Nch Ndata lb ub
  
  % set infinite bounds
  lb = repmat(-Inf,size(x));
  ub = repmat(Inf,size(x));

  % check on UncMtd and FastHess
  if strcmpi(UncMtd,'jacobian')
    FastHess = 0;
  elseif FastHess==1 && isempty(h)
    FastHess = 0;
  end

  Nfreeparams = numel(x);
  
  if ~FastHess
  
    % find new scale based on the best-fit found
    scale = find_scale(x, [], []);
    
  else
    
    scale = ones(1,Nfreeparams);
    
  end
  
    % scale best-fit
    x = x./scale;
    
  
  % standard deviation of the residuals
  sdr = sqrt(fval/dof);
  
  % compute information matrix from linear approximation: error propagation
  % from symbolical gradient
  if linUnc
    % compute Jacobian
    J = zeros(Nch*Ndata,Nfreeparams);
    for ii=1:Nch
      for ll=1:Nfreeparams
        J(((ii-1)*Ndata+1):ii*Ndata,ll) = dFcns{ii}{ll}(x.*scale);
      end
    end
  elseif ~strcmpi(UncMtd,'jacobian') || numel(modelFcn)~=1 && ~linUnc
    
      % Hessian method.
      % Brief description.
      % Here I use the most general method: Hessian of chi2 function. For further readings see
      % Numerical Recipes. Note that for inv, H should be non-singular.
      % Badly-scaled matrices may take to singularities: use Cholesky
      % factorization instead.
      % In practice, a singular Hessian matrix may go out for the following main reasons:
      % 1 - you have reached a false minimum (H should be strictly
      % positive-definite for a well-behaved minimum);
      % 2 - strong correlation between some parameters;
      % 3 - independency of the model on some parameters.
      % In the last two cases you should reduce the dimensionality of the
      % problem.
      % One last point discussed here in Trento is that the Hessian method reduces
      % to the Jacobian, when considering linear models.
      % Feedbacks are welcome.
      % Trento, Giuseppe Congedo
    
    if ~FastHess
      % scale function to find the hessian
%       func = @(x)scaling(func, x, scale);
      
      [H,errH] = hessian(@fit_chi2,x);
    
    elseif ~isempty(h) && FastHess % here the hessian is not scaled
      H = h;
    end
    
    if unweighted
      % information matrix based on sdr
      I = H / sdr^2 / 2;
    else
      % information matrix based on canonical form
      I = H./2;
    end
     
  elseif ~linUnc
    
%     % scale function to find the jacobian
%     modelFcn = @(x)scaling(modelFcn, x, scale);
    
    % Jacobian method
    [J,errJ] = jacobianest(modelFcn{1},x);
  end

  if exist('J','var')
    if unweighted
      % information matrix based on sdr
      I = J'*J ./ sdr^2;
    else
      % redefine the jacobian to take care of the weights
      if size(weights)~=size(J(:,1))
        weights = weights';
      end        
      for ii=1:size(J,2)
        J(:,ii) = sqrt(weights).*J(:,ii);
      end
      % information matrix based on jacobian
      I = J'*J;
    end
     
  end
  
  % check positive-definiteness
%   [R,p] = chol(I);
%   posDef = p==0;

  % Covariance matrix from inverse
  Sigma = inv(I);

%   % Covariance matrix from pseudo-inverse
%   if issparse(I)
% %     [U,S,V] = svds(I,Nfreeparams);
% %     I = full(I);
%     I = full(I);
%     [U,S,V] = svd(I);
%   else
%     [U,S,V] = svd(I);
%   end
%   Sigma = V/S*U';
  
  % Does the covariance give proper positive-definite variances?
  posDef = all(diag(Sigma)>=0);
  
  if posDef
    
    % Compute correlation matrix
    Corr = zeros(size(Sigma));
    for ii=1:size(Sigma,1)
      for jj=1:size(Sigma,2)
        Corr(ii,jj) = Sigma(ii,jj) / sqrt(Sigma(ii,ii)) / sqrt(Sigma(jj,jj));
      end
    end
    
    % Parameter standard errors
    se = sqrt(diag(Sigma))';
       
    % rescale errors and covariance matrix
    if ~FastHess && ~linUnc % otherwise H is already scaled in find_bestfit function
      se = se.*scale;
      for ii=1:Nfreeparams
        for jj=1:Nfreeparams
          Sigma(ii,jj) = Sigma(ii,jj)*scale(ii)*scale(jj);
        end
      end
    end
  end
    
    % rescale information matrix
    if ~FastHess && ~linUnc % otherwise H is already scaled in find_bestfit function
      for ii=1:Nfreeparams
        for jj=1:Nfreeparams
          I(ii,jj) = I(ii,jj)/scale(ii)/scale(jj);
        end
      end
    end
    
    if ~exist('se','var');         se = [];         end
    if ~exist('Sigma','var');      Sigma = [];      end
    if ~exist('Corr','var');       Corr = [];       end
    if ~exist('I','var');          I = [];          end
    if ~exist('H','var');          H = [];          end
    if ~exist('errH','var');       errH = [];       end
    if ~exist('J','var');          J = [];          end
    if ~exist('errJ','var');       errJ = [];       end
    
    clear global scale
 
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
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.sigproc, '', sets, pl);
  ii.setModifier(false);
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
  
  % Function
  p = param({'Function', 'The function (or symbolic model <tt>smodel</tt>) of Xdata that you want to fit. For example: ''P(1)*Xdata''.'}, paramValue.EMPTY_STRING);
  pl.append(p);
  
  % Weights
  p = param({'Weights', ['An array of weights, one value per X sample.<br>'...
    'By default, <tt>xfit</tt> takes data uncertainties from the dy field of the input object.'...
    'If provided, <tt>weights</tt> make <tt>xfit</tt> ignore these.'...
    'Otherwise <tt>weights</tt> will be considered as ones.']}, paramValue.EMPTY_STRING);
  pl.append(p);
  
  % P0
  p = param({'P0', ['An array of starting guesses for the parameters.<br>'...
    'This is not necessary if you fit with <tt>smodel</tt>s; in that case the parameter'...
    'values from the <tt>smodel</tt> are taken as the initial guess.']}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
%   % ADDP
%   p = param({'ADDP', 'A cell-array of additional parameters to pass to the function. These will not be fit.'}, {1, {'{}'}, paramValue.OPTIONAL});
%   pl.append(p);
  
  % LB
  p = param({'LB', ['Lower bounds for the parameters.<br>'...
    'This improves the convergency. Mandatory for Monte Carlo.<br>'...
    'For multichannel fitting it has to be a cell-array.']}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
  % UB
  p = param({'UB', ['Upper bounds for the parameters.<br>'...
    'This improves the convergency. Mandatory for Monte Carlo.<br>'...
    'For multichannel fitting it has to be a cell-array.']}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
  % Algorithm
  p = param({'ALGORITHM', ['A string defining the fitting algorithm.<br>'...
    '<tt>fminunc</tt>, <tt>fmincon</tt> require ''Optimization Toolbox'' to be installed.<br>'...
    '<tt>patternsearch</tt>, <tt>ga</tt>, <tt>simulannealbnd</tt> require ''Genetic Algorithm and Direct Search'' to be installed.<br>']}, ...
    {1, {'fminsearch', 'fminunc', 'fmincon', 'patternsearch', 'ga', 'simulannealbnd'}, paramValue.SINGLE});
  pl.append(p);

  % OPTSET
  p = param({'OPTSET', ['An optimisation structure to pass to the fitting algorithm.<br>'...
    'See <tt>fminsearch</tt>, <tt>fminunc</tt>, <tt>fmincon</tt>, <tt>optimset</tt>, for details.<br>'...
    'See <tt>patternsearch</tt>, <tt>psoptimset</tt>, for details.<br>'... 
    'See <tt>ga</tt>, <tt>gaoptimset</tt>, for details.<br>'...
    'See <tt>simulannealbnd</tt>, <tt>saoptimset</tt>, for details.']}, paramValue.EMPTY_STRING);
  pl.append(p);
  
  % FitUnc
  p = param({'FitUnc', 'Fit parameter uncertainties or not.'}, paramValue.TRUE_FALSE);
  pl.append(p);
  
  % UncMtd
  p = param({'UncMtd', ['Choose the uncertainties estimation method.<br>'...
    'For multi-channel fitting <tt>hessian</tt> is mandatory.']}, {1, {'hessian', 'jacobian'}, paramValue.SINGLE});
  pl.append(p);
  
  % FastHess
  p = param({'FastHess', ['Choose whether or not the hessian should be estimated from a fast-forward finite differences algorithm; '...
    'use this method to achieve better performance in CPU-time, but accuracy is not ensured; '...
    'otherwise, the default (computer expensive, but more accurate) method will be used.']}, paramValue.FALSE_TRUE);
  pl.append(p);
  
  % MonteCarlo
  p = param({'MonteCarlo', ['Do a Monte Carlo search in the parameter space.<br>'...
    'Useful when dealing with high multiplicity of local minima. May be computer-expensive.<br>'...
    'Note that, if used, P0 will be ignored. It also requires to define LB and UB.']}, paramValue.FALSE_TRUE);
  pl.append(p);
  
  % Npoints
  p = param({'Npoints', 'Set the number of points in the parameter space to be extracted.'}, 100000);
  pl.append(p);
  
  % Noptims
  p = param({'Noptims', 'Set the number of optimizations to be performed after the Monte Carlo.'}, 10);
  pl.append(p);
  
  % estimator
  p = param({'estimator', ['Choose the robust local M-estimate as the statistical estimator of the fit:<br>'...
    ' ''chi2'' (least square) for data with normal distribution;<br>'...
    ' ''abs'' (mean absolute deviation) for data with double exponential distribution;<br>'...
    ' ''log'' (log least square) for data with Lorentzian distribution.']}, ...
    {1, {'chi2', 'abs', 'log'}, paramValue.SINGLE});
  pl.append(p);
  
  
end
% END

%--------------------------------------------------------------------------

  % Author: John D'Errico
  % e-mail: woodchips@rochester.rr.com
    
%--------------------------------------------------------------------------
% DERIVEST SUITE
%--------------------------------------------------------------------------

function [der,errest,finaldelta] = derivest(fun,x0,varargin)
  % DERIVEST: estimate the n'th derivative of fun at x0, provide an error estimate
  % usage: [der,errest] = DERIVEST(fun,x0)  % first derivative
  % usage: [der,errest] = DERIVEST(fun,x0,prop1,val1,prop2,val2,...)
  %
  % Derivest will perform numerical differentiation of an
  % analytical function provided in fun. It will not
  % differentiate a function provided as data. Use gradient
  % for that purpose, or differentiate a spline model.
  %
  % The methods used by DERIVEST are finite difference
  % approximations of various orders, coupled with a generalized
  % (multiple term) Romberg extrapolation. This also yields
  % the error estimate provided. DERIVEST uses a semi-adaptive
  % scheme to provide the best estimate that it can by its
  % automatic choice of a differencing interval.
  %
  % Finally, While I have not written this function for the
  % absolute maximum speed, speed was a major consideration
  % in the algorithmic design. Maximum accuracy was my main goal.
  %
  %
  % Arguments (input)
  %  fun - function to differentiate. May be an inline function,
  %        anonymous, or an m-file. fun will be sampled at a set
  %        of distinct points for each element of x0. If there are
  %        additional parameters to be passed into fun, then use of
  %        an anonymous function is recommended.
  %
  %        fun should be vectorized to allow evaluation at multiple
  %        locations at once. This will provide the best possible
  %        speed. IF fun is not so vectorized, then you MUST set
  %        'vectorized' property to 'no', so that derivest will
  %        then call your function sequentially instead.
  %
  %        Fun is assumed to return a result of the same
  %        shape as its input x0.
  %
  %  x0  - scalar, vector, or array of points at which to
  %        differentiate fun.
  %
  % Additional inputs must be in the form of property/value pairs.
  %  Properties are character strings. They may be shortened
  %  to the extent that they are unambiguous. Properties are
  %  not case sensitive. Valid property names are:
  %
  %  'DerivativeOrder', 'MethodOrder', 'Style', 'RombergTerms'
  %  'FixedStep', 'MaxStep'
  %
  %  All properties have default values, chosen as intelligently
  %  as I could manage. Values that are character strings may
  %  also be unambiguously shortened. The legal values for each
  %  property are:
  %
  %  'DerivativeOrder' - specifies the derivative order estimated.
  %        Must be a positive integer from the set [1,2,3,4].
  %
  %        DEFAULT: 1 (first derivative of fun)
  %
  %  'MethodOrder' - specifies the order of the basic method
  %        used for the estimation.
  %
  %        For 'central' methods, must be a positive integer
  %        from the set [2,4].
  %
  %        For 'forward' or 'backward' difference methods,
  %        must be a positive integer from the set [1,2,3,4].
  %
  %        DEFAULT: 4 (a second order method)
  %
  %        Note: higher order methods will generally be more
  %        accurate, but may also suffere more from numerical
  %        problems.
  %
  %        Note: First order methods would usually not be
  %        recommended.
  %
  %  'Style' - specifies the style of the basic method
  %        used for the estimation. 'central', 'forward',
  %        or 'backwards' difference methods are used.
  %
  %        Must be one of 'Central', 'forward', 'backward'.
  %
  %        DEFAULT: 'Central'
  %
  %        Note: Central difference methods are usually the
  %        most accurate, but sometiems one must not allow
  %        evaluation in one direction or the other.
  %
  %  'RombergTerms' - Allows the user to specify the generalized
  %        Romberg extrapolation method used, or turn it off
  %        completely.
  %
  %        Must be a positive integer from the set [0,1,2,3].
  %
  %        DEFAULT: 2 (Two Romberg terms)
  %
  %        Note: 0 disables the Romberg step completely.
  %
  %  'FixedStep' - Allows the specification of a fixed step
  %        size, preventing the adaptive logic from working.
  %        This will be considerably faster, but not necessarily
  %        as accurate as allowing the adaptive logic to run.
  %
  %        DEFAULT: []
  %
  %        Note: If specified, 'FixedStep' will define the
  %        maximum excursion from x0 that will be used.
  %
  %  'Vectorized' - Derivest will normally assume that your
  %        function can be safely evaluated at multiple locations
  %        in a single call. This would minimize the overhead of
  %        a loop and additional function call overhead. Some
  %        functions are not easily vectorizable, but you may
  %        (if your matlab release is new enough) be able to use
  %        arrayfun to accomplish the vectorization.
  %
  %        When all else fails, set the 'vectorized' property
  %        to 'no'. This will cause derivest to loop over the
  %        successive function calls.
  %
  %        DEFAULT: 'yes'
  %
  %
  %  'MaxStep' - Specifies the maximum excursion from x0 that
  %        will be allowed, as a multiple of x0.
  %
  %        DEFAULT: 100
  %
  %  'StepRatio' - Derivest uses a proportionally cascaded
  %        series of function evaluations, moving away from your
  %        point of evaluation. The StepRatio is the ratio used
  %        between sequential steps.
  %
  %        DEFAULT: 2
  %
  %
  % See the document DERIVEST.pdf for more explanation of the
  % algorithms behind the parameters of DERIVEST. In most cases,
  % I have chosen good values for these parameters, so the user
  % should never need to specify anything other than possibly
  % the DerivativeOrder. I've also tried to make my code robust
  % enough that it will not need much. But complete flexibility
  % is in there for your use.
  %
  %
  % Arguments: (output)
  %  der - derivative estimate for each element of x0
  %        der will have the same shape as x0.
  %
  %  errest - 95% uncertainty estimate of the derivative, such that
  %
  %        abs(der(j) - f'(x0(j))) < erest(j)
  %
  %  finaldelta - The final overall stepsize chosen by DERIVEST
  %
  %
  % Example usage:
  %  First derivative of exp(x), at x == 1
  %   [d,e]=derivest(@(x) exp(x),1)
  %   d =
  %       2.71828182845904
  %
  %   e =
  %       1.02015503167879e-14
  %
  %  True derivative
  %   exp(1)
  %   ans =
  %       2.71828182845905
  %
  % Example usage:
  %  Third derivative of x.^3+x.^4, at x = [0,1]
  %   derivest(@(x) x.^3 + x.^4,[0 1],'deriv',3)
  %   ans =
  %       6       30
  %
  %  True derivatives: [6,30]
  %
  %
  % See also: gradient
  %
  %
  % Author: John D'Errico
  % e-mail: woodchips@rochester.rr.com
  % Release: 1.0
  % Release date: 12/27/2006
  
  par.DerivativeOrder = 1;
  par.MethodOrder = 4;
  par.Style = 'central';
  par.RombergTerms = 2;
  par.FixedStep = [];
  par.MaxStep = 100;
  par.StepRatio = 2;
  par.NominalStep = [];
  par.Vectorized = 'yes';
  
  na = length(varargin);
  if (rem(na,2)==1)
    error 'Property/value pairs must come as PAIRS of arguments.'
  elseif na>0
    par = parse_pv_pairs(par,varargin);
  end
  par = check_params(par);
  
  % Was fun a string, or an inline/anonymous function?
  if (nargin<1)
    help derivest
    return
  elseif isempty(fun)
    error 'fun was not supplied.'
  elseif ischar(fun)
    % a character function name
    fun = str2func(fun);
  end
  
  % no default for x0
  if (nargin<2) || isempty(x0)
    error 'x0 was not supplied'
  end
  par.NominalStep = max(x0,0.02);
  
  % was a single point supplied?
  nx0 = size(x0);
  n = prod(nx0);
  
  % Set the steps to use.
  if isempty(par.FixedStep)
    % Basic sequence of steps, relative to a stepsize of 1.
    delta = par.MaxStep*par.StepRatio .^(0:-1:-25)';
    ndel = length(delta);
  else
    % Fixed, user supplied absolute sequence of steps.
    ndel = 3 + ceil(par.DerivativeOrder/2) + ...
      par.MethodOrder + par.RombergTerms;
    if par.Style(1) == 'c'
      ndel = ndel - 2;
    end
    delta = par.FixedStep*par.StepRatio .^(-(0:(ndel-1)))';
  end
  
  % generate finite differencing rule in advance.
  % The rule is for a nominal unit step size, and will
  % be scaled later to reflect the local step size.
  fdarule = 1;
  switch par.Style
    case 'central'
      % for central rules, we will reduce the load by an
      % even or odd transformation as appropriate.
      if par.MethodOrder==2
        switch par.DerivativeOrder
          case 1
            % the odd transformation did all the work
            fdarule = 1;
          case 2
            % the even transformation did all the work
            fdarule = 2;
          case 3
            % the odd transformation did most of the work, but
            % we need to kill off the linear term
            fdarule = [0 1]/fdamat(par.StepRatio,1,2);
          case 4
            % the even transformation did most of the work, but
            % we need to kill off the quadratic term
            fdarule = [0 1]/fdamat(par.StepRatio,2,2);
        end
      else
        % a 4th order method. We've already ruled out the 1st
        % order methods since these are central rules.
        switch par.DerivativeOrder
          case 1
            % the odd transformation did most of the work, but
            % we need to kill off the cubic term
            fdarule = [1 0]/fdamat(par.StepRatio,1,2);
          case 2
            % the even transformation did most of the work, but
            % we need to kill off the quartic term
            fdarule = [1 0]/fdamat(par.StepRatio,2,2);
          case 3
            % the odd transformation did much of the work, but
            % we need to kill off the linear & quintic terms
            fdarule = [0 1 0]/fdamat(par.StepRatio,1,3);
          case 4
            % the even transformation did much of the work, but
            % we need to kill off the quadratic and 6th order terms
            fdarule = [0 1 0]/fdamat(par.StepRatio,2,3);
        end
      end
    case {'forward' 'backward'}
      % These two cases are identical, except at the very end,
      % where a sign will be introduced.
      
      % No odd/even trans, but we already dropped
      % off the constant term
      if par.MethodOrder==1
        if par.DerivativeOrder==1
          % an easy one
          fdarule = 1;
        else
          % 2:4
          v = zeros(1,par.DerivativeOrder);
          v(par.DerivativeOrder) = 1;
          fdarule = v/fdamat(par.StepRatio,0,par.DerivativeOrder);
        end
      else
        % par.MethodOrder methods drop off the lower order terms,
        % plus terms directly above DerivativeOrder
        v = zeros(1,par.DerivativeOrder + par.MethodOrder - 1);
        v(par.DerivativeOrder) = 1;
        fdarule = v/fdamat(par.StepRatio,0,par.DerivativeOrder+par.MethodOrder-1);
      end
      
      % correct sign for the 'backward' rule
      if par.Style(1) == 'b'
        fdarule = -fdarule;
      end
      
  end % switch on par.style (generating fdarule)
  nfda = length(fdarule);
  
  % will we need fun(x0)?
  if (rem(par.DerivativeOrder,2) == 0) || ~strncmpi(par.Style,'central',7)
    if strcmpi(par.Vectorized,'yes')
      f_x0 = fun(x0);
    else
      % not vectorized, so loop
      f_x0 = zeros(size(x0));
      for j = 1:numel(x0)
        f_x0(j) = fun(x0(j));
      end
    end
  else
    f_x0 = [];
  end
  
  % Loop over the elements of x0, reducing it to
  % a scalar problem. Sorry, vectorization is not
  % complete here, but this IS only a single loop.
  der = zeros(nx0);
  errest = der;
  finaldelta = der;
  for i = 1:n
    x0i = x0(i);
    h = par.NominalStep(i);
    
    % a central, forward or backwards differencing rule?
    % f_del is the set of all the function evaluations we
    % will generate. For a central rule, it will have the
    % even or odd transformation built in.
    if par.Style(1) == 'c'
      % A central rule, so we will need to evaluate
      % symmetrically around x0i.
      if strcmpi(par.Vectorized,'yes')
        f_plusdel = fun(x0i+h*delta);
        f_minusdel = fun(x0i-h*delta);
      else
        % not vectorized, so loop
        f_minusdel = zeros(size(delta));
        f_plusdel = zeros(size(delta));
        for j = 1:numel(delta)
          f_plusdel(j) = fun(x0i+h*delta(j));
          f_minusdel(j) = fun(x0i-h*delta(j));
        end
      end
      
      if ismember(par.DerivativeOrder,[1 3])
        % odd transformation
        f_del = (f_plusdel - f_minusdel)/2;
      else
        f_del = (f_plusdel + f_minusdel)/2 - f_x0(i);
      end
    elseif par.Style(1) == 'f'
      % forward rule
      % drop off the constant only
      if strcmpi(par.Vectorized,'yes')
        f_del = fun(x0i+h*delta) - f_x0(i);
      else
        % not vectorized, so loop
        f_del = zeros(size(delta));
        for j = 1:numel(delta)
          f_del(j) = fun(x0i+h*delta(j)) - f_x0(i);
        end
      end
    else
      % backward rule
      % drop off the constant only
      if strcmpi(par.Vectorized,'yes')
        f_del = fun(x0i-h*delta) - f_x0(i);
      else
        % not vectorized, so loop
        f_del = zeros(size(delta));
        for j = 1:numel(delta)
          f_del(j) = fun(x0i-h*delta(j)) - f_x0(i);
        end
      end
    end
    
    % check the size of f_del to ensure it was properly vectorized.
    f_del = f_del(:);
    if length(f_del)~=ndel
      error 'fun did not return the correct size result (fun must be vectorized)'
    end
    
    % Apply the finite difference rule at each delta, scaling
    % as appropriate for delta and the requested DerivativeOrder.
    % First, decide how many of these estimates we will end up with.
    ne = ndel + 1 - nfda - par.RombergTerms;
    
    % Form the initial derivative estimates from the chosen
    % finite difference method.
    der_init = vec2mat(f_del,ne,nfda)*fdarule.';
    
    % scale to reflect the local delta
    der_init = der_init(:)./(h*delta(1:ne)).^par.DerivativeOrder;
    
    % Each approximation that results is an approximation
    % of order par.DerivativeOrder to the desired derivative.
    % Additional (higher order, even or odd) terms in the
    % Taylor series also remain. Use a generalized (multi-term)
    % Romberg extrapolation to improve these estimates.
    switch par.Style
      case 'central'
        rombexpon = 2*(1:par.RombergTerms) + par.MethodOrder - 2;
      otherwise
        rombexpon = (1:par.RombergTerms) + par.MethodOrder - 1;
    end
    [der_romb,errors] = rombextrap(par.StepRatio,der_init,rombexpon);
    
    % Choose which result to return
    
    % first, trim off the
    if isempty(par.FixedStep)
      % trim off the estimates at each end of the scale
      nest = length(der_romb);
      switch par.DerivativeOrder
        case {1 2}
          trim = [1 2 nest-1 nest];
        case 3
          trim = [1:4 nest+(-3:0)];
        case 4
          trim = [1:6 nest+(-5:0)];
      end
      
      [der_romb,tags] = sort(der_romb);
      
      der_romb(trim) = [];
      tags(trim) = [];
      errors = errors(tags);
      trimdelta = delta(tags);
      
      [errest(i),ind] = min(errors);
      
      finaldelta(i) = h*trimdelta(ind);
      der(i) = der_romb(ind);
    else
      [errest(i),ind] = min(errors);
      finaldelta(i) = h*delta(ind);
      der(i) = der_romb(ind);
    end
  end
  
end % mainline end


function [jac,err] = jacobianest(fun,x0)
  % gradest: estimate of the Jacobian matrix of a vector valued function of n variables
  % usage: [jac,err] = jacobianest(fun,x0)
  %
  %
  % arguments: (input)
  %  fun - (vector valued) analytical function to differentiate.
  %        fun must be a function of the vector or array x0.
  %
  %  x0  - vector location at which to differentiate fun
  %        If x0 is an nxm array, then fun is assumed to be
  %        a function of n*m variables.
  %
  %
  % arguments: (output)
  %  jac - array of first partial derivatives of fun.
  %        Assuming that x0 is a vector of length p
  %        and fun returns a vector of length n, then
  %        jac will be an array of size (n,p)
  %
  %  err - vector of error estimates corresponding to
  %        each partial derivative in jac.
  %
  %
  % Example: (nonlinear least squares)
  %  xdata = (0:.1:1)';
  %  ydata = 1+2*exp(0.75*xdata);
  %  fun = @(c) ((c(1)+c(2)*exp(c(3)*xdata)) - ydata).^2;
  %
  %  [jac,err] = jacobianest(fun,[1 1 1])
  %
  %  jac =
  %           -2           -2            0
  %      -2.1012      -2.3222     -0.23222
  %      -2.2045      -2.6926     -0.53852
  %      -2.3096      -3.1176     -0.93528
  %      -2.4158      -3.6039      -1.4416
  %      -2.5225      -4.1589      -2.0795
  %       -2.629      -4.7904      -2.8742
  %      -2.7343      -5.5063      -3.8544
  %      -2.8374      -6.3147      -5.0518
  %      -2.9369      -7.2237      -6.5013
  %      -3.0314      -8.2403      -8.2403
  %
  %  err =
  %   5.0134e-15   5.0134e-15            0
  %   5.0134e-15            0   2.8211e-14
  %   5.0134e-15   8.6834e-15   1.5804e-14
  %            0     7.09e-15   3.8227e-13
  %   5.0134e-15   5.0134e-15   7.5201e-15
  %   5.0134e-15   1.0027e-14   2.9233e-14
  %   5.0134e-15            0   6.0585e-13
  %   5.0134e-15   1.0027e-14   7.2673e-13
  %   5.0134e-15   1.0027e-14   3.0495e-13
  %   5.0134e-15   1.0027e-14   3.1707e-14
  %   5.0134e-15   2.0053e-14   1.4013e-12
  %
  %  (At [1 2 0.75], jac should be numerically zero)
  %
  %
  % See also: derivest, gradient, gradest
  %
  %
  % Author: John D'Errico
  % e-mail: woodchips@rochester.rr.com
  % Release: 1.0
  % Release date: 3/6/2007
  
  % get the length of x0 for the size of jac
  nx = numel(x0);
  
  MaxStep = 100;
  StepRatio = 2;
  
  % was a string supplied?
  if ischar(fun)
    fun = str2func(fun);
  end
  
  % get fun at the center point
  f0 = fun(x0);
  f0 = f0(:);
  n = length(f0);
  if n==0
    % empty begets empty
    jac = zeros(0,nx);
    err = jac;
    return
  end
  
  relativedelta = MaxStep*StepRatio .^(0:-1:-25);
  nsteps = length(relativedelta);
  
  % total number of derivatives we will need to take
  jac = zeros(n,nx);
  err = jac;
  for i = 1:nx
    x0_i = x0(i);
    if x0_i ~= 0
      delta = x0_i*relativedelta;
    else
      delta = relativedelta;
    end
    
    % evaluate at each step, centered around x0_i
    % difference to give a second order estimate
    fdel = zeros(n,nsteps);
    for j = 1:nsteps
      fdif = fun(swapelement(x0,i,x0_i + delta(j))) - ...
        fun(swapelement(x0,i,x0_i - delta(j)));
      
      fdel(:,j) = fdif(:);
    end
    
    % these are pure second order estimates of the
    % first derivative, for each trial delta.
    derest = fdel.*repmat(0.5 ./ delta,n,1);
    
    % The error term on these estimates has a second order
    % component, but also some 4th and 6th order terms in it.
    % Use Romberg exrapolation to improve the estimates to
    % 6th order, as well as to provide the error estimate.
    
    % loop here, as rombextrap coupled with the trimming
    % will get complicated otherwise.
    for j = 1:n
      [der_romb,errest] = rombextrap(StepRatio,derest(j,:),[2 4]);
      
      % trim off 3 estimates at each end of the scale
      nest = length(der_romb);
      trim = [1:3, nest+(-2:0)];
      [der_romb,tags] = sort(der_romb);
      der_romb(trim) = [];
      tags(trim) = [];
      
      errest = errest(tags);
      
      % now pick the estimate with the lowest predicted error
      [err(j,i),ind] = min(errest);
      jac(j,i) = der_romb(ind);
    end
  end
  
end % mainline function end


function [grad,err,finaldelta] = gradest(fun,x0)
  % gradest: estimate of the gradient vector of an analytical function of n variables
  % usage: [grad,err,finaldelta] = gradest(fun,x0)
  %
  % Uses derivest to provide both derivative estimates
  % and error estimates. fun needs not be vectorized.
  %
  % arguments: (input)
  %  fun - analytical function to differentiate. fun must
  %        be a function of the vector or array x0.
  %
  %  x0  - vector location at which to differentiate fun
  %        If x0 is an nxm array, then fun is assumed to be
  %        a function of n*m variables.
  %
  % arguments: (output)
  %  grad - vector of first partial derivatives of fun.
  %        grad will be a row vector of length numel(x0).
  %
  %  err - vector of error estimates corresponding to
  %        each partial derivative in grad.
  %
  %  finaldelta - vector of final step sizes chosen for
  %        each partial derivative.
  %
  %
  % Example:
  %  [grad,err] = gradest(@(x) sum(x.^2),[1 2 3])
  %  grad =
  %      2     4     6
  %  err =
  %      5.8899e-15    1.178e-14            0
  %
  %
  % Example:
  %  At [x,y] = [1,1], compute the numerical gradient
  %  of the function sin(x-y) + y*exp(x)
  %
  %  z = @(xy) sin(diff(xy)) + xy(2)*exp(xy(1))
  %
  %  [grad,err ] = gradest(z,[1 1])
  %  grad =
  %       1.7183       3.7183
  %  err =
  %    7.537e-14   1.1846e-13
  %
  %
  % Example:
  %  At the global minimizer (1,1) of the Rosenbrock function,
  %  compute the gradient. It should be essentially zero.
  %
  %  rosen = @(x) (1-x(1)).^2 + 105*(x(2)-x(1).^2).^2;
  %  [g,err] = gradest(rosen,[1 1])
  %  g =
  %    1.0843e-20            0
  %  err =
  %    1.9075e-18            0
  %
  %
  % See also: derivest, gradient
  %
  %
  % Author: John D'Errico
  % e-mail: woodchips@rochester.rr.com
  % Release: 1.0
  % Release date: 2/9/2007
  
  % get the size of x0 so we can reshape
  % later.
  sx = size(x0);
  
  % total number of derivatives we will need to take
  nx = numel(x0);
  
  grad = zeros(1,nx);
  err = grad;
  finaldelta = grad;
  for ind = 1:nx
    [grad(ind),err(ind),finaldelta(ind)] = derivest( ...
      @(xi) fun(swapelement(x0,ind,xi)), ...
      x0(ind),'deriv',1,'vectorized','no', ...
      'methodorder',2);
  end
  
end % mainline function end


function [HD,err,finaldelta] = hessdiag(fun,x0)
  % HESSDIAG: diagonal elements of the Hessian matrix (vector of second partials)
  % usage: [HD,err,finaldelta] = hessdiag(fun,x0)
  %
  % When all that you want are the diagonal elements of the hessian
  % matrix, it will be more efficient to call HESSDIAG than HESSIAN.
  % HESSDIAG uses DERIVEST to provide both second derivative estimates
  % and error estimates. fun needs not be vectorized.
  %
  % arguments: (input)
  %  fun - SCALAR analytical function to differentiate.
  %        fun must be a function of the vector or array x0.
  %
  %  x0  - vector location at which to differentiate fun
  %        If x0 is an nxm array, then fun is assumed to be
  %        a function of n*m variables.
  %
  % arguments: (output)
  %  HD  - vector of second partial derivatives of fun.
  %        These are the diagonal elements of the Hessian
  %        matrix, evaluated at x0.
  %        HD will be a row vector of length numel(x0).
  %
  %  err - vector of error estimates corresponding to
  %        each second partial derivative in HD.
  %
  %  finaldelta - vector of final step sizes chosen for
  %        each second partial derivative.
  %
  %
  % Example usage:
  %  [HD,err] = hessdiag(@(x) x(1) + x(2)^2 + x(3)^3,[1 2 3])
  %  HD =
  %     0     2    18
  %
  %  err =
  %     0     0     0
  %
  %
  % See also: derivest, gradient, gradest
  %
  %
  % Author: John D'Errico
  % e-mail: woodchips@rochester.rr.com
  % Release: 1.0
  % Release date: 2/9/2007
  
  % get the size of x0 so we can reshape
  % later.
  sx = size(x0);
  
  % total number of derivatives we will need to take
  nx = numel(x0);
  
  HD = zeros(1,nx);
  err = HD;
  finaldelta = HD;
  for ind = 1:nx
    [HD(ind),err(ind),finaldelta(ind)] = derivest( ...
      @(xi) fun(swapelement(x0,ind,xi)), ...
      x0(ind),'deriv',2,'vectorized','no');
  end
  
end % mainline function end


function [hess,err] = hessian(fun,x0)
  % hessian: estimate elements of the Hessian matrix (array of 2nd partials)
  % usage: [hess,err] = hessian(fun,x0)
  %
  % Hessian is NOT a tool for frequent use on an expensive
  % to evaluate objective function, especially in a large
  % number of dimensions. Its computation will use roughly
  % O(6*n^2) function evaluations for n parameters.
  %
  % arguments: (input)
  %  fun - SCALAR analytical function to differentiate.
  %        fun must be a function of the vector or array x0.
  %        fun does not need to be vectorized.
  %
  %  x0  - vector location at which to compute the Hessian.
  %
  % arguments: (output)
  %  hess - nxn symmetric array of second partial derivatives
  %        of fun, evaluated at x0.
  %
  %  err - nxn array of error estimates corresponding to
  %        each second partial derivative in hess.
  %
  %
  % Example usage:
  %  Rosenbrock function, minimized at [1,1]
  %  rosen = @(x) (1-x(1)).^2 + 105*(x(2)-x(1).^2).^2;
  %
  %  [h,err] = hessian(rosen,[1 1])
  %  h =
  %           842         -420
  %          -420          210
  %  err =
  %    1.0662e-12   4.0061e-10
  %    4.0061e-10   2.6654e-13
  %
  %
  % Example usage:
  %  cos(x-y), at (0,0)
  %  Note: this hessian matrix will be positive semi-definite
  %
  %  hessian(@(xy) cos(xy(1)-xy(2)),[0 0])
  %  ans =
  %           -1            1
  %            1           -1
  %
  %
  % See also: derivest, gradient, gradest, hessdiag
  %
  %
  % Author: John D'Errico
  % e-mail: woodchips@rochester.rr.com
  % Release: 1.0
  % Release date: 2/10/2007
  
  % parameters that we might allow to change
  params.StepRatio = 2;
  params.RombergTerms = 3;
  
  % get the size of x0 so we can reshape
  % later.
  sx = size(x0);
  
  % was a string supplied?
  if ischar(fun)
    fun = str2func(fun);
  end
  
  % total number of derivatives we will need to take
  nx = length(x0);
  
  % get the diagonal elements of the hessian (2nd partial
  % derivatives wrt each variable.)
  [hess,err] = hessdiag(fun,x0);
  
  % form the eventual hessian matrix, stuffing only
  % the diagonals for now.
  hess = diag(hess);
  err = diag(err);
  if nx<2
    % the hessian matrix is 1x1. all done
    return
  end
  
  % get the gradient vector. This is done only to decide
  % on intelligent step sizes for the mixed partials
  [grad,graderr,stepsize] = gradest(fun,x0);
  
  % Get params.RombergTerms+1 estimates of the upper
  % triangle of the hessian matrix
  dfac = params.StepRatio.^(-(0:params.RombergTerms)');
  for i = 2:nx
    for j = 1:(i-1)
      dij = zeros(params.RombergTerms+1,1);
      for k = 1:(params.RombergTerms+1)
        dij(k) = fun(x0 + swap2(zeros(sx),i, ...
          dfac(k)*stepsize(i),j,dfac(k)*stepsize(j))) + ...
          fun(x0 + swap2(zeros(sx),i, ...
          -dfac(k)*stepsize(i),j,-dfac(k)*stepsize(j))) - ...
          fun(x0 + swap2(zeros(sx),i, ...
          dfac(k)*stepsize(i),j,-dfac(k)*stepsize(j))) - ...
          fun(x0 + swap2(zeros(sx),i, ...
          -dfac(k)*stepsize(i),j,dfac(k)*stepsize(j)));
        
      end
      dij = dij/4/prod(stepsize([i,j]));
      dij = dij./(dfac.^2);
      
      % Romberg extrapolation step
      [hess(i,j),err(i,j)] =  rombextrap(params.StepRatio,dij,[2 4]);
      hess(j,i) = hess(i,j);
      err(j,i) = err(i,j);
    end
  end
  
  
end % mainline function end



% ============================================
% subfunction - romberg extrapolation
% ============================================
function [der_romb,errest] = rombextrap(StepRatio,der_init,rombexpon)
  % do romberg extrapolation for each estimate
  %
  %  StepRatio - Ratio decrease in step
  %  der_init - initial derivative estimates
  %  rombexpon - higher order terms to cancel using the romberg step
  %
  %  der_romb - derivative estimates returned
  %  errest - error estimates
  %  amp - noise amplification factor due to the romberg step
  
  srinv = 1/StepRatio;
  
  % do nothing if no romberg terms
  nexpon = length(rombexpon);
  rmat = ones(nexpon+2,nexpon+1);
  switch nexpon
    case 0
      % rmat is simple: ones(2,1)
    case 1
      % only one romberg term
      rmat(2,2) = srinv^rombexpon;
      rmat(3,2) = srinv^(2*rombexpon);
    case 2
      % two romberg terms
      rmat(2,2:3) = srinv.^rombexpon;
      rmat(3,2:3) = srinv.^(2*rombexpon);
      rmat(4,2:3) = srinv.^(3*rombexpon);
    case 3
      % three romberg terms
      rmat(2,2:4) = srinv.^rombexpon;
      rmat(3,2:4) = srinv.^(2*rombexpon);
      rmat(4,2:4) = srinv.^(3*rombexpon);
      rmat(5,2:4) = srinv.^(4*rombexpon);
  end
  
  % qr factorization used for the extrapolation as well
  % as the uncertainty estimates
  [qromb,rromb] = qr(rmat,0);
  
  % the noise amplification is further amplified by the Romberg step.
  % amp = cond(rromb);
  
  % this does the extrapolation to a zero step size.
  ne = length(der_init);
  rhs = vec2mat(der_init,nexpon+2,max(1,ne - (nexpon+2)));
  rombcoefs = rromb\(qromb.'*rhs);
  der_romb = rombcoefs(1,:).';
  
  % uncertainty estimate of derivative prediction
  s = sqrt(sum((rhs - rmat*rombcoefs).^2,1));
  rinv = rromb\eye(nexpon+1);
  cov1 = sum(rinv.^2,2); % 1 spare dof
  errest = s.'*12.7062047361747*sqrt(cov1(1));
  
end % rombextrap


% ============================================
% subfunction - vec2mat
% ============================================
function mat = vec2mat(vec,n,m)
  % forms the matrix M, such that M(i,j) = vec(i+j-1)
  [i,j] = ndgrid(1:n,0:m-1);
  ind = i+j;
  mat = vec(ind);
  if n==1
    mat = mat.';
  end
  
end % vec2mat


% ============================================
% subfunction - fdamat
% ============================================
function mat = fdamat(sr,parity,nterms)
  % Compute matrix for fda derivation.
  % parity can be
  %   0 (one sided, all terms included but zeroth order)
  %   1 (only odd terms included)
  %   2 (only even terms included)
  % nterms - number of terms
  
  % sr is the ratio between successive steps
  srinv = 1./sr;
  
  switch parity
    case 0
      % single sided rule
      [i,j] = ndgrid(1:nterms);
      c = 1./factorial(1:nterms);
      mat = c(j).*srinv.^((i-1).*j);
    case 1
      % odd order derivative
      [i,j] = ndgrid(1:nterms);
      c = 1./factorial(1:2:(2*nterms));
      mat = c(j).*srinv.^((i-1).*(2*j-1));
    case 2
      % even order derivative
      [i,j] = ndgrid(1:nterms);
      c = 1./factorial(2:2:(2*nterms));
      mat = c(j).*srinv.^((i-1).*(2*j));
  end
  
end % fdamat


% ============================================
% subfunction - check_params
% ============================================
function par = check_params(par)
  % check the parameters for acceptability
  %
  % Defaults
  % par.DerivativeOrder = 1;
  % par.MethodOrder = 2;
  % par.Style = 'central';
  % par.RombergTerms = 2;
  % par.FixedStep = [];
  
  % DerivativeOrder == 1 by default
  if isempty(par.DerivativeOrder)
    par.DerivativeOrder = 1;
  else
    if (length(par.DerivativeOrder)>1) || ~ismember(par.DerivativeOrder,1:4)
      error 'DerivativeOrder must be scalar, one of [1 2 3 4].'
    end
  end
  
  % MethodOrder == 2 by default
  if isempty(par.MethodOrder)
    par.MethodOrder = 2;
  else
    if (length(par.MethodOrder)>1) || ~ismember(par.MethodOrder,[1 2 3 4])
      error 'MethodOrder must be scalar, one of [1 2 3 4].'
    elseif ismember(par.MethodOrder,[1 3]) && (par.Style(1)=='c')
      error 'MethodOrder==1 or 3 is not possible with central difference methods'
    end
  end
  
  % style is char
  valid = {'central', 'forward', 'backward'};
  if isempty(par.Style)
    par.Style = 'central';
  elseif ~ischar(par.Style)
    error 'Invalid Style: Must be character'
  end
  ind = find(strncmpi(par.Style,valid,length(par.Style)));
  if (length(ind)==1)
    par.Style = valid{ind};
  else
    error(['Invalid Style: ',par.Style])
  end
  
  % vectorized is char
  valid = {'yes', 'no'};
  if isempty(par.Vectorized)
    par.Vectorized = 'yes';
  elseif ~ischar(par.Vectorized)
    error 'Invalid Vectorized: Must be character'
  end
  ind = find(strncmpi(par.Vectorized,valid,length(par.Vectorized)));
  if (length(ind)==1)
    par.Vectorized = valid{ind};
  else
    error(['Invalid Vectorized: ',par.Vectorized])
  end
  
  % RombergTerms == 2 by default
  if isempty(par.RombergTerms)
    par.RombergTerms = 2;
  else
    if (length(par.RombergTerms)>1) || ~ismember(par.RombergTerms,0:3)
      error 'RombergTerms must be scalar, one of [0 1 2 3].'
    end
  end
  
  % FixedStep == [] by default
  if (length(par.FixedStep)>1) || (~isempty(par.FixedStep) && (par.FixedStep<=0))
    error 'FixedStep must be empty or a scalar, >0.'
  end
  
  % MaxStep == 10 by default
  if isempty(par.MaxStep)
    par.MaxStep = 10;
  elseif (length(par.MaxStep)>1) || (par.MaxStep<=0)
    error 'MaxStep must be empty or a scalar, >0.'
  end
  
end % check_params


% ============================================
% Included subfunction - parse_pv_pairs
% ============================================
function params=parse_pv_pairs(params,pv_pairs)
  % parse_pv_pairs: parses sets of property value pairs, allows defaults
  % usage: params=parse_pv_pairs(default_params,pv_pairs)
  %
  % arguments: (input)
  %  default_params - structure, with one field for every potential
  %             property/value pair. Each field will contain the default
  %             value for that property. If no default is supplied for a
  %             given property, then that field must be empty.
  %
  %  pv_array - cell array of property/value pairs.
  %             Case is ignored when comparing properties to the list
  %             of field names. Also, any unambiguous shortening of a
  %             field/property name is allowed.
  %
  % arguments: (output)
  %  params   - parameter struct that reflects any updated property/value
  %             pairs in the pv_array.
  %
  % Example usage:
  % First, set default values for the parameters. Assume we
  % have four parameters that we wish to use optionally in
  % the function examplefun.
  %
  %  - 'viscosity', which will have a default value of 1
  %  - 'volume', which will default to 1
  %  - 'pie' - which will have default value 3.141592653589793
  %  - 'description' - a text field, left empty by default
  %
  % The first argument to examplefun is one which will always be
  % supplied.
  %
  %   function examplefun(dummyarg1,varargin)
  %   params.Viscosity = 1;
  %   params.Volume = 1;
  %   params.Pie = 3.141592653589793
  %
  %   params.Description = '';
  %   params=parse_pv_pairs(params,varargin);
  %   params
  %
  % Use examplefun, overriding the defaults for 'pie', 'viscosity'
  % and 'description'. The 'volume' parameter is left at its default.
  %
  %   examplefun(rand(10),'vis',10,'pie',3,'Description','Hello world')
  %
  % params =
  %     Viscosity: 10
  %        Volume: 1
  %           Pie: 3
  %   Description: 'Hello world'
  %
  % Note that capitalization was ignored, and the property 'viscosity'
  % was truncated as supplied. Also note that the order the pairs were
  % supplied was arbitrary.
  
  npv = length(pv_pairs);
  n = npv/2;
  
  if n~=floor(n)
    error 'Property/value pairs must come in PAIRS.'
  end
  if n<=0
    % just return the defaults
    return
  end
  
  if ~isstruct(params)
    error 'No structure for defaults was supplied'
  end
  
  % there was at least one pv pair. process any supplied
  propnames = fieldnames(params);
  lpropnames = lower(propnames);
  for i=1:n
    p_i = lower(pv_pairs{2*i-1});
    v_i = pv_pairs{2*i};
    
    ind = strmatch(p_i,lpropnames,'exact');
    if isempty(ind)
      ind = find(strncmp(p_i,lpropnames,length(p_i)));
      if isempty(ind)
        error(['No matching property found for: ',pv_pairs{2*i-1}])
      elseif length(ind)>1
        error(['Ambiguous property name: ',pv_pairs{2*i-1}])
      end
    end
    p_i = propnames{ind};
    
    % override the corresponding default in params
    params = setfield(params,p_i,v_i); %#ok
    
  end
  
end % parse_pv_pairs


% =======================================
%      sub-functions
% =======================================
function vec = swapelement(vec,ind,val)
  % swaps val as element ind, into the vector vec
  vec(ind) = val;
  
end % sub-function end


% =======================================
%      sub-functions
% =======================================
function vec = swap2(vec,ind1,val1,ind2,val2)
  % swaps val as element ind, into the vector vec
  vec(ind1) = val1;
  vec(ind2) = val2;
  
end % sub-function end

% End of DERIVEST SUITE

