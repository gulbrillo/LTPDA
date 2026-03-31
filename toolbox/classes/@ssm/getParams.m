% GETPARAMS returns the parameter list for this SSM model.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: GETPARAMS returns the parameter list for this SSM model.
%
% CALL:        pl = obj.getParams;
%
% <a href="matlab:utils.helper.displayMethodInfo('ssm', 'getParams')">Parameters Description</a>
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = getParams(varargin)
  
  %% Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  import utils.const.*
  utils.helper.msg(msg.PROC3, 'running %s/%s', mfilename('class'), mfilename);
  
  ssms = utils.helper.collect_objects(varargin(:), 'ssm');
  
  pls = plist.initObjectWithSize(size(ssms,1), size(ssms,2));
  
  %% Loop over the input ssm objects
  for kk = 1:numel(ssms)
    ss = ssms(kk);
    pls(kk) = ss.params;
  end % End loop over ssm objects
  
  %% Set output depending on nargout
  if nargout == numel(pls)
    for i=1:nargout
      varargout{i} = pls(i);
    end
  else
    varargout{1} = pls;
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
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.output, '', sets, pl);
end

function plo = getDefaultPlist()
  plo = plist();
  
  % parameters
  p = param({'parameters', 'The plist containing the list of parameters you want the values of.'}, {1, {plist}, paramValue.OPTIONAL});
  plo.append(p);
end


