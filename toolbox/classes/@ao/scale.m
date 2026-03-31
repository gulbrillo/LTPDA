% SCALE scales the data in the AO by the specified factor.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: SCALE scales the data in the AO by the specified factor.
%
% CALL:        bs = scale(a1,a2,a3,...,pl)
%              bs = scale(as,pl)
%              bs = as.scale(pl)
%
% INPUTS:      aN   - input analysis objects
%              as   - input analysis objects array
%              pl   - input parameter list
% 
% OUTPUTS:     bs   - array of analysis objects, one for each input
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'scale')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = scale(varargin)
  
  import utils.const.*
  
  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  utils.helper.msg(msg.PROC3, 'running %s/%s', mfilename('class'), mfilename);
  
  % Collect input variable names
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
  
  % Collect all AOs
  [as, ao_invars] = utils.helper.collect_objects(varargin(:), 'ao', in_names);
  rest            = utils.helper.collect_objects(varargin(:), 'double', in_names);
  
  % Apply defaults to plist
  pl = applyDefaults(getDefaultPlist, varargin{:});
  
  % Get user specified target units
  target_units = mfind(pl, 'target units');
  scale_units  = ~isempty(target_units);
  
  % Get chosen axis
  axs = find(pl, 'axis');
  switch lower(axs)
    case 'y'
      dataSet  = @setY;
      ddataSet = @setDy;
      unitSet  = @setYunits;
    case 'x'
      dataSet  = @setX;
      ddataSet = @setDx;
      unitSet  = @setXunits;
    otherwise
      error('Unsupported axis %s', axs);
  end
  units = sprintf('%sunits', axs);
  data  = sprintf('%s', axs);
  ddata = sprintf('d%s', axs);
  
  if scale_units
    % Make sure we deal with units
    target_units = unit(target_units);
    
    % Extract the SI component and the scale of the target units
    [target_u, target_scale] = toSI(target_units);
    
    % Set the offset to 0
    offset = 0;
    
    % Set the factor error to empty
    factor_err = [];
    
  else
    
    % Get the factor from the plist
    factor = find_core(pl, 'factor');
    offset = find_core(pl, 'offset');
    
    % Get user specified units
    if ~isempty(find_core(pl, units))
      factor_units = find_core(pl, units);
    else
      factor_units = '';
    end
    
    if isa(factor, 'ao')
      % If the factor is an ao, then also get the units
      if isempty (factor_units)
        factor_units = factor.(units);
      end
      factor_err = factor.(ddata);
      factor     = factor.(data);
    else
      factor_err = [];
    end
    
    offset_units = '';
    if isa(offset, 'ao')
      % If the offset is an ao, then also get the units
      offset_units = offset.(units);
      offset = offset.(data);
    end
    
    
    % look in rest
    if factor == 1 && ~isempty(rest)
      switch class(rest)
        case 'cell'
          factor = rest{1};
        otherwise
          factor = rest;
      end
    end
    
    % now check we got a factor
    if isempty(factor) || ~isnumeric(factor) || numel(factor) ~= 1
      error('### The factor must be a single numeric value.');
    end
    
    % Set the factor to the plist.
    % It might be that the factor was not in the plist
    pl.pset('factor', factor, units, factor_units);
      
  end
  
  % Decide on a deep copy or a modify
  bs = copy(as, nargout);
  
  
  % Apply method to all AOs
  for kk = 1:numel(bs)
    
    if scale_units
      % Extract the SI component and the scale of the input data units
      [data_u, data_scale]     = toSI(bs(kk).(units));
      
      % Check units are SI equivalent
      if ~isequal(data_u, target_u)
        error('The object units %s and target units %s are not equivalent according to SI.', ...
          char(bs(kk).(units)), char(target_units));
      end
      
      % Calculate the scale factor
      factor = data_scale ./ target_scale;

      % Set units
      feval(unitSet, bs(kk).data, target_units);

    else
      % Set units
      if ~isempty(factor_units)
        feval(unitSet, bs(kk).data, ...
          simplify(unit(factor_units) .* bs(kk).data.(units), ...
          plist('prefixes', false)));
      end
      
      % check the offset units
      if ~isempty(offset_units) && ~eq(offset_units, bs(kk).(units))
        error('The offset units must match the scaled AO units [%s]', char(bs(kk).(units)));
      end
      
    end
    
    % Apply scale factor
    o = bs(kk).data.(sprintf('get%s', upper(data))) .* factor + offset;
    if ~isempty(factor_err)
      do = sqrt((bs(kk).data.(ddata) .* factor).^2 + (bs(kk).data.(data) .* factor_err).^2 + (bs(kk).data.(ddata) .* factor_err).^2);
    else
      do = bs(kk).data.(ddata) .* factor;
    end
    feval(dataSet, bs(kk).data, o);
    feval(ddataSet, bs(kk).data, do);
    
    % set name
    bs(kk).name = sprintf('(%s.*%g)', ao_invars{kk}, factor);

    % add history
    bs(kk).addHistory(getInfo('None'), pl, ao_invars(kk), as(kk).hist);
  end
  
  
  % Set output
  varargout = utils.helper.setoutputs(nargout, bs);
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
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.op, '', sets, pl);
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
  
  pl = plist();
  
  p = param({'factor', ['The factor to scale by.<br>', ...
    'It can be a double or an ao. In this latter case, the units will be multiplied as well']}, paramValue.DOUBLE_VALUE(1));
  pl.append(p);
  
  p = param({'offset', ['An offset to add to the scaled AO.<br>', ...
    'It can be a double or an ao. In this latter case, the units must match the scaled AO']}, paramValue.DOUBLE_VALUE(0));
  pl.append(p);
  
  p = param({'yunits', ['Set a value for the scale factor units;<br>', ...
    'empty => output object will have the same units as input.<br>', ...
    'Note: these units will override those from the scale factor, if the user specified it as an ao!']}, paramValue.EMPTY_STRING);
  pl.append(p);

  p = param({'xunits', ['Set a value for the scale factor units;<br>', ...
    'empty => output object will have the same units as input.<br>', ...
    'Note: these units will override those from the scale factor, if the user specified it as an ao!']}, paramValue.EMPTY_STRING);
  pl.append(p);
  
  p = param({'target units', ['The target units to scale the objects for.<br>', ...
    'If these are set, the ''factor'' will be ignored and the data will be scaled accordingly.']}, paramValue.EMPTY_DOUBLE);
  p.addAlternativeKey('output units');
  pl.append(p);
  
  p = param({'axis', 'The axis on which to apply the method.'},  ...
    {2, {'x', 'y', 'xy'}, paramValue.SINGLE});
  pl.append(p);
  
  
end

% END
