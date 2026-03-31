% PPSD makes power spectral density estimates of the time-series objects in the input analysis objects by estimating ARMA models coefficients.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   
% DESCRIPTION: PPSD makes power spectral density estimates of the
%              time-series objects in the input analysis objects
%              by estimating ARMA models coefficients. The coefficients
%              are stored in the procinfo plist of the output objects.
%
% CALL:        bs = ppsd(a1,a2,a3,...,pl)
%              bs = ppsd(as,pl)
%              bs = as.ppsd(pl)
%
% INPUTS:      aN   - input analysis objects
%              as   - input analysis objects array
%              pl   - input parameter list
%
% OUTPUTS:     bs   - array of analysis objects, one for each input
%
%<a href="matlab:utils.helper.displayMethodInfo('ao','ppsd')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varargout = ppsd(varargin)

callerIsMethod = utils.helper.callerIsMethod;
  
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
  
  % Decide on a deep copy or a modify
  bs = copy(as, nargout);
  
  inhists = [];
  
  % Apply defaults to plist
  usepl = applyDefaults(getDefaultPlist, varargin{:});
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
 
  % Loop over input AOs
  for jj = 1 : numel(bs)
   % gather the input history objects
   inhists = [inhists bs(jj).hist];

   if isa(bs(jj).data, 'tsdata') 
     
    time_range = mfind(usepl, 'split', 'times');
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
    
    % Check the length of the object
    if bs(jj).len <= 0
      error('### The object is empty! Please revise your settings ...');
    end
      
    % set default model order
    method = find_core(usepl, 'method');
    p = find_core(usepl,'order');
    if (isempty(p) && strcmp(method , 'ARMA'))
      error('### Please provide the order of the model...')
    elseif isempty(p)
      p = length(bs(jj).x) - 1;
    elseif (size(p,2) == 1 && strcmp(method , 'ARMA'))
      error('### Please provide the order of the model. (1x2 vector)')
    end
     
    switch method
      case 'AR'
        data = bs(jj).y;
        fs = bs(jj).fs;
        % solve Yule-walker equations
        [A , sigma] = aryule(data,p(1));
        
        % Check sigma
        if sigma<0,
           error(['### The variance estimate of the white noise input to the AR model is negative. '...
             'Consider lowering the order of the model.']);
        end
        
        N = length(data);
        B = 1; 
        [h , F] = freqz(B,A,N,'whole',fs);
        
        Sxx = sigma*abs(h).^2;
        
        % Compute frequencies
        f = psdfreqvec('npts', N,'Fs', fs, 'Range', 'half').';
      
        % get scale of spectrum
        scale = find_core(usepl, 'Scale');
        [Pxx, info] = scaling( Sxx, N, fs, f, scale, bs(jj).data.yunits);
        
      case 'ARMA'
        error('### Sorry! Not implemented yet :D ...');
      case 'MA'
        error('### Sorry! Not implemented yet :D ...');
      otherwise
        error('### Sorry! You must choose one of the available methods ...');  
    end
    
      % create new output fsdata
      fs = bs(jj).fs;
      fsd = fsdata(f, Pxx, fs);
      fsd.setXunits(unit.Hz);
      fsd.setYunits(info.units);
      fsd.setT0(bs(jj).data.t0+bs(jj).x(1));
      % update AO
      bs(jj).data = fsd;
      % add sigma
      bs(jj).data.setDy(sigma);
      % set name: scaling of spectrum
      scale = upper(find_core(usepl, 'Scale'));
      bs(jj).name = sprintf('%s(%s)', scale, ao_invars{jj});
      % Passing coefficients to the procinfo plist
      bs(jj).procinfo = plist('Order',p,'A',A,'B',B);
      % Add history
      if ~callerIsMethod
        bs(jj).addHistory(getInfo('None'), usepl, ao_invars(jj), inhists(jj));
      end 
 
   else
      warning('### Ignoring input AO number %d (%s); it is not a time-series.', jj, bs(jj).name)
   end
  end 
  
  % Set output
  varargout = utils.helper.setoutputs(nargout, bs);
end


