% LINEDETECT find spectral lines in the ao/fsdata objects.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: LINEDETECT find spectral lines in the ao/fsdata objects.
%
% CALL:        b = linedetect(a, pl)
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'linedetect')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = linedetect(varargin)

  callerIsMethod = utils.helper.callerIsMethod;
  
  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end

  if nargout == 0
    error('### cat cannot be used as a modifier. Please give an output variable.');
  end

  % Collect input variable names
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end

  % Collect all AOs
  [as, ao_invars] = utils.helper.collect_objects(varargin(:), 'ao', in_names);

  % Decide on a deep copy or a modify
  bs = copy(as, nargout);

  % Apply defaults to plist
  pl = applyDefaults(getDefaultPlist, varargin{:});

  Na = numel(bs);
  if isempty(bs)
    error('### Please input at least one AO.');
  end

  % Get parameters from plist
  N       = find_core(pl, 'N');
  fsearch = find_core(pl, 'fsearch');
  thresh  = find_core(pl, 'thresh');

  % Loop over input AOs
  for jj = 1:Na
    if isa(bs(jj).data, 'fsdata')

      % Make noise-floor estimate
      spl = plist();
      spl.pset('width', pl.find_core('bw'));
      spl.pset('hc', pl.find_core('hc'));
      nf = smoother(bs(jj), spl);
      % Make ratio
      r = bs(jj)./nf;

      % find lines
      lines = findLines(bs(jj).data.getY, r.data.getX, r.data.getY, thresh, N, fsearch);

      if isempty(lines)
        f = [];
        y = [];
      else
        f = [lines(:).f];
        y = [lines(:).a];
        
        % Keep the data shpare of the input AO
        if size(bs(jj).data.y, 2) == 1
          f = f.';
          y = y.';
        end
      end
        
        % Make output data: copy the fsdata object so to inherit all the feautures
        fs = copy(bs(jj).data, 1);
        
        % Make output data: set the values
        fs.setX(f);
        fs.setY(y);

    else
      error('### I can only find lines in frequency-series AOs.');
    end

    %------- Make output AO

    % make output analysis object
    bs(jj).data = fs;

    bs(jj).name = sprintf('lines(%s)', ao_invars{1});
    
    % set some sensible defaults for line style
    bs(jj).setPlotMarker('o');
    bs(jj).setPlotLineStyle('none');    
    
    % Add history
    if ~callerIsMethod
      bs(jj).addHistory(getInfo('None'), pl, ao_invars(jj), bs(jj).hist);
    end
  end

  % Set output
  varargout = utils.helper.setoutputs(nargout, bs);
end

%--------------------------------------------------------------------------
% find spectral lines
function lines = findLines(ay, f, nay, thresh, N, fsearch)

  % look for spectral lines
  l       = 0;
  pmax    = 0;
  pmaxi   = 0;
  line    = [];
  idx     = find( f>=fsearch(1) & f<=fsearch(2) );
  for jj = 1:length(idx)
    v = nay(idx(jj));
    if v > thresh
      if v > pmax
        pmax  = v;
        pmaxi = idx(jj);
      end
    else
      if pmax > 0
        % find index when we have pmax
        fidx = pmaxi; %(find(nay(1:idx(jj))==pmax));
        l = l+1;
        line(l).idx = fidx;
        line(l).f   = f(fidx);
        line(l).a   = ay(fidx);
      end
      pmax = 0;
    end
  end

  % Select largest peaks
  lines = [];
  if ~isempty(line)
    [bl, lidx] = sort([line.a], 'descend');
    lidxs = lidx(1:min([N length(lidx)]));
    lines = line(lidxs);
    disp(sprintf('   + found %d lines.', length([lines.f])));
  else
    disp('   + found 0 lines.');
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
  ii.setModifier(false);
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
  
  % N
  p = param({'N', 'The maximum number of lines to return.'}, {1, {10}, paramValue.OPTIONAL});
  pl.append(p);
  
  % fsearch
  p = param({'fsearch', 'The frequency search interval.'}, {1, {[0 1e10]}, paramValue.OPTIONAL});
  pl.append(p);
  
  % thresh
  p = param({'thresh', 'A threshold to test normalised amplitude against. (A sort-of SNR threshold.)'}, {1, {2}, paramValue.OPTIONAL});
  pl.append(p);
  
  % BW
  p = param({'bw', ['The bandwidth of the running median filter used to<br>'...
                    'estimate the noise-floor.']}, {1, {20}, paramValue.OPTIONAL});
  pl.append(p);                
                  
  % HC
  p = param({'hc', 'The cutoff used to reject outliers (0-1).'}, {1, {0.8}, paramValue.OPTIONAL});
  pl.append(p);
  
  
end
