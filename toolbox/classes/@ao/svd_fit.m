% SVD_FIT estimates parameters for a linear model using SVD
%
% DESCRIPTION: SVD_FIT estimates parameters for a linear model using SVD
%
% CALL:        X = svd_fit([C1 C2 ... CN], Y, pl)
%              X = svd_fit(C1,C2,C3,...,CN, Y, pl)
%
% INPUTS:      C1...CN - AOs defing the models to fit the measurement set to.
%              Y       - AO which represents the measurement set
%
% Note: the length of the vectors in Ci and Y must be the same.
% Note: the last input AO is taken as Y.
%
%              pl - parameter list (see below)
%
% OUTPUTs:     X  - An AO with N elements with the fitting coefficients to y_i 
%                   OR
%                 - a vector of N AOs each with one fitting coefficient to y_i
%                   
% The procinfo field of the output AOs is filled with the following key/value
% pairs:
%
%    'STDX' - standard deviations of the parameters
%    'MSE' - the mean-squared errors
%    'COV' - the covariance matrix
% 
% 
% PARAMETERS:
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'svd_fit')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varargout = svd_fit(varargin)
  
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
  [A, ao_invars] = utils.helper.collect_objects(varargin(:), 'ao', in_names);
  pl             = utils.helper.collect_objects(varargin(:), 'plist', in_names);
  
  if nargout == 0
    error('### svd_fit can not be used as a modifier method. Please give one output');
  end
  
  % combine plists
  pl = applyDefaults(getDefaultPlist(), pl);
  
  % Build matrices for fit
  
  C = A(1:end-1);
  Y = A(end);
  H = C.y;
  y = Y.y;
  [u,s,v] = svd(H,0);
  P       = v/s*u'*y;
  f = zeros(length(H),1);  %y = zeros(length(d),1);
  for kk = 1:length(P)
    f = f + P(kk).*H(:,kk);
  end
  MSE = sum(abs(y-f).^2)./length(y);
  a = H'*H;
  S = inv(a)*MSE;
  STDX = sqrt(diag(S));
  
   % Build X
  if  find_core(pl,'vector_out') 
    for jj = 1:length(P)
      X(jj) = ao(P(jj));
      X(jj).data.setYunits(Y.yunits/C(jj).yunits);
      X(jj).data.setDy(STDX(jj));
      X(jj).name = sprintf('svd_fit(%s)', Y.name);
      X(jj).addHistory(getInfo('None'), pl, ao_invars, [A(:).hist]);
      % Set proc info
      X(jj).procinfo = plist('STDX', STDX(jj), 'MSE', MSE, 'COV', S);
    end
  else
    X = ao(P);
    X.data.setYunits(Y.yunits/C(1).yunits);
    X.data.setDy(STDX);
    X.name = sprintf('svd_fit(%s)', Y.name);
    X.addHistory(getInfo('None'), pl, ao_invars, [A(:).hist]);
    % Set proc info
    X.procinfo = plist('STDX', STDX, 'MSE', MSE, 'COV', S);
  end
  
  % Set outputs
  varargout{1} = X;
    
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
function plout = getDefaultPlist()
  persistent pl;  
  if exist('pl', 'var')==0 || isempty(pl)
    pl = buildplist();
  end
  plout = pl;  
end

function pl = buildplist()
  pl = plist();
  
   % Vector out
  p = param({'vector_out','The estimated coefficients are output as a vector of AOs.'}, paramValue.TRUE_FALSE);
  pl.append(p);
  
end
% END
