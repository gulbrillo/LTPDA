% DELAY delays a time-series using various methods.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: DELAY delays a time-series using various methods.
%
% CALL:        b = delay(a, pl)
%              b = delay(a, tau) % in this case, fft filtering is used
%
% Time-series can be delayed either by an integer numbers of samples, or a
% time, depending on the method chosen. For delaying by an explicit time,
% you can use the fft filtering method, or a fractional delay filtering
% method.
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'delay')">Parameters Description</a>
%
% EXAMPLES:    1) Shift by 10 samples and zero pad the end of the time-series
%                 >> b = delay(a, plist('N', 10, 'method', 'zero'));
%
%              2) Shift by 0.1 seconds
%                 >> b = delay(a, plist('mode', 'fftfilter', 'tau', 0.1));
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% TODO
%                        'extrap' - extrapolate the last N samples

% Caller Is Method:
%
% CALL:
%          out = delay(obj, filter)
%

function varargout = delay(varargin)
  
  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  callerIsMethod = utils.helper.callerIsMethod;
  
  % Collect input variable names
  N    = [];
  if callerIsMethod
    
    in_names = {};
    
    % assume a call delay(ao, tau)
    as   = varargin{1};
    tau  = varargin{2};
    if isa(tau, 'plist')
      pl = applyDefaults(getDefaultPlist, tau);
      N      = find_core(pl, 'N');
      method = find_core(pl, 'method');
      mode   = find_core(pl, 'mode');
      tau    = find_core(pl, 'tau');
    elseif isnumeric(tau)
      mode = 'fftfilter';
    elseif isa(tau, 'ao')
      mode = 'fftfilter';
      tau  = double(tau);
    else
      error('Unknown usage of delay');
    end
    
  else
    import utils.const.*
    utils.helper.msg(msg.PROC3, 'running %s/%s', mfilename('class'), mfilename);
    
    in_names = cell(size(varargin));
    try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
    
    % Collect all AOs
    [as, ao_invars, rest] = utils.helper.collect_objects(varargin(:), 'ao', in_names);
    
    % Apply defaults to plist
    pl = applyDefaults(getDefaultPlist, varargin{:});
    
    %----------- Get parameters
    
    if ~isempty(rest) && isnumeric(rest{1})
      tau = rest{1};
      mode = 'fftfilter';
      pl.pset('mode', 'fftfilter');
      pl.pset('tau', tau);
    else
      % 1: Sample shift
      N      = find_core(pl, 'N');
      method = find_core(pl, 'method');
      mode   = find_core(pl, 'mode');
      tau    = pl.find_core('tau');
    end
  end
  
  % Decide on a deep copy or a modify
  bs = copy(as, nargout);
  
  % try to make uniform parameters here
  if ~isempty(N) && tau == 0
    tau = N;
  end
  
  % Loop over AOs
  for jj=1:numel(bs)
    if ~isa(bs(jj).data, 'tsdata')
      warning('!!! Skipping object %s - it contains no tsdata.', ao_invars{jj});
    else
      
      if tau ~= 0
        
        switch lower(mode)
          case 'sample'
            
            % Which method to use
            switch lower(method)
              case 'zero'
                bs(jj).data.setY([zeros(tau,1); bs(jj).data.getY(1:end-tau)]);
              otherwise
                error('### Unknown method for dealing with end of time-series.');
            end
            
          case 'fftfilter'
            
            vals = utils.math.fftdelay_core(bs(jj).y,tau,bs(jj).data.fs);
            bs(jj).data.setY(vals);
            
          case 'timedomain'
            
            vals = ao.delay_fractional_core(bs(jj).y, double(tau) , 1/bs(jj).data.fs);
            bs(jj).data.setY(vals);
            
          case 'fdfilter'
            wind = lower(pl.find_core('window'));
            taps = lower(pl.find_core('taps'));
            D = double(tau*bs(jj).data.fs);
            vals = utils.math.fdfilt_delay_core(bs(jj).y,D,taps,wind);
            bs(jj).data.setY(vals);
            
          otherwise
            error('Unknown delay mode [%s]', mode);
        end
        
      end
      
      if ~callerIsMethod
        % make output analysis object
        bs(jj).name = sprintf('delay(%s)', ao_invars{jj});
        % Add history
        bs(jj).addHistory(getInfo('None'), pl, ao_invars(jj), bs(jj).hist);
      end
      
      % Clear the errors since they don't make sense anymore
      clearErrors(bs(jj));
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
  
  % mode
  p = param({'mode', 'The mode to use to delay the data.'}, {1, {'sample', 'fftfilter', 'timedomain','fdfilter'}, paramValue.SINGLE});
  pl.append(p);
  
  % tau
  p = param({'tau', 'The delay time (s) for use in the ''fftfilter'', ''timedomain'', and ''fdfilter'' delay modes.'}, paramValue.DOUBLE_VALUE(0));
  pl.append(p);
  
  % N
  p = param({'N', 'The number of samples to delay by (for use in ''sample'' delay mode).'}, {1, {0}, paramValue.OPTIONAL});
  pl.append(p);
  
  % Method
  p = param({'method', 'The method for handling the end of the time-series when using the ''sample'' mode.'}, {1, {'zero'}, paramValue.SINGLE});
  pl.append(p);
  
  % window
  p = param({'window', 'The window to use for the ''fdfilter'' delay mode.'}, {2, {'blackman', 'blackman3', 'lagrange'}, paramValue.SINGLE});
  pl.append(p);
  
  % Taps
  p = param({'taps', 'The number of taps used in the ''fdfilter'' delay mode.'}, {1, {51}, paramValue.OPTIONAL});
  pl.append(p);
  
  
end
