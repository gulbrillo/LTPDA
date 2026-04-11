% MTXIIRRESP calculate rational resp by matrix product
% 
% A contains numerators coefficients (a row for each filter)
% A contains denominators coefficients (a row for each filter)
%
% NOTE: A and B should have the same size, zero pad if necessary
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function rsp = mtxratresp2(A,B,freq)
  
  % build Z matrix
  S = ones(size(A,2),numel(freq));
  ss = 2.*pi.*1i.*freq;
  for jj=2:size(S,1)
    S(jj,:) = ss.^(jj-1);
  end
  
  % get numerator and denominator
  num = A*S;
  den = B*S;
  % get response
  rspm = num./den;
  if size(A,1)>1
    rsp = sum(rspm,1);
  else
    rsp = rspm;
  end


end