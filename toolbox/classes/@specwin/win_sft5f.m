% WIN_SFT5F returns SFT5F window, with N points.
% If mode == 'define', the window values will be empty and all the features
% If mode == 'build', the window values will be calculated
%

function varargout = win_sft5f(w, mode, N)
  
  switch lower(mode)
    
    case 'build'
      n_args = nargin;
      if n_args < 3
        N = w.len;
      end
      % Calculate the values of the window
      z            = [0:N-1]./N * 2 * pi;
      varargout{1} = 0.1881 - 0.36923 * cos (z) + ...
                     0.28702 * cos (2 * z) - 0.13077 * cos (3 * z) + 0.02488 * cos (4 * z);
      
    case 'define'
      % Make window struct
      w.type         = 'SFT5F';
      w.alpha        = 0;
      w.psll         = 57.3;
      w.rov          = 78.5;
      w.nenbw        = 4.3412;
      w.w3db         = 4.2910;
      w.flatness     = -0.0025;
      w.len          = N;
      w.skip         = 0;
      
      varargout{1}   = w;
  end
  
  % END
