% NGCONV is called by the function fromPzmodel
% it takes the pole zero model pzm (user input to ao constructor)
% as input and returns as
%               outputs:
%                      - a: numerator coefficients
%                      - b: denominator coefficients
%                           of the target transfer function

function [a,b] = ngconv(pzm)

  zs = pzm.zeros;
  ps = pzm.poles;

  f_zer = zeros(length(zs));
  q_zer = zeros(length(zs));
  for j=1:length(zs)
    z = zs(j);
    f_zer(j,1) = z.f;
    q_zer(j,1) = z.q;
    %if isnan(q_zer(j))
    %    q_zer(j,1) = 0;
    %end
    %zv(j,1:2) = [f q];
  end

  f_pol = zeros(length(ps));
  q_pol = zeros(length(ps));
  for j=1:length(ps)
    p = ps(j);
    f_pol(j,1) = p.f;
    q_pol(j,1) = p.q;
    %if isnan(q_pol(j))
    %    q_pol(j,1) = 0;
    %end
  end

  %%% calculate factors from f and q
  pol = ao.fq2fac(f_pol,q_pol);
  zer = ao.fq2fac(f_zer,q_zer);

  %%%
  [b,a] = ao.conv_noisegen(pol,zer);
end


