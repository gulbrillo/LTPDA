% INDEX index into a 'ltpda_uoh' object array or matrix. This properly captures the history.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: INDEX into an 'ltpda_uoh' object array or matrix.
%              This properly captures the history.
% 
% Note: the same indexing convention as MATLAB is used. That is,
% 
%              i = row number
%              j = col number
% 
% Note: If multiple input arrays of objects are input, then they are
% collected into one large (linear) array.
%
% CALL:        b = index(a, i)
%              b = index(a, i, j)
%              b = a.index(plist('I', i))
%              b = a.index(plist('I', i, 'J', j))
%
% <a href="matlab:utils.helper.displayMethodInfo('ltpda_uoh', 'index')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function varargout = index(varargin)

  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end

  if nargout == 0
    error('### index cannot be used as a modifier. Please give an output variable.');
  end

  import utils.const.*
  utils.helper.msg(msg.PROC3, 'running %s/%s', mfilename('class'), mfilename);

  % We can only effectively handle a single matrix of 'ltpda_uoh' objects
  af = 0;
  for jj=1:nargin
    if isa(varargin{jj}, 'ltpda_uoh')
      af = af + 1;
    end
  end
  
%   if af > 1
%     error('### Input a single matrix of ''ltpda_uoh'' objects for indexing.');
%   end

  % Collect input variable names
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end

  % Collect all 'ltpda_uoh' objects and plists
  [aobjs, obj_invars] = utils.helper.collect_objects(varargin(:), 'ltpda_uoh', in_names);
  [pl, pl_invars, rest] = utils.helper.collect_objects(varargin(:), 'plist', in_names);

  arrayShapeKey = 'LTPDA:INDEX_INPUT_ARRAY_SHAPE';

  % we will need a plist if the input shape is not a linear array
  inputSize = size(aobjs);
  if min(inputSize) > 1
    if isempty(pl)
      pl = plist();
    end    
    if pl.isparam_core(arrayShapeKey)
      aobjs = reshape(aobjs, pl.find_core(arrayShapeKey));
    else
      pl.pset(arrayShapeKey, inputSize);
    end
  end
  
  % Decide on a deep copy or a modify
  bobjs = copy(aobjs, nargout);

  % Combine plists
  pl = applyDefaults(getDefaultPlist, pl, {arrayShapeKey});

  % Get indices
  idxi  = find_core(pl, 'i');
  idxj  = find_core(pl, 'j');
  if isempty(idxi) || isempty(idxj)
    % go through the other inputs
    for jj=1:numel(rest)
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
  aout = [];
  if isempty(idxj)
    aout = bobjs(idxi);
  else
    if length(idxj) ~= length(idxi)
      error('Please specify one j index per i index');
    end
    
    for kk=1:numel(idxi)
      aout = [aout bobjs(idxi(kk), idxj(kk))];
    end
  end

  % Make sure we store the indices

  % Name and add history to all outputs
  for jj=1:numel(aout)
    pl = pl.pset('i', idxi(jj));
    if ~isempty(idxj)
      
      pl = pl.pset('j', idxj(jj));
    end
    
    if isempty(idxj)
      aout(jj).addHistory(getInfo('None'), pl, obj_invars(idxi), [bobjs.hist]);
    else
      aout(jj).addHistory(getInfo('None'), pl, obj_invars(sub2ind(size(aobjs), idxi, idxj)), [bobjs.hist]);
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
    pl   = getDefaultPlist;
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
  if exist('pl', 'var')==0 || isempty(pl)
    pl = buildplist();
  end
  plout = pl;  
end

function pl = buildplist()
  pl = plist('I',  [], 'J', []);
end

