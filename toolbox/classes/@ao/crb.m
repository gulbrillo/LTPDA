% CRB computes the inverse of the Fisher Matrix
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: CRB computes the inverse of the Fisher Matrix
%
% CALL:        bs = crb(in,pl)
%
% INPUTS:      in      - matrix objects with input signals to the system
%              model   - symbolic models containing the transfer function model
%
%              pl      - parameter list
%
% OUTPUTS:     bs   - covariance matrix AO
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'crb')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = crb(varargin)
  
  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  import utils.const.*
  utils.helper.msg(msg.PROC3, 'running %s/%s', mfilename('class'), mfilename);
  
  % Method can not be used as a modifier
  if nargout == 0
    error('### crb cannot be used as a modifier. Please give an output variable.');
  end
  
  % Collect input variable names
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
  
  % Collect all AOs smodels and plists
  [aos_in, ao_invars] = utils.helper.collect_objects(varargin(:), 'ao', in_names);
  pl                  = utils.helper.collect_objects(varargin(:), 'plist', in_names);
  
  % Collect input histories
  inhists = [aos_in.hist];
  
  % Combine plists
  pl = applyDefaults(getDefaultPlist, pl);
  
  % copy input aos
  noise = copy(aos_in,1); 
  
  % Get the model
  model = pl.find_core('MODEL');
  
  %%%%%%%%%%%%%%%%%%%%%%%%%  Preprocess the Data  %%%%%%%%%%%%%%%%%%%%%%%%%
  
  % re-arrange to meet preprocessDataForMCMC standards
  % input : goes to the plist
  % output: not needed in crb. We use input to preserve structure. 
  if strcmpi(class(model),'ssm')
    out = copy(pl.find_core('INPUT'));
  else
    out = [];
  end
  
  % Check the version requested
  if isa(model, 'mfh') && ~model(1).numeric
    llhver = 'chi2 ao';
  else 
    llhver = 'chi2';
  end
  
  % Set values in the plist to avoid errors thrown
  % in the MCMC class.
  rng      = cell(1,numel(pl.find_core('FitParams')));
  [rng{:}] = deal(ones(1,2)); 
  plMCMC       = pset(pl,'range',    rng,...
                         'x0',       pl.find_core('ParamsValues'),...
                         'jumps',    ones(1,numel(pl.find_core('FitParams'))),...
                         'mhsample', false,...
                         'simplex',  false,...
                         'fs',       pl.find('fs'),...
                         'llh ver',  llhver);
 
  % Create a MCMC algorithm 
  m = MCMC(plMCMC.remove('version'));
  
  % Set data and model
  m.setModel(model);
  m.setInputs(pl.find_core('INPUT'));
  m.setNoise(noise);
  
  %  Preprocess the data
  m.buildLogLikelihood(out);  
  
  m.performDataChecks();

  m.calculateCovariance();
  
  % create output AO
  out = m.covariance;
  out = addHistory(out, getInfo('None'), pl, ao_invars, inhists);
  
  varargout{1} = out;
end


%--------------------------------------------------------------------------
% Get Info Object
%--------------------------------------------------------------------------
function ii = getInfo(varargin)
  if nargin == 1 && strcmpi(varargin{1}, 'None')
    sets = {};
    pls  = [];
  else
    sets = {'Default'};
    pls  = getDefaultPlist;
  end
  % Build info object
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.sigproc, '', sets, pls);
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
  
  p = param({'inNames','Input names. Used for ssm models.'}, paramValue.DOUBLE_VALUE(1));
  pl.append(p);
  
  p = param({'outNames','Output names. Used for ssm models.'}, paramValue.DOUBLE_VALUE(1));
  pl.append(p);
  
  p = param({'FitParams','The names of the parameters. Used for printing and for the case of the SSM.'}, paramValue.EMPTY_STRING);
  p.addAlternativeKey('parameter names');
  p.addAlternativeKey('param names');
  pl.append(p);
  
  p = param({'ParamsValues','The numerical values of the parameters.'}, paramValue.EMPTY_DOUBLE);
  p.addAlternativeKey('x0');
  p.addAlternativeKey('p0');
  pl.append(p);
  
  p = plist({'model','An array of matrix models'}, paramValue.EMPTY_STRING);
  pl.append(p);
  
  p = plist({'input',['The input signal to the system. It should be a matrix of AOs, the rows denoting the ' ...
             'channels, and the columns the number of experiments. An array of matrix objects is also accepted.']}, paramValue.EMPTY_STRING);
  pl.append(p);
  
  p = plist({'pinv','Use the Penrose-Moore pseudoinverse'}, paramValue.FALSE_TRUE);
  pl.append(p);
  
  p = plist({'tol','Tolerance for the Penrose-Moore pseudoinverse'}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
  p = plist({'diffstep','Numerical differentiation step for ssm models'}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
  p = plist({'ngrid','Number of points in the grid to compute the optimal differentiation step for ssm models'}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
  p = plist({'stepRanges','An array with upper and lower values for the parameters ranges. To be used to compute the optimal differentiation step for ssm models.'}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
  p = plist({'log parameters','An array with upper and lower values for the parameters ranges. To be used to compute the optimal differentiation step for ssm models.'}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
  p = plist({'frequencies','The frequencies to perform the analysis.'}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
  p = plist({'f1','Initial frequency for the analysis.'}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
  p = plist({'f2','Final frequency for the analysis.'}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
  p = plist({'Noise Scale',['Select the way to handle the noise/weight data. '...
             'Can use the PSD/CPSD or the LPSD/CLPSD functions.']}, {1, {'PSD','LPSD'}, paramValue.SINGLE});
  pl.append(p);
  
  p = param({'Yunits', 'The Y units of the noise time series, in case the MFH object is a ''core'' type.'}, paramValue.STRING_VALUE('m s^-2'));
  pl.append(p);
  
  p = param({'TRIM','A 2x1 vector that denotes the samples to split from the star and end of the time-series (split in offsets).'},  paramValue.DOUBLE_VALUE([100 -100]));
  pl.append(p);
  
  p = plist({'regularize', 'If the resulting fisher matrix is not positive definite, try a numerical trick to continue sampling.'}, paramValue.FALSE_TRUE);
  pl.append(p);
  
  p = param({'nearestSPD', 'Try to find the nearest symmetric and positive definite covariance matrix, with the ''nearestSPD'' method from MATLAB file exchange.'}, paramValue.FALSE_TRUE);
  pl.append(p);

  p = param({'fs','For the cae of ''CORE'', the sampling frequency of the time series is needed.'},  paramValue.DOUBLE_VALUE(1));
  pl.append(p);
  
  % WINDOW
  pl.combine(plist.WELCH_PLIST);
  
  % ICSM
  icsm_dpl = MCMC.getInfo('MCMC.computeICSMatrix').plists;
  pl = combine(pl, icsm_dpl);
  
end

% END
