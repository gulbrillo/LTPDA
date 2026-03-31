% CONTEXT set the context of object that this history refers to.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: CONTEXT set the context of object that this history
%              refers to.
%
% CALL:        h = setContext(h, context);
%              h.setContext(context);
%
% INPUT:       h     - history object
%              context - a cell-array of stings like thank coming from {dbstack.name}.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = setContext(varargin)
  
  % Check the inputs
  if nargin ~= 2
    error('### This method accepts only one history object and one cell-array.');
  end
  
  h  = varargin{1};
  ctxt = varargin{2};
  
  % Decide on a deep copy or a modify
  h = copy(h, nargout);
  
  % Set the class name to the history object
  h.context = ctxt;
  
  % Define the output
  varargout{1} = h;
  
end
