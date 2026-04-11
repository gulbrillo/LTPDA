% WELCHDFT welch method with dft
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% WELCHDFT comput welch'averaged periodogram with dft
% 
% CALL 
% Sf = welchdft(x,fs,f,Ns,olap,navs,order,win,psll)
% Sf = welchdft(x,fs,f,Ns,olap,navs,order,win,[])
% Sf = welchdft(x,fs,f,[],olap,navs,order,win,psll)
% Sf = welchdft(x,fs,f,[],olap,navs,order,win,[])
% 
% 
% INPUT
% 
% - x, data series, Nx1 double
% - fs, sampling frequency Hz, 1x1 double
% - f, frequenci vector Hz, 1x1 double
% - Ns, length of overlapping segments
% - olap, overlap percentage
% - navs, number of desired averages
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
function Sf = welchdft(x,fs,f,Ns,olap,navs,order,win,psll)

  N = numel(x);
  if isempty(olap)
    % compute shift factor
    n = floor((N-Ns)/(navs-1));
  else
    if olap>1
      olap = olap/100;
    end
    % compute Ns
    Ns = floor(N/(olap*(navs-1)+1));
    % compute shift factor
    n = olap*Ns;
  end
  
  Nf = numel(f);
  Sf = zeros(Nf,1);
  
  % run welch averages
  for ii=1:navs
    idx1 = n*(ii-1)+1;
    idx2 = n*(ii-1)+Ns;
    if idx2>N
      break
    end
    seg = x(idx1:idx2);
    
    % get estimate for a segment
    segxx = utils.math.computeDftPeriodogram(seg,fs,f,order,win,psll);
    % update sum
    Sf = Sf + segxx;
  end
  % complete average
  Sf = Sf./navs;








end