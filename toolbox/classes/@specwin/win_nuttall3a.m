% WIN_NUTTALL3A returns Nuttall3a window, with N points.
% If mode == 'define', the window values will be empty and all the features
% If mode == 'build', the window values will be calculated
%

function varargout = win_nuttall3a(w, mode, N)
  
  switch lower(mode)
    
    case 'build'
      n_args = nargin;
      if n_args < 3
        N = w.len;
      end
      % Calculate the values of the window
      z            = [0:N-1]./N * 2 * pi;
      varargout{1} = 0.40897 - 0.5 * cos (z) + 0.09103 * cos (2 * z);
      
    case 'define'
      % Make window struct
      w.type         = 'Nuttall3a';
      w.alpha        = 0;
      w.psll         = 64.2;
      w.rov          = 61.2;
      w.nenbw        = 1.7721;
      w.w3db         = 1.6828;
      w.flatness     = -1.0453;
      w.len          = N;
      w.skip         = 0;
      
      varargout{1}   = w;
  end
  
  % END
  