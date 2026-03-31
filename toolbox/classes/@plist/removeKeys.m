% REMOVEKEYS removes keys from a PLIST.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: Removes from the first input PLIST the keys which are
%              specified as the second in a cell-array.
%              This method will keep the oder of the keys inside the PLIST.
%
% CALL:        pl = removeKeys(pl, 'key');
%              pl = removeKeys(pl, {keys});
%              pl = removeKeys(pl, plist('remove', {keys}));
%
% <a href="matlab:utils.helper.displayMethodInfo('plist', 'removeKeys')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = removeKeys(varargin)
  
  %%% Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  %%% Check input objects
  if nargin ~= 2
    error('### Unknown number of inputs. ');
  end
  if ~isa(varargin{1}, 'plist') || numel(varargin{1}) ~= 1
    error('### The first input must be a single parameter list (PLIST).');
  end
  if ~(iscell(varargin{2}) || ischar(varargin{2}) || isa(varargin{2}, 'plist'))
    error('### The second input must be a cell array, a string or a PLIST which controles this method.')
  end
  
  obj = varargin{1};
  removeKeys = varargin{2};
  
  %%% Convert the second input to a cell array if necessary.
  if isa(removeKeys, 'plist')
    removeKeys = removeKeys.find_core('remove');
  end
  if ischar(removeKeys)
    removeKeys = cellstr(removeKeys);
  end
  removeKeys = upper(removeKeys);
  
  %%% Decide on a deep copy or a modify
  obj = copy(obj, nargout);
  
  matches = zeros(1, obj.nparams);
  for ii=1:numel(removeKeys)
    matches = matches | matchKey_core(obj, removeKeys{ii});
  end
  
  obj.params = obj.params(~matches);
  
  % reset cached keys
  obj.resetCachedKeys();
  
  varargout{1} = obj;
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
  ii.setArgsmin(2);
  ii.setArgsmax(2);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    getDefaultPlist
%
% DESCRIPTION: Get Default Plist
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function pl = getDefaultPlist()
  
  pl = plist();
  
  % Remove
  p = param({'remove', 'A list of the parameters to remove, specified by their keys.'}, {1, {'{}'}, paramValue.OPTIONAL});
  pl.append(p);
  
end

