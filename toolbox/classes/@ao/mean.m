% MEAN computes the mean value of the data in the AO.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: MEAN computes the mean value of the data in the AO.
% The uncertainty is evaluated as the standard deviation of the mean.
%
% CALL:        b = mean(a)
%              b = mean(a, pl)
%
% INPUTS:      pl   - a parameter list
%              a    - input analysis object
%
% OUTPUTS:     b  - output analysis object
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'mean')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = mean(varargin)
  
  % Check if the method was called by another method
  callerIsMethod = utils.helper.callerIsMethod;
  
  % Settings
  operatorName = 'mean';
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
  % is the correct type for doing mean.
  [as, dummy, rest] = utils.helper.collect_objects(varargin, 'ao', in_names);
  
  % Check for the correct data objects: Throw an error for data3D objects.
  as.checkDataType('data3D');

  copyObjects = nargout > 0;
  
  % We need a copy of the original object, in the case of a modifier call,
  % so to retain the data to calculate the uncertainty
  as_copy = copy(as, ~copyObjects);
  
  % Apply method to all AOs
  [out, pl] = ao.applymethod(copyObjects, callerIsMethod, in_names, operatorName, dxFcn, @getInfo, @getDefaultPlist, varargin{:});
  
  if isa(out, 'ao')
    out = fixAxisData(out, pl, callerIsMethod);
  end
  
  % evaluate the uncertainty
  setUncertainty(as_copy, out, pl);
  
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

function setUncertainty(aos_in, aos_out, pl)
  
  axs = find_core(pl, 'axis');
  dim = find_core(pl, 'dim');
  
  for ii = 1:numel(aos_in)
    switch axs
      case 'y'
        % Here I need to check for the 'dim' option
        if isempty(dim) || dim < 1 || dim > 2
          % Reset to default
          dim = 1;
        end
        v = aos_in(ii).y;
        d = std(v, 0, dim)/sqrt(size(v, dim));
        aos_out(ii).setDy(d);
      case 'z'
        % Here I need to check for the 'dim' option
        if isempty(dim) || dim < 1 || dim > 2
          % Reset to default
          dim = 1;
        end
        v = aos_in(ii).x;
        d = std(v, 0, dim)/sqrt(size(v, dim));
        
        aos_out(ii).setDy(d);
      case 'x'
        v = aos_in(ii).x;
        d = std(v)/sqrt(numel(v));
        
        aos_out(ii).setDy(d);
      case 'xy'
        v1 = aos_in(ii).x;
        v2 = aos_in(ii).y;
        d1 = std(v1)/sqrt(numel(v1));
        d2 = std(v2)/sqrt(numel(v2));
        
        aos_out(ii).setDx(d1);
        aos_out(ii).setDy(d2);
      case 'xyz'
        v1 = aos_in(ii).x;
        v2 = aos_in(ii).y;
        v3 = aos_in(ii).z;
        d1 = std(v1)/sqrt(numel(v1));
        d2 = std(v2)/sqrt(numel(v2));
        d3 = std(v3)/sqrt(numel(v3));
        
        aos_out(ii).setDx(d1);
        aos_out(ii).setDy(d2);
      otherwise
    end
  end
end
