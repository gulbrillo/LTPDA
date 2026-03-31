% getPest Get the estimated parameters in a pest object.
%
% CALL: pest_obj = algorithm.getPest();
%
function varargout = getPest(varargin)
  
  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  import utils.const.*
  utils.helper.msg(msg.PROC3, 'running %s/%s', mfilename('class'), mfilename);
  
  algo = varargin{1};
  
  if ~isempty(algo.pest)
    pestOut = algo.pest;
  else
    error('### The algorithm ''pset'' field is empty. Have you run ''process'' yet?')
  end
  
  pestOut.addHistory(getInfo('None'), getDefaultPlist, {}, algo.hist);
  
  varargout = utils.helper.setoutputs(nargout, pestOut);
  
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
