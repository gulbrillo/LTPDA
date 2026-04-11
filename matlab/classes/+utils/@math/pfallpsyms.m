% 
% DESCRIPTION:
% 
%     All pass filtering in order to stabilize transfer function poles and
%     zeros. It inputs a partial fraction expanded continuous model and
%     outputs a pole-zero minimum phase system
% 
% CALL:
%
%     [nr,np,nd,resp] = pfallpsyms(r,p,d,f)
% 
% INPUTS:
% 
%     r: are residues
%     p: are poles
%     d: is direct term
%     f: is the frequancies vector in (Hz)
%     fs: is the sampling frequency in (Hz)
%     
% OUTPUTS:
% 
%     resp: is the minimum phase frequency response
%     np: are the new stable poles
%     nz: are the new stable zeros
% 
% NOTE:
% 
%     This function make use of symbolic math toolbox functions
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [nr,np,nd,nmresp] = pfallpsyms(r,p,d,f)

% Reshaping
[a,b] = size(r);
if a<b
  r = r.'; % reshape as a column vector
end

[a,b] = size(p);
if a<b
  p = p.'; % reshape as a column vector
end

[a,b] = size(f);
if a<b
  f = f.'; % reshape as a column vector
end

[a,b] = size(d);
if a ~= b
  disp(' Function can handle only single constant direct terms. Only first term will be considered! ')
  d = d(1);
end

if isempty(d)
  d = 0;
end

% digits(100)
% Defining inputs as symbolic variable
r = sym(r,'f');
p = sym(p,'f');
d = sym(d,'f');
f = sym(f,'f');
syms z

% Function gain coefficient
if double(d) == 0
  k = sum(r);
else
  k = d;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
f = sym(f,'f');
syms z
p = sym(p,'f');

% stabilize poles
sp = p;
unst = abs(double(sp)) > 1;
sp(unst) = 1./conj(sp(unst));
skp = prod(1./conj(p(unst)));

[Na,Nb] = size(r);

for nn = 1:Nb

  % digits(100)
  % Defining inputs as symbolic variable
  rt = sym(r(:,nn),'f');
%   p = sym(p,'f');
  dt = sym(d(1,nn),'f');
%   f = sym(f,'f');
%   fs = sym(fs,'f');
%   syms z

  % Function gain coefficient
  if double(d) == 0
    k = sum(r);
  else
    k = d;
  end

  Np = length(p);

  % Defining the symbolic transfer function
  vter = rt./(z-p);
  vter = [vter; dt];
  Mter = diag(vter);
  H = trace(Mter);

  % Factorizing the transfer function
  HH = factor(H);

  % Extracting numerator and denominator
  [N,D] = numden(HH);

  % Symbolci calculation of function zeros
  cN = coeffs(expand(N),z);
  n = length(cN);
  cN2 = -1.*cN(2:end)./cN(1);
  A = sym(diag(ones(1,n-2),-1));
  A(1,:) = cN2;
  zrs = eig(A);
%   if double(d) == 0
%     zrs = [zrs; sym(0,'f')];
%   end

  if isempty(skp)
    skp = sym(1,'f');
  end
  if isempty(k)
    k = sym(1,'f');
  end

  % Calculating new gain
  % sk = real(k*skz*skp);
  sk = real(k*skp);

  HHHn = sym(1,'f');

  for ii = 1:length(zrs)
    HHHn = HHHn.*(z-zrs(ii));
  end
  for jj = 1:Np
    tsp = sp;
    tsp(jj) = [];
    tHHHd = sym(1,'f');
    for kk = 1:Np-1
      tHHHd = tHHHd.*(z-tsp(kk));
    end
    HHHd(jj,1) = tHHHd;

  end

  for jj = 1:Np
    sr(jj,1) = subs(sk*HHHn/(z*HHHd(jj,1)),z,sp(jj));
  end

  np = double(sp);
  for kk = 1:Np
    if imag(np(kk)) == 0
      sr(kk) = real(sr(kk));
    end
  end

  nr(:,nn) = double(sr);
  nd(:,nn) = double(dt);

  % Model evaluation
  pfparams.type = 'cont';
  pfparams.freq = f;
  pfparams.res = nr(:,nn);
  pfparams.pol = np;
  pfparams.dterm = nd(:,nn);
  pfr = utils.math.pfresp(pfparams);
  resp = pfr.resp;

  ratio = mean(abs(mresp(:,nn))./abs(resp));
  resp = resp.*ratio;
  nr(:,nn) = nr(:,nn).*ratio;
  nd(:,nn) = nd(:,nn).*ratio;
  nmresp(:,nn) = resp;
  
end
