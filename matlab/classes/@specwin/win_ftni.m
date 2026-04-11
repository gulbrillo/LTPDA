% WIN_FTNI returns FTNI window, with N points.
% If mode == 'define', the window values will be empty and all the features
% If mode == 'build', the window values will be calculated
%

function varargout = win_ftni(w, mode, N)
  
  switch lower(mode)
    
    case 'build'
      n_args = nargin;
      if n_args < 3
        N = w.len;
      end
      % Calculate the values of the window
      z            = [0:N-1]./N * 2 * pi;
      varargout{1} = 0.2810639 - 0.5208972 * cos (z) + 0.1980399 * cos (2 * z);
      
    case 'define'
      % Make window struct
      w.type         = 'FTNI';
      w.alpha        = 0;
      w.psll         = 44.4;
      w.rov          = 65.6;
      w.nenbw        = 2.9656;
      w.w3db         = 2.9355;
      w.flatness     = 0.0169;
      w.len          = N;
      w.skip         = 0;
      
      varargout{1}   = w;
  end
  
  % END
