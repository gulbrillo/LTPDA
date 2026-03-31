% HYPOT overloads robust computation of the square root of the sum of squares for AOs.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: HYPOT overloads robust computation of the square root of the
%              sum of squares for Analysis objects.
%
% CALL:        ao_out = hypot(ao_in);
%              ao_out = hypot(ao_in, pl);
%
% REMARK:      The data-object of the output AO is the same as the
%              data-object of the first AO input. The result of HYPOT will
%              be copied to the y values of this data-object if this is
%              called without an output.
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'hypot')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = hypot(varargin)
  
  callerIsMethod = utils.helper.callerIsMethod;
  
  operatorName   = 'hypot';
  operatorSymbol = 'hypot';
  
  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end

  % Collect input aos, plists and ao variable names
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end

  % Collect all AOs
  [as, ao_invars] = utils.helper.collect_objects(varargin(:), 'ao', in_names);
  pl              = utils.helper.collect_objects(varargin(:), 'plist', in_names);
  
  % Get default parameters
  pl = applyDefaults(getDefaultPlist, pl);

  % Check input arguments number
  if numel(as) ~= 2
    error ('### Incorrect inputs for %s. Please enter 2 AOs', operatorName);
  end
  if nargout == 0
    error('### %s cannot be used as a modifier. Please give an output variable.', operatorName);
  end
  
  % Go for a deep copy
  bs = copy(as, true);
  
  % Settings
  if callerIsMethod
    infoObj = [];
    pl = plist;
  else
    infoObj = getInfo();
    pl = getDefaultPlist;
  end
  
  % Apply method
  bs = bs.applyoperator(callerIsMethod, ao_invars, operatorName, operatorSymbol, pl, infoObj);
  % clear errors
  bs.clearErrors;

  % Set output
  varargout{1} = bs;
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
  if ~exist('pl', 'var') || isempty(pl)
    pl = buildplist();
  end
  plout = pl;  
end

function pl = buildplist()
  pl = plist({'axis', 'The axis on which to compute the sqrt of the sum of the squares.'},  ...
    {2, {'x', 'y', 'xy'}, paramValue.SINGLE});

end

