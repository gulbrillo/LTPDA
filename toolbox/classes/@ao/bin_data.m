% BIN_DATA rebins aos data, on logarithmic scale, linear scale, or arbitrarly chosen.
% The rebinning is done taking the mean of the bins included in the range
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: BIN_DATA rebins aos data, on logarithmic scale, linear scale, or arbitrarly chosen.
% The rebinning is done taking the mean of the bins included in the range
%
% CALL:        bs = bin_data(a1,a2,a3,...,pl)
%              bs = bin_data(as,pl)
%              bs = as.bin_data(pl)
%
% INPUTS:      aN   - input analysis objects
%              as   - input analysis objects array
%              pl   - input parameter list
%
% OUTPUTS:     bs   - array of analysis objects, one for each input
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'bin_data')">Parameters Description</a>
%
% The code is inherited from D Nicolodi, UniTN
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



function varargout = bin_data(varargin)
  
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
  
  % Collect all AOs
  [as, ao_invars] = utils.helper.collect_objects(varargin(:), 'ao', in_names);
  
  % Decide on a deep copy or a modify
  bs = copy(as, nargout);
  
  % Apply defaults to plist
  usepl = applyDefaults(getDefaultPlist(), varargin{:});

  x_scale     = find(usepl, 'x_scale', find_core(usepl, 'xscale'));
  x_vals      = find(usepl, 'x_vals', find_core(usepl, 'xvals'));
  resolution  = find(usepl, 'resolution');
  range       = find(usepl, 'range');
  method      = lower(find_core(usepl, 'method'));
  inherit_dy  = utils.prog.yes2true(find(usepl, 'inherit-dy', find_core(usepl, 'inherit_dy')));
  
  % Loop over input AOs
  for jj = 1:numel(bs)
      
    % check input data
    if isa(bs(jj).data, 'data2D')
      
      w = find_core(usepl, 'weights');
      
      if isa(w, 'ao')
        w = w.y;
      end
      
      if isempty(w)
        w =  1./(bs(jj).dy).^2;
      end
      
      if isempty(x_vals)
        if isempty(x_scale) || isempty(resolution)
          error('### Please specify a scale and density for binning, OR the list of the values to bin around');
        else
          
          switch lower(x_scale)
            case {'lin', 'linear'}
              % Case of linear binning
              % number of bins in the rebinned data set
              N = resolution; 

              % maximum and minimum x
              if ~isempty(range) && isfinite(range(1))
                xmin = range(1);
              else
                xmin = min(bs(jj).x);
              end
              
              if ~isempty(range) && isfinite(range(2))
                xmax = range(2);
              else
                xmax = max(bs(jj).x);
              end

              dx = (xmax - xmin)/N;
              
              x_min = bs(jj).x(1) + dx*(0:(N-1))';
              x_max = bs(jj).x(1) + dx*(1:N)';
              
            case {'log', 'logarithmic'}
              % Case of log-based binning

              % maximum and minimum x
              if ~isempty(range) && isfinite(range(1))
                xmin = range(1);
              else
                xmin = min(bs(jj).x(bs(jj).x > 0));
              end
              
              if ~isempty(range) && isfinite(range(2))
                xmax = range(2);
              else
                xmax = max(bs(jj).x);
              end
              
              alph = 10^(1/resolution);
                        
              % number of bins in the rebinned data set
              N = ceil(log10(xmax/xmin) * resolution);
              
              % maximum and minimum x-value for each bin
              x_min = xmin*alph.^(0:(N-1))';
              x_max = xmin*alph.^(1:N)';
            otherwise
              error(['### Unknown scaling option ' x_scale '. Please choose between ''lin'' and ''log']);
          end
        end
      else
        % number of bins in the rebinned data set
        % If the x-scale is an AO, then take the x values
        if isa(x_vals, 'ao')
          if isequal(x_vals.xunits, bs(jj).data.xunits)
            x_vals = x_vals.x;
          else
            error('x_vals AO and data AO have different x-units');
          end
        elseif ~isnumeric(x_vals)
          error('Unsupported x_vals object');
        end
        N = length(x_vals) - 1;
        x_min = x_vals(1:N);
        x_max = x_vals(2:N+1);
      end
      
      x =  bs(jj).x;
      y =  bs(jj).y;
      dy = bs(jj).dy;
      
      % preallocate output vectors
      xr = zeros(N, 1);
      yr = zeros(N, size(y, 2));
      if strcmpi(method, 'mean') || strcmpi(method, 'wmean')
        dyr = zeros(N, size(y, 2));
      else
        dyr = [];
      end
      nr = zeros(N, 1);
      
      % compute the averages
      for kk = 1:N
        in = x >= x_min(kk) & x < x_max(kk);
        if any(in)
          nr(kk) = sum(in);               % number of points averaged in this bin          
          
          switch method
            case {'mean', 'median', 'max', 'min', 'rms'}
              xr(kk) = feval(method, x(in));           % rebinned x bins;
              yr(kk) = feval(method, y(in));           % rebinned y bins;
              if strcmpi(method, 'mean')
                dyr(kk) = std(y(in), 0)/sqrt(nr(kk));
                % check for zeros in the uncertainty and replace it with the individual point uncertainty
                if dyr(kk) == 0
                  if inherit_dy && ~isempty(dy)
                    dyr(kk) = mean(dy(in));
                  else
                    dyr(kk) = Inf;
                  end
                end              
              end              
            case {'wmean'}
              xr(kk)  = mean(x(in));                      % rebinned x bins;                                          
              yr(kk)  = sum(y(in).*w(in))./sum(w(in));    % rebinned y bins;
              dyr(kk) = 1./sqrt(sum(w(in)));              % rebinned dy bins;
            otherwise
              error(['### Unsupported method ' method]);
          end
        end
      end
      
      % remove bins where we do not have nothing to average
      in = nr ~= 0;
      nr = nr(in);
      xr = xr(in);
      yr = yr(in,:);
      if strcmpi(method, 'mean') || strcmpi(method, 'wmean')  
        dyr = dyr(in,:);
      end
      
      % set the new object data
      bs(jj).clearErrors;
      bs(jj).setXY(xr, yr);
      bs(jj).setDy(dyr);
      
      % nr goes into the procinfo
      bs(jj).procinfo = plist('navs', nr);
      
      % set name
      bs(jj).name = sprintf('bin_data(%s)', ao_invars{jj});
      % Add history
      bs(jj).addHistory(getInfo('None'), usepl, ao_invars(jj), bs(jj).hist);
    else
      warning('### Ignoring input AO number %d (%s); it is not a 2D data object.', jj, bs(jj).name)
    end
  end % loop over analysis objects
  
  % Set output
  varargout = utils.helper.setoutputs(nargout, bs);
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
    pl   = getDefaultPlist();
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
  
  pl = plist();
  
  % method
  p = param({'method',['method for binning. Choose from:<ul>', ...
    '<li>mean</li>', ...
    '<li>median</li>', ...
    '<li>max</li>', ...
    '<li>min</li>', ...
    '<li>rms</li>', ...
    '<li>weighted mean (weights can be input or are taken from data dy)</li></ul>']}, ...
    {1, {'MEAN', 'MEDIAN', 'MAX', 'MIN', 'RMS', 'WMEAN'}, paramValue.SINGLE});
  pl.append(p);
  
  % x-scale
  p = param({'xscale',['scaling of binning. Choose from:<ul>', ...
    '<li>log - logaritmic</li>', ...
    '<li>lin - linear</li></ul>']}, {1, {'LOG', 'LIN'}, paramValue.SINGLE});
  pl.append(p);
  
  % resolution
  p = param({'resolution',['When setting logaritmic x scale, it sets the number of points per decade.<br>' ...
    'When setting linear x scale, it sets the number of points.']}, paramValue.DOUBLE_VALUE(10));
  pl.append(p);
  
  % x_vals
  p = param({'xvals',['List of x values to evaluate the binning between.<br>', ...
    'It may be a vector or an ao, in which case it will take the x field']}, paramValue.DOUBLE_VALUE([]));
  pl.append(p);
  
  % weights
  p = param({'weights', ['List of weights for the case of weighted mean.<br>', ...
    'If empty, weights will be taken from object(s) dy field as w = 1/dy^2']}, paramValue.DOUBLE_VALUE([]));
  pl.append(p);

  % range
  p = param({'range', ['Range of x where to operate.<br>', ...
    'If empty, the whole data set will be used']}, paramValue.DOUBLE_VALUE([]));
  pl.append(p);
  
  % inherit_dy
  p = param({'inherit_dy', ['Choose what to do in the case of mean, and bins with only one point. Choose from:<ul>', ...
    '<li>''true''  - take the uncertainty from the original data, if defined</li>', ...
    '<li>''false''   - set it to Inf so it weighs 0 in averaged means</li></ul>' ...
    ]}, paramValue.TRUE_FALSE);
  pl.append(p);
end
% END
