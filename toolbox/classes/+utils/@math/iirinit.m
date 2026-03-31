% IIRINIT defines the initial state of an IIR filter.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION
% 
%     iirinit define initial states for an IIR filter finding for the
%     steady state solution of the state quations in state-space
%     representation.
% 
% CALL:
% 
%     zi = iirinit(a,b)
% 
% INPUT:
% 
%     a coefficients vector for the numerator
%     b coefficients vector for the denominator
%       
% 
% OUTPUT:
% 
%     zi vector of filter initial states
% 
% NOTE:
% 
%     zi has to be multiplied by the first value of the time series to be
%     filtered and then can be passed to filter as initial conditions. e.g.
%     [Y,Zf] = FILTER(a,b,X,zi*X(1))
% 
% REFERENCES:
% 
%     <a href="matlab:web('http://autarkaw.com/books/matrixalgebra/index.html', '-browser')">[1] Autar K Kaw, Introduction to Matrix Algebra</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function zi = iirinit(a,b)
  
  na = length(a); % a is numerator
  nb = length(b); % b is denominator
  nfilt = max(nb,na);
  
  % Whant to deal with columns
  if size(a,2)>1
    a = a.';
  end
  if size(b,2)>1
    b = b.';
  end
  
  if nb < nfilt % zero padding if necessary
    b = [b; zeros(nfilt-nb,1)];
  end
  if na < nfilt % zero padding if necessary
    a = [a; zeros(nfilt-na,1)];
  end
  
  A = eye(nfilt-1) - [-b(2:end,1) [eye(nfilt-2);zeros(1,nfilt-2)]];
  B = a(2:end,1) - b(2:end,1).*a(1);
  
  % Checking for the conditioning of A.
  % cond(A)*eps gives the value of the possible relative error in the
  % solution vector. E.g. if cond(A)*eps < 1e-3 the solution can be
  % considered accurate to the third significant digit [1]
  knum = cond(A)*eps('double');
  if knum>1e-3
    warning('MATLAB:illcondsysmatrix','Condition number of the system matrix is larger than 1e-3/eps. Filter initial state will be set to zero.')
    zi = zeros(max(na,nb)-1,1);
  else
    zi = A\B;
  end
  
  nfi = isinf(zi);
  zi(nfi) = 0;
  
  nnn = isnan(zi);
  zi(nnn) = 0;
  
end
 
   