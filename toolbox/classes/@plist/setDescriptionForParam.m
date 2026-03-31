% SETDESCRIPTIONFORPARAM Sets the property 'desc' of the param object in dependencies of the 'key'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: Sets the property 'desc' of the param object in dependencies
%              of the 'key'
%
% CALL:        obj = obj.setDescriptionForParam('key', 'description for the key');
%              obj = obj.setDescriptionForParam(plist('key', 'key', 'desc', 'description for the key'));
%              obj = setDescriptionForParam(obj, 'key', 'description for the key');
%
% INPUTS:      obj - can be a vector, matrix, list, or a mix of them.
%              pl  - to set the description of a key with a plist, please
%                    specify only one plist with the key-words 'key' and
%                    'desc'
%
% <a href="matlab:utils.helper.displayMethodInfo('plist', 'setDescriptionForParam')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = setDescriptionForParam(varargin)

  %%% Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end

  [objs, obj_invars, rest] = utils.helper.collect_objects(varargin(:), 'plist');

  for kk = 1:numel(objs)
    pls = objs(kk);
    %%% If the plist contains only two key/value pairs with the keys 'key'
    %%% and 'desc' then set the description with this plist.
    if pls.nparams == 2 && pls.isparam_core('key') && pls.isparam_core('desc')
      rest{1} = pls.find_core('key');
      rest{2} = pls.find_core('desc');
      objs(kk) = [];
      break;
    end
  end

  if numel(rest) ~= 2
    error('### Please specify a description AND a key for this description, either in a plist or directly.');
  end
  
  key  = rest{1};
  desc = rest{2};
  
  %%% Check that the description is a string
  if ~ischar(desc)
    error('### The description for the key ''%s'' must be a string but it is from the class [%s]', key, class(desc));
  end

  %%% Set the Name
  for ii = 1:numel(objs)

    %%% decide whether we modify the first plist, or create a new one.
    objs(ii) = copy(objs(ii), nargout);

    for kk = 1:objs(ii).nparams
      if any(strcmpi(key, objs(ii).params(kk).key))
        objs(ii).params(kk).setDesc(desc);
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
  p = param({'key', 'The key of the parameter to set the description for.'}, paramValue.EMPTY_STRING);
  pl.append(p);
  
  % Index
  p = param({'desc', 'The description to set.'}, paramValue.EMPTY_STRING);
  pl.append(p);
  
end


