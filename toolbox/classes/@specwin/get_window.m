% GET_WINDOW returns the required window function as a structure.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: GET_WINDOW returns the required window function as a structure.
%
% CALL:        objs = get_window(objs, name, N);             % For standard windows
%              objs = get_window(objs, name, N, PSLL);       % For Kaiser windows
%              objs = get_window(objs, name, N, levelCoeff); % For levelled-Hann windows 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function w = get_window(varargin)

  PSLL = [];

  % Check inputs
  n_args = nargin;
  if n_args > 4 || n_args < 3
    error('### Incorrect inputs.');
  end
  
  % Get inputs
  w    = varargin{1};
  name = varargin{2};
  N    = varargin{3};
  if n_args == 4
    PSLL = varargin{4};
  end

  % Get window
  if isempty(PSLL)
    
    % Check for 'Kaiser' window
    if strcmpi(name, 'Kaiser')
      error('### The ''Kaiser'' window needed the length of the window and PSLL as an input');
    end
    
    % Check for 'levelledHanning' window
    if strcmpi(name, 'levelledHanning')
      error('### The ''levelledHanning'' window needed the levelling coefficient as an input');
    end
    
    % get standard window
    
    win_name = sprintf('win_%s', lower(name));
    try
      w = feval(win_name, w, 'define', N);
    catch ME
      if strcmp(ME.identifier, 'MATLAB:UndefinedFunction')
        error('\n### Your window [%s] is not a supported window.\n### Please type >> specwin.getTypes to see all supported windows.', name);
      else
        rethrow(ME);
      end
    end

  else

    if strcmpi(name, 'Kaiser')
      % Deal with Kaiser
      win_name = sprintf('win_%s', lower(name));
      w = feval(win_name, w, 'define', N, PSLL);
    elseif strcmpi(name, 'levelledHanning')
      % Deal with levelledHann window
      win_name = sprintf('win_%s', lower(name));
      levelCoef = PSLL;
      w = feval(win_name, w, 'define', N, levelCoef);
    else
      error('\n### Your window [%s] is not a supported 2-inputs window.\n### Please type >> specwin.getTypes to see all supported windows.', name);
    end
    
  end
end

