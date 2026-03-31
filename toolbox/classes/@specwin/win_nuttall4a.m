% WIN_NUTTALL4A returns Nuttall4a window, with N points.
% If mode == 'define', the window values will be empty and all the features
% If mode == 'build', the window values will be calculated
%

function varargout = win_nuttall4a(w, mode, N)
  
  switch lower(mode)
    
    case 'build'
      n_args = nargin;
      if n_args < 3
        N = w.len;
      end
      % Calculate the values of the window
      z            = [0:N-1]./N * 2 * pi;
      varargout{1} = 0.338946 - 0.481973 * cos (z) + 0.161054 * cos (2 * z) - 0.018027 * cos (3 * z);
      
    case 'define'
      % Make window struct
      w.type         = 'Nuttall4a';
      w.alpha        = 0;
      w.psll         = 82.6;
      w.rov          = 68;
      w.nenbw        = 2.1253;
      w.w3db         = 2.0123;
      w.flatness     = -0.7321;
      w.len          = N;
      w.skip         = 0;
      
      varargout{1}   = w;
  end
  
  % END
