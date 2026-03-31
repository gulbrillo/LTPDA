% MAX computes the maximum value of the data in the AO
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: MAX computes the maximum value of the data in the AO.
%
% CALL:        ao_out = max(ao_in);
%              ao_out = max(ao_in, pl);
% 
% NOTE: this does not currently work for data3D AOs.
%
% PARAMETERS: 
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'max')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = max(varargin)
  
  % Check if the method was called by another method
  callerIsMethod = utils.helper.callerIsMethod;
  
  % Settings
  operatorName = 'max';
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
  % is the correct type for doing max.
  [as, dummy, rest] = utils.helper.collect_objects(varargin, 'ao', in_names);
  
  % Check for the correct data objects: Throw an error for data3D objects.
  as.checkDataType('data3D');
  
  copyObjects = nargout > 0;
  
  % Apply method to all AOs
  [out, pl] = ao.applymethod(copyObjects, callerIsMethod, in_names, operatorName, dxFcn, @getInfo, @getDefaultPlist, varargin{:});
  
  if isa(out, 'ao')
    out = fixAxisData(out, pl, callerIsMethod);
  end
  
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
end
