% OVERLAPCORR Compute correlation introduced by segment overlapping
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% OVERLAPCORR Compute correlation introduced by segment overlapping in WOSA
% spectral estimations. It estimates the term contributing to the variance
% because of segment overlapping.
% 
% CALL 
% 
% R = utils.math.overlapCorr(w,N,navs,olap)
% 
% INPUT
% 
% - w, window name in LTPDA notation.
% - N total length of data series, 1x1 double
% - navs, number of averages, 1x1 double
% - segments overlap in % units, 1x1 double. E.g. 50
% 
% REFERENCES
% 
% D. B. Percival and A. T. Walden, Spectral Analysis for Physical
% Applications (Cambridge University Press, Cambridge, 1993) p 292.
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varargout = overlapCorr(wname,N,navs,olap)
  


  % For real x, the output in freqency has (nfft/2+1) rows if nfft is even,
  % and (nfft+1)/2 rows if nfft is odd

  % the number of time elements is
  % k = fix((Nx-noverlap)/(length(window)-noverlap))
  % Nx = length(x)

  % Check if the user is asking for a given number of averages
  % If so, the Nfft and the win values are reset based on the
  % calculated value:

  if ~isempty(navs) && navs > 1
    % Compute the number of segments
    if olap>1
      overlap = olap/100;
    else
      overlap = olap;
    end
    
    L = round(N/(navs*(1-overlap) + overlap));

    % Checks it will really obtain the correct answer.
    % This is needed to cope with the need to work with integers
    while fix((N-round(L*overlap))/(L-round(L*overlap))) < navs
      L = L - 1;
    end
    navs_actual = fix((N-round(L*overlap))/(L-round(L*overlap)));
    
    if navs_actual~=navs
      error('Unable to perform calculation with the given navs')
    end

    if L > 0
      % Reset Ns
      Ns = L;
    else
      error('Unable to calculate an appropriate segment length')

    end
    
    ww = specwin(wname, Ns);
    w = ww.win;
    w = w./sqrt(ww.ws2);

    % willing to work with columns
    [nn,mm] = size(w);
    if nn<mm
      w = w.';
    end

    % overlap offset
    n = floor((N-Ns)/(navs-1));
    
    % generate the window segments
    wins = zeros(N,navs);
    
    for ii=1:navs
      wins((ii-1)*n+1:(ii-1)*n+Ns,ii) = w;
    end
    
% version 2    
    R = 0;
    for jj=1:navs-1
      
      R = R + (1-jj/navs)*(abs(wins(:,1).'*wins(:,jj+1))^2);
      
    end

    varargout{1} = 2*R/navs;
    

% version 1
%     R = 0;
%     % run the sum
%     for jj=1:navs-1
%       for kk=jj+1:navs
%       
%         R = R + abs(wins(:,jj).'*wins(:,kk))^2;
%       
%       end
%     end
%     R = 2.*R./navs^2;

% version 0
%     win = [w; zeros((navs-1)*n,1)];
% 
%     R = 0;
%     for kk=1:navs-1
%       ew = zeros(size(win));
%       ew(kk*n+1:kk*n+Ns) = win(1:Ns);
% 
%       R = R + (navs-kk)*abs(win.'*ew)^2;   
%     end
%     R = 2.*R./navs^2;

%     varargout{1} = R;
    
  else
    
    % no averahe no overlap
    varargout{1} = 0;
    
  end
  
  
  

end
