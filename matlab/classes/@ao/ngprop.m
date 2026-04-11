% NGPROP is called by the function fromPzmodel
%
% Inputs calculated by ...
%  ... NGCONV:
%            - num:   numerator coefficients
%  ... NGSETUP:
%            - Tprop: matrix to calculate propagation vector
%            - E:     matrix to calculate propagation vector
%  ... NGINIT
%            - y:     initial state vector
%            - num:   numerator coefficients
%  ... USER
%            - ns:    number of samples given as input from the user
%  Outputs:
%            - x:     vector of timesamples
%            - y:     last calculated state vector (could be used as input
%                     for next LTPDA_NOISEGEN call)

function [x y] = ngprop(Tprop, E, num, y, ns)

  lengT = length(Tprop);
  lengb = lengT+1;

  num=num';
  num = [num zeros(1,(lengb-length(num)-1))];


  x = zeros(ns,1);
  R = randn(lengT, ns);
  for i=1:ns
    y = E * y + Tprop * R(:,i);
    x(i) = num*y;
  end

end
