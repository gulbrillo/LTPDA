% COMPLEX overloads the complex operator for Analysis objects.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: COMPLEX overloads the complex operator for Analysis Objects.
%              A3 = COMPLEX(A1,A2) returns the complex result A1 + A2i,
%              where A1 and A2 are Analysis Objects containing  
%              identically sized real arrays.
%
% CALL:        ao_out = complex(a1, a2);
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'complex')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = complex(varargin)

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

  % Decide on a deep copy or a modify
  bs = copy(as, nargout);

  % Check input arguments number
  if length(bs) ~= 2
    error ('### Incorrect inputs. Please enter 2 AOs');
  end

  if nargout == 0
    error('### Complex cannot be used as a modifier. Please give an output variable.');
  end

  % Only support data2D or cdata for now
  if isa(bs(1).data, 'data3D') || isa(bs(2).data, 'data3D')
    error('### 3D data objects are currently not supported.');
  end

  % Check for the same data.
  if ~strcmp(class(bs(1).data), class(bs(2).data))
    error ('### The data class of the two AOs must be the same. (%s <-> %s)', ...
      class(bs(1).data), class(bs(2).data));
  end

  % Check for the same sample rate
  fields = fieldnames(bs(1).data);
  if ismember('fs', fields)
    if ~isequaln(bs(1).data.fs, bs(2).data.fs)
      error('### The sample rate of the two AOs is not the same. Please resample one of them.');
    end
  end

  % Check the length of the AO's
  if length(bs(1).data.getY) ~= length(bs(2).data.getY) 
    error ('### The length of the data vectors must be the same.')
  end
  
  % The x vector, if present, should be the same
  if ismember('x', fields)
    if ~isequal(bs(1).data.getX, bs(2).data.getX)
      error('### The two data series should have the same x values.');
    end
  end

  % The time should be the same
  if ismember('t0', fields)
    if bs(1).data.t0.utc_epoch_milli ~= bs(2).data.t0.utc_epoch_milli
      error('### The two data series don''t start at the same time.');
    end
  end

  % The x units should match
  if ismember('xunits', fields)
    if ~isequal(bs(1).data.xunits, bs(2).data.xunits)
      error('### The two data series should have the same x units');
    end
  end

  % Copy object 1 for the output
  bs(1).data.setY(complex(bs(1).data.getY, bs(2).data.getY));
  if ismember('yunits', fields)
    if isequal(bs(1).data.yunits, bs(2).data.yunits)
      bs(1).data.setYunits(bs(1).data.yunits);
    else
      error('### Can''t combine data with different units');
    end
  end

  % Set name
  bs(1).name = sprintf('complex(%s, %s)', ao_invars{1}, ao_invars{2});
  % Add history
  bs(1).addHistory(getInfo('None'), getDefaultPlist, ao_invars, [bs(1).hist bs(2).hist]);

  % Set output
  varargout{1} = bs(1);
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
  ii.setModifier(false);
  ii.setArgsmin(2);
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
  pl = plist.EMPTY_PLIST;
end

