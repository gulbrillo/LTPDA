% PROCESS_SMODEL_DIFF_OPTIONS checks the options for the parameters needed by smodel methods like diff
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: PROCESS_SMODEL_DIFF_OPTIONS checks the options for the parameters needed
% by smodel methods like diff. Checked options/parameters are:
%              - var
%              - n
%
% CALL:       pl = process_smodel_options(pl, rest)
%
% INPUTS:
%             pl      - the parameter list passed by user
%             rest    - the list of user inputs to search for variable
%                       definition by string
%
% OUTPUTS:    var    - the variable to act with respect to
%             pl_out - the revised plist, with the variable to act with
%                      respect to added
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = process_smodel_diff_options(pl, rest)
  % Necessary for debug messages
  import utils.const.*
  
  % Select the variable to use and the order
  % Input as a string or in a plist
  
  % First look for values inside the plist
  var = find(pl, 'var');
  n = find(pl, 'n');
  
  % Then look for arguments inside a list (strings and/or numbers)
  switch numel(rest)
    case 0
      % Nothing to do
    case 1
      % Inputs in a list of arguments 
      if ischar(rest{1})
        var  = rest{1};        
      else
        n  = rest{1};        
      end
    case 2
      if ischar(rest{1})
        var  = rest{1};
        n  = rest{2};
      else
        var  = rest{2};
        n  = rest{1};
      end
    otherwise
      error('### Not sure what to say here');
  end
  
  if isempty(n)
    n = 1;
  end
  
  p_var = plist('var', var, 'n', n);  
  
  % Combine plists
  usepl = combine(p_var, pl);
  
  switch nargout
    case 2
      varargout{1} = var;
      varargout{2} = usepl;
    case 3
      varargout{1} = var;
      varargout{2} = n;      
      varargout{3} = usepl;
  end
end
