% CUMSUM overloads the cumsum operator for analysis objects.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: CUMSUM overloads the cumsum operator for analysis objects.
%
% CALL:        ao_out = cumsum(ao_in);
%              ao_out = cumsum(ao_in, pl);
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'cumsum')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = cumsum(varargin)

% Check if the method was called by another method
callerIsMethod = utils.helper.callerIsMethod;

% Settings
operatorName = 'cumsum';
dxFcn = @(x,dx) dx;

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
    % Clear errors
    clearErrors(bs, pl);
    
    for ii = 1:numel(bs)
        if isa(bs(ii).data,'tsdata')
            if pl.find('scale') && ~isempty(bs(ii).fs) && bs(ii).fs > 0
                Ts = ao(cdata(1/bs(ii).fs));
                Ts.setYunits(bs(ii).xunits);
                bs(ii) = bs(ii)*Ts;
                bs.simplifyYunits();
            end
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

% Indices
p = param(...
    {'Scale', ['For tsdata with fixed fs, scale by sampling frequency.']},...
    paramValue.FALSE_TRUE...
    );
plout.append(p);
end
