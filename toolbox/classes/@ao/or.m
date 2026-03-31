% OR (|) overloads the or (|) method for Analysis objects.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: OR (|) overloads the or (|) method for Analysis objects.
%
% CALL:        out = a | b;
%              out = or(a, b);
%              out = or(a, b, c, ...);
%              out = or(a, b, pl);
%
% INPUTS:      a   = any shape (1x1, 1xN, Nx1, NxM)
%              b,c = same shape as 'a'
%              pl  = PLIST object.
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'or')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = or(varargin)
  
  % Settings
  op     = 'or';
  opname = 'logical OR';
  opsym  = '|';
  
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
