% A built-in model of class <CLASS> called <NAME>
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: A built-in model of class <CLASS> called <NAME>
%
% CALL:
%           mdl = <CLASS>(plist('built-in', '<NAME>'));
%
% INPUTS:
%
%
% OUTPUTS:
%           mdl - an object of class <CLASS>
%
%
% INFO:
%   <a href="matlab:utils.models.displayModelOverview('<CLASS>_model_<NAME>')">Model Information</a>
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
function varargout = <CLASS>_model_<NAME>(varargin)
  
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
  desc = 'A built-in model that ...';
end

function package = getPackageName
  package = '<MODULE>';
end

function doc = getModelDocumentation
  doc = sprintf([...
    'Some information about this model. You can write html code here.\n'...
    ]);
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
        
        % parameter 'My Parameter'
        p = param({'My Parameter', ['A Parameter which configures the model in some way.']}, ...
          paramValue.EMPTY_DOUBLE);
        pl.append(p);
        
        % set output
        varargout{1} = pl;
        
      case 'description'
        varargout{1} = 'This version is ...';
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
  
  % Input plist
  userPlist  = varargin{1};
  % This can be locally modified without the changes being reflected to the user
  localPlist = copy(userPlist, 1);
  
  % Get parameters
  p = localPlist.find('My Parameter');
  
  % Build the model object the way you want
  
  obj = <CLASS>();
  
  varargout{1} = obj;
  
end


%--------------------------------------------------------------------------
% AUTHORS SHOULD NOT NEED TO EDIT BELOW HERE
%--------------------------------------------------------------------------


%--------------------------------------------------------------------------
% Get Version
%--------------------------------------------------------------------------
function v = getVersion
  
  v = '';
  
end
