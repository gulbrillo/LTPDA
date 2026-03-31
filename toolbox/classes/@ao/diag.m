% DIAG overloads the diagonal operator for analysis objects.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: DIAG overloads the diagonal operator for analysis objects.
%
% CALL:        b = diag (a)       % only with cdata AOs
%              b = diag (a, pl)   % only with cdata AOs
%
% INPUTS:      a  -  input analysis object
%              pl - parameter list
%
% OUTPUTS:     b  - output analysis object
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'diag')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = diag(varargin)
  
  % Check if the method was called by another method
  callerIsMethod = utils.helper.callerIsMethod;
  
  % Settings
  operatorName = 'diag';
  dxFcn = [];
  
  if callerIsMethod
    in_names = {};
  else
    % Collect input variable names
    in_names = cell(size(varargin));
    try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
    
    % Check if this is a call for the minfo object
    if utils.helper.isinfocall(varargin{:})
      varargout{1} = getInfo(varargin{3});
      return
    end
    
  end
  
  % Here we are forced to collect objects so that we can check that each ao
  % is the correct type and shape for doing diag.
  [as, dummy, rest] = utils.helper.collect_objects(varargin, 'ao', in_names);
  
  % Check for the correct data objects: Throw an error for data2D objects.
  as.checkDataType('data2D');
    
  copyObjects = nargout > 0;
  
  % Apply method to all AOs
  [out, pl] = ao.applymethod(copyObjects, callerIsMethod, in_names, operatorName, dxFcn, @getInfo, @getDefaultPlist, varargin{:});
  
  % set outputs
  varargout = utils.helper.setoutputs(nargout, out);
  
end

%--------------------------------------------------------------------------
% Get Info Object
%--------------------------------------------------------------------------
function ii = getInfo(varargin)
  ii = minfo.getInfoAxis(mfilename, @getDefaultPlist, mfilename('class'), 'ltpda', utils.const.categories.op, '', varargin);
end

%--------------------------------------------------------------------------
% Get Default Plist
%--------------------------------------------------------------------------

function plout = getDefaultPlist(set)
  persistent pl;
  persistent lastset;
  if ~exist('pl', 'var') || isempty(pl) || ~strcmp(lastset, set)
    pl = buildplist(set);
    lastset = set;
  end
  plout = pl;
end

function plout = buildplist(varargin)
  plout = plist.getDefaultAxisPlist(varargin{:});
  plout.remove('option');
  p = param({'option', 'See help on MATLAB''s <a href="matlab:doc(''diag'')">diag</a>.'}, {1, {0}, paramValue.OPTIONAL});
  plout.append(p);
end

