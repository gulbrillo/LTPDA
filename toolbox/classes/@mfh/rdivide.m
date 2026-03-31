% RDIVIDE implements division operator for mfh objects.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: RDIVIDE implements division operator for two mfh objects.
%
% CALL:
%              m = m1./m2
%              m = rdivide(m1,m2);
%              m = rdivide(m1,m2,a3) == rdivide(rdivide(m1,m2),m3)
%
% More than two inputs are handled with nested calls.
%
% <a href="matlab:utils.helper.displayMethodInfo('mfh', 'rdivide')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = rdivide(varargin)

  % Settings
  op     = 'rdivide';
  opname = 'divide';
  opsym  = './';
  
  if nargout == 0
    error('### A %s operator can not be used as a modifier.', opname);
  end
  
  callerIsMethod = utils.helper.callerIsMethod;  
    
  if callerIsMethod
    mfhNames = {};
  else    
    % collect input variable names
    for ii = 1:nargin,mfhNames{ii} = inputname(ii);end    
  end
  
  % apply operator
  res = mfh.elementOp(callerIsMethod, @getInfo, @getDefaultPlist, op, opname, opsym, mfhNames, varargin(:));
  
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
