% SETDYFORPARAMETER Sets the according dy-error for the specified parameter.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: SETDYFORPARAMETER Sets the according dy-error for the
%              specified parameter.
%
% CALL:        obj = obj.setDyForParameter('a', 2);
%              obj = obj.setDyForParameter('a', 2, 'b', 2);
%              obj = obj.setDyForParameter(plist('errors', [2 2],
%                                                'params'  {'a', 'b'}))
%
% INPUTS:      obj - one pest model.
%              pl  - parameter list
%
% <a href="matlab:utils.helper.displayMethodInfo('pest', 'setDyForParameter')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = setDyForParameter(varargin)
  
  % Check if this is a call from a class method
  callerIsMethod = utils.helper.callerIsMethod;
  
  if callerIsMethod
    
    %%% make sure that the parameters and errors are cell-arrays
    objs   = varargin{1};
    params = cellstr(varargin{2});
    errs   = varargin{3};
    if ~iscell(errs)
      errs = num2cell(errs);
    end
  else
    % Check if this is a call for parameters
    if utils.helper.isinfocall(varargin{:})
      varargout{1} = getInfo(varargin{3});
      return
    end
    
    %%% Collect input variable names
    in_names = cell(size(varargin));
    try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
    
    [objs, obj_invars, rest] = utils.helper.collect_objects(varargin(:), '', in_names);
    [pls,  invars, rest]     = utils.helper.collect_objects(rest(:), 'plist');
    
    params = {};
    errs   = {};
    %%% If pls contains only one plist with the two keys 'params' and
    %%% 'errors' then set the property with a plist.
    if length(pls) == 1 && isa(pls, 'plist') && nparams(pls) == 2 && isparam_core(pls, 'errors')
      params = cellstr(find(pls, 'params'));
      errs   = find(pls, 'errors');
      if ~iscell(errs)
        errs = num2cell(errs);
      end
    end
    
    while numel(rest) >= 2
      params = [params cellstr(rest{1})];
      if ~iscell(rest{2})
        errs   = [errs num2cell(rest{2})];
      else
        errs   = [errs rest{2}];
      end
      rest(2) = [];
      rest(1) = [];
    end
    
    %%% Combine plists
    pls = combine(pls, plist('params', params, 'errors', errs));
    
    if numel(params) ~= numel(errs)
      error('### Please specify one error per parameter.');
    end
    
  end % callerIsMethod
  
  %%% decide whether we modify the input pest object, or create a new one.
  objs = copy(objs, nargout);
  
  for objLoop = 1:numel(objs)
    
    for ll=1:numel(params)
      pname = params{ll};
      % get index of this param
      idx = find(strcmp(objs(objLoop).names, pname));
      if isempty(idx)
        objs(objLoop).names = [objs(objLoop).names {pname}];
        objs(objLoop).dy     = [objs(objLoop).dy;    errs{ll}];
      else
        objs(objLoop).dy(idx) = errs{ll};
      end
    end
    
    if ~callerIsMethod
      % set output history
      objs(objLoop).addHistory(getInfo('None'), pls, obj_invars(objLoop), objs(objLoop).hist);
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

function plout = getDefaultPlist()
  persistent pl;
  if exist('pl', 'var')==0 || isempty(pl)
    pl = buildplist();
  end
  plout = pl;
end

function pl = buildplist()
  
  pl = plist();
  
  % Params
  p = param({'params', 'A cell-array of parameter names.'}, {1, {'{}'}, paramValue.OPTIONAL});
  pl.append(p);
  
  % Error
  p = param({'errors', 'A cell-array of errors, one for each parameter to set.'}, {1, {'{}'}, paramValue.OPTIONAL});
  pl.append(p);
  
end

