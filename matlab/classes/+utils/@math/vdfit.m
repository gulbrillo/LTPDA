% VDFIT: Fit discrete models to frequency responses
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DESCRIPTION:
% 
%     Fits a discrete model to a frequency response using relaxed z-domain
%     vector fitting algorithm [1 - 3]. The function is able to fit more
%     than one frequency response per time. In case that more than one
%     frequency response is passed as input, they are fitted with a set of
%     common poles. Model functions are expanded in partial fractions:
% 
%                r1                  rN
%     f(z) = ----------- + ... + ----------- + d
%            1-p1*z^{-1}         1-pN*z^{-1}
% 
% CALL:
% 
%     [res,poles,dterm,mresp,rdl,mse] = vdfit(y,f,poles,weight,fitin)
% 
% INPUTS:
% 
%     - y: Is a vector with the frequency response data.
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
%       - fitin.plot = 1; plot fit results in loglog scale.
%       - fitin.plot = 2; plot fit results in semilogx scale.
%       - fitin.plot = 3; plot fit results in semilogy scale.
%       - fitin.plot = 4; plot fit results in linear xy scale.
%       - fitin.ploth = #; a plot handle to define the figure target for
%       plotting. Default: [1]
% 
% OUTPUT:
% 
%     - res: vector or residues.
%     - poles: vector of poles.
%     - dterm: direct term d.
%     - mresp: frequency response of the fitted model
%     - rdl: residuals y - mresp
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
%       res is a (Npx1) vector
%       poles is a (Npx1) vector
%       dterm is a constant
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
%       res is a (NpxNt) vector
%       poles is a (Npx1) vector
%       dterm is a (1xNt) vector
%       mresp is a (NxNt) vector
%       rdl is a (NxNt) vector
%       mse is a (1xNt) vector
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
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [res,poles,dterm,mresp,rdl,mse] = vdfit(y,f,poles,weight,fitin)

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Collecting inputs

  % Default input struct
  defaultparams = struct('stable',0, 'dterm',0, 'fs',1, 'plot',0, 'ploth',1,...
    'regout',-1, 'idsamp',1e3, 'idamp', 1e-3, 'weightmse', false);

  names = {'stable','dterm','fs','plot','ploth','regout','idsamp','idamp','weightmse'};

  % collecting input and default params
  if ~isempty(fitin)
    for jj=1:length(names)
      if isfield(fitin, names(jj)) && ~isempty(fitin.(names{1,jj}))
       defaultparams.(names{1,jj}) = fitin.(names{1,jj});
      end
    end
  end

  stab = defaultparams.stable; % Enforce pole stability is is 1
  dt = defaultparams.dterm; % 1 to fit with direct term
  fs = defaultparams.fs; % sampling frequency
  plotting = defaultparams.plot; % set to 1 if plotting is required
  plth = defaultparams.ploth; % set the figure target
  regout = defaultparams.regout; % set the strategy for complex plane fitting
  idsamp = defaultparams.idsamp; % number of samples to define impulse response
  idamp = defaultparams.idamp; % maximum aplitude of impulse response adimtted at idsamp
  weightmse = defaultparams.weightmse; % decide to weight or not the mse with the weights
  
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

  if dt
    dl = 1; % Fit with direct term
  else
    dl = 0; % Fit without direct term
  end

  % definition of z
  z = cos(2.*pi.*f./fs)+1i.*sin(2.*pi.*f./fs);

  Nz = length(z);

  [Nc,Ny] = size(y);
  if Ny ~= Nz
    error('### The number of data points is different from the number of frequency points.')
  end

  %Tolerances used by relaxed version of vector fitting
  TOLlow=1e-8;
  TOLhigh=1e8;
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Normalizing y

    for nn = 1:Nc
      y(nn,:) = y(nn,:)./z;
    end

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

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Augmented problem
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  % Matrix initialinzation
  BA = zeros(Nc*Nz+1,1);
  Ak=zeros(Nz,N+1);
  AA=zeros(Nz*Nc+1,(N+dl)*Nc+N+1);
  nf = zeros(1,Nc*(N+dl)+N+1); % Normalization factor

  % Defining Ak
  for jj = 1:N
    if cindex(jj) == 1 % conjugate complex couple of poles
      Ak(:,jj) = 1./(z-poles(jj)) + 1./(z-conj(poles(jj)));
      Ak(:,jj+1) = 1i./(z-poles(jj)) - 1i./(z-conj(poles(jj)));
    elseif cindex(jj) == 0 % real pole
      Ak(:,jj) = 1./(z-poles(jj));
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
    idc=(nn-1)*(N+dl)+1;

    for mm =1:N+dl % Diagonal blocks
      AA(ida:idb,idc-1+mm) = wg.*Ak(1:Nz,mm);
    end
    for mm =1:N+1 % Last right blocks
      AA(ida:idb,Nc*(N+dl)+mm) = -wg.*(Ak(1:Nz,mm).*y(nn,1:Nz).');
    end

  end

  % setting the last row of AA and BA for the relaxion condition
  for qq = 1:N+1
    AA(Nc*Nz+1,Nc*(N+dl)+qq) = real(sc*sum(Ak(:,qq)));
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

  lsr = XA((N+dl)*Nc+1:(N+dl)*Nc+N,1); % collect the least square results

  D = XA(end); % direct term of sigma
  
  CPOLES = diag(poles);
  B = ones(N,1);
  C = lsr.';
  
  for kk = 1:N
    if cindex(kk) == 1
      CPOLES(kk,kk)=real(poles(kk));
      CPOLES(kk,kk+1)=imag(poles(kk));
      CPOLES(kk+1,kk)=-1*imag(poles(kk));
      CPOLES(kk+1,kk+1)=real(poles(kk));
      B(kk,1) = 2;
      B(kk+1,1) = 0;
    end
  end
  
  H = CPOLES-B*C/D;
  
  szeros=eig(H);
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Exclude a region of the complex plane
  switch regout
    case -1
      % do nothing
    case 0
      % do nothing
    case 1
      % set the maximum admitted value for stable poles
      target_pole = (idamp)^(1/idsamp);
      % get stable poles outside the fixed limit
      uptgr = ((abs(szeros) > target_pole) & (abs(szeros) <= 1) & (imag(szeros)==0));
      uptgi = ((abs(szeros) > target_pole) & (abs(szeros) <= 1) & (imag(szeros)~=0));
      % get unstable polse smaller than minimum value
      lwtgr = ((abs(szeros) < 1/target_pole) & (abs(szeros) > 1) & (imag(szeros)==0));
      lwtgi = ((abs(szeros) < 1/target_pole) & (abs(szeros) > 1) & (imag(szeros)~=0));
      % get the maximum shift needed
      ushiftr = max(abs(abs(szeros(uptgr))-target_pole));
      ushifti = max(abs(abs(szeros(uptgi))-target_pole));
      lshiftr = max(abs(abs(szeros(lwtgr))-1/target_pole));
      lshifti = max(abs(abs(szeros(lwtgi))-1/target_pole));
      % shifting inside
      szeros(uptgr) = (abs(szeros(uptgr))-ushiftr).*sign(szeros(uptgr));
      szeros(uptgi) = (abs(szeros(uptgi))-ushifti).*exp(1i.*angle(szeros(uptgi)));
      % shifting outside
      szeros(lwtgr) = (abs(szeros(lwtgr))+lshiftr).*sign(szeros(lwtgr));
      szeros(lwtgi) = (abs(szeros(lwtgi))+lshifti).*exp(1i.*angle(szeros(lwtgi)));
  end
      

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Ruling out unstable poles

  % This option force the poles of f to stay inside the unit circle
  if stab
    unst = abs(szeros) > 1;
    szeros(unst) = 1./conj(szeros(unst));
  end
  szeros = sort(szeros);
  N = length(szeros);

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Separating complex poles from real poles and ordering

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

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Direct problem
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  % Matrix initialinzation
  nB(1:Nz,1:Nc) = real(w.*y).';
  nB(Nz+1:2*Nz,1:Nc) = imag(w.*y).';

  B = zeros(2*Nz,1);
  nAD = zeros(Nz,N+dl);
  AD = zeros(2*Nz,N+dl);
  Ak = zeros(Nz,N+dl);

  for jj = 1:N
    if cindex(jj) == 1 % conjugate complex couple of poles
      Ak(:,jj) = 1./(z-npoles(jj)) + 1./(z-npoles(jj+1));
      Ak(:,jj+1) = 1i./(z-npoles(jj)) - 1i./(z-npoles(jj+1));
    elseif cindex(jj) == 0 % real pole
      Ak(:,jj) = 1./(z-npoles(jj));
    end
  end

  if dt
  %   Ak(1:Nz,N+dl) = ones(Nz,1); % considering the direct term
    Ak(1:Nz,N+dl) = 1./z;
  end

  XX = zeros(Nc,N+dl);
  for nn = 1:Nc

    % Defining AD
    for m=1:N+dl
      nAD(1:Nz,m) = w(nn,:).'.*Ak(1:Nz,m); 
    end 

    B(1:2*Nz,1) = nB(1:2*Nz,nn);

    AD(1:Nz,:) = real(nAD);
    AD(Nz+1:2*Nz,:) = imag(nAD);

    % Normalization factor
    nf = zeros(N+dl,1);
    for pp = 1:N+dl
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

  res = zeros(N,Nc);
  % Real poles have real residues, complex poles have comples residues
  for nn = 1:Nc
    for tt = 1:N
      if cindex(tt) == 1 % conjugate complex couple of poles
        res(tt,nn) = lsr(nn,tt)+1i*lsr(nn,tt+1);
        res(tt+1,nn) = lsr(nn,tt)-1i*lsr(nn,tt+1);
      elseif cindex(tt) == 0 % real pole
        res(tt,nn) = lsr(nn,tt);
      end
    end
  end

  poles = npoles;

  if dt
    dterm = XX(:,N+dl).';
  else
    dterm = zeros(1,Nc);
  end

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Calculating responses and residuals

  mresp = zeros(Nz,Nc);
  rdl = zeros(Nz,Nc);
  yr = zeros(Nz,Nc);
  mse = zeros(1,Nc);

  for nn = 1:Nc
    % freq resp of the fit model
    r = res(:,nn);
    p = poles;
    d = dterm(:,nn);

    Nf = length(f);
    N = length(p);

    % Defining normalized frequencies
    fn = f./fs;

%     rsp = zeros(Nf,1);
%     indx = 0:length(d)-1;
%     for ii = 1:Nf
%       for jj = 1:N
%         rsptemp = exp(1i*2*pi*fn(ii))*r(jj)/(exp(1i*2*pi*fn(ii))-p(jj));
%         rsp(ii) = rsp(ii) + rsptemp;
%       end
%       % Direct terms response
%       rsp(ii) = rsp(ii) + sum(((exp((1i*2*pi*f(ii))*ones(length(d),1))).^(-1.*indx)).*d);
%     end

    rsp = zeros(Nf,1);
    indx = 0:length(d)-1;
    for ii = 1:Nf
      rsp(ii) = sum((exp(1i*2*pi*fn(ii)) * r) ./ (exp(1i*2*pi*fn(ii)) - p));      
      % Direct terms response
      rsp(ii) = rsp(ii) + sum(((exp((1i*2*pi*f(ii))*ones(length(d),1))).^(-1.*indx)).*d);
    end
    
    % Model response
    mresp(:,nn) = rsp;

    % Residual
    yr(:,nn) = (y(nn,:).*z).';
    rdl(:,nn) = yr(:,nn) - rsp;
    
    % RMS error
%     rmse(:,nn) = sqrt(sum((abs(rdl(:,nn)./yr(:,nn)).^2))/(Nf-N));
    
    % Chi Square or mean squared error
    % Note that this error is normalized to the input data in order to
    % comparable between different sets of data
    %mse(:,nn) = sum((rdl(:,nn)./yr(:,nn)).*conj((rdl(:,nn)./yr(:,nn))))/(Nf-N);
    if weightmse
      % weight mse with weights, should be used with external weights
      mse(:,nn) = sum(abs(w(nn,:).').*(abs(rdl(:,nn)./yr(:,nn)).^2))/(Nf-N);
    else
      % do not weight mse with weights, should be used for 1/abs(y) weights
      mse(:,nn) = sum((rdl(:,nn)./yr(:,nn)).*conj((rdl(:,nn)./yr(:,nn))))/(Nf-N);
    end
    
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
      legend([p1(1) p2(1) p3(1)],'Original', 'VDFIT','Residual')
      hold off

      subplot(2,1,2);
      p4 = semilogx(nf,(180/pi).*unwrap(angle(yr)),'k');
      hold on
      p5 = semilogx(nf,(180/pi).*unwrap(angle(mresp)),'r');
      xlabel('Normalized Frequency [f/fs]')
      ylabel('Phase [Deg]')
      legend([p4(1) p5(1)],'Original', 'VDFIT')
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
      legend([p1(1) p2(1) p3(1)],'Original', 'VDFIT','Residual')
      hold off

      subplot(2,1,2);
      p4 = semilogx(nf,(180/pi).*unwrap(angle(yr)),'k');
      hold on
      p5 = semilogx(nf,(180/pi).*unwrap(angle(mresp)),'r');
      xlabel('Normalized Frequency [f/fs]')
      ylabel('Phase [Deg]')
      legend([p4(1) p5(1)],'Original', 'VDFIT')
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
      legend([p1(1) p2(1) p3(1)],'Original', 'VDFIT','Residual')
      hold off

      subplot(2,1,2);
      p4 = semilogy(nf,(180/pi).*unwrap(angle(yr)),'k');
      hold on
      p5 = semilogy(nf,(180/pi).*unwrap(angle(mresp)),'r');
      xlabel('Normalized Frequency [f/fs]')
      ylabel('Phase [Deg]')
      legend([p4(1) p5(1)],'Original', 'VDFIT')
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
      legend([p1(1) p2(1) p3(1)],'Original', 'VDFIT','Residual')
      hold off

      subplot(2,1,2);
      p4 = plot(nf,(180/pi).*unwrap(angle(yr)),'k');
      hold on
      p5 = plot(nf,(180/pi).*unwrap(angle(mresp)),'r');
      xlabel('Normalized Frequency [f/fs]')
      ylabel('Phase [Deg]')
      legend([p4(1) p5(1)],'Original', 'VDFIT')
      hold off

  end
