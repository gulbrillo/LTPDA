% FILTSUBTRACT subtracts a frequency dependent noise contribution from an input ao.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: FILTSUBTRACT subtracts a frequency dependent noise contribution from an input ao.
%              The method computes the transfer function between both input AOs and
%              fits a miir model to it. The frequency band is applied is set by a
%              threshold in the coherence that the user defines as an input
%              parameter.
%
% CALL:        c = filtSubtract(a,b pl)
%
% INPUTS:      a  - AO from where subtract linear contributions
%              b  - AOs with noise contributions
%              pl - parameter list (see below)
%
% OUTPUTs:     c  - output AO with contributions subtracted (tsdata)
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'filtSubtract')">Parameters Description</a>
%
% TODO: handling errors
%       split by coherence function
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = filtSubtract(varargin)
  
  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  import utils.const.*
  utils.helper.msg(msg.PROC3, 'running %s/%s', mfilename('class'), mfilename);
  
  % Method can not be used as a modifier
  if nargout == 0
    error('### filtSubtract cannot be used as a modifier. Please give an output variable.');
  end
  
  % Collect input variable names
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
  
  % Collect all AOs and plists
  [as, ao_invars] = utils.helper.collect_objects(varargin(:), 'ao', in_names);
  pl              = utils.helper.collect_objects(varargin(:), 'plist', in_names);
  
  % Only two inputs ao's accepted
  if numel(as) ~= 2
    error('### filtSubtract only accepts two inputs AOs.');
  end
  
  % Decide on a deep copy or a modify
  bs = copy(as, nargout);
  
  % combine plists
  pl = applyDefaults(getDefaultPlist(), pl);
  
  % get parameters
  times = find_core(pl,'times');
  filttimes = find_core(pl,'times postfilter');
  fs = find_core(pl,'fs');
  filt = find_core(pl,'filt');
  fspl = find_core(pl,'frequencies');
  
  % resample and consolidate
  if isempty(fs)
    bs1r = bs(1);
    pl = pset(pl,'fs', bs(1).fs);
  else
    if fs ~= bs(1).fs
      bs1r = resample(bs(1), plist('fsout',fs));
    else
      bs1r = bs(1);
    end
  end
  
  % consolidate and split
  c  = consolidate(bs1r, bs(2), pl);
  if ~isempty(times)
    cs = split(c(1), plist('times', times));
    cn = split(c(2), plist('times', times));
  else
    cs = c(1);
    cn = c(2);
  end
  
  if isempty(filt)
    % Transfer functions
    tf = ltfe(cn, cs,pl);
    % split transfer function to relevant frequencies
    if ~isempty(fspl)
      tf_spl = split(tf, plist('frequencies', [fspl(1) fspl(2)]));
    else
      tf_spl = tf;
    end
    
    % get filter from transfer function
    fp = zDomainFit(tf_spl, pl);
    fp.filters.setIunits(cn.yunits);
    fp.filters.setOunits(cs.yunits);
  else
    fp = filt;
  end
  
  % get noise contribution
  cs_cont = filter(cn,fp);
  cs_cont.simplifyYunits();
  
  % remove filter transient
  if ~isempty(filttimes)
    cs_cont = split(cs_cont, plist('times', filttimes));
    cs = split(cs, plist('times', filttimes));
  end
  
  % subtraction
  cs_subt = cs -  cs_cont;
  
  % new tsdata
  fsd = tsdata(cs_subt.x, cs_subt.y, cs_subt.fs);
  % make output analysis object
  cs = ao(fsd);
  % set name
  cs.name = sprintf('filtSubtract(%s)', ao_invars{1});
  % set units
  cs.setYunits(cs_subt.yunits);
  % t0
%   if ~isempty(times) && ~isempty(filttimes)
%     cs.setT0(bs(1).t0 + times(1) + filttimes(1));
%   elseif isempty(times) && ~isempty(filttimes)
%     cs.setT0(bs(1).t0  + filttimes(1));
%   elseif ~isempty(times) && isempty(filttimes)
%     cs.setT0(bs(1).t0 + times(1));
%   else
    cs.setT0(bs(1).t0);
