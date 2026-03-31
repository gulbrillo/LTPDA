% GETOBJECTATINDEX index into the inner objects of one matrix object.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: GETOBJECTATINDEX index into the inner objects of one matrix object.
%
% CALL:        b = getObjectAtIndex(m, i)
%              b = getObjectAtIndex(m, i, j)
%              b = m.getObjectAtIndex(plist('I', i))
%              b = m.getObjectAtIndex(plist('I', i, 'J', j))
%
% <a href="matlab:utils.helper.displayMethodInfo('matrix', 'getObjectAtIndex')">Parameters Description</a>
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
  [mobjs, obj_invars, rest] = utils.helper.collect_objects(varargin(:), 'matrix', in_names);
  [pl, pl_invars, rest] = utils.helper.collect_objects(rest(:), 'plist', in_names);

  
  if numel(mobjs) > 1
    error('### %s only supports a single input matrix object.', mfilename);
  end
  
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
    error('### Please provide an index of index pair.');
  end

  % Now index with either (i) or (i,j)
  if isempty(idxj)
    for kk = 1:numel(idxi)
      aout(kk) = copy(mobjs.objs(idxi(kk)), true);
      hpl = pl.pset('i', idxi(kk));
      if isempty(aout(kk).name)
        aout(kk).setName(sprintf('%s(%s)', mobjs.name, num2str(idxi(kk))));
      end
      aout(kk).addHistory(getInfo('None'), hpl, obj_invars(1), mobjs.hist);
    end
  else
    for ii = 1:numel(idxi)
      for jj = 1:numel(idxj)
        aout(ii*jj) = copy(mobjs.objs(idxi(ii), idxj(jj)), true);
        hpl = pl.pset(...
          'i', idxi(ii), ...
          'j', idxj(jj));
        if isempty(aout(ii*jj).name)
          aout(ii*jj).setName(sprintf('%s(%s,%s)', mobjs.name, num2str(idxi(ii)), num2str(idxj(jj))));
        end
        aout(ii*jj).addHistory(getInfo('None'), hpl, obj_invars(1), mobjs.hist);
      end
    end
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

