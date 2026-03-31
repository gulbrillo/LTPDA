% SETSUBFUNCS sets the 'subfuncs' property of a mfh object.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: SETSUBFUNCS sets the 'subfuncs' property of a mfh object.
%
% CALL:        obj = setSubfuncs(obj, val)
%              obj = obj.setSubfuncs(plist('subfuncs', val);
%
% INPUTS:      obj: mfh object(s)
%              val: Single object or a array of objects
%
% <a href="matlab:utils.helper.displayMethodInfo('mfh', 'setSubfuncs')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = setSubfuncs(varargin)
  
  % Check if this is a call from a class method
  callerIsMethod = utils.helper.callerIsMethod;
  
  if callerIsMethod
    obj   = varargin{1};
    values = [varargin{2:end}];
    
  else
    % Check if this is a call for parameters
    if utils.helper.isinfocall(varargin{:})
      varargout{1} = getInfo(varargin{3});
      return
    end
    
    import utils.const.*
    utils.helper.msg(msg.PROC3, 'running %s/%s', mfilename('class'), mfilename);
    
    % Collect input variable names
    in_names = cell(size(varargin));
    try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
    
    % Collect all pzmodel objects
    [obj,  mfh_invars, rest] = utils.helper.collect_objects(varargin(:), 'mfh', in_names);
    pls = utils.helper.collect_objects(rest(:), 'plist');
    
    % If pls contains only one plist with the single key of the property name
    % then set the property with a plist.
    if length(pls) == 1 && isa(pls, 'plist') && isparam_core(pls, 'subfuncs')
      values = find_core(pls, 'subfuncs');
    elseif numel(obj) >= 2
      values = obj(2:end);
      obj   = obj(1);
    end
    
    % Combine input plists and default PLIST
    pls = applyDefaults(getDefaultPlist(), pls);
    
  end % callerIsMethod
  
  % Check if we have only one
  if numel(obj) ~= 1
    error('### You can set the subfuncs only to one mfh object.');
  end
  
  % Decide on a deep copy or a modify
  obj = copy(obj, nargout);
  
  obj.subfuncs = values;
  if ~callerIsMethod
    plh = pls.pset('subfuncs', values);
    obj.addHistory(getInfo('None'), plh, mfh_invars(1), obj.hist);
  end
  
  % reset cached properties
  obj.resetCachedProperties();

  % set outputs
  varargout = utils.helper.setoutputs(nargout, obj);
  
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               Local Functions                               %
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

function plout = getDefaultPlist()
  persistent pl;
  if exist('pl', 'var')==0 || isempty(pl)
    pl = buildplist();
  end
  plout = pl;
end

function pl = buildplist()
  pl = plist({'subfuncs', 'The sub-functions to set.'}, paramValue.EMPTY_DOUBLE);
end

