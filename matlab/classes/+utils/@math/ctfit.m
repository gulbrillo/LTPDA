% CTFIT fits a continuous model to a frequency response.
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DESCRIPTION:
%
%     Fits a continuous model to a frequency response using relaxed
%     s-domain vector fitting algorithm [1, 2]. Model function is expanded
%     in partial fractions:
%
%              r1              rN
%     f(s) = ------- + ... + ------- + d
%            s - p1          s - pN
%
% CALL:
%
%     [res,poles,dterm,mresp,rdl] = ctfit(y,f,poles,weight,fitin)
%
% INPUTS:
%
%     - y: Is a vector wuth the frequency response data.
%     - f: Is the frequency vector in Hz.
%     - poles: are a set of starting poles.
%     - weight: are a set of weights used in the fitting procedure.
%     - fitin: is a struct containing fitting options and parameters. fitin
%     fields are:
%       - fitin.stable = 0; fit without forcing poles to be stable.
%       - fitin.stable = 1; force poles to be stable flipping unstable
%       poles in the left side of the complex plane. s -> s - 2*conj(s).
%       - fitin.dterm = 0; fit with d = 0.
%       - fitin.dterm = 1; fit with d different from 0.
%       - fitin.polt = 0; fit without plotting results.
%       - fitin.plot = 1; plot fit results.
%
% OUTPUT:
%
%     - res: vector or residues.
%     - poles: vector of poles.
%     - dterm: direct term d.
%     - mresp: frequency response of the fitted model
%     - rdl: residuals y - mresp
%
% REFERENCES:
%
%     [1] B. Gustavsen and A. Semlyen, "Rational approximation of frequency
%         domain responses by Vector Fitting", IEEE Trans. Power Delivery
%         vol. 14, no. 3, pp. 1052-1061, July 1999.
%     [2] B. Gustavsen, "Improving the Pole Relocating Properties of Vector
%         Fitting", IEEE Trans. Power Delivery vol. 21, no. 3, pp.
%         1587-1592, July 2006.
%
% NOTE:
%
%     This function cannot handle more than one frequency response per time
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [res,poles,dterm,mresp,rdl] = ctfit(y,f,poles,weight,fitin)
  
  %% Collecting inputs
  
  % Default input struct
  defaultparams = struct('stable',0, 'dterm',0, 'plot',0);
  
  names = {'stable','dterm','plot'};
  
  % collecting input and default params
  if ~isempty(fitin)
    for jj=1:length(names)
      if isfield(fitin, names(jj))
        defaultparams.(names{1,jj}) = fitin.(names{1,jj});
      end
    end
  end
  
  stab = defaultparams.stable; % Enforce pole stability is is 1
  dt = defaultparams.dterm; % 1 to fit with direct term
  plotting = defaultparams.plot; % set to 1 if plotting is required
  
  %% Inputs in column vectors
  
  [a,b] = size(y);
  if a < b % shifting to column
    y = y.';
  end
  
  [a,b] = size(f);
  if a < b % shifting to column
    f = f.';
  end
  
  [a,b] = size(poles);
  if a < b % shifting to column
    poles = poles.';
  end
  
  clear w
  w = weight;
  [a,b] = size(w);
  if a < b % shifting to column
    w = w.';
  end
  
  N = length(poles); % Model order
  
  if dt
    dl = 1; % Fit with direct term
  else
    dl = 0; % Fit without direct term
  end
  
  % definition of s
  s = 1i.*2.*pi.*f;
  
  Nz = length(s);
  
  %% Marking complex and real poles
  
  % cindex = 1; pole is complex, next conjugate pole is marked with cindex
  % = 2. cindex = 0; pole is real
  cindex=zeros(N,1);
  for m=1:N
    if imag(poles(m))~=0
      if m==1
        cindex(m)=1;
      else
        if cindex(m-1)==0 || cindex(m-1)==2
          cindex(m)=1; cindex(m+1)=2;
        else
          cindex(m)=2;
        end
      end
    end
  end
  
  %% Initializing the augmented problem matrices
  
  
  
  % Matrix initialinzation
  BA = zeros(Nz+1,1);
  AA = zeros(Nz+1,2*N+dl+1);
  Ak=zeros(Nz,N+1);
  
  % Defining Ak
  for jj = 1:N
    if cindex(jj) == 1 % conjugate complex couple of poles
      Ak(:,jj) = (1./(s-poles(jj)))+(1./(s-poles(jj+1)));
      Ak(:,jj+1) = (1i./(s-poles(jj)))-(1i./(s-poles(jj+1)));
    elseif cindex(jj) == 0 % real pole
      Ak(:,jj) = 1./(s-poles(jj));
    end
  end
  
  
  Ak(1:Nz,N+1) = ones(Nz,1);
  
  
  for m=1:N+dl % left columns
    AA(1:Nz,m)=w.*Ak(1:Nz,m);
  end
  for m=1:N+1 %Rightmost blocks
    AA(1:Nz,N+dt+m)=-w.*(Ak(1:Nz,m).*y);
  end
  
  % Scaling factor
  clear sc
  sc = norm(w.*y)/Nz;
  
  % setting the last row of AA and BA for the relaxion condition
  for qq = 1:N+1
    AA(Nz+1,N+dl+qq) = real(sc*sum(Ak(:,qq)));
  end
  
  AA = [real(AA);imag(AA)];
  
  %   AAstr1 = AA; % storing
  
  % Last element of the solution vector
  BA(Nz+1) = Nz*sc;
  
  % solving for real and imaginary part of the solution vector
  nBA = [real(BA);imag(BA)];
  
  % Normalization factor
  nf = zeros(2*N+dl+1,1);
  for pp = 1:2*N+dl+1
    nf(pp,1) = norm(AA(:,pp),2); % Euclidean norm
    AA(:,pp) = AA(:,pp)./nf(pp,1); % Normalization
  end
  
  
  %% Solving augmented problem
  
  % XA = pinv(AA)*nBA;
  % XA = inv((AA.')*AA)*(AA.')*nBA;
  
  % XA = AA.'*AA\AA.'*nBA;
  
  XA = AA\nBA;
  
  XA = XA./nf; % renormalization
  
  %% Finding zeros of sigma
  
  lsr = XA(N+dl+1:2*N+dl,1); % collect the least square results
  
  Ds = XA(end); % direct term of sigma
  
  % Real poles have real residues, complex poles have comples residues
  rs = zeros(N,1);
  for tt = 1:N
    if cindex(tt) == 1 % conjugate complex couple of poles
      rs(tt,1) = lsr(tt)+1i*lsr(tt+1);
      rs(tt+1,1) = lsr(tt)-1i*lsr(tt+1);
    elseif cindex(tt) == 0 % real pole
      rs(tt,1) = lsr(tt);
    end
  end
  
  % [snum, sden] = residue(rs,poles,Ds);
  %
  % % ceking for numerical calculation errors
  % for jj = 1:length(snum)
  %   if ~isequal(imag(snum(jj)),0)
  %     snum(jj)=real(snum(jj));
  %   end
  % end
  %
  % % Zeros of sigma are poles of F
  % szeros = roots(snum);
  
  DPOLES = diag(poles);
  B = ones(N,1);
  C = rs.';
  for kk = 1:N
    if cindex(kk) == 1
      DPOLES(kk,kk)=real(DPOLES(kk,kk));
      DPOLES(kk,kk+1)=imag(DPOLES(kk,kk));
      DPOLES(kk+1,kk)=-1*imag(DPOLES(kk,kk));
      DPOLES(kk+1,kk+1)=real(DPOLES(kk,kk));
      B(kk,1) = 2;
      B(kk+1,1) = 0;
      C(1,kk) = real(C(1,kk));
      C(1,kk+1) = imag(C(1,kk));
    end
  end
  
  H = DPOLES-B*C/Ds;
  szeros = eig(H);
  
  %% Ruling out unstable poles
  
  % This option force the poles of f to stay inside the left side of the
  % complex plane
  
  if stab
    unst = real(szeros)>0;
    szeros(unst) = szeros(unst)-2*real(szeros(unst)); % Mirroring respect to the complex axes
  end
  N = length(szeros);
  
  %% Separating complex poles from real poles and ordering
  
  rnpoles = [];
  inpoles = [];
  for tt = 1:N
    if imag(szeros(tt)) == 0
      % collecting real poles
      rnpoles = [rnpoles; szeros(tt)];
    else
      % collecting complex poles
      inpoles = [inpoles; szeros(tt)];
    end
  end
  
  % Sorting complex poles in order to have them in the expected order a+jb
  % and a-jb a>0 b>0
  inpoles = sort(inpoles);
  npoles = [rnpoles;inpoles];
  npoles = npoles - 2.*1i.*imag(npoles);
  
  %% Marking complex and real poles
  
  cindex=zeros(N,1);
  for m=1:N
    if imag(npoles(m))~=0
      if m==1
        cindex(m)=1;
      else
        if cindex(m-1)==0 || cindex(m-1)==2
          cindex(m)=1; cindex(m+1)=2;
        else
          cindex(m)=2;
        end
      end
    end
  end
  
  %% Initializing direct problem
  
  % Matrix initialinzation
  B = w.*y;
  AD = zeros(Nz,N+dl);
  Ak=zeros(Nz,N+dl);
  
  % Defining Ak
  for jj = 1:N
    if cindex(jj) == 1 % conjugate complex couple of poles
      Ak(:,jj) = (1./(s-npoles(jj)))+(1./(s-npoles(jj+1)));
      Ak(:,jj+1) = (1i./(s-npoles(jj)))-(1i./(s-npoles(jj+1)));
    elseif cindex(jj) == 0 % real pole
      Ak(:,jj) = 1./(s-npoles(jj));
    end
  end
  
  if dt
    Ak(1:Nz,N+dl) = ones(Nz,1); % considering the direct term
  end
  
  % Defining AD
  for m=1:N+dl
    AD(1:Nz,m)=w.*Ak(1:Nz,m);
  end
  
  
  AD = [real(AD);imag(AD)];
  nB = [real(B);imag(B)];
  
  % Normalization factor
  nf = zeros(N+dl,1);
  for pp = 1:N+dl
    nf(pp,1) = norm(AD(:,pp),2); % Euclidean norm
    AD(:,pp) = AD(:,pp)./nf(pp,1); % Normalization
  end
  
  %% Solving direct problem
  
  % XD = inv((AD.')*AD)*(AD.')*nB;
  % XD = AD.'*AD\AD.'*nB;
  % XD = pinv(AD)*nB;
  XD = AD\nB;
  
  XD = XD./nf; % Renormalization
  
  %% Final residues and poles of f
  
  if dt
    lsr = XD(1:end-1); % Fitting with direct term
  else
    lsr = XD(1:end); % Fitting without direct term
  end
  
  res = zeros(N,1);
  % Real poles have real residues, complex poles have comples residues
  for tt = 1:N
    if cindex(tt) == 1 % conjugate complex couple of poles
      res(tt) = lsr(tt)+1i*lsr(tt+1);
      res(tt+1) = lsr(tt)-1i*lsr(tt+1);
    elseif cindex(tt) == 0 % real pole
      res(tt) = lsr(tt);
    end
  end
  
  clear poles
  poles = npoles;
  
  if dt
    dterm = XD(end);
  else
    dterm = 0;
  end
  
  %% freq resp of the fit model
  
  % f = pfparams.freq;
  r = res;
  p = poles;
  d = dterm;
  
  Nf = length(f);
  N = length(p);
  
  rsp = zeros(Nf,1);
  indx = (0:length(d)-1).';
  for ii = 1:Nf
    for jj = 1:N
      rsptemp = r(jj)/(1i*2*pi*f(ii)-p(jj));
      rsp(ii) = rsp(ii) + rsptemp;
    end
    % Direct terms response
    rsp(ii) = rsp(ii) + sum(((1i*2*pi*f(ii))*ones(length(d),1).^indx).*d);
  end
  
  mresp = rsp;
  
  % Residual
  rdl = y - mresp;
  
  %% Plotting response
  
  if plotting
    figure(1)
    subplot(2,1,1);
    loglog(f,abs(y),'k')
    hold on
    loglog(f,abs(mresp),'r')
    loglog(f,abs(rdl),'b')
    xlabel('Frequency [Hz]')
    ylabel('Amplitude')
    legend('Original', 'CTFIT','Residual')
    hold off
    
    subplot(2,1,2);
    semilogx(f,angle(y),'k')
    hold on
    semilogx(f,angle(mresp),'r')
    xlabel('Frequency [Hz]')
    ylabel('Phase [Rad]')
    legend('Original', 'CTFIT')
  end
  hold off
end