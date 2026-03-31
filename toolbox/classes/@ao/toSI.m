% TOSI converts the units of the x, y and z axes into SI units.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: TOSI converts the units of the x, y and z axes into SI units.
%
% CALL:        b = toSI(a, pl)
%
% INPUTS:      a  - input analysis object
%              pl - input parameter list (see below for parameters)
%
% OUTPUTS:     b  - output analysis objects
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'toSI')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = toSI(varargin)
  
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
  
  % Decide on a deep copy or a modify
  bs = copy(as, nargout);
  
  % combine input plists (if the input plists are more than one)
  pl = applyDefaults(getDefaultPlist(), pli);
  
  axis   = pl.find_core('axis');
  exList = pl.mfind('exception list', 'exceptions');
  exList = cellstr(exList);
  
  for ii = 1:numel(bs)
    a = bs(ii);
    inhist = a.hist;
    
    if ~isempty(strfind(axis, 'y'))
      if isa(a.data, 'ltpda_data')
        a.simplifyYunits(pl.pset('prefixes', true));
        applyOffsetForAbsTemp(a, @setY, 'y', exList);
        [u_SI, scale] = toSI(a.data.yunits, exList{:});
        a.data.setY(a.data.getY .* scale);
        a.data.setDy(a.data.getDy .* scale);
        a.data.setYunits(u_SI);
      end
    end
    if ~isempty(strfind(axis, 'x'))
      if isa(a.data, 'data2D')
        a.simplifyXunits(pl.pset('prefixes', true));
        applyOffsetForAbsTemp(a, @setX, 'x', exList);
        [u_SI, scale] = toSI(a.data.xunits, exList{:});
        a.data.setX(a.data.getX .* scale);
        a.data.setDx(a.data.getDx .* scale);
        a.data.setXunits(u_SI);
      end
    end
    if ~isempty(strfind(axis, 'z'))
      if isa(a.data, 'data3D')
        a.simplifyZunits(pl.pset('prefixes', true));
        applyOffsetForAbsTemp(a, @setZ, 'z', exList);
        [u_SI, scale] = toSI(a.data.zunits, exList{:});
        a.data.setZ(a.data.getZ .* scale);
        a.data.setDz(a.data.getDz .* scale);
        a.data.setZunits(u_SI);
      end
    end
    % create new output history
    a.addHistory(getInfo('None'), pl, ao_invars(ii), inhist);
  end
  
  varargout = utils.helper.setoutputs(nargout, bs);
end

%--------------------------------------------------------------------------
% Apply the offset from degC and K to the data
%--------------------------------------------------------------------------
function applyOffsetForAbsTemp(a, setFcn, axis, exList)
  % Special case for absolute temperatures [degC].
  % In this case we must also handle the offset from degC and K
  % (T/degC = T/K deg 273.15)
  u = a.(strcat(axis, 'units'));
  if isequal(u, unit('degC')) && ~utils.helper.ismember(u.strs, exList)
    setFcn(a.data, a.data.(axis)+273.15);
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
  
  % Add 'axis' on which to apply the method
  p = param({'axis', 'The axis on which to apply the method.'},  ...
    {7, {'x', 'y', 'z', 'xy', 'xz', 'yz', 'xyz'}, paramValue.SINGLE});
  plo.append(p);
  
  % Add 'exception list'
  p = param({'exception list', 'Cell array with units you don''t want to convert'}, ...
    {'Hz', 'kg'});
  plo.append(p);
  p.addAlternativeKey('exceptions');
end
