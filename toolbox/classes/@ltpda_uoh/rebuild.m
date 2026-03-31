% REBUILD rebuilds the input objects using the history.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: REBUILD rebuilds the input objects using the history.
%
% CALL:        out = rebuild(as)
%
% INPUTS:      as  - array of ltpda_uoh objects of the same kind
%
% OUTPUTS:     out - array of rebuilt objects.
%
% <a href="matlab:utils.helper.displayMethodInfo('ltpda_uoh', 'rebuild')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = rebuild(varargin)
  
  import utils.const.*
  
  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  utils.helper.msg(msg.PROC3, 'running %s/%s', mfilename('class'), mfilename);
  
  if nargout == 0
    error('### rebuild cannot be used as a modifier. Please give an output variable.');
  end
  
  % Collect input variable names
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
  
  % Collect all AOs and plists
  [as, ao_invars, rest] = utils.helper.collect_objects(varargin(:), 'ltpda_uoh', in_names);
  [pl, pl_invars, rest] = utils.helper.collect_objects(rest, 'plist', in_names);
  
  % Combine plists
  pl = applyDefaults(getDefaultPlist, pl);
  
  % Go through each input AO
  bs = [];
  for jj = 1:numel(as)
    
    if isempty(as(jj).hist)
      error('### Can not rebuild the object because the object have no history.');
    end
    
    % Rebuild the object and add to outputs
    bs = [bs rebuild(as(jj).hist, pl);];
    
  end % End object loop
  
  % Set output
  varargout = utils.helper.setoutputs(nargout, bs);
  
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
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.constructor, '', sets, pl);
  ii.setModifier(false);
end

%--------------------------------------------------------------------------
% Get Default Plist
%--------------------------------------------------------------------------
function plout = getDefaultPlist()
  persistent pl;
  if ~exist('pl', 'var') || isempty(pl)
    pl = buildplist();
  end
  plout = pl;
end

function pl = buildplist()
  
  pl = plist();
  
  pl.append(plist.HISTORY_TREE_PLIST);
  
  
end

% END
