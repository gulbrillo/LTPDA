% DTFIT fits a discrete model to a frequency response.
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DESCRIPTION:
%
%     Fits a discrete model to a frequency response using relaxed z-domain
%     vector fitting algorithm [1 - 3]. Model function is expanded in
%     partial fractions:
%
%                r1                  rN
%     f(z) = ----------- + ... + ----------- + d
%            1-p1*z^{-1}         1-pN*z^{-1}
%
% CALL:
%
%     [res,poles,dterm,mresp,rdl] = dtfit(y,f,poles,weight,fitin)
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
%       poles in the unit circle. z -> 1/z*.
%       - fitin.dterm = 0; fit with d = 0.
%       - fitin.dterm = 1; fit with d different from 0.
%       - fitin.fs = fs; input the sampling frequency in Hz (default value
%       is 1 Hz).
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
%     [3] Y. S. Mekonnen and J. E. Schutt-Aine, "Fast broadband
%         macromodeling technique of sampled time/frequency data using
%         z-domain vector-fitting method", Electronic Components and
%         Technology Conference, 2008. ECTC 2008. 58th 27-30 May 2008 pp.
%         1231 - 1235.
%
% NOTE:
%
%     This function cannot handle more than one frequency response per time
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [res,poles,dterm,mresp,rdl] = dtfit(y,f,poles,weight,fitin)
  
  
  %% Collecting inputs
  
  % Default input struct
  defaultparams = struct('stable',0, 'dterm',0, 'fs',1, 'plot',0);
  
  names = {'stable','dterm','fs','plot'};
  
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
  fs = defaultparams.fs; % sampling frequency
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
  
  % definition of z
  z = cos(2.*pi.*f./fs)+1i.*sin(2.*pi.*f./fs);
  
  Nz = length(z);
  
  %% Normalizing y
  
  y = y./z;
  
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
  % for jj = 1:N
  %   if cindex(jj) == 1 % conjugate complex couple of poles
  %     Ak(:,jj) = (1./(1-poles(jj)./z))+(1./(1-poles(jj+1)./z));
  %     Ak(:,jj+1) = (j./(1-poles(jj)./z))-(j./(1-poles(jj+1)./z));
  %   elseif cindex(jj) == 0 % real pole
  %     Ak(:,jj) = 1./(1-poles(jj)./z);
  %   end
  % end
  
  for jj = 1:N
    if cindex(jj) == 1 % conjugate complex couple of poles
      Ak(:,jj) = (1./(z-poles(jj)))+(1./(z-poles(jj+1)));
      Ak(:,jj+1) = (j./(z-poles(jj)))-(j./(z-poles(jj+1)));
    elseif cindex(jj) == 0 % real pole
      Ak(:,jj) = 1./(z-poles(jj));
    end
  end
  
  
  Ak(1:Nz,N+1) = ones(Nz,1);
  
  for m=1:N+dl % left columns
    AA(1:Nz,m)=w.*Ak(1:Nz,m);
  end
  if dt
    AA(1:Nz,N+dl)=w./z;
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
  
  % [snum, sden] = residuez(rs,poles,Ds);
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
  
  % This option force the poles of f to stay inside the unit circle
  if stab
    unst = abs(szeros) > 1;
    szeros(unst) = 1./conj(szeros(unst));
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
  % for jj = 1:N
  %   if cindex(jj) == 1 % conjugate complex couple of poles
  %     Ak(:,jj) = (1./(1-npoles(jj)./z))+(1./(1-npoles(jj+1)./z));
  %     Ak(:,jj+1) = (j./(1-npoles(jj)./z))-(j./(1-npoles(jj+1)./z));
  %   elseif cindex(jj) == 0 % real pole
  %     Ak(:,jj) = 1./(1-npoles(jj)./z);
  %   end
  % end
  
  for jj = 1:N
    if cindex(jj) == 1 % conjugate complex couple of poles
      Ak(:,jj) = (1./(z-npoles(jj)))+(1./(z-npoles(jj+1)));
      Ak(:,jj+1) = (1i./(z-npoles(jj)))-(1i./(z-npoles(jj+1)));
    elseif cindex(jj) == 0 % real pole
      Ak(:,jj) = 1./(z-npoles(jj));
    end
  end
  
  if dt
    %   Ak(1:Nz,N+dl) = ones(Nz,1); % considering the direct term
    Ak(1:Nz,N+dl) = 1./z;
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
  
  %% Calculating response and residual
  
  % freq resp of the fit model
  r = res;
  p = poles;
  d = dterm;
  
  Nf = length(f);
  N = length(p);
  
  % Defining normalized frequencies
  fn = f./fs;
  
  rsp = zeros(Nf,1);
  indx = 0:length(d)-1;
  for ii = 1:Nf
    for jj = 1:N
      rsptemp = exp(1i*2*pi*fn(ii))*r(jj)/(exp(1i*2*pi*fn(ii))-p(jj));
      rsp(ii) = rsp(ii) + rsptemp;
    end
    % Direct terms response
    rsp(ii) = rsp(ii) + sum(((exp((1i*2*pi*f(ii))*ones(length(d),1))).^(-1.*indx)).*d);
  end
  
  % Model response
  mresp = rsp;
  
  % Residual
  yr = y.*z;
  rdl = yr - mresp;
  
  %% Plotting response
  
  if plotting
    figure(1)
    subplot(2,1,1);
    loglog(fn,abs(yr),'k')
    hold on
    loglog(fn,abs(mresp),'r')
    loglog(fn,abs(rdl),'b')
    xlabel('Normalized Frequency [f/fs]')
    ylabel('Amplitude')
    legend('Original', 'DTFIT','Residual')
    hold off
    
    subplot(2,1,2);
    semilogx(fn,angle(yr),'k')
    hold on
    semilogx(fn,angle(mresp),'r')
    xlabel('Normalized Frequency [f/fs]')
    ylabel('Phase [Rad]')
    legend('Original', 'DTFIT')
    hold off
  end
end