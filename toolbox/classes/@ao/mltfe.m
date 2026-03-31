% MLTFE compute log-frequency space TF
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: MLTFE compute log-frequency space TF
%
% CALL:        Txy = mltfe(X,f,r,m,L,fs,win,order,olap,Lmin,method,variance)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = mltfe(varargin)
  
  import utils.const.*
  
  % Get inputs
  X      = varargin{1};
  f      = varargin{2};
  r      = varargin{3};
  m      = varargin{4};
  L      = varargin{5};
  K      = varargin{6};
  fs     = varargin{7};
  win    = varargin{8};
  order  = varargin{9};
  olap   = varargin{10};
  Lmin   = varargin{11};
  method = varargin{12};
  
  % --- Prepare some variables
  si         = size(X);
  nc         = si(1);
  nf         = length(f);
  Txy        = zeros(nf,1);
  dev        = zeros(nf,1);
  disp_each  = round(nf/100)*10;
  
  winType = win.type;
  winPsll = win.psll;
  
  % ----- Loop over Frequency
  for fi=1:nf
    [Txy(fi) dev(fi)]= computeTF(fs, L(fi), K(fi), m, winType, winPsll, X, olap, order, nc, f(fi), fi, nf, disp_each, method);
  end
  
  % Set output
  varargout{1} = Txy;
  varargout{2} = dev;
end

%--------------------------------------------------------------------------
% Function to run over channels
function  [Txy,dev]= computeTF(fs, l, K, m, winType, winPsll, X, olap, order, nc, ffi, fi, nf, disp_each, method)
  
  switch lower(winType)
    case 'kaiser'
      lwin = specwin(winType, l, winPsll);
    otherwise
      lwin = specwin(winType, l);
  end
  
  % Compute DFT coefficients
  twopi = 2.0*pi;
  p     = 1i * twopi * m(fi)/l.*[0:l-1];
  C     = lwin.win .* exp(p);
  
  if mod(fi,disp_each) == 0 || fi == 1 || fi == nf
    utils.helper.msg(utils.const.msg.PROC1, 'computing frequency %04d of %04d: %f Hz', fi, nf, ffi);
  end
  % Loop over input channels
  [Txy,dev] = in2out(l, X, K, olap, order, nc, method, C, lwin, fs);
  
end

%--------------------------------------------------------------------------
% Compute 1 input to multiple outputs
function [Txy,dev]= in2out(l, X, K, olap, order, nc, method, C, lwin, fs)
  
  % if no errors are required the function returns zero but errors are not
  % stored in the final ao
  dev = 0;
  
   switch lower(method)
    case 'tfe'
      % Core cross-DFT part in C-mex file
      % We need cross-spectrum and Power spectrum
      [XY, XX, YY, M2, nsegs] = ltpda_dft(X(1,:), X(2,:), l, C, olap, order);
      Txy  = conj(XY)/(XX);
      if nsegs == 1
        dev = Inf;
      else
        dev = sqrt((nsegs/(nsegs-1)^2)*(YY./XX).*(1 - (abs(XY).^2)./(XX.*YY)));
%       dP =  sqrt((k/(k-1)^2)*(Pyy./Pxx).*(1 - (abs(Pxy).^2)./(Pxx.*Pyy)));
      end
      
    case 'cpsd'
      % Core cross-DFT part in C-mex file
      [XY, XX, YY, M2, nsegs] = ltpda_dft(X(1,:), X(2,:), l, C, olap, order);
      S1      = lwin.ws;
      S2      = lwin.ws2;
      Txy  = 2.0*XY/fs/S2;
      Var = 4.0*M2/fs^2/S2^2/nsegs;
       if nsegs == 1
        dev = Inf;
      else
        dev = sqrt(Var);
       end
      
    case 'mscohere'
      % Core cross-DFT part in C-mex file
      % We need cross-spectrum and Power spectrum
      [XY, XX, YY, M2, nsegs] = ltpda_dft(X(1,:), X(2,:), l, C, olap, order);
      Txy  = (abs(XY).^2)./(XX.*YY); % Magnitude-squared coherence
      if nsegs == 1
        dev = Inf;
      else
        dev = sqrt((2*Txy/nsegs).*(1-Txy).^2);
      end
      
    case 'cohere'
      % Core cross-DFT part in C-mex file
      % We need cross-spectrum and Power spectrum
      [XY, XX, YY, M2, nsegs] = ltpda_dft(X(1,:), X(2,:), l, C, olap, order);
      Txy  = XY./sqrt(XX.*YY);  % Complex coherence
      if nsegs == 1
        dev = Inf;
      else
        dev = sqrt((2*abs(Txy)/nsegs).*(1-abs(Txy)).^2);
      end
  end
  
end
