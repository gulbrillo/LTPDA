%
% Perform sanity Checks on Inputs.
%
% Errors and warnings are thrown if incorrect inputs
% are specified.
%
function algo = performDataChecks(algo)

  rnge       = algo.params.find('range');
  jumps      = algo.params.find('jumps');
  paramNames = algo.params.find('FitParams');
  logparams  = algo.params.find('log parameters');
  in_step    = algo.params.find('diffStep');
  p0         = algo.params.find('x0');
  
  % Check initial guess
  if isempty(p0)
    error('### A first guess on the parameter values is necessary... Please fill the ''P0'' plist key.')
  end
  
  % Check the type of the input
  [p0, paramNames] = algo.checkP0class(p0, paramNames);
  
  % Get # of parameters
  Nparams = numel(paramNames);

  if isempty(rnge) && algo.params.find('mhsample')
    error('### Please specify a range for each parameter.');
  else
    if iscell(rnge) && ~isempty(rnge)
      % Get range for parameters
      rang = zeros(2,Nparams);
      for ii = 1:Nparams
        rang(:,ii) = rnge{ii};
      end
      algo.params.pset('range',rang);
    end
  end

  if iscell(rnge) && ~isempty(rnge)
    if numel(rnge) ~= Nparams
      error('### The number of parameters and elements of ''range'' must be equal.');
    end
  elseif isnumeric(rnge) && ~isempty(rnge)
    if size(rnge, 2) ~= Nparams
      error('### The number of parameters and elements of ''range'' must be equal.');
    end
  end

  if numel(logparams) > Nparams
    error('### Please check inputs: numel(logparams) > Nparams ');
  end

  lp = zeros(1,Nparams);
  if ~isempty(logparams)
    for ii = 1:Nparams
      if any(strcmpi(paramNames{ii},logparams))
        lp(ii) = 1;
      end
    end
  end
  
  % Handle dstep if is empty
  algo.checkDiffStep(in_step, p0);
  
  if ~isempty(algo.covariance) && ~isnumeric(algo.covariance)
    algo.covariance = double(algo.covariance);
  end

  % check covariance against parameters
  if ~isempty(algo.covariance) && size(algo.covariance, 1) ~= Nparams-numel(algo.params.find('ETA INDICES'))
    error('The size of the covariance matrix should be [Nparams x Nparams]');
  end

  algo.logParams = lp;

  if isempty(jumps) && algo.params.find('mhsample')
    fprintf(['* The ''jumps'' field of the plist is empty. The rescaling of the',...
             ' covariance matrix during heating will be deactivated. \n'])
    algo.params.pset('jumps', ones(1, Nparams));
  end
  
  % Check if SSM and if all info is provided
  if (isempty(algo.params.find('innames')) || isempty(algo.params.find('outnames')) ) && strcmpi(class(algo.model), 'ssm')
    error('### The model is from the ''SSM'' class, while no ''INNAMES'' or ''OUTNAMES'' are defined... ')
  end
  
  % Add history step
  algo.addHistory(getInfo, plist.EMPTY_PLIST(), {}, [algo.hist]);

end % End performDataChecks

%
% GetInfo function
%
function ii = getInfo(varargin)
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.helper, '', {}, plist.EMPTY_PLIST);
end

% END