% ISPARAM look for a given key in the parameter lists.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: ISPARAM look for a given key in the parameter lists. Exist the key
%              in the parameter list then is the result 1 otherwise 0.
%              The output size have the same numer as the numer of the input
%              plists.
%
% CALL:        res = isparam(pl, 'key')
%              res = isparam(pl1, pl2, 'key')
%
% <a href="matlab:utils.helper.displayMethodInfo('plist', 'isparam')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = isparam(varargin)

  
  %%% Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end

  callerIsMethod = utils.helper.callerIsMethod;
  
  if callerIsMethod
    objs = [varargin{1:end-1}];
    rest = varargin(end);
  else
    [objs, invars, rest] = utils.helper.collect_objects(varargin(:), 'plist');
  end
  
  %%%%%%%%%%   Some plausibility checks   %%%%%%%%%%
  if numel(rest) ~= 1
    error('### Please specify only one ''key''.');
  end

  if ~ischar(rest{1}) && ~iscell(rest{1})
    error('### The ''key'' must be a string or a cell-string but it is from the class %s.', class(rest{1}));
  end

  key = rest{1};
  res = isparam_core(objs, key);

  varargout{1} = logical(res);
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
    pl   = [];
  else
    sets = {'Default'};
    pl   = getDefaultPlist;
  end
  % Build info object
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.helper, '', sets, pl);
  ii.setModifier(false);
  ii.setArgsmin(1);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    getDefaultPlist
%
% DESCRIPTION: Get Default Plist
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function plo = getDefaultPlist()
  plo = plist();
end

