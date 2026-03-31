% PAD pads the input data series to a given value.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: PAD pads the input data series to a given value.
%
% CALL:        b = pad(a, pl)
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'pad')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = pad(varargin)
  
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
  
  % Collect all AOs and plists
  [as, ao_invars] = utils.helper.collect_objects(varargin(:), 'ao', in_names);
  pl              = utils.helper.collect_objects(varargin(:), 'plist', in_names);
  
  %%% Decide on a deep copy or a modify
  bs = copy(as, nargout);
  
  % combine plists
  pl = applyDefaults(getDefaultPlist(), pl);
  
  % Extract necessary parameters
  factor = find_core(pl, 'Factor');
  N      = find_core(pl, 'N');
  pos    = find_core(pl, 'position');
  padVal = find_core(pl, 'values');
  
  if isempty(factor) && isempty(N)
    error('### Specify either a padding Factor, or a number of samples.');
  end
  
  % Loop over input AOs
  for jj = 1:numel(bs)
    if ~isa(bs(jj).data, 'tsdata')
      error('Padding only works on time-series. AO %s is not a time-series.', ao_invars{jj});
    else
      % Check the time-series is evenly samples
      if ~isempty(bs(jj).data.x)
        error('### Padding only makes sense on evenly sampled time-series. Resample first.');
      end
      
      % clear errors
      bs(jj).clearErrors;
      % Get y-values
      y = bs(jj).data.getY;
      s = size(y);
      
      % Check here which padding function we want:
      % 1. Values from PLIST
      % 2. By a factor
      % 3. By number of samples
      
      if numel(padVal) > 1

        %%%%%%%%%%   Padding with given value from the PLIST
        pads = padVal;
        numNewVals = numel(padVal);
        
      elseif isempty(N)

        %%%%%%%%%%   Padding with a factor.
        % Check the 'factor'
        if rem(factor, 1) ~= 0, error('### The padding factor (%.2f) must be an integer.', factor); end
        if factor < 2, error('### Padding factor must be >= 2'); end
        
        % Calculate the padding values
        pads = repmat(ones(s) * padVal, factor-1, 1);
        numNewVals = (factor-1) * s(1);
        
      else
        
        %%%%%%%%%%   Padding with number of samples 'N'
        % Check the number of samples 'N'
        if rem(N, 1) ~= 0, error('### The number of samples N (%.2f) must be an integer.', N); end
        if N <= 0, error('### Number of samples to pad must be > 0'); end
        
        % Calculate the padding values
        pads = ones(N, 1) * padVal;
        numNewVals = N;
      end
      
      % Add the padding values to the AO
      if strcmpi(pos, 'pre')
        bs(jj).data.setY([pads; y]);
        bs(jj).data.setToffset(bs(jj).data.toffset - numNewVals / bs(jj).data.fs * 1000);
      elseif strcmpi(pos, 'post')
        bs(jj).data.setY([y; pads]);
      else
        error('Unknown ''position'' to pad. Choose either ''pre'' or ''post'' for the ''position'' value.');
      end
      
      % Set name
      bs(jj).name = sprintf('pad(%s)', ao_invars{jj});
      % Correct Nsecs
      bs(jj).data.fixNsecs;
      % Add history
      bs(jj).addHistory(getInfo('None'), pl, ao_invars(jj), bs(jj).hist);
      
    end
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
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.sigproc, '', sets, pl);
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
  
  % Factor
  p = param({'Factor', 'Pad to <Factor> times the input data length.'}, paramValue.DOUBLE_VALUE(2));
  pl.append(p);
  
  % N
  p = param({'N', 'Pad with N samples.'}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
  % Position
  p = param({'Position', 'Where to pad: before or after.'}, {2, {'pre', 'post'}, paramValue.SINGLE});
  pl.append(p);
  
  % Values, Value
  p = param({'values', 'Value(s) for the padding'}, paramValue.DOUBLE_VALUE(0));
  p.addAlternativeKey('value');
  pl.append(p);
  
end
% END
