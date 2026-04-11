% PFALLPSYMZ all pass filtering in order to stabilize TF poles and zeros.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DESCRIPTION:
% 
%     All pass filtering in order to stabilize transfer functions poles. 
%     It inputs a partial fraction expanded discrete model and outpu
%     residues, poles direct terms and frequency response of the stabilized
%     model. Function can handle multiple models with common poles.
% 
% CALL:
% 
%     [nr,np,nd,resp] = pfallpsymz(r,p,d,f,fs)
% 
% INPUTS:
% 
%     r: are residues. (Npx1) or (NpxM) vector
%     p: are poles. (Npx1) vector
%     d: is direct term (1x1) or (1xM) vector
%     mresp: input model response. (Nx1) or (NxM) vector
%     f: is the frequancies vector in (Hz). (Nx1) vector
%     fs: is the sampling frequency in (Hz). (1x1)
%     
% OUTPUTS:
% 
%     nr: new residues. (Npx1) or (NpxM) vector
%     np: new stable poles. (Npx1) vector
%     nd: new direct term. (1x1) or (1xM) vector
%     nmresp: new model response. (Nx1) or (NxM) vector
% 
% NOTE:
% 
%     This function make use of symbolic math toolbox functions
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [nr,np,nd,nmresp] = pfallpsymz(r,p,d,mresp,f,fs)

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

  [a,b] = size(f);
  if a<b
    f = f.'; % reshape as a column vector
  end

  [a,b] = size(d);
  if a > b
    d = d.'; % reshape as a row
    d = d(1,:); % taking the first row (the function can handle only simple constant direct terms)
  end

  if isempty(fs)
    fs = 1;
  end
  [a,b] = size(fs);
  if a ~= b
    disp(' Fs has to be a number. Only first term will be considered! ')
    fs = fs(1);
  end

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  f = sym(f,'f');
  fs = sym(fs,'f');
  syms z
  p = sym(p,'f');

  % stabilize poles
  sp = p;
  unst = abs(double(sp)) > 1;
  sp(unst) = 1./conj(sp(unst));
  skp = prod(1./conj(p(unst)));

  [Na,Nb] = size(r);

  for nn = 1:Nb
    
%     pp = p(unst);
%     psp = sp(unst);
%     tterm = 1;
%     for ii = 1:length(pp)
%       tterm = tterm.*(z-pp(ii))./(z-psp(ii));
%     end
%     
%     s = cos((2*pi/fs).*f) + 1i.*sin((2*pi/fs).*f);
%     allresp = subs(tterm,z,s);
%     phs = angle(allresp);
%     nmresp(:,nn) = mresp(:,nn).*(cos(phs)+1i.*sin(phs));
%     np = double(sp);

    % digits(100)
    % Defining inputs as symbolic variable
    rt = sym(r(:,nn),'f');
  %   p = sym(p,'f');
    dt = sym(d(1,nn),'f');
  %   f = sym(f,'f');
  %   fs = sym(fs,'f');
  %   syms z

    % Function gain coefficient
    k = sum(rt)+dt;

    Np = length(p);

    % Defining the symbolic transfer function
    vter = rt.*z./(z-p);
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
    if double(d) == 0
      zrs = [zrs; sym(0,'f')];
    end

    % % stabilize zeros
    % szrs = zrs;
    % unst = abs(double(szrs)) > 1;
    % szrs(unst) = 1./conj(szrs(unst));
    % skz = prod(conj(zrs(unst)));

  %   % stabilize poles
  %   sp = p;
  %   unst = abs(double(sp)) > 1;
  %   sp(unst) = 1./conj(sp(unst));
  %   skp = prod(1./conj(p(unst)));

    % Correcting for some special cases
    % if isempty(skz)
    %   skz = sym(1,'f');
    % end
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

    for jj = 1:Np
      HHHn = HHHn.*(z-zrs(jj));
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
    pfparams.type = 'disc';
    pfparams.freq = f;
    pfparams.fs = fs;
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
