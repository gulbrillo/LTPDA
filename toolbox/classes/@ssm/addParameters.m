% ADDPARAMETERS Adds the parameters to the model.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: ADDPARAMETERS Adds the parameters to the (array of) models.
%              Parameters are combined with the ones in the field 'params'
%
% CALL:        obj = obj.addParameters('key1', val1, 'key2', val2);
%              obj = obj.addParameters(plist);
%
% <a href="matlab:utils.helper.displayMethodInfo('ssm', 'addParameters')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = addParameters(varargin)
  
  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  % send starting message
  import utils.const.*
  utils.helper.msg(msg.PROC3, 'running %s/%s', mfilename('class'), mfilename);
  
  % collecting input
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
  
  [ssms, ssm_invars, rest] = utils.helper.collect_objects(varargin(:), 'ssm', in_names);  
  [pl, pl_invars, rest]   = utils.helper.collect_objects(rest(:), 'plist', in_names);
  if ~isempty(rest)
    pl = combine(pl, plist(rest{:}));
  end
  pl = combine(pl, getDefaultPlist());
  
  % Copy ssm objects
  ssmouts = copy(ssms, nargout);
  
  % Loop over the input ssm objects
  for kk = 1:numel(ssmouts)
    if ~isempty(pl.params)
      ssmouts(kk).params = pl.combine(ssmouts(kk).params);
    end
    % append history step
    ssmouts(kk).addHistory(getInfo('None'), pl, ssm_invars(kk), ssmouts(kk).hist);
  end % End loop over ssm objects
    
  % Set output
  varargout = utils.helper.setoutputs(nargout, ssmouts);
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
function pl = getDefaultPlist()
  pl = plist();
end


