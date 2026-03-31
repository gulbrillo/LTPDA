% OVERLAP This method cuts out the the overlapping data of the input AOs.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: OVERLAP This method cuts out the the overlapping data of the
%              input AOs.
%
% CALL:        b = overlap(a, pl)
%
% INPUTS:      a  - input analysis object
%              pl - input parameter list (see below for parameters)
%
% OUTPUTS:     b  - output analysis objects
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'overlap')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = overlap(varargin)
  
  %%% Check if this is a call for parameters
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
  [as, ao_invars]  = utils.helper.collect_objects(varargin(:), 'ao', in_names);
  pli = utils.helper.collect_objects(varargin(:), 'plist', in_names);
  
  % combine input plists (if the input plists are more than one)
  pl = applyDefaults(getDefaultPlist(), pli);
  
  tBegin = zeros(size(as));
  tEnd   = tBegin;
  for ii=1:numel(as)
    tBegin(ii) = double(as(ii).t0) + as(ii).x(1);
    tEnd(ii)   = double(as(ii).t0) + as(ii).x(end);
  end
  maxTbegin = max(tBegin);
  minTend   = min(tEnd);
  
  % gather the input history objects
  inhists = [as.hist];
  
  for ii=1:numel(as)
    a = as(ii);
    % backup history
    a = split(a, plist('start_time', maxTbegin-1/a.fs/2, 'end_time', minTend+1/a.fs/2));
    % create new output history
    a.addHistory(getInfo('None'), pl, ao_invars(ii), inhists);
    % set name
    a.name = sprintf('%s(%s)', mfilename, ao_invars{ii});
    as(ii) = a;
  end
  
  if nargout > 1
    % Add additional history step for indexing if the user uses moew
    % outputs
    for ii=1:numel(as)
      as(ii) = as.index(ii);
    end
  end
  
  varargout = utils.helper.setoutputs(nargout, as);
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

function plo = buildplist()
  plo = plist();
end
