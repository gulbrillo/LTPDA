% HETERODYNE heterodynes time-series.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: HETERODYNE heterodynes time-series.
%
% The input signal is mixed down at the specified frequency. The mixed
% signal is then (optionally) low-pass filtered and (optionally) downsampled 
% to have the specified bandwidth.
%
% CALL:     b = heterodyne(a,pl)
%
% INPUTS:   pl   - a parameter list
%           a    - input analysis object
%
% OUTPUTS:  b    - output analysis object containing the filtered data.
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'heterodyne')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = heterodyne(varargin)
  
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
  
  % Collect all AOs
  [as, ao_invars] = utils.helper.collect_objects(varargin(:), 'ao', in_names);
  
  % Make copies or handles to inputs
  bs   = copy(as, nargout);
  
  % Apply defaults to plist
  pl = applyDefaults(getDefaultPlist, varargin{:});

  
  % Get parameters
  t0 = find_core(pl, 't0');
  f0 = find_core(pl, 'f0');
  if isempty(f0)
    error('### Please specify the heterodyne frequency with the paramter ''f0''');
  end
  mix = find_core(pl, 'quad');
  
  for jj = 1:numel(bs)
    if isa(bs(jj).data, 'tsdata')
      
      % store input history
      inhist = bs(jj).hist;
      
      % check bandwidth
      bw = find_core(pl, 'bw');
      if isempty(bw)
        bw = bs(jj).data.fs;
      end
      if bw > bs(jj).data.fs
        error('### The output bandwidth can not exceed the input bandwidth');
      end
      
      % split the bit requested by user
            % Check the time range.
      time_range = mfind(pl, 'split', 'times');
      if ~isempty(time_range)
        switch class(time_range)
          case 'double'
            bs(jj) = split(bs(jj), plist(...
              'times', time_range));
          case 'timespan'
            bs(jj) = split(bs(jj), plist(...
              'timespan', time_range));
          case 'time'
            bs(jj) = split(bs(jj), plist(...
              'start_time', time_range(1), ...
              'end_time', time_range(2)));
          case 'cell'
            bs(jj) = split(bs(jj), plist(...
              'start_time', time_range{1}, ...
              'end_time', time_range{2}));
          otherwise
        end
      end
      
      % mix at f0
      switch lower(mix)
        case 'cos'
          bs(jj).data.setY(bs(jj).data.getY .* 2.0 .* cos(2*pi * f0 .* (bs(jj).data.getX - t0)));
        case 'sin'
          bs(jj).data.setY(bs(jj).data.getY .* 2.0 .* sin(2*pi * f0 .* (bs(jj).data.getX - t0)));
        otherwise
          error('### Unknown quadrature specified');
      end
      
      
      % user-input filter for low pass
      filt = find_core(pl, 'filter');
      
      % lowpass filter at bw/w
      if ~isempty(filt) || utils.prog.yes2true(find_core(pl, 'lp'))
        if isempty(filt)
          % standard filter for low-pass
          filt = miir(plist('type', 'lowpass', 'order', 4, 'fc', 0.4*bw, 'fs', bs(jj).data.fs));
        end
        bs(jj).filtfilt(filt);
      end
      
      % downsample
      if utils.prog.yes2true(find_core(pl, 'ds'))
        factor = ceil(bs(jj).data.fs / bw);
        bs(jj).downsample(plist('factor', factor));
      end
      
      % set name and history
      bs(jj).name = sprintf('heterodyne(%s, %s@%.01g Hz)', ao_invars{jj}, mix, f0);
      bs(jj).addHistory(getInfo('None'), pl, ao_invars(jj), inhist);
      % clear errors
      bs(jj).clearErrors;
      
    else
      error('### heterodyne only works on time-series AOs currently.');
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
    pl  = [];
  else
    sets = {'Default'};
    pl  = getDefaultPlist;
  end
  % Build info object
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.sigproc, '', sets, pl);
  ii.setModifier(false);
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
  
  % f0
  p = param({'f0', 'The heterodyne frequency in Hz.'}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
  % t0
  p = param({'t0', 'Modulation start time offset in s.'}, paramValue.DOUBLE_VALUE(0));
  pl.append(p);
  
  % quad
  p = param({'quad', 'The quadrature to output. ''sin'' or ''cos''.'},{2, {'sin', 'cos'}, paramValue.SINGLE});
  pl.append(p);
  
  % bw
  p = param({'bw', 'The bandwidth at the output in Hz.'}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
  % lp
  p = param({'lp', 'Low pass filter the output data at ''bw''.'}, paramValue.TRUE_FALSE);
  pl.append(p);
  
  % filter
  p = param({'filter', ['Filter to be used to low pass the output data.<br>' ...
    'If this parameter is set, the low pass is applied regardless to the value of the ''lp'' parameter']}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
  % ds
  p = param({'ds', 'Downsample the output data.'}, paramValue.TRUE_FALSE);
  pl.append(p);
  
  % split, times
  pw = plist.WELCH_PLIST;
  p = pw.params(strcmpi(pw.getKeys, 'Times'));
  pl.append(p);
end
