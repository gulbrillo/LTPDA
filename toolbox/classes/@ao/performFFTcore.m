% performFFTcore performs fft for flscov and flscovSegments
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varargout = performFFTcore(varargin)
  
  ts_s      = varargin{1};
  N_ts      = varargin{2};
  nSegments = varargin{3};
  freqs     = varargin{4};
  pl        = varargin{5};
  
  % initialise
  fs   = ao.initObjectWithSize(N_ts, nSegments);
  
  % Define fft plist
  plfft = plist('win',         pl.find('win'),'scale',0);
  fpl   = plist('frequencies', freqs);
  
  % Compute scale factor to compensate for the window power
  win     = pl.find_core('win');
  nfs     = numel(ts_s(1,1).y);
  winVals = specwin(win, nfs).win.';
  K       = sqrt(winVals'*winVals);
  
  % Loop over segments
  for ii = 1:N_ts
    fft_ts = fft(ts_s(ii,:), plfft);
    if isempty(freqs)
      fpl.pset('frequencies', [fft_ts(1).x(1) fft_ts(1).x(end)]);
    end
    fs(ii,:) = fft_ts;
  end
  
  % Scale to window power
  fs = fs/K;
  
  % Scale fft to PSD
  scale_factor = ao(plist('yvals',ts_s(1,1).fs,'yunits','Hz'));
  fs = fs./sqrt(scale_factor);
  
  varargout{1} = fs;
  
end
