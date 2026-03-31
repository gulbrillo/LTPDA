% LINSUBTRACT subtracts a linear contribution from an input ao.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: LINSUBTRACT subtracts a linear contribution from an input ao.
%              The methods assumes the input data to be synchronous. The
%              user selects a filter to be applied to the data before
%              fitting and a time segment where the fit is performed.
%
% CALL:        c = linSubtract(a,b1,b2,b3,...,bN, pl)
%
% INPUTS:      a  - AO from where subtract linear contributions
%              b  - AOs with noise contributions
%              pl - parameter list (see below)
%
% OUTPUTs:     c  - output AO with contributions subtracted (tsdata)
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'linSubtract')">Parameters Description</a> 
%
% EXAMPLES:
%
% 1) Given the data (d):
%
%             d = a + c1*b1 + c2*(b2+b3).^2
%
%    where (bs) are noisy contributions added to a signal (a). To recover (a)
%    in the [1 1e3] segment applying a [5e-2 0.1] 2nd order bandpass
%    filter to the data, the call to the function would be
%
%            pl = plist('type', 'bandpass',...
%                       'fc', [5e-2 0.1],...
%                       'order', 2,...
%                       'times', [1 1e3],...
%                       'coupling', {{'n(1)'}, {'(n(2) + n(3)).^2'}});
%
%            a = linSubtract(d, b1, b2, b3, pl)
%
%
% TODO: option for parallel and serial subtraction
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = linSubtract(varargin)
  
  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  import utils.const.*
  utils.helper.msg(msg.PROC3, 'running %s/%s', mfilename('class'), mfilename);
  
  % Method can not be used as a modifier
  if nargout == 0
    error('### tfe cannot be used as a modifier. Please give an output variable.');
  end
  
  % Collect input variable names
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
  
  % Collect all AOs and plists
  [as, ao_invars] = utils.helper.collect_objects(varargin(:), 'ao', in_names);
  pl              = utils.helper.collect_objects(varargin(:), 'plist', in_names);
  
  % Decide on a deep copy or a modify
  bs = copy(as, nargout);
  
  % Combine plists
  pl = applyDefaults(getDefaultPlist, pl);
  
  
  % get parameters
  fc = find_core(pl, 'fc');
  if isempty(fc)
    error('### Please define a cut-off frequency ''fc''');
  end
  times = find_core(pl, 'times');
  cp = find_core(pl, 'coupling');
  if isempty(cp)
    error('### Please define a coupling model ''coupling''')
  end
  order = find_core(pl, 'order');
  type = find_core(pl, 'type');
  
  % split in time
  if ~isempty(times)
    cs = split(bs, plist('times', times));
  else
    cs = bs;
  end
  
  s = cs(1);
  for ii = 2:length(bs)
    n(ii-1) = cs(ii);
  end
  
  % Loop noise sources
  for kk = 1:length(cp)
    % coupling
    nterm = ao();
    if numel(cp{kk}) == 1
      nterm = eval([char(cp{kk}) ';']);
    else
      nn = numel(cp{kk});
      for jj = 1:nn
        nterm(jj) = eval([char(cp{kk}{jj}) ';']);
      end
    end
    % bandpass filter
    fbp  = miir(plist('type', type, 'fc', fc, 'order', order, 'fs', s.fs));
    sbp = filtfilt(s, fbp);
    nterm_bp = filtfilt(nterm, fbp);
    % linear fit
    c = lscov(nterm_bp, sbp);
    sn = lincom(nterm, c);
    % subtract
    s = s - sn;
  end
  
  % make output analysis object
  cs = s;
  % set name
  cs.name = sprintf('linSubtract(%s)', ao_invars{1});
  % t0
  if ~isempty(times)
    cs.setT0(times(1));
  else
    cs.setT0(bs(1).t0);
  end
  % Propagate 'plotinfo'
  plotinfo = [as(:).plotinfo];
  if ~isempty(plotinfo)
    cs.plotinfo = combine(plotinfo);
  end
  % Add history
  cs.addHistory(getInfo('None'), pl, [ao_invars(:)], [bs(:).hist]);
  % Set output
  varargout{1} = cs;
  
  
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
  
  pl = plist();
  
  % Type
  p = param({'type', 'Sets the type of filter used to fit the data.'}, {1, {'bandpass', 'bandreject', 'highpass', 'lowpass'}, paramValue.SINGLE});
  pl.append(p);
  
  % fc
  p = param({'fc', 'Frequency cut-off of the filter.'}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
  % Order
  p = param({'order', 'Order of the filter.'}, {1, {2}, paramValue.OPTIONAL});
  pl.append(p);
  
  % Times
  p = param({'times', 'A set of times where the fit+subtraction is applied.'}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
  % Coupling
  p = param({'coupling', ['A cell-array defining the model of the noise<br>'...
    'terms to be subtracted. In the cell expression<br>'...
    '''s'' stands for the input ao and ''n(i)'' for the N<br>' ...
    'N noise contributions.']}, {1, {'{}'}, paramValue.OPTIONAL});
  pl.append(p);
  
end
