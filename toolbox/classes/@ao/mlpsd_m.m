% MLPSD_M m-file only version of the LPSD algorithm
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: MLPSD_M m-file only version of the LPSD algorithm
%
% CALL:        [S,Sxx,ENBW] = mlpsd_m(x,f,r,m,L,fs,win,order,olap)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = mlpsd_m(varargin)

  import utils.const.*

  utils.helper.msg(msg.PROC1, 'using MATLAB to compute core DFT');

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

  twopi    = 2.0*pi;

  nx   = length(x);
  nf   = length(f);
  Sxx  = zeros(nf,1);
  S    = zeros(nf,1);
  ENBW = zeros(nf,1);

  disp_each = round(nf/100)*10;

  for jj = 1:nf

    if mod(jj, disp_each) == 0 || jj == 1 || jj == nf
      utils.helper.msg(msg.PROC1, 'computing frequency %04d of %d: %f Hz', jj, nf, f(jj));
    end

    % compute DFT exponent and window
    l = L(jj);
    switch lower(win.type)
      case 'kaiser'
        win = specwin(win.type, l, win.psll);
      otherwise
        win = specwin(win.type, l);
    end

    p     = 1i * twopi * m(jj)/l.*[0:l-1];
    C     = win.win .* exp(p);
    Xolap = (1-olap);
    % do segments
    A  = 0.0;

    % Compute the number of averages we want here
    segLen = l;
    nData  = length(x);
    ovfact = 1 / (1 - olap);
    davg   = (((nData - segLen)) * ovfact) / segLen + 1;
    navg   = round(davg);

    % Compute steps between segments
    if navg == 1
      shift = 1;
    else
      shift = (nData - segLen) / (navg - 1);
    end
    if shift < 1 || isnan(shift)
      shift = 1;
    end

    %   disp(sprintf('Seglen: %d\t | Shift: %f\t | navs: %d', segLen, shift, navg))

    start = 1.0;
    for ii = 1:navg
      % compute start index
      istart = round (start);
      start  = start + shift;

      % get segment
      xs  = [x(istart:istart+l-1)].';

      % detrend segment
      switch order
        case -1
          % do nothing
        case 0
          xs = xs - mean(xs);
        case 1
          xs = detrend(xs);
        otherwise
          xs = polydetrend(xs, order);
      end

      % make DFT
      a   = C*xs;
      A   = A + a*conj(a);

    end

    if mod(jj, disp_each) == 0 || jj == 1 || jj == nf
      utils.helper.msg(msg.PROC2, 'averaged %d segments', navg);
    end

    A2ns     = 2.0*A/navg;
    S1       = win.ws;
    S12      = S1*S1;
    S2       = win.ws2;
    ENBW(jj) = fs*S2/S12;
    Sxx(jj)  = A2ns/fs/S2;
    S(jj)    = A2ns/S12;

  end % for j=1:nf

  varargout{1} = S;
  varargout{2} = Sxx;
  varargout{3} = ENBW;

end

