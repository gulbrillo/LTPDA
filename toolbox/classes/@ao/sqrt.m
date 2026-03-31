% SQRT computes the square root of the data in the AO.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: SQRT computes the square root of the data in the AO.
%
% CALL:        ao_out = sqrt(ao_in);
%              ao_out = sqrt(ao_in, pl);
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'sqrt')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = sqrt(varargin)
  
  % Check if the method was called by another method
  callerIsMethod = utils.helper.callerIsMethod;
  
  % Settings
  operatorName = 'sqrt';
  dxFcn = @(x,dx)abs(1./(2*sqrt(abs(x)))).*dx;
  
  if callerIsMethod
    in_names = {};
  else
    % Collect input variable names
    in_names = cell(size(varargin));
    try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
  end
  
  copyObjects = nargout>0;
  [bs, pl] = ao.applymethod(copyObjects, callerIsMethod, in_names, operatorName, dxFcn, @getInfo, @getDefaultPlist, varargin{:});
  
  if isa(bs, 'ao')
    % Set units
    for ii = 1:numel(bs)
      app_axis = pl.find_core('axis');
      if any('X'==upper(app_axis))
        bs(ii).data.setXunits(feval('sqrt', bs(ii).data.xunits));
      end
      if any('Y'==upper(app_axis))
        bs(ii).data.setYunits(feval('sqrt', bs(ii).data.yunits));
      end
      if any('Z'==upper(app_axis))
        bs(ii).data.setZunits(feval('sqrt', bs(ii).data.zunits));
      end
    end
  end
  
  % set outputs
  varargout = utils.helper.setoutputs(nargout, bs);
  
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

