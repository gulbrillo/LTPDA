% MRDIVIDE implements mrdivide operator for smodel objects.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: MRDIVIDE implements mrdivide operator for smodel objects.
%
% CALL:        obj = obj1/obj2
%              obj = rdivide(obj1,obj2);
%
% <a href="matlab:utils.helper.displayMethodInfo('smodel', 'mrdivide')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function mdl = mrdivide(varargin)
  
  callerIsMethod = utils.helper.callerIsMethod;
  
  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    mdl = getInfo(varargin{3});
    return
  end
  
  if nargout == 0
    error('### Matrix division operator can not be used as a modifier.');
  end
  
  mdl1 = varargin{1};
  mdl2 = varargin{2};
  
  % Convert numbers into a smodel object
  if isnumeric(mdl1)
    mdl1 = smodel(mdl1);
  end
  if isnumeric(mdl2)
    mdl2 = smodel(mdl2);
  end
  
  %----------------- Gather the input objects names and history
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
  
  % Convert cdata aos into a smodel object
  if isa(mdl2, 'ao')
    if isa(mdl2.data, 'cdata') && numel(mdl2.data.y) == 1
      mdl2 = smodel(mdl2.y);
    else
      error('### It is not possible to divide the two objects!');
    end
  end
  
  mdl = copy(mdl1, true);
  mdl.expr = msym(['(' mdl.expr.s ')/(' mdl2.expr.s ')']);
  mdl.name = ['(' mdl.name ')*(' mdl2.name ')'];

  smodel.mergeFields(mdl1, mdl2, mdl, 'params', 'values');
  smodel.mergeFields(mdl1, mdl2, mdl, 'aliasNames', 'aliasValues');
  smodel.mergeFields(mdl1, mdl2, mdl, 'xvar', 'xvals');
  smodel.mergeFields(mdl1, mdl2, mdl, 'xvar', 'xunits');
  smodel.mergeFields(mdl1, mdl2, mdl, 'xvar', 'trans');

  if ~callerIsMethod
    mdl.addHistory(getInfo('None'), [], in_names, [mdl1.hist mdl2.hist]);
  end
  
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               Local Functions                               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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
