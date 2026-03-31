% MCOLOR2JCOLOR converts a MATLAB color to a java Color object.
%
% CALL:
%            jc = utils.prog.mcolor2jcolor('m');
%            jc = utils.prog.mcolor2jcolor([0 1 0.2]);
%            jc = utils.prog.mcolor2jcolor(0, 1, 0.2);
%
function out = mcolor2jcolor(varargin)
  
  cval = [];
  switch nargin
    case 1
      
      if ischar(varargin{1})
        switch varargin{1}
          case {'y', 'yellow'}
            cval = [1 1 0];
          case {'m', 'magenta'}
            cval = [1 0 1];
          case {'c', 'cyan'}
            cval = [0 1 1];
          case {'r', 'red'}
            cval = [1 0 0];
          case {'g', 'green'}
            cval = [0 1 0];
          case {'b', 'blue'}
            cval = [0 0 1];
          case {'w', 'white'}
            cval = [1 1 1];
          case {'k', 'black'}
            cval = [0 0 0];
          otherwise
            error('Unknown color string');
        end
      else
        cval = varargin{1};
      end
      
    case 3
      cval = [varargin{:}];
    otherwise
      help(mfilename);
      error('Incorrect inputs');
  end
  
  if any(cval > 1)
    % For the case that the user have define the color in the range 0 - 255
    cval = cval/255;
  end
  
  if isempty(cval)
    cval = [0 0 0];
  end
  
  out = java.awt.Color(cval(1), cval(2), cval(3));
  
end
