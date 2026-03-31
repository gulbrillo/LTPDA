% A built-in model of class ao called oscillator_fd_tf
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: A built-in model of class ao called oscillator_fd_tf
%
% CALL:
%           mdl = smodel(plist('built-in', 'oscillator_fd_tf'));
%
% INPUTS:
%
%
% OUTPUTS:
%           mdl - an object of class smodel
%
%
% INFO:
%   <a href="matlab:utils.models.displayModelOverview('smodel_model_oscillator_fd_tf')">Model Information</a>
%
%
% REFERENCES:
%
%
% HISTORY:
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% YOU SHOULD NOT NEED TO EDIT THIS MAIN FUNCTION
function varargout = smodel_model_oscillator_fd_tf(varargin)
  
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
  desc = 'constructs a frequency-domain model of an harmonic oscillator transfer function.';
end

function doc = getModelDocumentation
  doc = sprintf([...
    ''...
    ]);
end

function package = getPackageName
  package = 'ltpda';
end

% default version is always the first one
function vt = versionTable()
  
  vt = {...
    'Version 1', @version1, ...
    };
  
end

% This version is ...
%
function varargout = version1(varargin)
  
  if nargin == 1 && ischar(varargin{1})
    switch varargin{1}
      case 'plist'
        
        % The plist for this version of this model
        pl = plist();
        
        % var
        p = param(...
          {'var', ['The variable to use for the frequency. Choose from:<ul>' ...
          '<li>''f'' to use  2*pi*i*f</li>' ...
          '<li>''s'' to use  s</li></ul>']}, {1, {'f', 's'}, paramValue.SINGLE});
        pl.append(p);
                
        % set output
        varargout{1} = pl;
        
      case 'description'
        varargout{1} = 'This version is version 1.';
      case 'info'
        % Add info calls for any other models that you use to build this
        % model. For example:
        %         varargout{1} = [ ...
        %  ao_model_SubModel1('info', 'Some Version') ...
        %  ao_model_SubModel2('info', 'Another Version') ...
        %                        ];
        %
        varargout{1} = [];
      otherwise
        error('unknown inputs');
    end
    return;
  end
  
  % build model
  pl = varargin{1};
  
  var = find(pl, 'var');
  
  % Let's define the oscillator parameters:  
  switch var
    case 'f'
      var_str = '(2i.*pi.*f)';      
    case 's'
      var_str = 's';
    otherwise
      var_str = '';
  end
  H = ['1./(m.*(k/m + ' var_str '.^2 + ' var_str './tau))'];
  
  a = smodel(H);
  a.setXvar(var);
  a.setParams({'m','k','tau'},{[],[],[]});
  a.setYunits('m/N');
  a.setName('Oscillator frequency response');
  a.setDescription('frequency-domain response of a mechanical oscillator transfer function');
  
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
