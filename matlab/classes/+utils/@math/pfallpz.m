% PFALLPZ all pass filtering to stabilize TF poles and zeros.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DESCRIPTION:
% 
%     All pass filtering in order to stabilize transfer function poles and
%     zeros. It inputs a partial fraction expanded discrete model and
%     outputs a pole-zero minimum phase system
% 
% CALL:
% 
%     [resp,np] = pfallpz(ir,ip,id,mresp,f,fs)
%     [resp,np] = pfallpz(ir,ip,id,mresp,f,fs,minphase)
%     [resp,np,nz] = pfallpz(ir,ip,id,mresp,f,fs,minphase)
% 
% INPUTS:
% 
%     ir: are residues
%     ip: are poles
%     id: is direct term
%     f: is the frequancies vector in (Hz)
%     fs: is the sampling frequency in (Hz)
%     minphase: is a flag assuming true (output a minimum phase system) or
%     false (output a stable non minimum phase system) values. Default,
%     false
%     
% OUTPUTS:
% 
%     resp: is the functions phase frequency response
%     np: are the new stable poles
%
% NOTE:
% 
%     This function make use of signal analysis toolbox functions
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = pfallpz(ir,ip,id,mresp,f,fs,varargin)

  % Reshaping
  [a,b] = size(ir);
  if a<b
    ir = ir.'; % reshape as a column vector
  end

  [a,b] = size(ip);
  if a<b
    ip = ip.'; % reshape as a column vector
  end

  [a,b] = size(f);
  if a<b
    f = f.'; % reshape as a column vector
  end

  [a,b] = size(id);
  if a > b
    id = id.'; % reshape as a row
    id = id(1,:); % taking the first row (the function can handle only simple constant direct terms)
  end

  if isempty(fs)
    fs = 1;
  end
  [a,b] = size(fs);
  if a ~= b
    disp(' Fs has to be a number. Only first term will be considered! ')
    fs = fs(1);
  end
  
  if nargin == 7
    minphase = varargin{1};
  else
    minphase = false;
  end

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  [Na,Nb] = size(ir);
  np = zeros(Na,Nb);
  nz = zeros(Na,Nb);
  for nn = 1:Nb

    r = ir(:,nn);
    d = id(1,nn);
    p = ip;
%     iresp = mresp(:,nn);

%     k = sum(r)+d;

    % stabilizing poles
    sp = p;
    unst = abs(p) > 1;
    sp(unst) = 1./conj(sp(unst));
    
    s = cos((2*pi/fs).*f) + 1i.*sin((2*pi/fs).*f);
    
    pp = p(unst);
    psp = sp(unst);
    for ii = 1:length(s)
      nterm = 1;
      for jj = 1:length(sp(unst))
        nterm = nterm.*(s(ii)-pp(jj))./(s(ii)-psp(jj));
      end
      phs(ii,1) = angle(nterm);
    end
      
    resp(:,nn) = mresp(:,nn).*(cos(phs)+1i.*sin(phs));
    
    % output stable poles
    np(:,nn) = sp;
    
    if minphase
      if d~=0
        error('!!!Minimum phase filers can be obtained only when direct term is zero')
      end
      % finding zeros
%       N = Na+1;
%       [mults, idx] = mpoles(p,1e-15,0);  % checking for poles multiplicity
%       p = p(idx);     % re-arrange poles & residues
%       r = r(idx);
%       den = poly(p);
%       num = conv(den,d);
%       for i=1:Na
%          temp = poly( p([1:(i-mults(i)), (i+1):Na]) );
%          num = num + [r(i)*temp zeros(1,N-length(temp))];
%       end
%       zrs = roots(num);
      D = 0; % direct term of sigma
  
      A = diag(p);
      B = ones(Na,1);
      C = zeros(1,Na);
      % Real poles have real residues, complex poles have comples residues

      cindex=zeros(1,Na);
      for m=1:Na 
        if imag(p(m))~=0  
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


      for kk = 1:Na
        if cindex(kk) == 1
          A(kk,kk)=real(p(kk));
          A(kk,kk+1)=imag(p(kk));
          A(kk+1,kk)=-1*imag(p(kk));
          A(kk+1,kk+1)=real(p(kk));
          B(kk,1) = 2;
          B(kk+1,1) = 0;
          C(1,kk) = real(r(kk,1));
          C(1,kk+1) = imag(r(kk,1));
        elseif cindex(kk) == 0 % real pole
          C(1,kk) = r(kk,1);
        end
      end
      
      [zrs,p2,k] = ss2zp(A,B,C,D,1);
      
      % stabilizing zeros
      szrs = zrs;
      % willing to work with columns
      [a,b] = size(szrs);
      if a<b
        szrs = szrs.'; % reshape as a column vector
        zrs = zrs.';
      end
      % adding the zero at the origin
      zrs = [0;zrs];
      szrs = [0;szrs];
      % do stabilization
      zunst = abs(zrs) > 1;
      szrs(zunst) = 1./conj(zrs(zunst));
      
      zzrs = zrs(zunst);
      zszrs = szrs(zunst);
      for ii = 1:length(s)
        nterm = 1;
        for jj = 1:length(szrs(zunst))
          nterm = nterm.*(s(ii)-zszrs(jj))./(s(ii)-zzrs(jj));
        end
        zphs(ii,1) = angle(nterm);
      end

      resp(:,nn) = resp(:,nn).*(cos(zphs)+1i.*sin(zphs));
      
      % output stable zeros
      nz(:,nn) = szrs;
    end
    
  end
  
  
  % output
  if nargout == 1
    varargout{1} = resp;
  elseif nargout == 2
    varargout{1} = resp;
    varargout{2} = np;
  elseif (nargout == 3) && minphase
    varargout{1} = resp;
    varargout{2} = np;
    varargout{3} = nz;
  else
    error('Too many output arguments!')
  end
end


