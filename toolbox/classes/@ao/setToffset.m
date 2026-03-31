% SETTOFFSET sets the 'toffset' property of the ao with tsdata
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: SETTOFFSET sets the 'toffset' property of the ao with tsdata
%
% CALL:        objs.setToffset(val);
%              objs.setToffset(plist('toffset', val));
%              objs = objs.setToffset(val);
%
% INPUTS:      objs: Can be a vector, matrix, list, or a mix of them.
%              val:  In seconds
%                 1. Single value e.g. [2]
%                      Each AO in objs get this value.
%                 2. Single value in a cell-array e.g. {12.1}
%                      Each AO in objs get this value.
%                 3. cell-array with the same number of values as in objs
%                    e.g. {7, 5, 12.2} and 3 AOs in objs
%                      Each AO in objs get its corresponding value from the
%                      cell-array
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'setToffset')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = setToffset(varargin)
  
  % Check if this is a call from a class method
  callerIsMethod = utils.helper.callerIsMethod;
  
  if callerIsMethod
    as      = varargin{1};
    toffset = varargin(2);
        
    % Replicate the values
    values = cell(size(as));
    values(:) = toffset;

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
    pName = 'toffset';
    
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
    if isa(bs(jj).data, 'tsdata')
      bs(jj).data.setToffset(values{jj}*1e3);
      if ~callerIsMethod
        plh = pls.pset(pName, values{jj});
        bs(jj).addHistory(getInfo('None'), plh, ao_invars(jj), bs(jj).hist);
      end
    else
      error('### Set toffset works only for time series data AOs');
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
  pl = plist({'toffset', 'Time offset from t0 to the first data sample in seconds.'}, paramValue.DOUBLE_VALUE(NaN));
end
