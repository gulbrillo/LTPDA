% CAST - converts the numeric values in an AO to the data type specified by type.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: CAST - converts the numeric values in an AO to the data type
%              specified by type. The input for the parameter 'type' is a
%              string and can be set to one of the following:
%              'uint8',  'int8',
%              'uint16', 'int16',
%              'uint32', 'int32',
%              'uint64', 'int64',
%              'single', or 'double'
%              This conversion is applied by default to the y-axis but can
%              be changed by the user by using the 'axis' parameter.
%
% CALL:        b = cast(a, pl)
%              b = cast(a, 'int32')
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'cast')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = cast(varargin)
  
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
  pl              = utils.helper.collect_objects(varargin(:), 'plist', in_names);
  dataType        = utils.helper.collect_objects(varargin(:), 'char', in_names);
  
  %%% Decide on a deep copy or a modify
  bs = copy(as, nargout);
  
  % combine plists
  pl = applyDefaults(getDefaultPlist(), pl);
  
  % Extract necessary parameters
  type = find_core(pl, 'type');
  axis = find_core(pl, 'axis');
  
  % Check if the user have defined the data type not inside a PLIST
  if ~isempty(dataType)
    type = dataType;
    pl.pset('type', dataType);
  end
  
  % Loop over input AOs
  for jj = 1:numel(bs)
    
    % Cast the numeric value to a new data type
    bs(jj).data.cast(type, axis);
    % Correct Nsecs
    bs(jj).data.fixNsecs;
    % Add history
    bs(jj).addHistory(getInfo('None'), pl, ao_invars(jj), bs(jj).hist);
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
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.converter, '', sets, pl);
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
  p = param({'type', 'New data type for the numeric values in the AO.'}, ...
    {10, {'uint8',  'int8', ...
    'uint16', 'int16', ...
    'uint32', 'int32', ...
    'uint64', 'int64', ...
    'single', 'double'}, paramValue.OPTIONAL});
  p.addAlternativeKey('data type');
  p.addAlternativeKey('precision');
  pl.append(p);
  
  % Add 'axis' from factory PLIST
  axPl = copy(plist.AXIS_3D_PLIST,1);
  axPl.removeKeys({'dim', 'option'});
  axPl.setDefaultForParam('axis', 'y');
  pl.append(axPl);
  
end

