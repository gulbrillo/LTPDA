% TDFIT fit a MATRIX of transfer function SMODELs to a matrix of input and output signals.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: TDFIT fits a MATRIX of transfer function SMODELs to a set of 
%              input and output signals. It uses ao\tdfit as the core algorithm.
% 
%
% CALL:        b = tdfit(outputs, pl)
%
% INPUTS:      outputs  - an array of MATRIXs representing the outputs of a system, 
%                         one per each experiment.
%              pl       - parameter list (see below)
%
% OUTPUTs:     b  - a pest object containing the best-fit parameters,
%                   goodness-of-fit reduced chi-squared, fit degree-of-freedom
%                   covariance matrix and uncertainties. Additional
%                   quantities, like the Information Matrix, are contained 
%                   within the procinfo. The best-fit model can be evaluated
%                   from pest\eval.
%
% <a href="matlab:utils.helper.displayMethodInfo('matrix', 'tdfit')">Parameters Description</a>
%
% EXAMPLES:
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = tdfit(varargin)
  
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
  
  % Collect all ltpdauoh objects
  [mtxs, mtxs_invars] = utils.helper.collect_objects(varargin(:), 'matrix', in_names);
  [pl, invars] = utils.helper.collect_objects(varargin(:), 'plist');
  
  % combine plists
  pl = applyDefaults(getDefaultPlist(), pl);
  
  if nargout == 0
    error('### tdfit cannot be used as a modifier. Please give an output variable.');
  end
    
  % combine plists
  pl = applyDefaults(getDefaultPlist(), pl);
  
  % Extract necessary parameters
  inputs    = pl.find_core('inputs');
  TFmodels  = pl.find_core('models');
  WhFlts    = pl.find_core('WhFlts');
  inNames   = pl.find_core('innames');
  outNames  = pl.find_core('outnames');
  P0        = pl.find_core('P0');
  pnames    = pl.find_core('pnames');
  
  % Checks
  if ~isa(mtxs,'matrix')
    error('### Please, give the system outputs as an array of MATRIXs per each experiment.');
  end
  if ~isa(inputs,'collection') && any(~isa(inputs.objs,'matrix'))
    error('### Please, give the system inputs as a COLLECTION of MATRIXs per each experiment.');
  end
  if ~isa(TFmodels,'ssm') && ~isa(TFmodels,'matrix') && any(~isa(TFmodels.objs,'smodel'))
    error('### Please, give the system transfer functions as a MATRIX of SMODELs, or a single SSM model.');
  end
  if ~isa(WhFlts,'matrix') && any(~isa(WhFlts.objs,'filterbank'))
    error('### Please, give the system inputs as a MATRIX of FILTERBANKs.');
  end
  
  % Define constants
  Nexp = numel(mtxs);
  
  % Prepare objects for fit
  outputs2fit = prepare2fit(mtxs,'outputs',Nexp);
  inputs2fit = prepare2fit(inputs,'inputs',Nexp);
  WhFlts2fit = prepare2fit(WhFlts,'filters',Nexp);
  if ~isa(TFmodels,'ssm')
    models2fit = prepare2fit(TFmodels,'models',Nexp);
  else
    models2fit = TFmodels;
  end
  inNames2fit = prepare2fit(inNames,'inNames',Nexp);
  outNames2fit = prepare2fit(outNames,'outNames',Nexp);

  % fit plist
  fitpl = pl.pset('inputs', inputs2fit,...
                  'models', models2fit,...
                  'WhFlts', WhFlts2fit,...
                  'inNames', inNames2fit,...
                  'outNames', outNames2fit,...
                  'P0', P0,...
                  'pnames', pnames);
              
  % do fit
  params = tdfit(outputs2fit, fitpl);
  
  % Make output pest
  out = copy(params,1);
      
  % Set Name and History
  mdlname = char(TFmodels(1).name);
  for kk=2:numel(TFmodels)
    mdlname = strcat(mdlname,[',' char(TFmodels(kk).name)]);
  end
  out.name = sprintf('tdfit(%s)', mdlname);
  out.addHistory(getInfo('None'), pl, mtxs_invars(:), [mtxs(:).hist]);
   
  % Set outputs
  if nargout > 0
    varargout{1} = out;
  end
end

