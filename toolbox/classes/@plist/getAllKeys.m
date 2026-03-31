% GETALLKEYS Return all keys (even the alternative key names) of the parameter list.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: GETALLKEYS Return all keys (even the alternative key names)
%              of the parameter list. That means the output cell-array can
%              contain cells with alternative key names. eg
%              {'key1', {'key2', 'alt1', 'alt2'}, 'key2'}
%
% CALL:        cell-array = obj.getAllKeys();
%              cell-array = getAllKeys(obj);
%
% NOTE: if you want to get a list of only the default keys, use plist/getKeys.
% 
% INPUTS:      obj - input parameter list.
%
% <a href="matlab:utils.helper.displayMethodInfo('plist', 'getAllKeys')">Parameters Description</a>
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = getAllKeys(varargin)
  
  %%% Check if this is a call for parameters
  if nargin == 3 && utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  if nargin ~= 1 && numel(varargin{1}) ~= 1
    error('### This method works only with one parameter list.');
  end
  
  pl = varargin{1};
  
  if ~isempty(pl.keys)
    varargout{1} = pl.keys;
    return
  end
  
  % Single output
  if isempty(pl.params)
    pl.keys = {};
  else
    if isempty(pl.keys)
      pl.keys = {pl.params(:).key};
    end
  end
  
  varargout{1} = pl.keys;
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

