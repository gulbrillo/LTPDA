% MLPSD_MEX calls the ltpda_dft.mex to compute the DFT part of the LPSD algorithm
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: MLPSD_MEX calls the ltpda_dft.mex to compute the DFT part of the
%              LPSD algorithm
%
% CALL:        [S,Sxx,ENBW] = mlpsd_mex(x,f,r,m,L,fs,win,order,olap)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = mlpsd_mex(varargin)
  
  import utils.const.*
  
  utils.helper.msg(msg.PROC1, 'using ltpda_dft.mex to compute core DFT');
  
  % Get inputs
  x     = varargin{1};
  f     = varargin{2};
  r     = varargin{3};
  m     = varargin{4};
  L     = varargin{5};
  fs    = varargin{6};
  win   = varargin{7};
  order = varargin{8};
  olap  = varargin{9};
  Lmin  = varargin{10};
  
  twopi    = 2.0*pi;
  nf   = length(f);
  Sxx  = zeros(nf,1);
  S    = zeros(nf,1);
  ENBW = zeros(nf,1);
  devxx  = zeros(nf,1);
  dev    = zeros(nf,1);
  
  disp_each = round(nf/100)*10;
  
  winType = win.type;
  winPsll = win.psll;
  
  minReached = 0;
  
  for jj = 1:nf
    
    if mod(jj, disp_each) == 0 || jj == 1 || jj == nf
      utils.helper.msg(msg.PROC1, 'computing frequency %04d of %d: %f Hz', jj, nf, f(jj));
    end
    
    % compute DFT exponent and window
    l = L(jj);
    
    % Check if we need to update the window values
    % - once we reach Lmin, the window values don't change.
    if ~minReached
      switch lower(winType)
        case 'kaiser'
          win = specwin(winType, l, winPsll);
        otherwise
          win = specwin(winType, l);
      end
      if l == Lmin
        minReached = 1;
      end
    end
    
    p     = 1i * twopi * m(jj)/l.*(0:l-1);
    C     = win.win .* exp(p);
    
    % Core DFT part in C-mex file
    [A, B,nsegs] = ltpda_dft(x, l, C, olap, order);
    
    if mod(jj, disp_each) == 0 || jj == 1 || jj == nf
      utils.helper.msg(msg.PROC2, 'averaged %d segments', nsegs);
    end
    
    A2ns    = 2.0*A;
    B2ns    = 4.0*B/nsegs;
    S1      = win.ws;
    S12     = S1*S1;
    S2      = win.ws2;
    ENBW(jj) = fs*S2/S12;
    %        scale asd/psd
    Sxx(jj)  = A2ns/fs/S2;
    S(jj)    = A2ns/S12;
    %        scale sqrt(variance)
    devxx(jj)  = sqrt(B2ns/fs^2/S2^2);
    dev(jj)    = sqrt(B2ns/S12^2);
    
  end
  
  varargout{1} = S;
  varargout{2} = Sxx;
  varargout{3} = dev;
  varargout{4} = devxx;
  varargout{5} = ENBW;
end

