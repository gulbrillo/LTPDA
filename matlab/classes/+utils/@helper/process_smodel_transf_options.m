% PROCESS_SMODEL_TRANSF_OPTIONS checks the options for the parameters needed by smodel methods like transforms
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: PROCESS_SMODEL_TRANSF_OPTIONS checks the options for the parameters needed
% by smodel methods like transforms. Checked options/parameters are:
%              - in_var
%              - ret_var
%
% CALL:       pl = process_smodel_transf_options(pl, type, varargin)
%
% INPUTS:
%             pl      - the parameter list passed by user
%             rest    - the list of user inputs to search for variable
%                       definition by string
%
% OUTPUTS:    in_var    - the variable to act with respect to
%             ret_var   - the variable to transform into
%             pl_out - the revised plist, with the variable to act with
%                      respect to added
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = process_smodel_transf_options(pl, rest)
  % Necessary for debug messages
  import utils.const.*
  
  % Select the variable to use and the order
  % Input as a string or in a plist
  
  % First look for values inside the plist
  in_var = find(pl, 'in_var');
  ret_var = find(pl, 'ret_var');  
  
  % Then look for arguments inside a list (strings and/or numbers)
  switch numel(rest)
    case 0
      % Nothing to do
    case 1
      % Inputs in a list of arguments
      ret_var  = rest{1};
    case 2
      in_var  = rest{1};
      ret_var  = rest{2};
    otherwise
      error('### Not sure what to say here');
  end
    
  p_var = plist('in_var', in_var, 'ret_var', ret_var);  
  
  % Combine plists
  usepl = combine(pl, p_var);
  
  switch nargout
    case 2
      varargout{1} = ret_var;
      varargout{2} = usepl;
    case 3
      varargout{1} = in_var;
      varargout{2} = ret_var;      
      varargout{3} = usepl;
  end
end
