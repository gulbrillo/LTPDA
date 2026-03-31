% LOGLIKELIHOOD: Compute log-likelihood for MFH objects
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Compute the (unnormalized) log-likelihood for MFH objects.
% For the MFH objects, the log-likelihood function must be defined
% by the user. For example, for the definition <o - H x i>*S^-1<o - H x i>
% the function 'func' must cover the term <o - H x i>. The 'S' matrix 
% corresponds to the 'noise' plist key.
%
% EXAMPLE:  LLH = loglikelihood(func, pl);
%
% For more than one channel model, then input an array of MFH objects.
% NOTE: The 'S' matrix must be of the correct size Nout X Nout.
% For example, for the 2 input - 2 output case:
%
%           mfh_fncs = [ch1_mfh_exp1 , ch1_mfh_exp2 ; ...
%                       ch2_mfh_exp1 , ch2_mfh_exp2 ]
%
%           LLH = loglikelihood(mfh_fncs, plist);
%
% For systems that require multiple channels and experiments, then:          
%
%           LLH = loglikelihood([ch1_mfh ; ch2_mfh], plist);
%
% OUTPUTS:  logL - A collection of objects containing the LLH, SNR,
%                  LLH(frequencies).
%
% NOTE:     If callerIsMethod is true, only the numerical values of the
%           above items are returned.
%
% Example:  [LLH SNR LLH(f)] = loglikelihood(m, plist);
%
%           Otherwise, if callerIsMethod == false
%
%           collection = loglikelihood(myfunc, plist);
%
% <a href="matlab:utils.helper.displayMethodInfo('mfh', 'loglikelihood')">Parameters Description</a>
%
% M. Nofrarias, N. Karnesis 2012
%
%
function varargout = loglikelihood(varargin)
  
  if nargin == 3 && utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  % Use the caller is method flag
  callerIsMethod = utils.helper.callerIsMethod;
  
  if callerIsMethod
    % Assume loglikelihood(sys, ..., ...)
    system = varargin{1};
    xn     = varargin{2};
    data   = varargin{3};
    k0     = varargin{4};
    if nargin > 4
      pl = varargin{5};
    else
      pl = plist();
    end
  else
    
    % Collect input variable names
    in_names = cell(size(varargin));
    try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
    
    % Assume loglikelihood(sys, plist)
    [sys_in, mfh_invars] = utils.helper.collect_objects(varargin(:), 'mfh',   in_names);
    pl                   = utils.helper.collect_objects(varargin(:), 'plist', in_names);
  
    % Combine plists
    pl = applyDefaults(getDefaultPlist, pl);
  
    % copy input ssm
    system = copy(sys_in,1);
    
    xn    = find_core(pl, 'x');
    data  = find_core(pl, 'noise');
    freqs = find_core(pl, 'f');
    k0    = find_core(pl, 'k0');
    
    if isempty(data) 
      
     error(['### To calculate the log-likelihood with a MFH, the key '...
            ' ''noise'' of the plist must be defined.'])
    end
  
  end
  
  if isa(data, 'ao') || isa(data, 'matrix')
    
    % Store the data into structure arrays
    data    = MCMC.ao2strucArrays(plist('S',data,'Nexp',numel(data)));
    
  else
    error('### Input ''noise'' must be an AO.')
  end
    
  % ensure the model returns doubles
  if pl.find_core('wrap double')
    sys = mfh(plist(...
      'func',         sprintf('double(%s(p))', system.name), ...
      'name',         system.name, ...
      'inputs',       'p', ...
      'subfuncs',     system));
  else
    sys = system;
  end

  % Call the loglikelihood_core
  [loglk, snr, Lf] = loglikelihood_core(sys, xn, data, k0);
  
  % Set output
  if callerIsMethod
    varargout{1} = loglk;
    if nargout > 1
      varargout{2} = snr;
    end
    if nargout > 2
      varargout{3} = Lf;
    end
  else
    % Output a collection of objects.
    LLH = ao(loglk);
    LLH.setName('log-likelihood');
    
    SNR = ao(snr);
    SNR.setName('SNR');
    
    if ~isempty(freqs) && numel(freqs) == numel(Lf)
      LLHf = ao(plist('type','fsdata', 'name', 'log-likelihood(f)', 'yvals', Lf, 'xvals', freqs));
    else
      freqs = 1:numel(Lf); 
      LLHf  = ao(plist('type','fsdata', 'name', 'log-likelihood(f)', 'yvals', Lf, 'xvals', freqs));
    end
    
    % set procinfo
    out = LLH.setProcinfo(plist('LLHF', LLHf, 'SNR', SNR));
        
    % Set history
    out = addHistory(out,getInfo('None'), pl, mfh_invars(:), sys_in.hist);
    varargout = utils.helper.setoutputs(nargout, out);
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
end

%--------------------------------------------------------------------------
% Get Default Plist
%--------------------------------------------------------------------------
function pl = getDefaultPlist()
  
  pl = plist();

  p = param({'x', 'The parameter values. A 1xNumParams array.'}, paramValue.EMPTY_DOUBLE) ;
  pl.append(p);
  
  p = param({'noise', 'The inverse cross-spectrum matrix of the measured noise.'}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
  p = param({'f', 'Numerical array of frequencies.'}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
  p = param({'wrap double', 'Wraps the input model in a double() call to ensure the model output is numeric for internal calculations. If your model already returns a numeric vector, you can leave this set to false.'}, paramValue.FALSE_TRUE);
  pl.append(p);
  
  p = param({'k0','The first FFT coefficient of the analysis. All FFT coefficients with k<k0 are discarded from the analysis.'},  paramValue.DOUBLE_VALUE(1));
  pl.append(p);
  
end

% END
