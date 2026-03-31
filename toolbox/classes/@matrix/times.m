% TIMES implements multiplication operator for matrix objects.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: TIMES implements multiplication operator for matrix objects.
%
% CALL:        obj = obj1 .* obj2
%              obj = times(obj1,obj2);
%              obj = times(obj1,obj2,obj3) == times(times(obj1,obj2),obj3)
%
% REMARK:      More than two inputs are handled with nested calls.
%              (This doesn't work at the moment. Do we need this?)
%
% <a href="matlab:utils.helper.displayMethodInfo('matrix', 'times')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = times(varargin)
  
  callerIsMethod = utils.helper.callerIsMethod;
  
  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  if nargout == 0
    error('### Matrix multiplication operator can not be used as a modifier.');
  end
  
  op      = 'times';
  opname  = 'multiplication';
  opsym   = '.*';
  infoObj = getInfo('None');
  
  % collect input variable names
  if callerIsMethod
    in_names = {};
    pl = [];
    rest = varargin(:);
  else
    in_names = cell(size(varargin));
    for ii = 1:nargin,if ~isa(varargin{ii}, 'plist'), in_names{ii} = inputname(ii); end, end
    
    % Collect all plists
    [pl, pl_invars, rest] = utils.helper.collect_objects(varargin(:), 'plist', in_names);
    
    % Combine default plist
    pl = applyDefaults(getDefaultPlist(), pl);
  end
  
  mat = matrix.elementOp(callerIsMethod, op, opname, opsym, infoObj, pl, rest, in_names);
  
  
  %%%%%%%%%%   Prepare output   %%%%%%%%%%
  if nargout == numel(mat)
    for kk=1:numel(mat)
      varargout{kk} = mat(kk);
    end
  else
    varargout{1} = mat;
  end
  
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
    pls  = getDefaultPlist;
  end
  % Build info object
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.aop, '', sets, pls);
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

function plout = getDefaultPlist()
  persistent pl;  
  if exist('pl', 'var')==0 || isempty(pl)
    pl = buildplist();
  end
  plout = pl;  
end

function pl = buildplist()
  pl = plist.EMPTY_PLIST;
end
