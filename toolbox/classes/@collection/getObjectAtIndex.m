% GETOBJECTATINDEX index into the inner objects of one collection object.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: GETOBJECTATINDEX index into the inner objects of one
%              collection object.
%              This doesn't captures the history.
%
% CALL:        b = getObjectAtIndex(coll, i)
%              b = getObjectAtIndex(coll, i, j)
%              b = coll.getObjectAtIndex(plist('I', i))
%              b = coll.getObjectAtIndex(plist('I', i, 'J', j))
%
% <a href="matlab:utils.helper.displayMethodInfo('collection', 'getObjectAtIndex')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = getObjectAtIndex(varargin)
  
  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  if nargout == 0
    error('### getObjectAtIndex cannot be used as a modifier. Please give an output variable.');
  end
  
  import utils.const.*
  utils.helper.msg(msg.PROC3, 'running %s/%s', mfilename('class'), mfilename);
  
  % Collect input variable names
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
  
  % Collect all 'ltpda_uoh' objects and plists
  [cobjs, obj_invars, rest] = utils.helper.collect_objects(varargin(:), 'collection', in_names);
  [pl, pl_invars, rest] = utils.helper.collect_objects(rest(:), 'plist', in_names);
  
  % Combine plists
  pl = applyDefaults(getDefaultPlist, pl);
  
  % Get indices
  idxi  = find_core(pl, 'i');
  idxj  = find_core(pl, 'j');
  if isempty(idxi) || isempty(idxj)
    % go through the other inputs
    for jj = 1:numel(rest)
      if isnumeric(rest{jj}) && isempty(idxi)
        idxi = rest{jj};
      elseif isnumeric(rest{jj}) && isempty(idxj)
        idxj = rest{jj};
      end
    end
  end
  
  if isempty(idxi) && isempty(idxj)
    error('### Please provide an index or an index pair.');
  end
  
  % Now index with either (i) or (i,j)
  if isempty(idxj)
    if isa([cobjs.objs{idxi}], 'ltpda_obj')
      aout = copy([cobjs.objs{idxi}], 1);
    else
      aout = [cobjs.objs{idxi}];
    end
    pl.pset('i', idxi);
  else
    if isa(cobjs.objs{idxi, idxj}, 'ltpda_obj')
      aout = copy(cobjs.objs{idxi, idxj}, 1);
    else
      aout = cobjs.objs{idxi, idxj};
    end
    pl.pset('i', idxi);
    pl.pset('j', idxj);
  end
  
  if isa(aout, 'ltpda_uoh')
    aout.addHistory(getInfo('None'), pl, obj_invars(1), cobjs.hist);
  end

  % Set output
  varargout{1} = aout;
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
    pl   = getDefaultPlist();
  end
  % Build info object
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.helper, '', sets, pl);
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

function plo = buildplist()
  
  plo = plist();
  
  p = param({'I', 'The I index of the inner object vector or matrix.'}, paramValue.EMPTY_DOUBLE);
  plo.append(p);
  
  p = param({'J', 'The J index of the inner object matrix.'}, paramValue.EMPTY_DOUBLE);
  plo.append(p);
  
end

