% MERGE the values for the same key of multiple parameter lists together.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: MERGE the values for the same key of multiple parameter
%              lists together. 
%
% CALL:        pl = merge(p1, p2, p3);
%              pl = merge(p1, [p2 p3], p4)
%
% EXAMPLES:    >> pl1 = plist('A', 1);
%              >> pl2 = plist('A', 3);
%              >> plo = merge(pl1, pl2)
%
%              Then plo will contain a parameter 'A' with value [1 3].
%
% <a href="matlab:utils.helper.displayMethodInfo('plist', 'merge')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = merge(varargin)
  
  %%% Check if this is a call for parameters
  if nargin == 3 && utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  if nargout == 0
    error('### This method cannot be used as a modifier. Please give an output variable.');
  end
  
  dpl = getDefaultPlist();
  concatenateStrings = dpl.find_core('concatenate strings');
  removeDuplicates   = dpl.find_core('remove duplicates');
  
  % Collect all PLIST.
  objs = [];
  for ii = 1:nargin
    if isa(varargin{ii}, 'plist')
      if  numel(varargin{ii}) == 1                                   && ...
          ((varargin{ii}.nparams == 1                       && ...
          (varargin{ii}.isparam_core('remove duplicates') || ...
          varargin{ii}.isparam_core('concatenate strings')))           || ...
          (varargin{ii}.nparams == 2                        && ...
          varargin{ii}.isparam_core('remove duplicates')  && ...
          varargin{ii}.isparam_core('concatenate strings')))
        % For example:
        % plist('remove duplicates', true)
        % plist('concatenate strings', ', ')
        % plist('remove duplicates', true, 'concatenate strings', ', ')
        removeDuplicates   = varargin{ii}.find_core('remove duplicates');
        concatenateStrings = varargin{ii}.find_core('concatenate strings');
      else
        if isempty(objs)
          objs = varargin{ii};
        else
          objs = [reshape(objs, 1, []), reshape(varargin{ii}, 1, [])];
        end
      end
    end
  end
  
  keys = {};
  values = struct();
  
  for ii = 1:numel(objs)
    
    % Loop over all params in the current plist
    for jj = 1:length(objs(ii).params)
      
      key = objs(ii).params(jj).key;
      % Quick hack for PLIST with alternative key names.
      if iscell(key)
        error('### This method doesn''t support alternativ key names. Please code me up or doen''t use PLISTs with alternative key names.');
      end
      
      if isa(objs(ii).params(jj).val, 'paramValue')
        val = objs(ii).params(jj).val.getVal();
      else
        val = objs(ii).params(jj).val;
      end
      
      idxKey = strmatch(key, keys);
      
      if isempty(idxKey)
        keys = [keys; {key}];
        values.(sprintf('KEY%d', length(keys))) = {val};
      else
        if ~removeDuplicates
          name = sprintf('KEY%d', idxKey);
          values.(name) = [values.(name) {val}];
        end
      end
      
    end
  end
  
  % Build new PLIST
  pl = plist();
  
  for ii = 1:numel(keys)
    key  = keys{ii};
    name = sprintf('KEY%d', ii);
    val  = values.(name);
    
    if iscellstr(val) && ~isempty(val)
      
      % Keep cell or concatenate the strings?
      if isempty(concatenateStrings)
        % Keep cell
        s = val;
      else
        s = val{1};
        for ss = 2:numel(val)
          s = [s, concatenateStrings, val{ss}];
        end
      end
      p = param(key, s);
      
    else
      
      % Get class of each value
      classType = unique(cellfun(@class, val, 'UniformOutput', false));
      
      if numel(classType) == 1
        % Here we are sure that the values have the same type.
        p = param(key, [val{:}]);
      else
        % Here we are sure that the values does NOT have the same type.
        p = param(key, val);
      end
    end
    
    pl.append(p);
    
  end
  
  % reset cached keys
  pl.resetCachedKeys();
  
  varargout{1} = pl;
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
  ii.setModifier(false);
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
  
  p = param({'remove duplicates', 'Don''t keep duplicates for the same key.'}, paramValue.FALSE_TRUE);
  plo.append(p);
  
  p = param({'concatenate strings', 'Specify a separator for concatenating strings.'}, paramValue.EMPTY_STRING);
  plo.append(p);
  
end

