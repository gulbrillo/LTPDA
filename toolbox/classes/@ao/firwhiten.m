% FIRWHITEN whitens the input time-series by building an FIR whitening filter.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: FIRWHITEN whitens the input time-series by building an FIR
%              whitening filter. The algorithm ultimately uses fir2() to
%              build the whitening filter.
%
% ALGORITHM:
%            1) Make ASD of time-series
%            2) Perform running median to get noise-floor estimate (ao/smoother)
%            3) Invert noise-floor estimate
%            4) Call mfir() on noise-floor estimate to produce whitening filter
%            5) Filter data
%
% CALL:                   b = firwhiten(a, pl) % returns whitened time-series AOs
%                [b, filts] = firwhiten(a, pl) % returns the mfir filters used
%           [b, filts, nfs] = firwhiten(a, pl) % returns the noise-floor
%                                              % estimates as fsdata AOs
%
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'firwhiten')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = firwhiten(varargin)

  callerIsMethod = utils.helper.callerIsMethod;

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

  % Decide on a deep copy or a modify
  bs = copy(as, nargout);
  inhists = copy([as.hist],1);

  % combine plists
  pl = applyDefaults(getDefaultPlist(), pl);

  % Extract necessary parameters
  iNfft   = find_core(pl, 'Nfft');
  bw      = find_core(pl, 'bw');
  hc      = find_core(pl, 'hc');
  swin    = find_core(pl, 'win');
  order   = find_core(pl, 'order');
  fwin    = find_core(pl, 'FIRwin');
  Ntaps   = find_core(pl, 'Ntaps');

  % Loop over input AOs
  filts    = [];
  nfs      = [];

  for j=1:numel(bs)
    if ~isa(bs(j).data, 'tsdata')
      warning('!!! %s expects ao/tsdata objects. Skipping AO %s', mfilename, ao_invars{j});
      bs(j) = [];
    else
      % get Nfft
      if iNfft < 0 || isempty(iNfft)
        Nfft = length(bs(j).data.y);
      else
        Nfft = iNfft;
      end
      utils.helper.msg(msg.PROC1, 'building spectrum');
      % Make spectrum
      axx = psd(bs(j), plist('Nfft', Nfft, 'Win', swin, 'Order', order, 'Scale', 'ASD'));
      % make noise floor estimate
      utils.helper.msg(msg.PROC1, 'estimating noise-floor');
      nxx = smoother(axx, plist('width', bw, 'hc', hc));
      % collect noise-floor estimates for output
      nfs = [nfs nxx];
      % invert and make weights
      w = 1./nxx;
      % Make mfir object
      utils.helper.msg(msg.PROC1, 'building filter');
      ff = mfir(w, plist('Win', fwin, 'N', Ntaps));
      % collect filters for output
      filts = [filts ff];
      % Filter data
      utils.helper.msg(msg.PROC1, 'filter data');
      filter(bs(j), ff);
      % Set name
      bs(j).name = sprintf('firwhiten(%s)', ao_invars{j});
      % add history
      if ~callerIsMethod
        bs(j).addHistory(getInfo('None'), pl, ao_invars(j), inhists(j));
      end
      % clear errors
      bs(j).clearErrors;
      
    end
  end
  
  % Any errors are meaningless after this process, so clear them on both
  % axes.
  bs.clearErrors(plist('axis', 'xy'));

  % Set outputs
  if nargout > 0
    varargout{1} = bs;
  end
  if nargout > 1
    varargout{2} = filts;
  end
  if nargout > 2
    varargout{3} = nfs;
  end
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
  if exist('pl', 'var')==0 || isempty(pl)
    pl = buildplist();
  end
  plout = pl;  
end

function pl = buildplist()
  
  pl = plist();
  
  % Nfft
  p = param({'Nfft', ['The number of points in the FFT used to estimate<br>'...
                      'the power spectrum. If unspecified, this is calculated as Ndata/4.']}, paramValue.DOUBLE_VALUE(-1));
  pl.append(p);
  
  % BW
  p = param({'bw', ['The bandwidth of the running median filter used to<br>'...
                    'estimate the noise-floor.']}, {1, {20}, paramValue.OPTIONAL});
  pl.append(p);                
                  
  % HC
  p = param({'hc', 'The cutoff used to reject outliers (0-1).'}, {1, {0.8}, paramValue.OPTIONAL});
  pl.append(p);
  
  % Win
  p = param({'Win', 'Spectral window used in spectral estimation.'}, paramValue.WINDOW);
  pl.append(p);
  
  % Order
  p = param({'Order',['The order of segment detrending:<ul>', ...
    '<li>-1 - no detrending</li>', ...
    '<li>0 - subtract mean</li>', ...
    '<li>1 - subtract linear fit</li>', ...
    '<li>N - subtract fit of polynomial, order N</li></ul>']}, paramValue.DETREND_ORDER);
  pl.append(p);
  
  % FIR win
  p = param({'FIRwin', 'The window to use in the filter design.'}, paramValue.WINDOW);
  pl.append(p);
  
  % Ntaps
  p = param({'Ntaps', 'The length of the FIR filter to build.'}, {1, {256}, paramValue.OPTIONAL});
  pl.append(p);
  
end

% END
