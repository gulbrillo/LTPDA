% MKALLPASS returns an allpass filter miir(). 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: MKALLPASS returns an allpass filter miir().
%
% CALL:        f = mkallpass(f, pl)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function f = mkallpass(f, pl)
  
  fs     = find_core(pl, 'fs');
  method = find_core(pl, 'method');
  D      = find_core(pl, 'delay');
  N      = find_core(pl, 'N');
  
  % Build filter coefficients
  switch method
    case 'thirlen'
      for k=0:N        
        a(k+1) = (-1.0)^k * factorial(N)/(factorial(k)*factorial(N-k));        
        for n=0:N
          a(k+1) = a(k+1) * (D-N+n)/(D-N+k+n);
        end
      end
      
      a = a/sum(a);
      b(1) = 1;
      
    otherwise
      error(['Unrecognised method [' method ']']);
  end
  
  % Set filter properties
  f.name    = 'bandpass';
  f.fs      = fs;
  f.a       = a;
  f.b       = b;
  f.histin  = zeros(1,f.ntaps-1); % initialise input history
  f.histout = zeros(1,f.ntaps-1); % initialise output history
end

