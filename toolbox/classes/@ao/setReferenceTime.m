% SETREFERENCETIME sets the t0 to the new value but doesn't move the data in time
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: SETREFERENCETIME sets the t0 to the new value but doesn't
%              move the data in time.
%
% CALL:        objs.setReferenceTime(val);
%              objs.setReferenceTime(val1, val2);
%              objs.setReferenceTime(plist('t0', val));
%              objs = objs.setReferenceTime(val);
%
% INPUTS:      objs: Can be a vector, matrix, list, or a mix of them.
%              val:  A time-string or number
%                 1. Single value e.g. '14:00:00'
%                      Each AO in objs get this value.
%                 2. Single value in a cell-array e.g. {4}
%                      Each AO in objs get this value.
%                 3. cell-array with the same number of values as in objs
%                    e.g. {'14:00:00, 5, '15:00:00'} and 3 AOs in objs
%                      Each AO in objs get its corresponding value from the
%                      cell-array
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'setReferenceTime')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = setReferenceTime(varargin)
  
  % Check if this is a call from a class method
  callerIsMethod = utils.helper.callerIsMethod;
  
  if callerIsMethod
    as = varargin{1};
    t0 = varargin{2};
    
    if ~iscell(t0)
      t0 = {t0};
    end
    
    % Replicate the values
    values = cell(size(as));
    values(:) = t0;

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
    
    % Collect all AOs and PLISTs
    [as,  ao_invars, rest] = utils.helper.collect_objects(varargin(:), 'ao', in_names);
    [pls, invars,    rest] = utils.helper.collect_objects(rest(:), 'plist');
    
    % Define property name
    pName = 't0';
    
    % Get values for the AOs
    [as, values] = processSetterValues(as, pls, rest, pName);
    
    % If no values are specified and there are more than one AOs then take
    % the last AO to be the container (y-values).
    if isempty(values) && numel(as) >= 2
      values = {as(end).y};
      as(end) = [];
    end
    
    % Combine input plists and default PLIST
    pls = applyDefaults(getDefaultPlist(), pls);
    
  end % callerIsMethod
  
  % Decide on a deep copy or a modify
  bs = copy(as, nargout);
  
  % Loop over AOs
  for jj = 1:numel(bs)
    bs(jj).data.setToffset(bs(jj).data.toffset - (values{jj}.double - bs(jj).data.t0.double)*1000.0);
    bs(jj).data.setT0(values{jj});
    if ~callerIsMethod
      plh = pls.pset(pName, values{jj});
      bs(jj).addHistory(getInfo('None'), plh, ao_invars(jj), bs(jj).hist);
    end
  end
  
  % Set output
  varargout = utils.helper.setoutputs(nargout, bs);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               Local Functions                               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------
% Get Info Object
%--------------------------------------------------------------------------
function ii = getInfo(varargin)
  
  if nargin == 1 && strcmpi(varargin{1}, 'None')
    sets = {};
    pl   = [];
  else
    sets = {'Default'};
    pl   = getDefaultPlist();
  end
  % Build info object
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.helper, '', sets, pl);
end

%--------------------------------------------------------------------------
% Get Default Plist
%--------------------------------------------------------------------------
function plout = getDefaultPlist()
  persistent pl;
  if ~exist('pl', 'var') || isempty(pl)
    pl = buildplist();
  end
  plout = pl;
end

function pl = buildplist()
  pl = plist({'t0', ['The time to set.<br>' ...
    'You can enter the t0 as a string or as a number. If you want to enter a number please enter this number and convert the type with a right click on the number to a double.']}, ...
    {1, {'14:00:00 10-10-2009'}, paramValue.OPTIONAL});
end
