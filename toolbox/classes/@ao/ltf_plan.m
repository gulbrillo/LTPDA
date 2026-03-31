% LTF_PLAN computes all input values needed for the LPSD and LTFE algorithms.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: LTF_PLAN computes all input values needed for the LPSD and LTFE
%              algorithms.
%
% CALL:       [f, r, b, L, K] = ltf_plan(Ndata, fs, olap, bmin, Lmin, Jdes, Kdes)
%
% INPUTS:     Ndata  - the length of the time-series to be processed
%             fs     - the sample rate of the time-series to be processed
%             olap   - overlap percentage, usually taken from the window function
%             bmin   - the minimum bin number to be used. This is usually taken
%                      from the window function.
%             Lmin   - The minimum segment length.
%             Jdes   - the desired number of frequencies.
%             Kdes   - The desired number of averages.
%
% OUTPUTS:    Each output is a vector, one value per frequency:
%             f      - the frequency
%             r      - frequency resolution (Hz)
%             b      - bin number
%             L      - segment lengths
%             K      - number of averages
%
% PARAMETER LIST:
%
% REFERENCE:  "lpsd revisited: ltf" / S2-AEI-TN-3052
%              2008/02/07  V1.1
%              G Heinzel
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%       q      - a vector of start indices for the segments

function varargout = ltf_plan(varargin)

  %% ------ Check inputs     ------------------------------------------------
  if nargin ~= 7 || nargout ~= 5
    help(mfilename)
    error('### Incorrect usage');
  end

  Ndata  = varargin{1};
  fs     = varargin{2};
  olap   = varargin{3};
  bmin   = varargin{4};
  Lmin   = varargin{5};
  Jdes   = varargin{6};
  Kdes   = varargin{7};

  %% ------ Set up some variables -------------------------------------------

  xov     = (1 - olap/100);
  fmin    = fs / Ndata * bmin;
  fmax    = fs/2;
  fresmin = fs / Ndata;
  freslim = fresmin * (1+xov*(Kdes-1));
  logfact = (Ndata/2)^(1/Jdes) - 1;



  %% ------ Prepare outputs       -------------------------------------------

  f = [];
  r = [];
  b = [];
  L = [];
  K = [];
  % q = [];

  %% ------ Loop over frequency   -------------------------------------------
  fi = fmin;
  while fi < fmax

    fres = fi * logfact;
    if fres <= freslim
      fres = sqrt(fres*freslim);
    end
    if fres < fresmin
      fres = fresmin;
    end

    bin = fi/fres;
    if bin < bmin
      bin = bmin;
      fres = fi/bin;
    end

    dftlen = round(fs / fres);
    if dftlen > Ndata
      dftlen = Ndata;
    end
    if dftlen < Lmin
      dftlen = Lmin;
    end

    nseg = round((Ndata - dftlen) / (xov*dftlen) + 1);
    if nseg == 1
      dftlen = Ndata;
    end

    fres = fs / dftlen;
    bin  = fi / fres;

    % Store outputs
    f = [f fi];
    r = [r fres];
    b = [b bin];
    L = [L dftlen];
    K = [K nseg];

    fi = fi + fres;

  end

  %% ------ Set outputs           -------------------------------------------

  varargout{1} = f.';
  varargout{2} = r.';
  varargout{3} = b.';
  varargout{4} = L.';
  varargout{5} = K.';
end

