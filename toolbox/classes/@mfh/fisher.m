% FISHER.M Calculation of the Fisher Information Matrix/Covariance
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% INPUTS:
%         - The MFH object of the time series of the signals.
%         - A plist object.
%
% OUTPUTS:
%         - Covariance matrix of the parameters. Unlike the 
%           ssm/fisher and matrix/fisher, this functions returns
%           directly the covariance matrix of the parameters. This
%           is due to the properties of the MATLAB function handle 
%           objects.
%
%
% EXAMPLE:  C = fisher(mfh_object, plist);
%
% <a href="matlab:utils.helper.displayMethodInfo('mfh', 'fisher')">Parameters Description</a>
%
% NK 2014
%
function varargout = fisher(varargin)
  
  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  import utils.const.*
  utils.helper.msg(msg.PROC3, 'running %s/%s', mfilename('class'), mfilename);
  
  % Method can not be used as a modifier
  if nargout == 0
    error('### FISHER cannot be used as a modifier. Please give an output variable.');
  end
  
  % Collect input variable names
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
  
  % Collect all AOs smodels and plists
  [mfh_in, mfh_invars, rest] = utils.helper.collect_objects(varargin(:), 'mfh', in_names);
  pl          = utils.helper.collect_objects(rest(:), 'plist', in_names);
  
  % Combine plists
  pl = applyDefaults(getDefaultPlist, pl);
  
  xo         = find_core(pl, 'p0');
  n          = find_core(pl, 'Noise');
  dStep      = find_core(pl, 'diffstep');
  trim       = find_core(pl, 'trim');
  fs         = find_core(pl, 'fs');
  yun        = find_core(pl, 'yunits');
  llhver     = find_core(pl, 'version');
  
  % Check if input is a pest
  if ~isa(xo, 'pest')
    warning('### The input parameter values are not encapsuled in a pest object. This might cause errors ...')
  end
  
  % copy input aos
  sts  = copy(mfh_in,1); 
  Nexp = size(sts,2);
  Nout = size(sts,1);
  S    = matrix.initObjectWithSize(1, Nexp);
 
  fft_pl = subset(pl, getKeys(mfh_model_fft_signals('plist','core')));
  fft_pl.remove('paramsvalues', 'pinv', 'tol', 'diffstep', 'noise',...
                'regularize', 'yunits', 'paramnames', MCMC.getInfo('MCMC.computeICSMatrix').plists.getKeys);
  
  % remove key if AO
  if strcmpi(fft_pl.find_core('version'), 'chi2 ao')
    fft_pl.remove('etas','bin groups','nu','fs','s','error ratio');
    fft_pl.pset('version', 'ao');
    % Update the fs 
    switch class(n)
      case 'ao'
        fs = n.fs;
      case 'mfh'
        noi = n.index(1).eval(p0);
        fs = noi.fs;
    end
  else
    fft_pl.pset('fs', fs, 'version', 'core');
  end

  % set some keys
  fft_pl.pset('ts fh', sts, 'p0', xo, 'built-in', 'fft_signals', 'name', 'fft_signals');
  
  % compute FFTs of signals
  h = mfh(fft_pl);
  
  % handle noise data/model
  v = MCMC.handle_data_for_icsm(n, xo, Nout, trim, fs, yun, pl.find_core('version'));
  
  % split plist
  spl = plist('offsets', trim./fs);
  
  for kk = 1:Nexp
    
    % eval time series
    if ~strcmpi(llhver, 'chi2 ao')
      vs = split(ao(plist('yvals', double(sts(1,kk).eval(xo)),'fs',fs,'xunits','s','yunits',yun,'type','tsdata')),spl);
    else
      vs = split(sts(1,kk).eval(xo),spl);
    end

    % calculate the inverse cross-spectrum matrix
    scpl = subset(pl, getKeys(MCMC.getInfo('MCMC.computeICSMatrix').plists));
    
    scpl.pset('NOUT',  Nout,...
              'FREQS', x(split(fft(vs), plist('frequencies', pl.find('frequencies')))));

    S(kk) = MCMC.computeICSMatrix(v, scpl);
  end
  
  % callerIsMEthod
  callerIsMethod = utils.helper.callerIsMethod;
  
  % ensure parameters are doubles
  dStep = double(dStep);

  % Initialise
  FisMat = zeros(numel(double(xo)));
  F      = zeros(numel(double(xo)));
  
  % Store noise into the correct format 
  if isa(S,'matrix')
    Nexp = numel(S);
    data = MCMC.ao2strucArrays(plist('S',S,'Nexp',Nexp));
  elseif isa(S,'ao')
    Nexp = size(h,2);
    data = MCMC.ao2strucArrays(plist('S',S,'Nexp',Nexp));
  else
    error('### S must be a matrix or an AO object....')
  end
  
  for nn = 1:Nexp
  
    for kk = 1:size(h,1)

      % get Jacobian
      aoJ = getJacobian(h.index(kk,nn),xo,dStep);
      J = aoJ.y;
      D(nn).exp(:,kk,:) = reshape(J,numel(J(:,1)),numel(J(1,:)));

    end

    % Compute Fisher Matrix (only upper triangle, it must be symmetric)
    for ii =1:length(double(xo))

      for jj =ii:length(double(xo))

        g = utils.math.mult(data(nn).noise, D(nn).exp(:,:,jj));

        FisMat(ii,jj) = sum(real(utils.math.ctmult(D(nn).exp(:,:,ii) , g)));

      end
    end
    
    % Adding up
    F = F + FisMat;
    
  end

    % Fill lower triangle
    for jj =1:length(double(xo))
      for ii =jj:length(double(xo))
        F(ii,jj) = F(jj,ii);
      end
    end
  
  % add history
  if ~callerIsMethod
    F = ao(F, plist('name', 'Fisher matrix'));
    ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.sigproc, '', 'None', []);
    F.addHistory(ii, pl, mfh_invars, [h.hist]);
  end
  
  % create output object
  varargout{1} = F;
  
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
  
  p = param({'p0','The numerical values of the parameters.'}, paramValue.EMPTY_STRING);
  pl.append(p);
  
  p = plist({'pinv','Use the Penrose-Moore pseudoinverse'}, paramValue.TRUE_FALSE);
  pl.append(p);
  
  p = plist({'tol','Tolerance for the Penrose-Moore pseudoinverse'}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
  p = plist({'diffstep','Numerical differentiation step for ssm models'}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
  p = plist({'Noise','The noise time series or MFH objects.'}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
  p = plist({'Regularize', 'If the resulting fisher matrix is not positive definite, try a numerical trick to continue sampling. '}, paramValue.FALSE_TRUE);
  pl.append(p);
  
  p = param({'Yunits', 'The Y units of the noise time series, in case the MFH object is a ''core'' type.'}, 'm s^-2');
  pl.append(p);
  
  p = param({'nearestSPD', 'Try to find the nearest symmetric and positive definite covariance matrix, with the ''nearestSPD'' method from MATLAB file exchange.'}, paramValue.FALSE_TRUE);
  pl.append(p);
  
  % Get keys for the log-likelihood MFH model
  llh_pl = mfh_model_fft_signals('plist','core');
  llh_pl = remove(llh_pl, 'version');
  pl = combine(pl, llh_pl);
  
  % Get keys for computeICSMatrix function
  pl = combine(pl, MCMC.getInfo('MCMC.computeICSMatrix').plists);
  
  p = param({'version', 'Choose between ''AO'' and ''CORE'' types.'}, {1, {'core', 'ao'}, paramValue.OPTIONAL});
  pl.append(p);
  
end

% END
