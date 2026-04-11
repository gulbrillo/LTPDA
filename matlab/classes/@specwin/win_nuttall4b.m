% WIN_NUTTALL4B returns Nuttall4b window, with N points.
% If mode == 'define', the window values will be empty and all the features
% If mode == 'build', the window values will be calculated
%

function varargout = win_nuttall4b(w, mode, N)
  
  switch lower(mode)
    
    case 'build'
      n_args = nargin;
      if n_args < 3
        N = w.len;
      end
      % Calculate the values of the window
      z            = [0:N-1]./N * 2 * pi;
      varargout{1} = 0.355768 - 0.487396 * cos (z) + 0.144232 * cos (2 * z) - 0.012604 * cos (3 * z);
      
    case 'define'
      % Make window struct
      w.type         = 'Nuttall4b';
      w.alpha        = 0;
      w.psll         = 93.3;
      w.rov          = 66.3;
      w.nenbw        = 2.0212;
      w.w3db         = 1.9122;
      w.flatness     = -0.8118;
      w.len          = N;
      w.skip         = 0;
      
      varargout{1}   = w;
  end
  
  % END
