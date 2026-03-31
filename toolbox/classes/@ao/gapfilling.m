% GAPFILLING fills possible gaps in data.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: GAPFILLING interpolated data between two data
%              segments. This function might be useful for possible
%              gaps or corrupted data. Two different types of
%              interpolating are available: linear and spline, the latter
%              results in a smoother curve between the two data segments.
%
% CALL:        b = gapfilling(a1, a2, pl)
%
% INPUTS:      a1 - data segment previous to the gap
%	             a2 - data segment posterior to the gap
%	             pl - parameter list
%
% OUTPUTS:     b - data segment containing a1, a2 and the filled data
%                  segment, i.e., b=[a1 datare_filled a2].
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'gapfilling')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = gapfilling(varargin)
  
  %%% Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  if nargout == 0
    error('### Cat cannot be used as a modifier. Please give an output variable.');
  end
  
  % Collect input variable names
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
  
  % Collect all AOs
  [as, ao_invars] = utils.helper.collect_objects(varargin(:), 'ao', in_names);
  pli             = utils.helper.collect_objects(varargin(:), 'plist', in_names);
  
  %%%%%% Some input checks
  if length(as)~=2
    error('### This method can handle only two analysis objects.')
  end
  
  % Check for the right data object
  if ~isa(as(1).data, 'tsdata') || ~isa(as(1).data, 'tsdata')
    error(' ### Gap filling requires tsdata (time-series) inputs.')
  end
  
  % Check x-units
  if ~isequal(as(1).xunits, as(2).xunits)
    error('### Data have different X units.');
  end
  
  % Check y-units
  if ~isequal(as(1).yunits, as(2).yunits)
    error('### Data have different Y units.');
  end
  
  %%%%% Get input parameters
  
  if as(1).x(1) + double(as(1).t0) < as(2).x(1) + double(as(2).t0)
    a1  = as(1);
    a2  = as(2);
  else
    a1  = as(2);
    a2  = as(1);
  end
  
  pls = applyDefaults(getDefaultPlist(), pli);
  
  method   = find_core(pls, 'method');  % method definition: linear or 'spline'
  addnoise = utils.prog.yes2true(find_core(pls, 'addnoise')); % decide whether add noise or not in the filled data
  
  if a1.fs ~= a2.fs
    warning('Sampling frequencies of the two AOs are different. The sampling frequency of the first AO will be used to reconstruct the gap.')
  end
  
  
  a1_length = len(a1);
  a2_length = len(a2);
  start_a2  = a2.t0.double + a2.x(1);
  end_a1    = a1.t0.double + a1.x(1) + a1.nsecs - 1/a1.fs;
  gaptime   = start_a2 - end_a1;
  gapn      = gaptime*a1.fs - 1;
  t         = (1:1:gapn)'/a1.fs;
  
  % Check if there is a gap between the AOs or not
  if isempty(t)
    error('### There is no gap between the two analysis objects. Please use ao/join instead.');
  end
  
  %--- gapfilling process itself
  if strcmp(method,'linear')
    % linear interpolation method ---xfilled=(deltay/deltax)*t+y1(length(y1))---
    if len(a1)>10 && len(a2)>10
      dy = mean(a2.y(1:10))-mean(a1.y(a1_length-10:a1_length));
      
      filling_data = (dy/gaptime)*t + mean(a1.y(a1_length-10:a1_length));
      filling_time = (1:1:gapn)'/a1.fs + a1.x(a1_length);
    else
      error('### Not enough data in the data segments (min=11 for each one for the linear method).');
    end
    
  elseif strcmp(method,'spline') % spline method xfilled = a*T^3 + b*T^2 + c*T +d
    
    if len(a1)>1000 && len(a2)>1000
      
      % derivatives of the input data are calculated
      da1 = diff(a1.y(1:100:a1_length))*(a1.fs/100);
      da1 = tsdata(da1, a1.fs/100);
      da1 = ao(da1);
      
      da2 = diff(a2.y(1:100:a2_length))*(a2.fs/100);
      da2 = tsdata(da2, a2.fs/100);
      da2 = ao(da2);
      
      % This filters the previous derivatives
      % filters parameters are obtained
      plfa1 = getlpFilter(a1.fs/100);
      plfa2 = getlpFilter(a2.fs/100);
      
      lpfa1 = miir(plfa1);
      lpfpla1 = plist(param('filter', lpfa1));
      
      lpfa2 = miir(plfa2);
      lpfpla2 = plist(param('filter', lpfa2));
      
      % derivatives are low-pass filtered
      da1filtered = filtfilt(da1, lpfpla1);
      da2filtered = filtfilt(da2, lpfpla2);
      
      % coefficients are calculated
      c = mean(da1filtered.y(len(da1filtered)...
        -10:len(da1filtered)));
      d = mean(a1.y(len(a1)-10:len(a1)));
      
      a=(2*d+(c+mean(da2filtered.y(1:10)))...
        *gaptime-2*mean(a2.y(1:10)))/(gaptime.^3);
      
      b=-(3*d+2*c*gaptime+mean(da2filtered.y(1:10))...
        *gaptime-3*mean(a2.y(1:10)))/(gaptime^2);
      
      % filling data is calculated with the coefficients a, b, c and d
      filling_data = a*t.^3+b*t.^2+c*t+d;
      filling_time = (1:1:gapn)'/a1.fs + a1.x(a1_length);
    else
      error('### Not enough data in data segments (min=1001 in spline method)');
    end
    
  end
  
  % this add noise (if desired) to the filled gap
  if addnoise
    % calculation of the standard deviation after eliminating the low-frequency component
    phpf = gethpFilter(a1.fs);
    ax = tsdata(a1.y, a1.fs);
    ax = ao(ax);
    hpf = miir(phpf);
    hpfpl = plist(param('filter', hpf));
    xhpf = filter(ax, hpfpl);
    hfnoise = std(xhpf);
    
    % noise is added to the filling data
    filling_data = filling_data + randn(length(filling_data),1)*hfnoise.data.getY;
  end
  
  % join data
  filling_data = [a1.y; filling_data; a2.y];
  filling_time = [a1.x; filling_time; a2.x];
  
  % preserves data shape
  if ~iscolumn(a1.data.y)
    filling_data = filling_data.';
    filling_time = filling_time.';
  end
  
  % create new output tsdata
  ts = tsdata(filling_time, filling_data);
  ts.setYunits(a1.yunits);
  ts.setXunits(a1.xunits);
  
  % make output analysis object
  b = ao(ts);
  b.setT0(a1.t0);
  b.name = sprintf('gapfilling(%s,%s)', ao_invars{1}, ao_invars{2});
  b.addHistory(getInfo('None'), pls, [ao_invars(1) ao_invars(2)], [a1.hist a2.hist]);
  
  % Set output
  varargout = utils.helper.setoutputs(nargout, b);
  
