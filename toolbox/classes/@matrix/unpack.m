% UNPACK unpacks the objects in a matrix and sets them to the given output
% variables.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: UNPACK unpacks the objects in a matrix and sets them to the
%              given output variables.
%
% CALL:        [o1, o2] = unpack(in);
%
%
% If you are only interested in particular outputs, you can use MATLAB's
% dummy output variable. For example, suppose we have a matrix object
% containing 3 objects, and we only want the first and third, then we can
% do:
%
% >> [o1, ~, o3] = unpack(m)
%
% Note: this is just a convenient wrapper around matrix/getObjectAtIndex.
% The output objects will be the result of calling matrix/getObjectAtIndex
% for the correct index. This method does not add history, instead the
% history contains the call to getObjectAtIndex.
%
% INPUTS:      in      -  input matrix object
%
% OUTPUTS:     out     -  output objects
%
% <a href="matlab:utils.helper.displayMethodInfo('matrix', 'unpack')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varargout = unpack(varargin)
  
  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  % Collect all smodels and plists
  ms = utils.helper.collect_objects(varargin(:), 'matrix');
  if numel(ms) ~= 1
    error('matrix/unpack can only work on a single matrix object');
  end
  
  if nargout ~= numel(ms.objs)
    error('The number of outputs doesn''t match the number of objects in the matrix.');
  end
  
  out = {};
  for kk=1:nargout
    out{kk} = ms.getObjectAtIndex(kk);
  end
  
  varargout = out;
  
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               Local Functions                               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    getInfo
%
% DESCRIPTION: Get Info Object
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function ii = getInfo(varargin)
  
  if nargin == 1 && strcmpi(varargin{1}, 'None')
    sets = {};
    pls  = [];
  else
    sets = {'Default'};
    pls = [];
    for kk=1:numel(sets)
      pls = [pls getDefaultPlist(sets{kk})];
    end
  end
  % Build info object
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.output, '', sets, pls);
  ii.setArgsmin(2);
  ii.setModifier(false);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    getDefaultPlist
%
% DESCRIPTION: Get Default Plist
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%--------------------------------------------------------------------------
% Get Default Plist
%--------------------------------------------------------------------------
function plout = getDefaultPlist(set)
  persistent pl;
  persistent lastset;
  if ~exist('pl', 'var') || isempty(pl) || ~strcmp(lastset, set)
    pl = buildplist(set);
    lastset = set;
  end
  plout = pl;
end

function pl = buildplist(set)
  
  pl = plist();
  
end
