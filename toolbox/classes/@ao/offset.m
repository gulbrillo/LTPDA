% OFFSET adds an offset to the data in the AO.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: OFFSET adds an offset to the data in the AO.
%
% CALL:        ao_out = offset(ao_in);
%              ao_out = offset(ao_in, pl);
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'offset')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = offset(varargin)

  import utils.const.*

  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end

  utils.helper.msg(msg.PROC3, 'running %s/%s', mfilename('class'), mfilename);

  % Collect input variable names
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end

  % Collect all AOs
  [as, ao_invars,rest] = utils.helper.collect_objects(varargin(:), 'ao', in_names);
  [pls,  invars, rest] = utils.helper.collect_objects(rest(:), 'plist');

  % Get default parameters
  pl = applyDefaults(getDefaultPlist, pls);
  
  % Get the offset from the plist
  offset = find_core(pl, 'offset');
  
  if isa(offset, 'ao')
    for kk = 1:numel(as)         
      if isequal(offset.yunits, as(kk).yunits) || isequal(offset.yunits, unit)
        offsety = offset.y;
      else
        error('### The offset units must be empty or consistent with those of the input objects')
      end
    end
    offset = offsety;
  end
  
  % look in rest
  if isempty(offset) && ~isempty(rest)
    offset = rest{1};
  end
  
  % now check we got a factor
  if isempty(offset) || ~isnumeric(offset) || numel(offset) ~= 1
    error('### The offset must be a single numeric value.');
  end
  
  % Set the offset to the plist.
  % It might be that the offset was not in the plist
  pl.pset('offset', offset);
  
  % Decide on a deep copy or a modify
  bs = copy(as, nargout);

  % Apply method to all AOs
  for kk = 1:numel(bs)
    bs(kk).data.setY(bs(kk).data.y + offset);
    % set name
    bs(kk).name  = sprintf('(%s+%g)', bs(kk).name, offset);
    % add history
    bs(kk).addHistory(getInfo('None'), pl, ao_invars(kk), as(kk).hist);    
  end
  
  % Set output
  if nargout == numel(bs) && numel(bs)>1
    for ii = 1:numel(bs)
      varargout{ii} = bs(ii);
    end
  else
    varargout{1} = bs;
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
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.op, '', sets, pl);
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

  pl = plist({'offset', ['The offset to add.<br>' ...
    'It can be a double or an ao. In this latter case, <br>' ...
    'the units should be empty or matching those of the input objects']}, paramValue.EMPTY_DOUBLE);
  
end

% PARAMETERS:  
%              'offset' - the offset to add [default: empty]

% END