end

function plf = getlpFilter(x)
  
  plf = plist();
  plf = append(plf, param('gain', 1));
  plf = append(plf, param('ripple', 0.5));
  plf = append(plf, param('type', 'lowpass'));
  plf = append(plf, param('order', 2));
  plf = append(plf, param('fs', x));
  plf = append(plf, param('fc', 0.1/100));
  
end

function phf = gethpFilter(x)
  
  phf = plist();
  phf = append(phf, param('gain', 1));
  phf = append(phf, param('ripple', 0.5));
  phf = append(phf, param('type', 'highpass'));
  phf = append(phf, param('order', 2));
  phf = append(phf, param('fs', x));
  phf = append(phf, param('fc', 0.1/100));
  
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               Local Functions                               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    getInfo
%
% DESCRIPTION: Get Info Object
%
% HISTORY:     11-07-07 M Hewitson
%                Creation.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function ii = getInfo(varargin)
  
  if nargin == 1 && strcmpi(varargin{1}, 'None')
    sets = {};
    pl   = [];
  else
    sets = {'Default'};
    pl   = getDefaultPlist();
  end
  % Build info object
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.sigproc, '', sets, pl);
  ii.setModifier(false);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    getDefaultPlist
%
% DESCRIPTION: Get Default Plist
%
% HISTORY:     11-07-07 M Hewitson
%                Creation.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function plout = getDefaultPlist()
  persistent pl;
  if ~exist('pl', 'var') || isempty(pl)
    pl = buildplist();
  end
  plout = pl;
end

function pl = buildplist()
  
  pl = plist();
  
  % Method
  p = param({'method', 'The method used to interpolate data.'}, {1, {'linear', 'spline'}, paramValue.SINGLE});
  pl.append(p);
  
  % Add noise
  p = param({'addnoise', ...
    ['Noise can be added to the interpolated data.<br>'...
    'This noise is defined as random variable with<br>'...
    'zero mean and variance equal to the high-frequency<br>'...
    'noise of the first input.']}, paramValue.FALSE_TRUE);
  pl.append(p);
  
end

% PARAMETERES: 'method' - method used to interpolate data between a1 and a2.
%                         Two options can be used: 'linear' and 'spline'.
%                         Default values is 'linear'.
%              'addnoise' - noise can be added to the interpolated data.
%                           This noise is defined as random variable with
%                           zero mean and variance equal to the high-frequency
%                           noise if a1. 'true' adds noise. Default value
%                           is 'false'.
