% MOD overloads the modulus function for analysis objects.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: MOD overloads the modulus operator for analysis objects.
%
% CALL:        out = mod(a, val)
%              out = mod(a, plist('axis', 'y',  'value', val))
%
% INPUTS:      a   - Single or vector of analysis objects
%              val - Numeric value
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'mod')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = mod(varargin)
  
  callerIsMethod = utils.helper.callerIsMethod;
  
  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  % Settings
  if callerIsMethod
    aoIn = varargin{1};
    if isa(varargin{2}, 'plist')
      % out = mod(in, plist(...))
      plh    = varargin{2};
      modVal = plh.find_core('value');
      axis   = plh.find_core('axis');
    else
      % out = mod(in, numeric-val)
      plh    = [];
      modVal = varargin{2};
      axis   = 'y';
    end
  else
    
    % Collect input aos and ao variable names
    in_names = cell(size(varargin));
    try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
    
    % Collect all AOs
    [aoIn, ao_invars, rest] = utils.helper.collect_objects(varargin(:), 'ao', in_names);
    [plh, ~, rest]        = utils.helper.collect_objects(rest(:), 'plist');
    
    % Check input arguments number
    if length(aoIn) > 2
      error ('### Incorrect inputs for MOD. Please enter one AO with a PLIST or two AOs.');
    end
    
    % Apply defaults to plist
    plh = applyDefaults(getDefaultPlist(aoIn(1)), plh);
    
    % Get axis from the PLIST
    axis = plh.find_core('axis');
    
    % Get modulus value from the PLIST, AO or inputs
    if ~isempty(rest) && isnumeric(rest{1})
      % out = mod(in, numeric-val)
      modVal = rest{1};
      % Store the value in the history PLIST.
      plh.pset('value', modVal);
      
    else
      % out = mod(in, plist(...))
      modVal = plh.find_core('value');
      
    end
  end
  
  % Decide on a deep copy or a modify
  aoOut = copy(aoIn, nargout);
  
  % Loop over input AOs
  for oo = 1:numel(aoIn)
    
    % Check if 'modVal' is an AO
    if isa(modVal, 'ao')
      modVal = modVal.y;
    end
    
    % Apply MOD to the z-axis
    if any('z' == lower(axis))
      if ~isa(aoOut(oo).data, 'data3D')
        warning('!!! Can not apply MOD to the %d. AO with the name [%s] because it doesn''t have a z-axis -> Skip object.', oo, aoOut(oo).name);
        continue;
      end
      aoOut(oo).data.setZ( mod(aoOut(oo).data.zaxis.data, modVal) );
    end
    % Apply MOD to the x-axis
    if any('x' == lower(axis))
      if ~isa(aoOut(oo).data, 'data2D')
        warning('!!! Can not apply MOD to the %d. AO with the name [%s] because it doesn''t have a x-axis -> Skip object.', oo, aoOut(oo).name);
        continue;
      end
      aoOut(oo).data.setX( mod(aoOut(oo).data.xaxis.data, modVal) );
    end
    % Apply MOD to the y-axis
    if any('y' == lower(axis))
      aoOut(oo).data.setY( mod(aoOut(oo).data.yaxis.data, modVal) );
    end
    
    % Set a new name
    aoName = aoOut(oo).name;
    if isempty(aoName)
      aoName = ao_invars{oo};
    end
    aoOut(oo).name = sprintf('mod(%s, %.2f)', aoName, modVal);
    
    % Add history
    if ~callerIsMethod
      aoOut(oo).addHistory(getInfo('None'), plh, ao_invars(oo), aoIn(oo).hist);
    end
    
  end % loop over analysis objects
  
  % Clear errors
  clearErrors(aoOut, plh);
  
  % Set output
  varargout = utils.helper.setoutputs(nargout, aoOut);
  
end

%--------------------------------------------------------------------------
% Get Info Object
%--------------------------------------------------------------------------
function ii = getInfo(varargin)
  if nargin == 1 && strcmpi(varargin{1}, 'None')
    sets = {};
    pl   = [];
  elseif nargin == 1 && ~isempty(varargin{1}) && ischar(varargin{1})
    sets = varargin(1);
    pl = getDefaultPlist(sets{1});
  else
    sets = {'1D', '2D', '3D'};
    pl = plist.initObjectWithSize(3,1);
    for kk=1:numel(sets)
      pl(kk) = getDefaultPlist(sets{kk});
    end
  end
  % Build info object
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.aop, '', sets, pl);
end

%--------------------------------------------------------------------------
% Get Default Plist
%--------------------------------------------------------------------------

function plout = getDefaultPlist(in)
  
  if ischar(in)
    % The input is a set name
    set = in;
  else
    % The input is an AO and the AO defines the set.
    if isa(in.data, 'data3D')
      set = '3D';
    elseif isa(in.data, 'data2D')
      set = '2D';
    else
      set = '1D';
    end
  end
  
  persistent pl;
  persistent lastset;
  if isempty(pl) || ~strcmp(lastset, set)
    pl = buildplist(set);
    lastset = set;
  end
  plout = pl;
end

function pl = buildplist(set)
  pl = plist.getDefaultAxisPlist(set);
  
  % Remove the keys DIM and OPTION
  pl.remove('DIM', 'OPTION');
  
  % 'value'
  p = param({'value', 'Value for the modulus operation.'}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
end


