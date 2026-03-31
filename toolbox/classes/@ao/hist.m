% HIST overloads the histogram function (hist) of MATLAB for Analysis Objects.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: HIST overloads the histogram function (hist) of MATLAB for
%              Analysis Objects.
%
% CALL:        b = hist(a)
%              b = hist(a, pl)
%
% INPUTS:      a  - input analysis object(s)
%              pl - a parameter list
%
% OUTPUTS:     b  - xydata type analysis object(s) containing the
%                   histogrammed data
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'hist')">Parameters Description</a>
%
% WARNING: the '.' method of calling hist() doesn't work since AOs have a
% property called 'hist'. Use the standard function call instead:
%
%    >> a.hist  % returns the history object and doesn't call ao/hist
%    >> hist(a) % calls ao/hist
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = hist(varargin)

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
  [pli, pl_invars, rest] = utils.helper.collect_objects(varargin(:), 'plist', in_names);

  % Define which default PLIST we need:
  pl = combine(pli, plist());
  if pl.isparam_core('X')
    pl = applyDefaults(getDefaultPlist('bin centres'), pli);
  else
    pl = applyDefaults(getDefaultPlist('Number of bins'), pli);
    normalize = utils.prog.yes2true(find_core(pl, 'norm'));
  end
   
  % Decide on a deep copy or a modify
  bs = copy(as, nargout);

  % Get parameters
  N = find_core(pl, 'N');
  X = find_core(pl, 'X');

  %---------------- Loop over input AOs

  % start looping
  for jj=1:numel(bs)
    % Histogram this data
    if isempty(X)
      [n,x] = hist(bs(jj).data.y, N);
    else
      [n,x] = hist(bs(jj).data.y, X);
    end
    % Keep the data shape of the input AO
    if size(bs(jj).data.y, 1) ~= 1
      x = x.';
      n = n.';
    end
    % In the case of equally spaced bins, introduce normalization
    if isempty(X) && normalize
      dx = mean(diff(x)); 
      n = n / sum(n) / dx;
      yunits = (bs(jj).data.yunits)^(-1);
      dy = sqrt(n);
    else
      yunits = 'Count';
      dy = sqrt(n);
    end
    % make a new xydata object
    xy = xydata(x, n);
    xy.setXunits(bs(jj).data.yunits);
    xy.setYunits(yunits);
    xy.setDy(dy);
    % make output analysis object
    bs(jj).data = xy;
    % name for this object
    bs(jj).name = sprintf('hist(%s)', ao_invars{jj});
    % Add history
    bs(jj).addHistory(getInfo('None'), pl, ao_invars(jj), bs(jj).hist);
    % Add to outputs
    % clear errors
    bs(jj).clearErrors;
  end % end of AO loop

  % Set output
  if nargout == numel(bs)
    % List of outputs
    for ii = 1:numel(bs)
      varargout{ii} = bs(ii);
    end
  else
    % Single output
    varargout{1} = bs;
  end
end

%--------------------------------------------------------------------------
% Get Info Object
%--------------------------------------------------------------------------
function ii = getInfo(varargin)
  if nargin == 1 && strcmpi(varargin{1}, 'None')
    sets = {};
    pls   = [];
  elseif nargin == 1 && ~isempty(varargin{1}) && ischar(varargin{1})
    sets{1} = varargin{1};
    pls = getDefaultPlist(sets{1});
  else
    sets = {'Number Of Bins', 'Bin Centres'};
    pls = [];
    for kk=1:numel(sets)
      pls = [pls getDefaultPlist(sets{kk})];
    end
  end
  % Build info object
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.sigproc, '', sets, pls);
end

%--------------------------------------------------------------------------
% Get Default Plist
%--------------------------------------------------------------------------

function plout = getDefaultPlist(set)
  persistent pl;
  persistent lastset;
  if exist('pl', 'var')==0 || isempty(pl) || ~strcmp(lastset, set)
    pl = buildplist(set);
    lastset = set;
  end
  plout = pl;
end

function plo = buildplist(set)
  switch lower(set)
    case 'number of bins'
      plo = plist;
      
      % N number of bins
      p = param({'N', ['The number of bins to compute the histogram on.']}, {1, {10}, paramValue.OPTIONAL});
      plo.append(p);
      
      % normalized output
      p = param({'norm', ['Normalized output. If set to true, it will give the output comparable <br>', ...
        'to the normal distrubution PDF. <br>']}, paramValue.FALSE_TRUE);             
      plo.append(p);
      
    case 'bin centres'
      plo = plist({'X', 'A vector of bin centers.'}, paramValue.EMPTY_DOUBLE);
    otherwise
      error('### Unknown default plist for the set [%s]', set);
  end
end


