% WIN_NUTTALL3B returns Nuttall3b window, with N points.
% If mode == 'define', the window values will be empty and all the features
% If mode == 'build', the window values will be calculated
%

function varargout = win_nuttall3b(w, mode, N)
  
  switch lower(mode)
    
    case 'build'
      n_args = nargin;
      if n_args < 3
        N = w.len;
      end
      % Calculate the values of the window
      z            = [0:N-1]./N * 2 * pi;
      varargout{1} = 0.4243801 - 0.4973406 * cos (z) + 0.0782793 * cos (2 * z);
      
    case 'define'
      % Make window struct
      w.type         = 'Nuttall3b';
      w.alpha        = 0;
      w.psll         = 71.5;
      w.rov          = 59.8;
      w.nenbw        = 1.7037;
      w.w3db         = 1.6162;
      w.flatness     = -1.1352;
      w.len          = N;
      w.skip         = 0;
      
      varargout{1}   = w;
  end
  
  % END
  