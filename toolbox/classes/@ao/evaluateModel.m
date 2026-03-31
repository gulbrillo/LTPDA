% EVALUATEMODEL evaluate a curvefit model.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: EVALUATEMODEL evaluate a curvefit model.
%
% CALL:        b = evaluateModel(a, pl)
%
% INPUTS:      a  - input AO(s) containing parameter values. The parameter
%                   values are collected from the Y data of all input cdata
%                   AOs. The most common approach would be one AO per
%                   parameter, or a single AO with all parameters in.
%              pl - parameter list (see below)
%
% OUTPUTs:     b  - an AO containing the model evaluated at the give X
%                   values, with the given parameter values.
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'evaluateModel')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = evaluateModel(varargin)
  
  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  import utils.const.*
  utils.helper.msg(msg.PROC3, 'running %s/%s', mfilename('class'), mfilename);
  
  warning(['The method ''ao/curvefit'' and ''ao/evaluateModel'' have been replaced by ''ao/xfit'' and ''pest/eval''.' ...
    'They are no longer maintained and will be removed from future releases of LTPDA Toolbox.']);
  
  % Collect input variable names
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
  
  % Collect all AOs and plists
  [as, ao_invars] = utils.helper.collect_objects(varargin(:), 'ao', in_names);
  pl              = utils.helper.collect_objects(varargin(:), 'plist', in_names);
  
  %%% Decide on a deep copy or a modify
  bs = copy(as, nargout);

  % Each of the input AOs should be a cdata AO; from these we get the
  % parameter values
  P = [];
  for kk=1:numel(bs)
    if isa(bs(kk).data, 'cdata')
      P = [P; bs(kk).data.y(:)];
    else
      warning('!!! AO %s is not a cdata AO. Not using for parameter values.', bs(kk).name);
    end
  end
  
  % combine plists
  pl = applyDefaults(getDefaultPlist(), pl);
  
  % Extract necessary parameters
  targetFcn = find_core(pl, 'Function');
  ADDP      = find_core(pl, 'ADDP');
  dtype     = find_core(pl, 'dtype');
  Xdata     = find_core(pl, 'Xdata');
  if isa(Xdata, 'ao')
    Xdata = Xdata.x;
  end
  
  
  if ~iscell(ADDP)
    ADDP = {ADDP};
  end
  
  % Check parameters
  if isempty(targetFcn)
    error('### Please specify a target function');
  end
  if isempty(P)
    error('### Please give values for the parameters');
  end
  
  % Make an anonymous function of the target function
  cmd = sprintf('tfunc = @(P,Xdata,ADDP)(%s);', targetFcn);
  eval(cmd);
  % Evaluate function at best fit
  Y = tfunc(P, Xdata, ADDP);
  if isa(Y, 'ao')
    Y = Y.y;
  end
  
  % Make new output AO
  switch lower(dtype)
    case 'tsdata'
      out = ao(tsdata(Xdata,Y));
      out.data.setXunits(unit.seconds);
    case 'fsdata'
      out = ao(fsdata(Xdata,Y));
      out.data.setXunits(unit.Hz);
    case 'xydata'
      out = ao(xydata(Xdata,Y));
    otherwise
      error('### Unknown data type specified. Choose from xydata, fsdata, or tsdata');
  end
  
  % Set output AO name
  name = sprintf('eval(%s,', targetFcn);
  for kk=1:numel(bs)
    name = [name bs(kk).name ','];
  end
  name = [name(1:end-1) ')'];
  out.name = name;
  % Add history
  out.addHistory(getInfo('None'), pl, ao_invars, [bs(:).hist]);
  
  % Set outputs
  if nargout > 0
    varargout{1} = out;
  end
end


%--------------------------------------------------------------------------
% Get Info Object
%--------------------------------------------------------------------------
function ii = getInfo(varargin)
  if nargin == 1 && strcmpi(varargin{1}, 'None')
    sets = {};
    pl   = [];
  else
    sets = {'Default'};
    pl   = getDefaultPlist;
  end
  % Build info object
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.sigproc, '', sets, pl);
end

%--------------------------------------------------------------------------
% Get Default Plist
%--------------------------------------------------------------------------
function plout = getDefaultPlist()
  persistent pl;  
  if exist('pl', 'var')==0 || isempty(pl)
    pl = buildplist();
  end
  plout = pl;  
end

function pl = buildplist()

  pl = plist();
  
  % Function
  p = param({'Function', ['The function to evaluate. <br>'...
                          'The function should be parameterized by the vector of '...
                          'parameters P, the cell-array ADDP, and the '...
                          'x-vector Xdata.'...
                          ]}, paramValue.EMPTY_STRING);
  pl.append(p);
  
  % ADDP
  p = param({'ADDP', 'A cell-array of additional parameters to pass to the target function'}, ...
    {1, {{}}, paramValue.OPTIONAL});
  pl.append(p);
  
  % DTYPE
  p = param({'dtype', 'The data type to interpret this model as.'}, {1, {'xydata', 'fsdata', 'tsdata'}, paramValue.SINGLE});
  pl.append(p);
  
  % XDATA
  p = param({'Xdata', ['The X values to evaluate the model at.<br>'...
                       'This can be a vector or an AO (from which the Xdata will '...
                       'be extracted).']}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
  
end
% END
