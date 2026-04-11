% WIN_SFT4F returns SFT4F window, with N points.
% If mode == 'define', the window values will be empty and all the features
% If mode == 'build', the window values will be calculated
%

function varargout = win_sft4f(w, mode, N)
  
  switch lower(mode)
    
    case 'build'
      n_args = nargin;
      if n_args < 3
        N = w.len;
      end
      % Calculate the values of the window
      z            = [0:N-1]./N * 2 * pi;
      varargout{1} = 0.21706 - 0.42103 * cos (z) + 0.28294 * cos (2 * z) - 0.07897 * cos (3 * z);
      
    case 'define'
      % Make window struct
      w.type         = 'SFT4F';
      w.alpha        = 0;
      w.psll         = 44.7;
      w.rov          = 75;
      w.nenbw        = 3.7970;
      w.w3db         = 3.7618;
      w.flatness     = 0.0041;
      w.len          = N;
      w.skip         = 0;
      
      varargout{1}   = w;
  end
  
  % END
