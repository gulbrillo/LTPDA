% TIMES implements multiplication operator for smodel objects.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: TIMES implements multiplication operator for smodel objects.
%
% CALL:        obj = obj1 .* obj2
%              obj = times(obj1,obj2);
%
% <a href="matlab:utils.helper.displayMethodInfo('smodel', 'times')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = times(varargin)
  
  callerIsMethod = utils.helper.callerIsMethod;
  
  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  % Settings
  op     = 'times';
  opname = 'multiplication';
  opsym  = '.*';
  
  if callerIsMethod
    pl = [];
    infoObj = [];
  else    
    pl = getDefaultPlist();
    infoObj = getInfo('None');
  end
  varNames = cell(size(varargin));
  for ii = 1:nargin,varNames{ii} = inputname(ii);end
  
  if nargout == 0
    error('### A %s operator can not be used as a modifier.', opname);
  end
  
  mdl = smodel.elementOp(callerIsMethod, op, opname, opsym, infoObj, pl, varargin(:), varNames);
  
  % Set output
  varargout = utils.helper.setoutputs(nargout, mdl);
  
end

%--------------------------------------------------------------------------
% Get Info Object
%--------------------------------------------------------------------------
function ii = getInfo(varargin)
  
  if nargin == 1 && strcmpi(varargin{1}, 'None')
    sets = {};
    pl  = [];
  else
    sets = {'Default'};
    pl  = getDefaultPlist();
  end
  % Build info object
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.aop, '', sets, pl);
  ii.setArgsmin(2);
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
  pl = plist.EMPTY_PLIST;
end
