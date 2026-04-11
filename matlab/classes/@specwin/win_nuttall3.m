% WIN_NUTTALL3 returns Nuttall3 window, with N points.
% If mode == 'define', the window values will be empty and all the features
% If mode == 'build', the window values will be calculated
%

function varargout = win_nuttall3(w, mode, N)
  
  switch lower(mode)
    
    case 'build'
      n_args = nargin;
      if n_args < 3
        N = w.len;
      end
      % Calculate the values of the window
      z            = [0:N-1]./N * 2 * pi;
      varargout{1} = 0.375 - 0.5 * cos (z) + 0.125 * cos (2 * z);
      
    case 'define' 
      % Make window struct
      w.type         = 'Nuttall3';
      w.alpha        = 0;
      w.psll         = 46.7;
      w.rov          = 64.7;
      w.nenbw        = 1.9444;
      w.w3db         = 1.8496;
      w.flatness     = -0.8630;
      w.len          = N;
      w.skip         = 0;
      
      varargout{1}   = w;
  end
  
  % END
  
