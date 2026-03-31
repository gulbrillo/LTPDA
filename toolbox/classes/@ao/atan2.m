% ATAN2 overloads the atan2 operator for analysis objects. Four quadrant inverse tangent.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: ATAN2 overloads the atan2 operator for analysis objects.
%              Four quadrant inverse tangent.
%
% REMARK:      The data-object of the output AO is the same as the data-object
%              of the first AO input. The result of the atan2 will be copied to
%              the y values of this data-object.
%
% CALL:        ao_out = atan2(ao1, ao2);
%              ao_out = atan2(ao1, ao2);
%              ao_out = atan2(ao_vec1, ao_vec2);
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'atan2')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = atan2(varargin)
  
  callerIsMethod = utils.helper.callerIsMethod;
  
  operatorName   = 'atan2';
  operatorSymbol = 'atan2';
  
  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end

  % Collect input aos and ao variable names
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end

  % Collect all AOs
  [as, ao_invars] = utils.helper.collect_objects(varargin(:), 'ao', in_names);
  
  % Check output arguments number
  if nargout == 0
    error('### %s cannot be used as a modifier. Please give an output variable.', operatorName);
  end  

  % Check input arguments number
  if length(as) ~= 2
    error ('### Incorrect inputs for %s. Please enter 2 AOs', operatorName);
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
  
  % Apply method and set output
  varargout{1} = bs.applyoperator(callerIsMethod, ao_invars, operatorName, operatorSymbol, pl, infoObj);

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
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.trig, '', sets, pl);
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
  pl = plist.EMPTY_PLIST;
end


