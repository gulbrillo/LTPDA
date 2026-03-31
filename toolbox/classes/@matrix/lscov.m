% LSCOV is a wrapper for MATLAB's lscov function.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: LSCOV is a wrapper for MATLAB's lscov function. It solves a
% set of linear equations by performing a linear least-squares fit. It
% solves the problem
%
%        Y = HX
%
%   where X are the parameters, Y the measurements, and H the linear
%   equations relating the two.
%
% CALL:        X = lscov([C1 C2 ... CN], Y, pl)
%              X = lscov(C1,C2,C3,...,CN, Y, pl)
%
% INPUTS:      C1...CN - MATRIX objects with inside AOs or AOs which
%                        represent the columns of H.
%              Y       - AO which represents the measurement set
%              pl      - Parameter list (see below)
%
% Note: The length of the vectors in Ci and Y must be the same.
% Note: The last input AO is taken as Y.
%
% OUTPUTs:     X  - A pest object with fields:
%                   y   - the N fitting coefficients to y_i
%                   dy  - the parameters' standard deviations (lscov 'STDX' vector)
%                   cov - the parameters' covariance matrix (lscov 'COV' vector)
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'lscov')">Parameters Description</a>
%
% SEE ALSO: ao/lscov
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = lscov(varargin)
  
  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  warning('!!! THIS METHOD IS JUST A BETA VERSION AND MAY BE CHANGED IN FUTURE RELEASE !!!');
  
  if nargout == 0
    error('### Matrix lscov method can not be used as a modifier.');
  end
  
  % Collect the AO's from the matrix objects
  objs = [];
  for ii = 1:nargin
    if isa(varargin{ii}, 'matrix')
      if isa(varargin{ii}.objs, 'ao')
        objs = [objs reshape(varargin{ii}.objs, 1, [])];
      end
    elseif isa(varargin{ii}, 'ao')
      objs = [objs reshape(varargin{ii}, 1, [])];
    end
  end
  
  % Collect plists
  pl = utils.helper.collect_objects(varargin(:), 'plist');
  
  % call lscov for AOs
  varargout{1} = lscov(objs, pl);
  
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
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.op, '', sets, pls);
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
