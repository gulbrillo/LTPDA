% SETSELECTIONFORPARAM Sets the selection mode of the param object in dependencies of the 'key'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: Sets the selection mode of the param object in dependencies
%              of the 'key'
%
% CALL:        obj = obj.setSelectionForParam('key', selection);
%              obj = obj.setSelectionForParam(plist('KEY', 'key', 'SELECTION', selection));
%              obj = setSelectionForParam(obj, 'key', selection);
%
% INPUTS:      obj       - can be a vector, matrix, list, or a mix of them.
%              key       - The key which should be changed
%              selection - Selection mode of the parameter
%              pl        - to set the default value of a key with a plist,
%                          please specify only one plist with the key-words
%                          'key' and 'selection'
%
% POSSIBLE VALUES FOR 'selection'
%
%              selection:  1 == paramValue.OPTIONAL
%                          2 == paramValue.SINGLE
%                          3 == paramValue.MULTI
%
% <a href="matlab:utils.helper.displayMethodInfo('plist', 'setSelectionForParam')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = setSelectionForParam(varargin)
  
  %%% Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  [objs, obj_invars, rest] = utils.helper.collect_objects(varargin(:), 'plist');
  
  for kk = 1:numel(objs)
    pls = objs(kk);
    %%% If the plist contains only two key/value pairs with the keys 'key'
    %%% and 'selection' then set the slection mode with this plist.
    if pls.nparams == 2 && pls.isparam_core('key') && pls.isparam_core('selection')
      rest{1} = pls.find_core('key');
      rest{2} = pls.find_core('selection');
      objs(kk) = [];
      break;
    end
  end
  
  if numel(rest) ~= 2
    error('### Please specify a selection mode AND a key, either in a plist or directly.');
  end
  
  key       = rest{1};
  selection = rest{2};
  
  %%% decide whether we modify the first plist, or create a new one.
  objs = copy(objs, nargout);
  
  %%% Set the Name
  for ii = 1:numel(objs)

    matches = matchKey_core(objs(ii), key);
    if sum(matches) == 1
      % Check if we have a paramValue object or a single value
      if isa(objs(ii).params(matches).val, 'paramValue')
        objs(ii).params(matches).val.setSelection(selection);
      else
        % Create a varanValue object from the singel value.
        newVal = paramValue(1, {objs(ii).params(matches).val}, selection);
        objs(ii).params(matches).setVal(newVal);
      end
    else
      warning('LTPDA:setSelectionForParam', '!!! The %d. PLIST object doesn''t have the key ''%s''.', ii, key);
    end
  
  end
  
  %%% Set output
  if nargout == numel(objs)
    % List of outputs
    for ii = 1:numel(objs)
      varargout{ii} = objs(ii);
    end
  else
    % Single output
    varargout{1} = objs;
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

function pl = getDefaultPlist()
  
  pl = plist();
  
  % Key
  p = param({'key', 'The key of the parameter to set the selection mode for.'}, paramValue.EMPTY_STRING);
  pl.append(p);
  
  % Index
  p = param({'selection', 'The selection mode to set.'}, {1, {1,2,3}, paramValue.OPTIONAL});
  pl.append(p);
  
end

