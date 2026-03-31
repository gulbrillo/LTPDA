% WIN_NUTTALL4 returns Nuttall4 window, with N points.
% If mode == 'define', the window values will be empty and all the features
% If mode == 'build', the window values will be calculated
%

function varargout = win_nuttall4(w, mode, N)
  
  switch lower(mode)
    
    case 'build'
      n_args = nargin;
      if n_args < 3
        N = w.len;
      end
      % Calculate the values of the window
      z            = [0:N-1]./N * 2 * pi;
      varargout{1} = 0.3125 - 0.46875 * cos(z) + 0.1875 * cos (2 * z) - 0.03125 * cos (3 * z);
      
    case 'define'
      % Make window struct
      w.type         = 'Nuttall4';
      w.alpha        = 0;
      w.psll         = 60.9;
      w.rov          = 70.5;
      w.nenbw        = 2.31;
      w.w3db         = 2.1884;
      w.flatness     = -0.6184;
      w.len          = N;
      w.skip         = 0;
      
      varargout{1}   = w;
  end
  
  % END
  