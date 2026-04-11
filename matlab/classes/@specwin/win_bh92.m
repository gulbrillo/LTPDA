% WIN_BH92 returns BH92 window, with N points.
% If mode == 'define', the window values will be empty and all the features
% If mode == 'build', the window values will be calculated
%

function varargout = win_bh92(w, mode, N)
  
  switch lower(mode)
    
    case 'build'
      n_args = nargin;
      if n_args < 3
        N = w.len;
      end
      % Calculate the values of the window
      z            = [0:N-1]./N * 2 * pi;
      varargout{1} = 0.35875 - 0.48829 * cos (z) + 0.14128 * cos (2 * z) - 0.01168 * cos (3 * z);
      
    case 'define'
      % Make window struct
      w.type         = 'BH92';
      w.alpha        = 0;
      w.psll         = 92;
      w.rov          = 66.1;
      w.nenbw        = 2.0044;
      w.w3db         = 1.8962;
      w.flatness     = -0.8256;
      w.len          = N;
      w.skip         = 4;
      
      varargout{1}   = w;
  end
  
  % END
