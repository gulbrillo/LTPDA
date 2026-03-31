% getLikelihood Get the likelihood function in a mfh object.
%
% CALL: llh_obj = algorithm.getLikelihood();
%
function varargout = getLikelihood(varargin)
  
  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  import utils.const.*
  utils.helper.msg(msg.PROC3, 'running %s/%s', mfilename('class'), mfilename);
  
  algo = varargin{1};
  
  if ~isempty(algo.loglikelihood)
    loglikelihood = algo.loglikelihood;
  else
    error('### The algorithm ''loglikelihood'' field is empty. Have you run ''buildLoglikelihood'' yet?')
  end
  
  loglikelihood.addHistory(getInfo('None'), getDefaultPlist, {}, algo.hist);
  
  varargout = utils.helper.setoutputs(nargout, loglikelihood);
  
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
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.helper, '', sets, pl);
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

function pl_default = buildplist()
  pl_default = plist();
end
