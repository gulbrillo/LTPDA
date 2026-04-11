% FQ2FAC is a private function and is called by ngconv.m which can be found in the
% folder 'noisegenerator'.
% It calculates polynomial coefficients from given poles and Zeros.
%
% Inputs (from ngconv.m):
%        - f : frequency of apole or zero
%        - q : quality factor of a pole or zero
%
% Outputs:
%        - polzero: a vector of resulting polynomial coefficients
%
%

function polzero = fq2fac(f,q)

  n = length(f);
  polzero = zeros(n,3);
  for i = 1:n
    if isnan(q(i))
      polzero(i,1:2) = [1 1/(2*pi*f(i))];
    else
      polzero(i,1:3) = [1 1/(2*pi*f(i)*q(i)) 1/((2*pi*f(i))*(2*pi*f(i)))];
    end
  end

end

