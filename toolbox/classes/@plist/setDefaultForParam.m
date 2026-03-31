% SETDEFAULTFORPARAM Sets the default value of the param object in dependencies of the 'key'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: Sets the default value (index to the possible options) of
%              the param object in dependencies of the 'key'.
%
% CALL:        obj = obj.setDefaultForParam('key', newOption);
%              obj = obj.setDefaultForParam(plist('KEY', 'key', 'option', newOption));
%              obj = setDefaultForParam(obj, 'key', newOption);
%
% INPUTS:      obj       - can be a vector, matrix, list, or a mix of them.
%              key       - The key which should be changed
%              newOption - new option for the selection mode
%                            OPTIONAL: If the new option doesn't exist in
%                                      the param-options then add this
%                                      method the 'new' option.
%                            SINGLE:   Sets the 'new' option only if it is
%                                      found in the param-options.
%              pl        - to set the default value of a key with a plist,
%                          please specify only one plist with the key-words
%                          'key' and 'option'
%
% <a href="matlab:utils.helper.displayMethodInfo('plist', 'setDefaultForParam')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = setDefaultForParam(varargin)

  
  %%% Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  callerIsMethod = utils.helper.callerIsMethod;
  
  if callerIsMethod
    objs    = [varargin{1:end-2}];
    key     = varargin{end-1};
    option  = varargin{end};
  else
    [objs, obj_invars, rest] = utils.helper.collect_objects(varargin(:), 'plist');
    
    for kk = 1:numel(objs)
      pls = objs(kk);
      %%% If the plist contains only two key/value pairs with the keys 'key'
      %%% and 'option' then set the default option with this plist.
      if numel(pls.params) == 2 && pls.isparam_core('key') && pls.isparam_core('option')
        rest{1} = pls.find_core('key');
        rest{2} = pls.find_core('option');
        objs(kk) = [];
        break;
      end
    end
    
    if numel(rest) ~= 2
      error('### Please specify a ''key'' AND a the new option, either in a plist or direct.');
    end
    
    key    = rest{1};
    option = rest{2};
  end

  %%% Set the Name
  for ii = 1:numel(objs)

    %%% decide whether we modify the first plist, or create a new one.
    objs(ii) = copy(objs(ii), nargout);
    setDefaultForParam_core(objs(ii), key, option);
  end

  %%% Set output
  varargout = utils.helper.setoutputs(nargout, objs);

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
  p = param({'key', 'The key of the parameter to set the default index for.'}, paramValue.EMPTY_STRING);
  pl.append(p);
  
  % Index
  p = param({'options', 'The index to set.'}, paramValue.DOUBLE_VALUE(-1));
  pl.append(p);
  
end

