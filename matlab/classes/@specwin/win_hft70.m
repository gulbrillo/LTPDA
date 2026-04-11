% WIN_HFT70 returns HFT70 window, with N points.
% If mode == 'define', the window values will be empty and all the features
% If mode == 'build', the window values will be calculated
%

function varargout = win_hft70(w, mode, N)
  
  switch lower(mode)
    
    case 'build'
      n_args = nargin;
      if n_args < 3
        N = w.len;
      end
      % Calculate the values of the window
      z            = [0:N-1]./N * 2 * pi;
      varargout{1} =  (1 - 1.90796 * cos (z) + ...
                       1.07349 * cos (2 * z) - 0.18199 * cos (3 * z));
      
    case 'define'
      % Make window struct
      w.type         = 'HFT70';
      w.alpha        = 0;
      w.psll         = 70.4;
      w.rov          = 72.2;
      w.nenbw        = 3.4129;
      w.w3db         = 3.3720;
      w.flatness     = -0.0065;
      w.len          = N;
      w.skip         = 0;
      
      varargout{1}   = w;
  end
  
  % END
