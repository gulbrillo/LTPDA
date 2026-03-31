% MTXIIRRESP calculate iir resp by matrix product
% 
% INPUT:
%       fil: a miir filter or a vector of filoters
%       freq: the frequency vector
%       fs: sampling frequency
%       bank: filterbank type parameter ('parallel', 'serial' or 'none'). 
%       If it is left empty, it provide a vector of responses at the
%       output.
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function rsp = mtxiirresp(fil,freq,fs,bank)
  
  T = 1/fs;
  
  Nfil = numel(fil);
  
  if Nfil>1
    % check for different orders
    sza = zeros(Nfil,1);
    szb = zeros(Nfil,1);
    for jj=1:Nfil
      sza(jj) = numel(fil(jj).a);
      szb(jj) = numel(fil(jj).b);
    end
    Ncl = max([sza;szb]);
  else
    sza = numel(fil.a);
    szb = numel(fil.b);
    Ncl = max([sza szb]);
  end
  
  % init A and B
  A = zeros(Nfil,Ncl);
  B = zeros(Nfil,Ncl);
  
  % get filters coefficients
  if Nfil>1
    for ii=1:Nfil
      A(ii,1:sza(ii)) = fil(ii).a;
      B(ii,1:szb(ii)) = fil(ii).b;
    end
  else
    A(1:sza) = fil.a;
    B(1:szb) = fil.b;
  end
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
  if Nfil>1
    switch lower(bank)
      case 'parallel'
        rsp = sum(rspm,1);
      case 'serial'
        rsp = prod(rspm,1);
      otherwise
        rsp = rspm;
    end
  else
    rsp = rspm;
  end


end