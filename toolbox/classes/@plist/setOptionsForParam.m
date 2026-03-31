% SETOPTIONSFORPARAM Sets the options of the param object in dependencies of the 'key'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: Sets the options of the param object in dependencies of the
%              'key'.
%
% CALL:        obj = obj.setOptionsForParam('key', options);
%              obj = obj.setOptionsForParam(plist('KEY', 'key', 'OPTIONS', options));
%              obj = setOptionsForParam(obj, 'key', options);
%
% INPUTS:      obj     - can be a vector, matrix, list, or a mix of them.
%              key     - The key which should be changed
%              options - Possible options of the prameter object
%              pl      - to set the default value of a key with a plist,
%                        please specify only one plist with the key-words
%                        'key' and 'options'
%
% <a href="matlab:utils.helper.displayMethodInfo('plist', 'setOptionsForParam')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = setOptionsForParam(varargin)
  
  %%% Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  [objs, ~, rest] = utils.helper.collect_objects(varargin(:), 'plist');
  
  for kk = 1:numel(objs)
    pls = objs(kk);
    %%% If the plist contains only two key/value pairs with the keys 'key'
    %%% and 'options' then set the options with this plist.
    if pls.nparams == 2 && pls.isparam_core('key') && pls.isparam_core('options')
      rest{1} = pls.find_core('key');
      rest{2} = pls.find_core('options');
      objs(kk) = [];
      break;
    end
  end
  
  if numel(rest) ~= 2
    error('### Please specify some options in a cell-array AND a key, either in a plist or directly.');
  end
  
  key     = rest{1};
  options = rest{2};
  
  %%% decide whether we modify the first plist, or create a new one.
  objs = copy(objs, nargout);
  
  %%% Set the options
  for ii = 1:numel(objs)
    for kk = 1:objs(ii).nparams
      if any(strcmpi(key, objs(ii).params(kk).key))
        if isa(objs(ii).params(kk).val, 'paramValue')
          objs(ii).params(kk).val.setOptions(options);
        else
          objs(ii).params(kk).setVal(paramValue(1, options));
        end
      end
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
  p = param({'key', 'The key of the parameter to set the options for.'}, paramValue.EMPTY_STRING);
  pl.append(p);
  
  % Index
  p = param({'options', 'A cell-array of options to set.'}, {1, {'{}'}, paramValue.OPTIONAL});
  pl.append(p);
  
end

