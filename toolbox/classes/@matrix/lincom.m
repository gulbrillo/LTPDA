% LINCOM make a linear combination of analysis objects
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: LINCOM makes a linear combination of the input analysis
%              objects. The analysis objects can be inside a matrix object.
%
% CALL:        b = lincom(a1,a2,a3,...,aN,c)
%              b = lincom([a1,a2,a3,...,aN],c)
%              b = lincom(a1,a2,a3,...,aN,[c1,c2,c3,...,cN])
%              b = lincom([a1,a2,a3,...,aN],[c1,c2,c3,...,cN])
%              b = lincom(a1,a2,a3,...,aN,pl)
%              b = lincom([a1,a2,a3,...,aN],pl)
%
%
%              If no plist is specified, the last object should be:
%               + an AO of type cdata with the coefficients inside OR
%               + a vector of AOs of type cdata with individual coefficients OR
%               + a pest object with the coefficients
%
% INPUTS:      ai - Matrix objects with inside AOs or analysis objects. All
%                   AOs must be from the same type.
%              c  - Analysis object OR pest object with coefficient(s)
%              pl - input parameter list
%
% OUTPUTS:     b  - output analysis object
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'lincom')">Parameters Description</a>
%
% See also: ao/lincom
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = lincom(varargin)
  
  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  warning('!!! THIS METHOD IS JUST A BETA VERSION AND MAY BE CHANGED IN FUTURE RELEASE !!!');
  
  if nargout == 0
    error('### Matrix lincom method can not be used as a modifier.');
  end
  
  % Collect the AO's from the matrix objects of the AOs itself
  objs = [];
  ps   = {};
  for ii = 1:nargin
    if isa(varargin{ii}, 'matrix')
      if isa(varargin{ii}.objs, 'ao')
        objs = [objs reshape(varargin{ii}.objs, 1, [])];
      elseif isa(varargin{ii}.objs, 'pest')
        ps = [ps reshape(varargin{ii}.objs, 1, [])];
      end
    elseif isa(varargin{ii}, 'ao')
      objs = [objs reshape(varargin{ii}, 1, [])];
    elseif isa(varargin{ii}, 'pest')
      ps = [ps reshape(varargin{ii}, 1, [])];
    end
  end
  
  % Collect plists
  pl = utils.helper.collect_objects(varargin(:), 'plist');
  
  % call lincom for AOs
  varargout{1} = lincom(objs, ps{:}, pl);
  
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
    ii = ao.getInfo(mfilename());
    sets = ii.sets;
    pls = [];
    for kk=1:numel(sets)
      pls = [pls getDefaultPlist(sets{kk})];
    end
  end
  % Build info object
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.sigproc, '', sets, pls);
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
  ii = ao.getInfo(mfilename(), set);
  pl = ii.plists(1);
end
