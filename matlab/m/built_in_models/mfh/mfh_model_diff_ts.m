% mfh_model_diff_ts constructs differentiated time-series
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: MFH_MODEL_DIFF_TS constructs diff. time series.
%
% CALL:        a = mfh(plist('built-in', 'delayed_diff_ts'), pl);
%
% OUTPUTS:
%           mdl - an MFH object with the desired propertis.
%
% EXAMPLE: a =  mfh(plist('built-in', 'diff_ts'));
%
% INFO:
%   <a href="matlab:utils.models.displayModelOverview('mfh_model_diff_ts')">Model Information</a>
%
%
% REFERENCES:
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = mfh_model_diff_ts(varargin)
  
  varargout = utils.models.mainFnc(varargin(:), ...
    mfilename, ...
    @getModelDescription, ...
    @getModelDocumentation, ...
    @getVersion, ...
    @versionTable, ...
    @getPackageName);
  
end

%--------------------------------------------------------------------------
% AUTHORS EDIT THIS PART
%--------------------------------------------------------------------------

function desc = getModelDescription
  desc = 'Constructs a @mfh object for a differentiation of a time series. ';
end

function doc = getModelDocumentation
  doc = sprintf([...
    'The outputs can be MFH objects that compute the first or second '...
    'derivative of given time-series.' ...
    ]);
end

function package = getPackageName
  package = 'ltpda';
end

% default version is always the first one
function vt = versionTable()
  
  vt = {...
    'dt', @dt, ...
    'dtdt', @dtdt, ...
    };
  
end


% dt
%
function varargout = dt(varargin)
  
  if nargin == 1 && ischar(varargin{1})
    switch varargin{1}
      case 'plist'
        
        % The plist for this version of this model
        pl = plist();
        
        % parameter 'DT'
        p = param({'DT',['1/FS or DT of the time series. It can be '...
                         'a vector for un-even sampled time series taken from diff(ao.x).']},  paramValue.DOUBLE_VALUE(1));
        pl.append(p);  
                       
        % parameter 'NAME'
        p = param({'NAME','The name of the function handle.'},  paramValue.STRING_VALUE('dxdt'));
        pl.append(p);
        
        varargout{1} = pl;
        
      case 'description'
        varargout{1} = 'This version makes a first derivative';
      case 'info'
        varargout{1} = [];
      otherwise
        error('unknown inputs');
    end
    return;
  end
  
  pl = copy(varargin{1}, 1);
  dt = pl.find('DT');
  nm = pl.find('NAME');
  
  if isempty(dt)
    error('The key ''DT'' of the plist is necessary...')
  end
  
  % Derivative
  dxdt = mfh(plist('name',         nm, ...
                   'func',         'ao.diff3p_core(y,dt)', ...
                   'inputs',       {'y'},...
                   'constants',    {'dt'}, ...
                   'constObjects', {dt}));
  
  varargout{1} = dxdt;
  
end

% dtdt
%
function varargout = dtdt(varargin)
  
  if nargin == 1 && ischar(varargin{1})
    switch varargin{1}
      case 'plist'
        
        % The plist for this version of this model
        pl = plist();
        
        % parameter 'DT'
        p = param({'DT',['1/FS or DT of the time series. It can be '...
                         'a vector for un-even sampled time series taken from diff(ao.x).']},  paramValue.DOUBLE_VALUE(1));
        pl.append(p);
        
        % parameter 'NAME'
        p = param({'NAME','The name of the function handle.'},  paramValue.STRING_VALUE('d2xdt2'));
        pl.append(p);
        
        varargout{1} = pl;
        
      case 'description'
        varargout{1} = 'This version makes a second derivative.';
      case 'info'
        varargout{1} = [];
      otherwise
        error('unknown inputs');
    end
    return;
  end
  
  pl = copy(varargin{1}, 1);
  dt = pl.find('DT');
  nm = pl.find('NAME');
  
  if isempty(dt)
    error('The key ''DT'' of the plist is necessary...')
  end
  
  % Derivative
  dx2dt2 = mfh(plist('name',         nm, ...
                     'func',         'ao.diff3p_core(ao.diff3p_core(y,dt),dt)', ...
                     'inputs',       {'y'},...
                     'constants',    {'dt'}, ...
                     'constObjects', {dt}));
  
  varargout{1} = dx2dt2;
  
end

%--------------------------------------------------------------------------
% AUTHORS SHOULD NOT NEED TO EDIT BELOW HERE
%--------------------------------------------------------------------------


%--------------------------------------------------------------------------
% Get Version
%--------------------------------------------------------------------------
function v = getVersion
  
  v = '$Id$';
  
end

