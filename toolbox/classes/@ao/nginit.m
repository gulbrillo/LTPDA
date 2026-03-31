% NGINIT is called by the function fromPzmodel
% it takes the matrix Tinit (calculated by NGSETUP) as input
% and returns the initial state vector y
%

function y = nginit(Tinit)

  n = length(Tinit);

  % writing the generator
  r = randn(n,1);
  y = Tinit * r;

end

