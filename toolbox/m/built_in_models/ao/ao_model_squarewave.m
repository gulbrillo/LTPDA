% AO_MODEL_SQUAREWAVE constructs a square-wave time-series
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: AO_MODEL_SQUAREWAVE constructs a square-wave time-series
%
% CALL:        a = ao(plist('built-in', 'squarewave'), pl);
%
% INPUTS:
%           pl - a parameter list of additional parameters (see below)
%
% OUTPUTS:
%           mdl - an AO object representing the time-series of the signal
%
%
% INFO:
%   <a href="matlab:utils.models.displayModelOverview('ao_model_squarewave')">Model Information</a>
%
%
% REFERENCES:
%
%
% HISTORY:
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = ao_model_squarewave(varargin)
  
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
  desc = 'Constructs a square-wave time-series';
end

function doc = getModelDocumentation
  doc = sprintf([...
    'No documentation at the moment' ...
    ]);
end

function package = getPackageName
  package = 'ltpda';
end

% default version is always the first one
function vt = versionTable()
  
  vt = {...
    'Initial version', @version01, ...
    };
  
end

  
% This version is the initial one
%
function varargout = version01(varargin)

  if nargin == 1 && ischar(varargin{1})
    switch varargin{1}
      case 'plist'
        
        % The plist for this version of this model
        pl = plist();
        
        % parameters 'Fs', 'Nsecs', 'Xunits'
        pl.append(plist.TSDATA_PLIST);
        
        % parameter 'F'
        p = param({'f', 'Frequency of the signal.'}, ...
          {1, {1}, paramValue.OPTIONAL});
        pl.append(p);
        
        % parameter 'Yunits'
        p = param({'yunits','Unit on Y axis.'},  paramValue.STRING_VALUE(''));
        pl.append(p);
        
        % set output
        varargout{1} = pl;
        
      case 'description'
        varargout{1} = 'This version is the initial one';
      case 'info'
        varargout{1} = [];
      otherwise
        error('unknown inputs');
    end
    return;
  end
  
  % build model
  pl = varargin{1};
  fs    = find(pl, 'fs');
  nsecs = find(pl, 'nsecs');
  f      = find(pl, 'f');
  xunits = find(pl, 'xunits');
  yunits = find(pl, 'yunits');
  
  % Build the AO and set its name
  spl = plist('waveform', 'squarewave', ...
    'fs', fs, ...
    'nsecs', nsecs, ...
    'f', f, ...
    'yunits', yunits, ...
    'xunits', xunits, ...
    'name', 'Square wave' ...
    );
  
  a = ao(spl);
  a.setProcinfo(spl);
  
  varargout{1} = a;
  
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

