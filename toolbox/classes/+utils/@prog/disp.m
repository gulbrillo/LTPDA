function varargout = disp(varargin)

% DISP display a formatted string to screen.
% 
% usage:     disp(format, args);
%        s = disp(format, args);
% 
% Examples:
%      >> disp('%s-%d', 'hello', 3);
%      >> s = disp('%s-%d', 'hello', 3);
% 

% so simple
s = sprintf(varargin{1}, varargin{2:end});
disp(s);

if nargout == 1
  varargout{1} = s;
end

% END