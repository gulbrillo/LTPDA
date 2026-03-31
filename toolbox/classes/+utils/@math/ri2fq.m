% RI2FQ Convert complex pole/zero into frequency/Q pole/zero representation.
%
%  [f0, q]= ri2fq(c)
%

function [f0, q]= ri2fq(c)
  
  if(nargin==0)
    disp('usage: [f0, q]= ri2fq(c)');
    return
  end
  
  a = real(c(1));
  b = imag(c(1));

  f0 = sqrt(a^2 + b^2)/(2*pi);
  q = 0.5*sqrt(1 + b^2/a^2);
  
end
% END
