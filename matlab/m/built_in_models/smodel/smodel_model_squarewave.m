% A built-in model of class ao called squarewave
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: A built-in model of class ao called squarewave
%
% CALL:
%           mdl = smodel(plist('built-in', 'squarewave'));
%
% INPUTS:
%
%
% OUTPUTS:
%           mdl - an object of class smodel
%
%
% INFO:
%   <a href="matlab:utils.models.displayModelOverview('smodel_model_squarewave')">Model Information</a>
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
function varargout = smodel_model_squarewave(varargin)
  
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
  desc = 'constructs a square-wave with amplitude 1 and frequency f.';
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
  
  a = smodel('square(2.*pi.*f.*t)');
  a.setXvar('t');
  a.setParams({'f'}, {[]});
  a.setName('Square wave');
  a.setDescription('Square wave with amplitude 1 and frequency f');
  
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
