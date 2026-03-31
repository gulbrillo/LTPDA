% ISINFOCALL defines the condition for an 'info' call
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: ISINFOCALL defines the condition for an 'info' call
%
% CALL:        out = isinfocall(varargin{:})
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function out = isinfocall(varargin)
  
  % Check if this is a call for parameters
  if nargin == 3
    if ischar(varargin{2}) && ischar(varargin{3}) && strcmp(varargin{2}, 'INFO')
      out = true;
      return
    end
  end
  out = false;
end

