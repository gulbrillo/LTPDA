% MTXIIRRESP calculate iir resp by matrix product
%
% A contains numerators coefficients (a row for each filter)
% A contains denominators coefficients (a row for each filter)
%
% NOTE: A and B should have the same size, zero pad if necessary
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function rsp = mtxiirresp2(A,B,freq,fs)
  T = 1/fs;
  
  % build Z matrix
  Z = ones(size(A,2),numel(freq));
  zz = exp(-2.*pi.*1i.*T.*freq);
  for jj=2:size(Z,1)
    Z(jj,:) = zz.^(jj-1);
  end
  
  % get numerator and denominator
  num = A*Z;
  den = B*Z;
  % get response
  rspm = num./den;
  if size(A,1)>1
    rsp = sum(rspm,1);
  else
    rsp = rspm;
  end


end