% CONV_NOISEGEN calls the matlab function conv.m to convolute poles and zeros from a given pzmodel
%
% The function is a private one and is called from ngconv.m in the
% noisegenerator folder.
%
% Inputs (from ngconv.m):
%        - pol
%        - zero
%
% Outputs:
%        - b: denominator coefficients of transfer function
%        - a: numerator coefficients of transfer function
% A Monsky 24-07-07
%

function [b,a] = conv_noisegen(pol,zer)

  [m,k] = size(pol);
  [n,l] = size(zer);

  coefb = pol(1,:);

  for i = 2:m
    coefb = conv(coefb, pol(i,:));
  end

  b = nonzeros(coefb);

  if n~=0
    coefa = zer(1,:);
    for i = 2:n
      coefa = conv(coefa, zer(i,:));
    end
    a = nonzeros(coefa);
  else
    a = 1;
  end

  %normalize to bn = 1
  m = length(b);
  normfac = b(m);
  b = b/normfac;
  a = a/(normfac*sqrt(2));

end

