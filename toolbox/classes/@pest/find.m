% FIND Creates analysis objects from the selected parameter(s).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: FIND Creates analysis objects from the selected
%              parameter(s).
%
% CALL:        obj = obj.find();
%              obj = obj.find('a');
%              obj = obj.find('a', 'b');
%              obj = obj.find(plist('params', {'a', 'b'}))
%
% INPUTS:      obj - one pest model.
%              pl  - parameter list
%
% <a href="matlab:utils.helper.displayMethodInfo('pest', 'find')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = find(varargin)
  
  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  %%% Collect input variable names
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
  
  [objs, obj_invars, rest] = utils.helper.collect_objects(varargin(:), 'pest', in_names);
  [pls,  invars, rest]     = utils.helper.collect_objects(rest(:), 'plist');
  
  inParams = {};
  out      = [];
  %%% If pls contains only one plist with the key 'params' then set the
  %%% property with a plist.
  if length(pls) == 1 && isa(pls, 'plist') && pls.nparams == 1 && pls.isparam_core('params')
    inParams = find(pls, 'params');
    if ~iscell(inParams)
      inParams = {inParams};
    end
  end
   
  if ~iscellstr(rest)
    % try to convert to a string. This allows us to support any class which
    % can return a string from char(), for example, LPFParam.
    rest = cellfun(@char, rest, 'UniformOutput', false);
  end
  
  inParams = [inParams rest];
  
  for objLoop = 1:numel(objs)
    
    %%% decide whether we modify the input pest object, or create a new one.
    objs(objLoop) = copy(objs(objLoop), nargout);
    
    %%% Create from each parameter an AO if the user doesn't specify a
    %%% parameter name.
    if isempty(inParams)
      params = objs(objLoop).names;
    else
      params = inParams;
    end
    
    for ll=1:numel(params)
      pname = char(params{ll});
      
      % get index of this param
      idx = find(strcmp(objs(objLoop).names, pname), 1);
      if isempty(idx)
        % Do nothing because it is not possible to create an AO from a not
        % existing parameter name.
      else
        a = ao(objs(objLoop).y(idx));
        a.setName(pname);
        if ~isempty(objs(objLoop).dy)
          a.setDy(objs(objLoop).dy(idx));
        end
        if ~isempty(objs(objLoop).yunits)
          a.setYunits(objs(objLoop).yunits(idx));
        end
        if idx <= numel(objs(objLoop).models)
          a.setProcinfo(plist('model', objs(objLoop).models.index(idx)));
        else
          a.setProcinfo(plist('model', objs(objLoop).models));
        end
        if ~utils.helper.callerIsMethod
          a.addHistory(pest.getInfo('find', 'None'), plist('params', pname), obj_invars(objLoop), objs(objLoop).hist);
        end
        out = [out a];
      end
    end
    
  end
  
  %%% Set output
  if nargout == numel(out)
    % List of outputs
    for ii = 1:numel(out)
      varargout{ii} = out(ii);
    end
  else
    % Single output
    varargout{1} = out;
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

end