function [yy, info] = scaling(xx, N, fs, f, norm, inunits)
  
  df = f(2)-f(1);
  enbw = 4 * fs / (N/2)^2 / df;

  if isempty(norm)
    norm = 'None';
  end
  switch lower(norm)
    case 'asd'
      y = scaleToPSD(xx,N,fs);
      yy = sqrt(y);
      info.units = inunits ./ unit('Hz^0.5');
    case 'psd'
      yy = scaleToPSD(xx,N,fs);  
       %[Sxx,F,units] = computepsd(Sxx,F,range,N,fs,scale);
       info.units = inunits.^2 / unit.Hz;
    case 'as'
      y = scaleToPSD(xx,N,fs);
      yy = sqrt(y * enbw);
      info.units = inunits;
    case 'ps'
      y = scaleToPSD(xx,N,fs);
      yy = y * enbw;
      info.units = inunits.^2;
    case 'none'
      yy = xx;
      info.units = inunits;
    otherwise
      error('Unknown normalisation');
  end
  
  info.nfft = N;
  info.norm = norm;
  
end

% scale averaged periodogram to PSD
function Pxx = scaleToPSD(Sxx, nfft, fs)
  
  % Take 1-sided spectrum which means we double the power in the
  % appropriate bins
  if rem(nfft,2),
    indices = 1:(nfft+1)/2;  % ODD
    Sxx1sided = Sxx(indices,:);
    % double the power except for the DC bin
    Sxx = [Sxx1sided(1,:); 2*Sxx1sided(2:end,:)];  
  else
    indices = 1:nfft/2+1;    % EVEN
    Sxx1sided = Sxx(indices,:);
    % Double power except the DC bin and the Nyquist bin
    Sxx = [Sxx1sided(1,:); 2*Sxx1sided(2:end-1,:); Sxx1sided(end,:)];
  end

  % Now scale to PSD
  Pxx   = Sxx./fs;
  
end

function ii = getInfo(varargin)
  if nargin == 1 && strcmpi(varargin{1}, 'None')
    sets = {};
    pl   = [];
  else
    sets = {'Default'};
    pl   = getDefaultPlist();
  end
  % Build info object
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.sigproc, '', sets, pl);
end

function plout = getDefaultPlist()
  persistent pl;  
  if ~exist('pl', 'var') || isempty(pl)
    pl = buildplist();
  end
  plout = pl;  
end

function pl = buildplist()

  pl = plist();
  
  % Method
  p = param({'method','Model type to use and estimate its coefficients.'}, {1, {'AR', 'MA', 'ARMA'}, paramValue.SINGLE});
  pl.append(p);
  
  % Order
  p = param({'order',['Order of the applied filter. If the method chosen is ',...
    '''ARMA'', then a vector of 1x2 size must be provided containing the orders AR and MA models. ',...
    '(example: [ p q ]). <ul><li>If no order is specified, then p = q = length(X) - 1;</li></ul>']}, {1, {[]}, paramValue.OPTIONAL});
  pl.append(p);
  
  % Times
  p = param({'times','The time range to analyze. If not empty, sets the time interval to operate on.'}, {1, {[]}, paramValue.OPTIONAL});
  pl.append(p);
  
  % Times
  p = param({'split',['The time range to analyze. If not empty, sets the time',... 
    'interval to operate on.<br>As in ao/split, the interval can be specified',...
    'by:<ul><li>a vector of doubles</li><li>a timespan object</li><li>a cell',... 
    'array of time strings</li><li>a vector of time objects</li></ul>']}, {1, {[]}, paramValue.OPTIONAL});
  pl.append(p);
  
  % Scale
  p = param({'Scale',['The scaling of output. Choose from:<ul>', ...
    '<li>PSD - Power Spectral Density</li>', ...
    '<li>ASD - Amplitude (linear) Spectral Density</li>', ...
    '<li>PS  - Power Spectrum</li>', ...
    '<li>AS  - Amplitude (linear) Spectrum</li></ul>']}, {1, {'PSD', 'ASD', 'PS', 'AS'}, paramValue.SINGLE});
  pl.append(p);
    
end
