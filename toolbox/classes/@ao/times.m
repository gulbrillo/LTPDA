% TIMES implements multiplication operator for analysis objects.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: TIMES implements multiplication operator for two analysis objects.
%
% CALL:
%              a = a1.*a2
%              a = times(a1,a2);
%              a = times(a1,a2,a3) == times(times(a1,a2),a3)
%
% More than two inputs are handled with nested calls.
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'times')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = times(varargin)
  
  % Settings
  op       = 'times';
  opname   = 'multiply';
  opsym    = '.*';
  
  if nargout == 0
    error('### A %s operator can not be used as a modifier.', opname);
  end
  
  callerIsMethod = utils.helper.callerIsMethod;  
    
  if callerIsMethod
    aosNames = {};
  else    
    % collect input variable names
    for ii = 1:nargin,aosNames{ii} = inputname(ii);end    
  end
  
  % apply operator
  res = ao.elementOp(callerIsMethod, @getInfo, @getDefaultPlist, op, opname, opsym, aosNames, varargin(:));
  
  % Set output
  varargout = utils.helper.setoutputs(nargout, res);  
  
end

%--------------------------------------------------------------------------
% Get Info Object
%--------------------------------------------------------------------------
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
  ii.setModifier(false);
  ii.setArgsmin(2);
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
