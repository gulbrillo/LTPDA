% TIMESHIFT for AO/tsdata objects, shifts data in time by the specified value in seconds.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: TIMESHIFT for AO/tsdata objects, shifts data in time by the
%              specified value.
%
% This method does no fancy interpolation it just shifts the start time of
% the first sample by the given amount relative to t0.
% 
% Providing an empty value for the offset (the default value) results in
% the special behaviour of subtracting the first x value from all the x
% values, such that the x vector starts at 0.
% 
% 
%
% CALL:        b = timeshift(a, offset)
%              bs = timeshift(a1,a2,a3, offset)
%              bs = timeshift(a1,a2,a3,...,pl)
%              bs = timeshift(as,pl)
%              bs = as.timeshift(pl)
%
% INPUTS:      aN   - input analysis objects
%              as   - input analysis objects array
%              pl   - input parameter list
%
% OUTPUTS:     bs   - array of analysis objects, one for each input
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'timeshift')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = timeshift(varargin)
  
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
  [as, ao_invars, rest] = utils.helper.collect_objects(varargin(:), 'ao', in_names);
  [pl, ~,         rest] = utils.helper.collect_objects(rest(:), 'plist', in_names);
  [offsetIn, ~,   ~]    = utils.helper.collect_objects(rest(:), 'double', in_names);
  
  % Decide on a deep copy or a modify
  bs = copy(as, nargout);
  
  % Combine input and default PLIST
  usepl = applyDefaults(getDefaultPlist, pl);
  
  % Get the offset
  if ~isempty(offsetIn)
    offset = offsetIn;
    usepl.pset('offset', offset);
  else
    offset = usepl.find_core('offset');
  end
  
  adjustT0 = usepl.find_core('adjust t0');
  
  % Check input analysis object
  for jj = 1:numel(bs)
    % Which data type do we have
    switch class(bs(jj).data)
      case 'tsdata'
        
        % Add the new offset
        if ~isempty(offset)
          bs(jj).data.setToffset(bs(jj).data.toffset + offset*1000);
        else
          % We do the old behaviour
          if adjustT0
            bs(jj).data.setT0(bs(jj).data.t0+bs(jj).x(1));
          end
          bs(jj).data.setX(bs(jj).x-bs(jj).x(1));
        end        
        % Add history
        bs(jj).addHistory(getInfo('None'), usepl, ao_invars(jj), bs(jj).hist);
        
      case {'fsdata', 'cdata', 'xydata'}
        error('### I don''t work for frequency-series, xy and constant data.');
        
      otherwise
        error('### unknown data type. They can not be addded.')
    end
  end
  
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
    pl   = getDefaultPlist;
  end
  % Build info object
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.helper, '', sets, pl);
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
  
  % offset
  p = param({'offset', 'Offset in seconds to shift the data in time.'}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
  % adjust t0
  p = param({'adjust t0', 'For the case where offset is zero, adjust t0 accordingly'}, paramValue.FALSE_TRUE);
  pl.append(p);
  
end


