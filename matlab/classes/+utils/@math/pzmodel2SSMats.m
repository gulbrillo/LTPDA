function [A,B,C,D] = pzmodel2SSMats(pzm)
  if (~numel(pzm)==1) || (~isa(pzm, 'pzmodel'))
    error(['function ' mfilename ' only accepts one pzmodel as an input'])
  end
  
  den = 1;
  num = 1;
  G = pzm.gain;
  
  % computing the A matrix
  for i=1:length(pzm.poles)
    if isnan(pzm.poles(i).q)
      w0 = pzm.poles(i).f*2*pi ;
      den = conv(den,[1 w0]);
      G = G * w0;
    else
      q = pzm.poles(i).q;
      w0 = 2*pi*pzm.poles(i).f;
      p = [1, 1/q*w0 w0^2];
      den = conv(den,p);
      G = G * w0 * w0;
    end
  end
  
  % computing the C matrix
  for i=1:length(pzm.zeros)
    if isnan(pzm.zeros(i).q)
      w0 = pzm.zeros(i).f*2*pi ;
      num = conv(num,[1 w0]);
      G = G / w0;
    else
      q = pzm.zeros(i).q;
      w0 = 2*pi*pzm.zeros(i).f;
      p = [1, 1/q*w0 w0^2];
      num = conv(num,p);
      G = G / w0 / w0;
    end
  end
  
  % setting gain
  num = num*G;
  
  % zero padding TF numerator if degree is smaller than denominator
  Nss = length(den)-1;
  if length(num)<Nss+1
    num = [zeros(1,Nss+1-length(num)) num];
  end
  
  % computing the D/C matrix
  [q,r] = deconv(num,den); % polynmial division for den = conv(num,q)+r .
  if ~length(q)==1
    error('system may be non causal');
  end
  
  % Allocating matrices
  D = q;
  A = [zeros(Nss-1,1) eye(Nss-1); fliplr(-den(2:(Nss+1)))];
  B = zeros(Nss,1);
  if Nss>0
    B(Nss) = 1;
  end
  C = fliplr(r(2:(Nss+1)));
  
end