%   end
  % Add procinfo
  cs.procinfo = plist('filter', fp);
  % Add history
  cs.addHistory(getInfo('None'), pl, ao_invars, [bs(:).hist]);
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
  
  % fs
  p = param({'fs','target sampling frequency to resample the data.'}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
  % times
  p = param({'times', 'selects the interval where the subtraction is applied.'},...
    paramValue.EMPTY_STRING);
  pl.append(p);
  
  % times postfilter
  p = param({'times postfilter', 'selects the filter transient intervals to be removed.'},...
    paramValue.EMPTY_STRING);
  pl.append(p);
  
  % frequencies
  p = param({'frequencies', 'selects the frequency band where the transfer<br>'...
    'function is fitted.'}, paramValue.EMPTY_STRING);
  pl.append(p);
  
  % filt
  p = param({'filt', ['a miir/mfir object which will be used as a<br>'...
    'transfer function. If this option is selected<br>'...
    ' the fit is avoided.']}, paramValue.EMPTY_STRING);
  pl.append(p);
  
  % autosearch
  p = param({'autosearch', '(ao.zDomainFit)'}, ...
    getParamValueForParam(ao.getInfo('zDomainFit').plists, 'autosearch'));
  pl.append(p);
  
  % maxiter
  p = param({'maxiter', 'Maximum number of iterations in fit routine (ao.zDomainFit).'}, ...
    getParamValueForParam(ao.getInfo('zDomainFit').plists, 'maxiter'));
  pl.append(p);
  
  % minorder
  p = param({'minorder', 'Minimum order to fit with (ao.zDomainFit).'}, ...
    getParamValueForParam(ao.getInfo('zDomainFit').plists, 'minorder'));
  pl.append(p);
  
  % maxorder
  p = param({'maxorder', 'Maximum order to fit with (ao.zDomainFit).'}, ...
    getParamValueForParam(ao.getInfo('zDomainFit').plists, 'maxorder'));
  pl.append(p);
  
  % weightparam
  p = param({'weightparam', '(ao.zDomainFit)'}, ...
    getParamValueForParam(ao.getInfo('zDomainFit').plists, 'weightparam'));
  pl.append(p);
  
  % forcestability
  p = param({'forcestability', 'Force poles to be stable (ao.zDomainFit)'}, ...
    getParamValueForParam(ao.getInfo('zDomainFit').plists, 'forcestability'));
  pl.append(p);
  
  % plot
  p = param({'plot', 'Plot results of each fitting step (ao.zDomainFit)'}, ...
    getParamValueForParam(ao.getInfo('zDomainFit').plists, 'plot'));
  pl.append(p);
  
  % checkprogress
  p = param({'checkprogress','Display the status of the fit iteration. (ao.zDomainFit)'}, ...
    getParamValueForParam(ao.getInfo('zDomainFit').plists, 'checkprogress'));
  pl.append(p);
  
  % kdes
  p = param({'kdes','The desired number of averages (ao.ltfe).'}, ...
    getParamValueForParam(ao.getInfo('ltfe').plists, 'kdes'));
  pl.append(p);
  
  % jdes
  p = param({'jdes','The desired number of spectral frequencies to compute (ao.ltfe).'}, ...
    getParamValueForParam(ao.getInfo('ltfe').plists, 'jdes'));
  pl.append(p);
  
  % scale
  p = param({'scale',''}, paramValue.EMPTY_STRING);
  pl.append(p);
  
  % type
  p = param({'type',''}, paramValue.EMPTY_STRING);
  pl.append(p);
  
  % win
  p = param({'win','The window to be applied to the data to remove the discontinuities at edges of segments (ao.ltfe).'}, ...
    getParamValueForParam(ao.getInfo('ltfe').plists, 'win'));
  pl.append(p);
  
end
