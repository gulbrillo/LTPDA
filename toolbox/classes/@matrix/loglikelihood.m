% LOGLIKELIHOOD: Compute log-likelihood for MATRIX objects
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Compute the (unnormalized) log-likelihood for MATRIX objects.
%
% loglik_snr = loglikelihood(model,pl);
%
% OUTPUTS:  logL - A collection of objects containing the LLH, SNR,
%                  LLH(exp), SNR(exp), LLH(frequencies).
%
% NOTE:     If callerIsMethod is true, only the numerical values of the
%           above items are returned.
%
% Example:  [LLH SNR LLH(exp) SNR(exp) LLH(f)] = loglikelihood(m, plist);
%
%           Otherwise, if callerIsMethod == false
%
%           collection = loglikelihood(m, plist);
%
% <a href="matlab:utils.helper.displayMethodInfo('matrix', 'loglikelihood')">Parameters Description</a>
%
% M. Nofrarias, N. Karnesis 2012
%
%
function varargout = loglikelihood(varargin)
  
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  % Use the caller is method flag
  callerIsMethod = utils.helper.callerIsMethod;
  
  if callerIsMethod
    % Assume loglikelihood(sys, ..., ...)
    system = varargin{1};
    data   = varargin{2};
    params = varargin{3};
    lp     = varargin{4};
    freqs  = varargin{5};
    
  else
    
    % Collect input variable names
    in_names = cell(size(varargin));
    try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
    
    % Assume loglikelihood(sys, plist)
    [sys_in, matrix_invars] = utils.helper.collect_objects(varargin(:), 'matrix',   in_names);
    pl                      = utils.helper.collect_objects(varargin(:), 'plist', in_names);
  
    % Combine plists
    pl = applyDefaults(getDefaultPlist, pl);
  
    % copy input ssm
    system = copy(sys_in,1);
    
    xn        = find_core(pl, 'x');
    fin       = find_core(pl, 'in');
    fout      = find_core(pl, 'out');
    noise     = find_core(pl, 'noise');
    params    = find_core(pl, 'params');
    freqs     = find_core(pl, 'f');
    lp        = find_core(pl, 'log parameters');
    
    if isempty(lp)
      lp = zeros(1,numel(params));
    end
    
    if isempty(xn) && isempty(fin) && isempty(fout) && isempty(noise) && ...
       isempty(params) && isempty(freqs)
      
     error(['### To calculate the log-likelihood with a SSM, the keys '...
            '''x'', ''in'', ''out'', ''noise'', ''''  ' ...
            'of the plist must be defined.'])
    end
  
    if (isa(fin, 'ao') && isa(fout, 'ao') && isa(noise, 'ao'))
      
      Nexp = numel(fin(1,:));
      
      % Store the data into structure arrays
      data = MCMC.ao2strucArrays(fout,plist('in',fin,'S',noise,'Nexp',Nexp));
      
    else
      error('### Inputs ''in'', ''out'' and ''noise'' must be AO objects.')
    end
    
  end
  
  % Call the loglikelihood_core
  [loglk snr logLexp snrexp Lf] = loglikelihood_core(system, xn, data, params, lp);
  
  % Set output
  if callerIsMethod
    varargout{1} = loglk;
    varargout{2} = snr;
    varargout{3} = logLexp;
    varargout{4} = snrexp;
    varargout{5} = Lf;
  else
    % Output a collection of objects.
    LLH = ao(loglk);
    LLH.setName('log-likelihood');
    
    SNR = ao(snr);
    SNR.setName('SNR');
    
    LLHexp = ao(logLexp);
    LLHexp.setName('log-likelihood(experiment)');
    
    SNRexp = ao(snrexp);
    SNRexp.setName('SNR(experiment)');
    
    LLHf = ao.initObjectWithSize(1, Nexp);
    
    for ii = 1:numel(Lf) 
      if iscell(freqs)
        LLHf(ii) = ao(plist('type','fsdata', 'name', 'log-likelihood(f)', 'yvals', Lf{ii}, 'xvals', freqs{ii}));
      else
        LLHf(ii) = ao(plist('type','fsdata', 'name', 'log-likelihood(f)', 'yvals', Lf{ii}, 'xvals', freqs));
      end
    end
    
    out = collection(LLH, SNR, LLHexp, SNRexp, LLHf);
    
    % Set history
    out = addHistory(out,getInfo('None'), pl, matrix_invars(:), sys_in.hist);
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
  
  p = param({'in', 'The injection signals (in frequency domain).'}, paramValue.EMPTY_DOUBLE) ;
  pl.append(p);
  
  p = param({'out', 'The measured output of the system (in frequency domain).'}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
  p = param({'noise', 'The inverse cross-spectrum matrix of the measured noise.'}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
  p = param({'params', 'A cell array containing the names of the parameters to fit.'}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
  p = param({'f', 'Numerical array of frequencies.'}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
  p = param({'log parameters', 'A vector of zeros and ones, denoting the position of a log-parameter.'}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
end

% END
