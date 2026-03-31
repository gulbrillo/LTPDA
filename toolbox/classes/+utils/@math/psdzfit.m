% PSDZFIT: Fit discrete partial fraction model to PSD
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DESCRIPTION:
% 
%     Fits discrete partial fractions model to power spectral density. The
%     function is able to fit more than one frequency response per time. In
%     case that more than one frequency response is passed as input, they
%     are fitted with a set of common poles [1]. The function is based on
%     the vector fitting algorithm [2 - 4].
% 
% CALL:
% 
%     [res,poles,fullpoles,mresp,rdl,mse] = psdzfit(y,f,poles,weight,fitin)
% 
% INPUTS:
% 
%     - y: Is a vector with the power spectrum data.
%     - f: Is the frequency vector in Hz.
%     - poles: are a set of starting poles.
%     - weight: are a set of weights used in the fitting procedure.
%     - fitin: is a struct containing fitting options and parameters. fitin
%     fields are:
% 
%       - fitin.fs = fs; input the sampling frequency in Hz (default value
%       is 1 Hz).
% 
%       - fitin.polt = 0; fit without plotting results. [Default].
%       - fitin.plot = 1; plot fit results in loglog scale.
%       - fitin.plot = 2; plot fit results in semilogx scale.
%       - fitin.plot = 3; plot fit results in semilogy scale.
%       - fitin.plot = 4; plot fit results in linear xy scale.
% 
%       - fitin.ploth = #; a plot handle to define the figure target for
%       plotting. Default 1.
% 
% OUTPUT:
% 
%     - res: vector of all residues.
%     - poles: vector of causal poles.
%     - fullpoles: complete vector of poles.
%     - mresp: frequency response of the fitted model.
%     - rdl: residuals y - mresp.
%     - mse: normalized men squared error
% 
% EXAMPLES:
% 
%     - Fit on a single transfer function:
% 
%       INPUT
%       y is a (Nx1) or (1xN) vector
%       f is a (Nx1) or (1xN) vector
%       poles is a (Npx1) or (1xNp) vector
%       weight is a (Nx1) or (1xN) vector
% 
%       OUTPUT
%       res is a (2*Npx1) vector
%       poles is a (Npx1) vector
%       fullpoles is a (2*Npx1) vector
%       mresp is a (Nx1) vector
%       rdl is a (Nx1) vector
%       mse is a constant
% 
%       - Fit Nt transfer function at the same time:
% 
%       INPUT
%       y is a (NxNt) or (NtxN) vector
%       f is a (Nx1) or (1xN) vector
%       poles is a (Npx1) or (1xNp) vector
%       weight is a (NxNt) or (NtxN) vector
% 
%       OUTPUT
%       res is a (2*NpxNt) vector
%       poles is a (Npx1) vector
%       fullpoles is a (2*NpxNt) vector
%       mresp is a (NxNt) vector
%       rdl is a (NxNt) vector
%       mse is a (1xNt) vector
% 
% REFERENCES:
% 
%     [1] 
%     [2] B. Gustavsen and A. Semlyen, "Rational approximation of frequency
%         domain responses by Vector Fitting", IEEE Trans. Power Delivery
%         vol. 14, no. 3, pp. 1052-1061, July 1999.
%     [3] B. Gustavsen, "Improving the Pole Relocating Properties of Vector
%         Fitting", IEEE Trans. Power Delivery vol. 21, no. 3, pp.
%         1587-1592, July 2006.
%     [4] Y. S. Mekonnen and J. E. Schutt-Aine, "Fast broadband
%         macromodeling technique of sampled time/frequency data using
%         z-domain vector-fitting method", Electronic Components and
%         Technology Conference, 2008. ECTC 2008. 58th 27-30 May 2008 pp.
%         1231 - 1235.
% 
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [res,poles,fullpoles,mresp,rdl,mse] = psdzfit(y,f,poles,weight,fitin)

  warning off all
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Collecting inputs

  % Default input struct
  defaultparams = struct('fs',1, 'plot',0, 'ploth',1);

  names = {'fs','plot','ploth'};

  % collecting input and default params
  if ~isempty(fitin)
    for jj=1:length(names)
      if isfield(fitin, names(jj)) && ~isempty(fitin.(names{1,jj}))
       defaultparams.(names{1,jj}) = fitin.(names{1,jj});
      end
    end
  end

  fs = defaultparams.fs; % sampling frequency
  plotting = defaultparams.plot; % set to 1 if plotting is required
  plth = defaultparams.ploth; % set the figure target
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Inputs in row vectors

  [a,b] = size(y);
  if a > b % shifting to row
    y = y.';
  end

  [a,b] = size(f);
  if a > b % shifting to row
    f = f.';
  end

  [a,b] = size(poles);
  if a > b % shifting to row
    poles = poles.';
  end

  clear w
  w = weight;
  [a,b] = size(w);
  if a > b % shifting to row
    w = w.';
  end

  N = length(poles); % Model order

  % definition of z
  z = cos(2.*pi.*f./fs)+1i.*sin(2.*pi.*f./fs);

  Nz = length(z);

  [Nc,Ny] = size(y);
  if Ny ~= Nz
    error(' Number of data points different from number of frequency points! ')
  end

  %Tolerances used by relaxed version of vector fitting
  TOLlow=1e-8;
  TOLhigh=1e8;

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Marking complex and real poles

  % cindex = 1; pole is complex, next conjugate pole is marked with cindex
  % = 2. cindex = 0; pole is real
  cindex=zeros(1,N);
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
  ipoles = 1./poles;
  effpoles = [poles ipoles];
  ddpol = 1./(poles.*poles);

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Augmented problem
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  % Matrix initialinzation
  BA = zeros(Nc*Nz+1,1);
  Ak=zeros(Nz,N+1);
  AA=zeros(Nz*Nc+1,N*Nc+N+1);
  nf = zeros(1,Nc*N+N+1); % Normalization factor

  % Defining Ak
  for jj = 1:N
    if cindex(jj) == 1 % conjugate complex couple of poles
      Ak(:,jj) = 1./(z-poles(jj)) + 1./(z-conj(poles(jj))) - ddpol(jj)./(z-ipoles(jj)) - conj(ddpol(jj))./(z-conj(ipoles(jj)));
      Ak(:,jj+1) = 1i./(z-poles(jj)) - 1i./(z-conj(poles(jj))) - 1i.*ddpol(jj)./(z-ipoles(jj)) + 1i.*conj(ddpol(jj))./(z-conj(ipoles(jj)));
    elseif cindex(jj) == 0 % real pole
      Ak(:,jj) = 1./(z-poles(jj)) - ddpol(jj)./(z-ipoles(jj));
    end
  end

  Ak(1:Nz,N+1) = 1;

  % Scaling factor
  sc = 0;
  for mm = 1:Nc
    sc = sc + (norm(w(mm,:).*y(mm,:)))^2;
  end
  sc=sqrt(sc)/Nz; 

  for nn = 1:Nc

    wg = w(nn,:).'; % Weights

    ida=(nn-1)*Nz+1;
    idb=nn*Nz;
    idc=(nn-1)*N+1;

    for mm =1:N % Diagonal blocks
      AA(ida:idb,idc-1+mm) = wg.*Ak(1:Nz,mm);
    end
    for mm =1:N+1 % Last right blocks
      AA(ida:idb,Nc*N+mm) = -wg.*(Ak(1:Nz,mm).*y(nn,1:Nz).');
    end

  end

  % setting the last row of AA and BA for the relaxion condition
  for qq = 1:N+1
    AA(Nc*Nz+1,Nc*N+qq) = real(sc*sum(Ak(:,qq)));
  end

  AA = [real(AA);imag(AA)];

  % Last element of the solution vector
  BA(Nc*Nz+1) = Nz*sc;

  xBA = real(BA);
  xxBA = imag(BA);
  
  Nrow = Nz*Nc+1;
  
  BA = zeros(2*Nrow,1);
  
  BA(1:Nrow,1) = xBA;
  BA(Nrow+1:2*Nrow,1) = xxBA;

  % Normalization factor
  % nf = zeros(2*N+dl+1,1);
  for pp = 1:length(AA(1,:))
    nf(pp) = norm(AA(:,pp),2); % Euclidean norm
    AA(:,pp) = AA(:,pp)./nf(pp); % Normalization
  end

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Solving augmented problem

%   XA = pinv(AA)*BA;
  % XA = inv((AA.')*AA)*(AA.')*BA;

  % XA = AA.'*AA\AA.'*BA;

  XA = AA\BA;

  XA = XA./nf.'; % renormalization
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Checking the tolerance
  
  if abs(XA(end))<TOLlow || abs(XA(end))>TOLhigh
    
    if XA(end)==0
      Dnew=1;
    elseif abs(XA(end))<TOLlow
      Dnew=sign(XA(end))*TOLlow;
    elseif abs(XA(end))>TOLhigh
      Dnew=sign(XA(end))*TOLhigh;
    end

    for pp = 1:length(AA(1,:))
      AA(:,pp) = AA(:,pp).*nf(pp); %removing previous scaling
    end

    ind=length(AA(:,1))/2; %index to additional row related to relaxation
    
    AA(ind,:)=[]; % removing relaxation term
    
    BA=-Dnew*AA(:,end);  %new right side
    
    AA(:,end)=[];
    
    nf(end)=[];
    
    for pp = 1:length(AA(1,:))
      nf(pp) = norm(AA(:,pp),2); % Euclidean norm
      AA(:,pp) = AA(:,pp)./nf(pp); % Normalization
    end
          
    % XA=(AA.'*AA)\(AA.'*BA); % using normal equation
      
    XA=AA\BA;
    
    XA = XA./nf.'; % renormalization
    
    XA=[XA;Dnew];
    
  end

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Finding zeros of sigma

  lsr = XA(N*Nc+1:N*Nc+N,1); % collect the least square results

  D = XA(end); % direct term of sigma
  
  CPOLES = diag(effpoles);
  B = ones(2*N,1);
  C = zeros(1,2*N);
%   C = lsr.';
  res = zeros(2*N,1);
  % Real poles have real residues, complex poles have comples residues

  for tt = 1:N
    if cindex(tt) == 1 % conjugate complex couple of poles
      res(tt,1) = lsr(tt)+1i*lsr(tt+1);
      res(tt+1,1) = lsr(tt)-1i*lsr(tt+1);
      res(N+tt,1) = -1*(lsr(tt)+1i*lsr(tt+1))*ddpol(tt);
      res(N+tt+1,1) = -1*(lsr(tt)-1i*lsr(tt+1))*conj(ddpol(tt));
    elseif cindex(tt) == 0 % real pole
      res(tt,1) = lsr(tt);
      res(N+tt,1) = -1*lsr(tt)*ddpol(tt);
    end
  end

  
  for kk = 1:N
    if cindex(kk) == 1
      CPOLES(kk,kk)=real(effpoles(kk));
      CPOLES(kk,kk+1)=imag(effpoles(kk));
      CPOLES(kk+1,kk)=-1*imag(effpoles(kk));
      CPOLES(kk+1,kk+1)=real(effpoles(kk));
      B(kk,1) = 2;
      B(kk+1,1) = 0;
      C(1,kk) = real(res(kk,1));
      C(1,kk+1) = imag(res(kk,1));
      
      CPOLES(N+kk,N+kk)=real(effpoles(N+kk));
      CPOLES(N+kk,N+kk+1)=imag(effpoles(N+kk));
      CPOLES(N+kk+1,N+kk)=-1*imag(effpoles(N+kk));
      CPOLES(N+kk+1,N+kk+1)=real(effpoles(N+kk));
      B(N+kk,1) = 2;
      B(N+kk+1,1) = 0;
      C(1,N+kk) = real(res(N+kk,1));
      C(1,N+kk+1) = imag(res(N+kk,1));
    elseif cindex(kk) == 0 % real pole
      C(1,kk) = res(kk,1);
      C(1,N+kk) = res(N+kk,1);
    end
  end
  
  H = CPOLES-B*C/D;
  
  % avoiding NaN and inf
  idnan = isnan(H);
  if any(any(idnan))
    H(idnan) = 1;
  end
  idinf = isinf(H);
  if any(any(idinf))
    H(idinf) = 1;
  end

  szeros=eig(H);

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % separating causal from anticausal poles
  unst = abs(szeros) > 1;
  stab = abs(szeros) <= 1;
  unzeros = szeros(unst);
  stzeros = szeros(stab);
  
  stzeros = sort(stzeros);
  N = length(stzeros);

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Separating complex poles from real poles and ordering

  rnpoles = [];
  inpoles = [];
  for tt = 1:N
    if imag(stzeros(tt)) == 0
      % collecting real poles
      rnpoles = [rnpoles; stzeros(tt)];
    else
      % collecting complex poles
      inpoles = [inpoles; stzeros(tt)];
    end
  end

  % Sorting complex poles in order to have them in the expected order a+jb
  % and a-jb a>0 b>0
  inpoles = sort(inpoles);
  npoles = [rnpoles;inpoles];
  npoles = npoles - 2.*1i.*imag(npoles);

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Marking complex and real poles

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
  
  inpoles = 1./npoles;
  effnpoles = [npoles;inpoles];
  ddpol = 1./(npoles.*npoles);

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Direct problem
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  % Matrix initialinzation
  nB(1:Nz,1:Nc) = real(w.*y).';
  nB(Nz+1:2*Nz,1:Nc) = imag(w.*y).';

  B = zeros(2*Nz,1);
  nAD = zeros(Nz,N);
  AD = zeros(2*Nz,N);
  Ak = zeros(Nz,N);

  for jj = 1:N
    if cindex(jj) == 1 % conjugate complex couple of poles
      Ak(:,jj) = 1./(z-npoles(jj)) + 1./(z-conj(npoles(jj))) - ddpol(jj)./(z-inpoles(jj)) - conj(ddpol(jj))./(z-conj(inpoles(jj)));
      Ak(:,jj+1) = 1i./(z-npoles(jj)) - 1i./(z-conj(npoles(jj))) - 1i.*ddpol(jj)./(z-inpoles(jj)) + 1i.*conj(ddpol(jj))./(z-conj(inpoles(jj)));
    elseif cindex(jj) == 0 % real pole
      Ak(:,jj) = 1./(z-npoles(jj)) - ddpol(jj)./(z-inpoles(jj));
    end
  end

  XX = zeros(Nc,N);
  for nn = 1:Nc

    % Defining AD
    for m=1:N
      nAD(1:Nz,m) = w(nn,:).'.*Ak(1:Nz,m); 
    end 

    B(1:2*Nz,1) = nB(1:2*Nz,nn);

    AD(1:Nz,:) = real(nAD);
    AD(Nz+1:2*Nz,:) = imag(nAD);

    % Normalization factor
    nf = zeros(N,1);
    for pp = 1:N
      nf(pp,1) = norm(AD(:,pp),2); % Euclidean norm
      AD(:,pp) = AD(:,pp)./nf(pp,1); % Normalization
    end

    % Solving direct problem

    % XD = inv((AD.')*AD)*(AD.')*B;
    % XD = AD.'*AD\AD.'*B;
%     XD = pinv(AD)*B;
    XD = AD\B;

    XD = XD./nf; % Renormalization
    XX(nn,1:N) = XD(1:N).';

  end

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Final residues and poles of f

  lsr = XX(:,1:N);
  
  clear res

  res = zeros(2*N,Nc);
  % Real poles have real residues, complex poles have comples residues
  for nn = 1:Nc
    for tt = 1:N
      if cindex(tt) == 1 % conjugate complex couple of poles
        res(tt,nn) = lsr(nn,tt)+1i*lsr(nn,tt+1);
        res(tt+1,nn) = lsr(nn,tt)-1i*lsr(nn,tt+1);
        res(N+tt,nn) = -1*(lsr(tt)+1i*lsr(tt+1))*ddpol(tt);
        res(N+tt+1,nn) = -1*(lsr(tt)-1i*lsr(tt+1))*conj(ddpol(tt));
      elseif cindex(tt) == 0 % real pole
        res(tt,nn) = lsr(nn,tt);
        res(N+tt,nn) = -1*lsr(nn,tt)*ddpol(tt);
      end
    end
  end
  

  poles = npoles;
  fullpoles = effnpoles;

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Calculating responses and residuals

  mresp = zeros(Nz,Nc);
  rdl = zeros(Nz,Nc);
  yr = zeros(Nz,Nc);
  mse = zeros(1,Nc);

  for nn = 1:Nc
    % freq resp of the fit model
    r = res(:,nn);
    p = effnpoles;

    Nf = length(f);
    N = length(p);

    rsp = zeros(Nf,1);
    for ii = 1:Nf
      for jj = 1:N
        rsptemp = r(jj)/(z(ii)-p(jj));
        rsp(ii) = rsp(ii) + rsptemp;
      end
    end

    % Model response
    mresp(:,nn) = rsp;

    % Residual
    yr(:,nn) = y(nn,:).';
    rdl(:,nn) = yr(:,nn) - rsp;
    
    % RMS error
%     rmse(:,nn) = sqrt(sum((abs(rdl(:,nn)./yr(:,nn)).^2))/(Nf-N));
    
    % Chi Square or mean squared error
    % Note that this error is normalized to the input data in order to
    % comparable between different sets of data
    mse(:,nn) = sum((rdl(:,nn)./yr(:,nn)).*conj((rdl(:,nn)./yr(:,nn))))/(Nf-N);
    
  end

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Plotting response
  nf = f./fs;

  switch plotting

    case 0
      % No plot

    case 1
      % LogLog plot for absolute value
      figure(plth)
      subplot(2,1,1);
      p1 = loglog(nf,abs(yr),'k');
      hold on
      p2 = loglog(nf,abs(mresp),'r');
      p3 = loglog(nf,abs(rdl),'b');
      xlabel('Normalized Frequency [f/fs]')
      ylabel('Amplitude')
      legend([p1(1) p2(1) p3(1)],'Original', 'PSDZFIT','Residual')
      hold off

      subplot(2,1,2);
      p4 = semilogx(nf,(180/pi).*unwrap(angle(yr)),'k');
      hold on
      p5 = semilogx(nf,(180/pi).*unwrap(angle(mresp)),'r');
      xlabel('Normalized Frequency [f/fs]')
      ylabel('Phase [Deg]')
      legend([p4(1) p5(1)],'Original', 'PSDZFIT')
      hold off

    case 2
      % Semilogx plot for absolute value
      figure(plth)
      subplot(2,1,1);
      p1 = semilogx(nf,abs(yr),'k');
      hold on
      p2 = semilogx(nf,abs(mresp),'r');
      p3 = semilogx(nf,abs(rdl),'b');
      xlabel('Normalized Frequency [f/fs]')
      ylabel('Amplitude')
      legend([p1(1) p2(1) p3(1)],'Original', 'PSDZFIT','Residual')
      hold off

      subplot(2,1,2);
      p4 = semilogx(nf,(180/pi).*unwrap(angle(yr)),'k');
      hold on
      p5 = semilogx(nf,(180/pi).*unwrap(angle(mresp)),'r');
      xlabel('Normalized Frequency [f/fs]')
      ylabel('Phase [Deg]')
      legend([p4(1) p5(1)],'Original', 'PSDZFIT')
      hold off

    case 3
      % Semilogy plot for absolute value
      figure(plth)
      subplot(2,1,1);
      p1 = semilogy(nf,abs(yr),'k');
      hold on
      p2 = semilogy(nf,abs(mresp),'r');
      p3 = semilogy(nf,abs(rdl),'b');
      xlabel('Normalized Frequency [f/fs]')
      ylabel('Amplitude')
      legend([p1(1) p2(1) p3(1)],'Original', 'PSDZFIT','Residual')
      hold off

      subplot(2,1,2);
      p4 = semilogy(nf,(180/pi).*unwrap(angle(yr)),'k');
      hold on
      p5 = semilogy(nf,(180/pi).*unwrap(angle(mresp)),'r');
      xlabel('Normalized Frequency [f/fs]')
      ylabel('Phase [Deg]')
      legend([p4(1) p5(1)],'Original', 'PSDZFIT')
      hold off

    case 4
      % Linear plot for absolute value
      figure(plth)
      subplot(2,1,1);
      p1 = plot(nf,abs(yr),'k');
      hold on
      p2 = plot(nf,abs(mresp),'r');
      p3 = plot(nf,abs(rdl),'b');
      xlabel('Normalized Frequency [f/fs]')
      ylabel('Amplitude')
      legend([p1(1) p2(1) p3(1)],'Original', 'PSDZFIT','Residual')
      hold off

      subplot(2,1,2);
      p4 = plot(nf,(180/pi).*unwrap(angle(yr)),'k');
      hold on
      p5 = plot(nf,(180/pi).*unwrap(angle(mresp)),'r');
      xlabel('Normalized Frequency [f/fs]')
      ylabel('Phase [Deg]')
      legend([p4(1) p5(1)],'Original', 'PSDZFIT')
      hold off

  end