%--------------------------------------------------------------------------
% Included Functions
%--------------------------------------------------------------------------

function obj2fit = prepare2fit(obj,type,Nexp)
  switch type
    case 'outputs'
      obj2fit = obj(1).objs;
    case 'inputs'
      obj2fit = obj.objs{1}.objs;
    case 'filters'
      obj2fit = obj.objs;
    case 'inNames'
      obj2fit = obj;
    case 'outNames'
      obj2fit = obj;
  end
  if exist('obj2fit','var')
    if size(obj2fit)~=[numel(obj2fit),1]
      obj2fit = obj2fit';
    end
    for ii=2:Nexp
      switch type
        case 'outputs'
          obj2cat = obj(ii).objs;
        case 'inputs'
          obj2cat = obj.objs{ii}.objs;
        case 'filters'
          obj2cat = obj.objs;
        case 'inNames'
          obj2cat = obj;
        case 'outNames'
          obj2cat = obj;
      end
      if size(obj2cat)~=[numel(obj2cat),1]
        obj2cat = obj2cat';
      end
      obj2fit = [obj2fit;obj2cat];
    end
  end
  if strcmp(type,'models')
    obj2fit = smodel();
%     obj2fit.setXvar();
    sz = size(obj.objs);
    obj2fit = repmat(obj2fit,Nexp*sz);
    for ii=1:Nexp
      obj2fit((1:sz(1))+(ii-1)*sz(1),(1:sz(2))+(ii-1)*sz(2)) = obj.objs;
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
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.sigproc, '', sets, pl);
  ii.setModifier(false);
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
  
  pl = plist();
  
  % Inputs
  p = param({'Inputs', 'A COLLECTION of MATRIXs, one per each experiment, containing the input A0s.'}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
 
  % Models
  p = param({'Models', 'A MATRIX of transfer function SMODELs.'}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
  % PadRatio
  p = param({'PadRatio', ['PadRatio is defined as the ratio between the number of zero-pad points '...
    'and the data length.<br>'...
    'Define how much to zero-pad data after the signal.<br>'...
    'Being <tt>tdfit</tt> a fft-based algorithm, no zero-padding might bias the estimation, '...
    'therefore it is strongly suggested to do that.']}, 1);
  pl.append(p);
  
  % Whitening Filters
   p = param({'WhFlts', 'A MATRIX of FILTERBANKs containing the whitening filters per each output AO.'}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
  % Parameters
  p = param({'Pnames', 'A cell-array of parameter names to fit.'}, paramValue.EMPTY_CELL);
  pl.append(p);
  
  % P0
  p = param({'P0', 'An array of starting guesses for the parameters.'}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
  % LB
  p = param({'LB', ['Lower bounds for the parameters.<br>'...
    'This improves convergency. Mandatory for Monte Carlo.']}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
  % UB
  p = param({'UB', ['Upper bounds for the parameters.<br>'...
    'This improves the convergency. Mandatory for Monte Carlo.']}, paramValue.EMPTY_DOUBLE);
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
  
  % SymDiff
  p = param({'SymDiff', 'Use symbolic derivatives or not. Only for gradient-based algorithm or for LinUnc option.'}, paramValue.FALSE_TRUE);
  pl.append(p);
  
  % DiffOrder
  p = param({'DiffOrder', 'Symbolic derivative order. Only for SymDiff option.'}, {1, {1,2}, paramValue.SINGLE});
  pl.append(p);
  
  % FitUnc
  p = param({'FitUnc', 'Fit parameter uncertainties or not.'}, paramValue.TRUE_FALSE);
  pl.append(p);
  
  % UncMtd
  p = param({'UncMtd', ['Choose the uncertainties estimation method.<br>'...
    'For multi-channel fitting <tt>hessian</tt> is mandatory.']}, {1, {'hessian', 'jacobian'}, paramValue.SINGLE});
  pl.append(p);
  
  % LinUnc
  p = param({'LinUnc', 'Force linear symbolic uncertainties.'}, paramValue.TRUE_FALSE);
  pl.append(p);
  
  % GradSearch
  p = param({'GradSearch', 'Do a preliminary gradient-based search using the BFGS Quasi-Newton method.'}, paramValue.FALSE_TRUE);
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
  
end
% END
