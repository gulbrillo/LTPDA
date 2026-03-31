% ADDFILTERS This method adds a filter to the filterbank
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: ADDFILTERS This method adds a filter to the filterbank
%
% CALL:        f = addFilters(filter-object);
%              f = addFilters(plist-object);
%
% <a href="matlab:utils.helper.displayMethodInfo('filterbank', 'addFilters')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function nfbs = addFilters(varargin)
  
  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    nfbs = getInfo(varargin{3});
    return
  end
  
  % Collect input variable names
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
  
  [fbs, invars_fb, rest] = utils.helper.collect_objects(varargin, 'filterbank', in_names);
  [filts, invars, rest] = utils.helper.collect_objects(rest(:), 'ltpda_filter');
  [pli, invars, rest] = utils.helper.collect_objects(rest(:), 'plist');
  
  if numel(fbs) > 1
    error('### _This method can only handle one filterbank object.');
  end
  
  internal = utils.helper.callerIsMethod();
  
  % Decide on a deep copy or a modify
  nfbs = copy(fbs, nargout);
  
  % Get default parameters
  pl = applyDefaults(getDefaultPlist, pli);
  
  filtColl = [];

  if numel(nfbs.filters) > 0
    cl = class(nfbs.filters(1));
  else
    cl = '';
  end
  
  for kk=1:numel(filts)
    filt = filts(kk);
    if isempty(cl)
      filtColl = [filtColl filt];
    else
      if isa(filt, cl)
        filtColl = [filtColl filt];
      else
        warning('Not adding filter "%s" due to wrong filter type', filt.name);
      end
    end
  end
  
  filtColl = [filtColl pl.find_core('filters')];
  
  % Set the collected filters to the filterbank object
  nfbs.filters = [nfbs.filters filtColl];

  % Add history if it is not a internal command.
  if ~internal
    pl.pset('filters', filtColl);
    nfbs.addHistory(getInfo('None'), pl, invars_fb(1), nfbs.hist);
  end
  
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function ii = getInfo(varargin)
  
  if nargin == 1 && strcmpi(varargin{1}, 'None')
    sets = {};
    pls  = [];
  else
    sets = {'Default'};
    pls  = getDefaultPlist;
  end
  % Build info object
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.aop, '', sets, pls);
  ii.setArgsmin(2);
  ii.setModifier(false);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    getDefaultPlist
%
% DESCRIPTION: Get Default Plist
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function plout = getDefaultPlist()
  persistent pl;  
  if exist('pl', 'var')==0 || isempty(pl)
    pl = buildplist();
  end
  plout = pl;  
end

function plo = buildplist()
  plo = plist();
  
  p = param({'filters', 'IIR or FIR Filter Objects.'}, {1, {[]}, paramValue.SINGLE});
  plo.append(p);
end
