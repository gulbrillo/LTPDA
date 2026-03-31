function varargout = strpad(varargin)
% STRPAD Pads a string with blank spaces until it is N characters long.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: STRPAD Pads a string with blank spaces until it is N characters
%              long. If s is already N characters long (or longer) then
%              no action is taken.
%
% CALL:       so = utils.prog.strpad('Pads this string to 30 characters', 30)
%             so = utils.prog.strpad('Pads this string to 30 characters', [10 30])
%             so = utils.prog.strpad('Pads this string with = characters', [10 30], '=')
%
% INPUTS:     s  - string
%             N  - length of the string. If you give two values here, then
%                  the string is padded at the front and back.
%             c  - pad with this string/character. Default is ' '.
% 
% OUTPUTS:    so - the padded string
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

c = '';
if nargin == 2
  s = varargin{1};
  N = varargin{2};
elseif nargin == 3
  s = varargin{1};
  N = varargin{2};
  c = varargin{3};
else
  help(mfilename);
  error('### Incorrect inputs');
end

if isempty(c)
  c = ' ';
end

if numel(N) == 2
  numOfPads = sum(N) - length(s);
  left  = floor(numOfPads/2);
  right = ceil(numOfPads/2);
  s = [repmat(c, 1, left), s, repmat(c, 1, right)];
else
  s = [s repmat(c, 1, N-length(s))];
end

% Set output
varargout{1} = s;

% END
