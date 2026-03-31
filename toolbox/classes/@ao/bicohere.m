% BICOHERE computes the bicoherence of two input time-series
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: BICOHERE computes the bicoherence of two input time-series.
%
% CALL:        bs = bicohere(a1,a2,pl)
%
% INPUTS:      aN    - input analysis objects
%              a1,a2 - input analysis objects array
%              pl    - input parameter list
%
% OUTPUTS:     bs   - xyz data analysis object
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'bicohere')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function varargout = bicohere(varargin)
  
  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  import utils.const.*
  utils.helper.msg(msg.PROC3, 'running %s/%s', mfilename('class'), mfilename);
  
  % Collect input variable names
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
  
  % Collect all AOs and plists
  [as, ao_invars] = utils.helper.collect_objects(varargin(:), 'ao', in_names);
  pl              = utils.helper.collect_objects(varargin(:), 'plist', in_names);
  
  if numel(as) ~= 2
    error('bicohere only works with 2 time-series at the moment.');
  end
  
  % Get data
  a  = as(1);
  b  = as(2);
  
  % same fs?
  if a.data.fs ~= b.data.fs
    error('### Two time-series have different sample rates.');
  end
  
  % Same length vectors?
  if a.len ~= b.len
    error('### Two time-series must have same length');
  end
  
  L = a.len;
  
  % Combine plists
  pl = applyDefaults(getDefaultPlist, pl); 
  usepl = utils.helper.process_spectral_options(pl, 'lin', a.len, a.fs);
  
    
  % Parse inputs
  win          = find_core(usepl, 'Win');
  nfft         = find_core(usepl, 'Nfft');
  olap         = find_core(usepl, 'Olap');
  xOlap        = round(olap*nfft/100);
  detrendOrder = find_core(usepl, 'order');
  fs           = a.fs;
  winVals      = win.win.'; % because we always get a column from ao.y
  
  % Compute segment details
  
  select = 1:(nfft+1)/2;
  m = zeros(length(select), length(select));
  
  nSegments = fix((L - xOlap)./(nfft - xOlap));
  utils.helper.msg(msg.PROC3, 'N segment: %d', nfft);
  utils.helper.msg(msg.PROC3, 'N overlap: %d', xOlap);
  utils.helper.msg(msg.PROC3, 'N segments: %d', nSegments);
  
  % Compute start and end indices of each segment
  segmentStep = nfft-xOlap;
  segmentStarts = 1:segmentStep:nSegments*segmentStep;
  segmentEnds   = segmentStarts+nfft-1;
  
  
  for ii = 1:nSegments
    if detrendOrder < 0
      Xseg = a.y(segmentStarts(ii):segmentEnds(ii));
      Yseg = b.y(segmentStarts(ii):segmentEnds(ii));
    else
      [Xseg,coeffs] = ltpda_polyreg(a.y(segmentStarts(ii):segmentEnds(ii)), detrendOrder);
      [Yseg,coeffs] = ltpda_polyreg(b.y(segmentStarts(ii):segmentEnds(ii)), detrendOrder);
    end
     
    % window
    xw = Xseg.*winVals;
    yw = Yseg.*winVals;

    % FFT
    xx2s = fft(xw);    
    xx   = xx2s(select);
    yy2s = fft(yw);
    yy   = yy2s(select);
    
    scalex = abs(xx);
    scaley = abs(yy);
    sc = scalex * scaley';
    m = m + (xx * yy')./sc;
        
  end
    
  m = m./nSegments;
  
  f = psdfreqvec('npts',nfft,'Fs',fs);
  f = f(select);
  do = xyzdata(f, f, m);
  do.setXunits(unit.Hz);
  do.setYunits(unit.Hz);
  do.setZunits(a.yunits*b.yunits);
  
  ma = ao(do);
  ma.setName(sprintf('%s, %s', a.name, b.name));
  ma.addHistory(getInfo('None'), usepl, ao_invars, [a.hist b.hist]);

  
  % Set output
  varargout{1} = ma;
end

%--------------------------------------------------------------------------
% Get Info Object
%--------------------------------------------------------------------------
function ii = getInfo(varargin)
  if nargin == 1 && strcmpi(varargin{1}, 'None')
    sets = {};
    pl   = [];
  else
    sets = {'Default'};
    pl   = getDefaultPlist;
  end
  % Build info object
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.sigproc, '', sets, pl);
end

%--------------------------------------------------------------------------
% Get Default Plist
%--------------------------------------------------------------------------
function plout = getDefaultPlist()
  persistent pl;  
  if ~exist('pl', 'var') || isempty(pl)
    pl = buildplist();
  end
  plout = pl;  
end

function pl = buildplist()
  
  % General plist for Welch-based, linearly spaced spectral estimators
  pl = plist.WELCH_PLIST;
  
end
% END

