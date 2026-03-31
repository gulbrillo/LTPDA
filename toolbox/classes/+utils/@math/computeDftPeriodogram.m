% COMPUTEDFTPERIODOGRAM compute periodogram with dft
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% DESCRIPTION
% 
% Define one sided periodogram as:
% Xp(f) = 2*T*|DFT(w(t)*x(t))/T|^2
% Where w(t) are window sameples, which are supposed to be square
% integrable: sum(w(t)^2)=1
% 
% CALL 
% Sf = computeDftPeriodogram(x,fs,f,order,win,psll)
% Sf = computeDftPeriodogram(x,fs,f,order,win,[])
% 
% 
% INPUT
% 
% - x, data series, Nx1 double
% - fs, sampling frequency Hz, 1x1 double
% - f, frequenci vector Hz, 1x1 double
% - order, detrend order, -1,0,1,2,3,4,...
% - win, window name. e.g 'BH92'
% - psll, for Kaiser window only
% 
% REFERENCES
% 
% D. B. Percival and A. T. Walden, Spectral Analysis for Physical
% Applications (Cambridge University Press, Cambridge, 1993) p 291.
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function Sf = computeDftPeriodogram(x,fs,f,order,win,psll)

  
  % detrend segment
  if order < 0
    xd = x; % no detrend
  else
    [xd,coeffs] = ltpda_polyreg(x,order);
  end
  
  N = numel(x);
  
  % get window
  switch lower(win)
    case 'kaiser'
      wnd = specwin('Kaiser', N, psll);
    otherwise
      wnd = specwin(win, N);
  end
  w = wnd.win;
  w = w./sqrt(wnd.ws2);  % compensates for the power of the window.
  
  if size(w)~=size(xd)
    w = w.';
  end
  
  % apply window
  xdw = xd.*w;
  
  T = 1/fs;
  
  Nf = numel(f);
  Sf = zeros(Nf,1);
  for ii=1:Nf
    xx = utils.math.dft(xdw,f(ii),T);
    xx = xx/T;
    Sf(ii) = 2*T*xx*conj(xx);
  end

  

end