% WIN_HFT196D returns HFT196D window, with N points.
% If mode == 'define', the window values will be empty and all the features
% If mode == 'build', the window values will be calculated
%

function varargout = win_hft196d(w, mode, N)
  
  switch lower(mode)
    
    case 'build'
      n_args = nargin;
      if n_args < 3
        N = w.len;
      end
      % Calculate the values of the window
      z            = [0:N-1]./N * 2 * pi;
      varargout{1} = (1 - 1.979280420 * cos (z) + ...
                      1.710288951 * cos (2 * z) - 1.081629853 * cos (3 * z) + ...
                      0.448734314 * cos (4 * z) - 0.112376628 * cos (5 * z) + ...
                      0.015122992 * cos (6 * z) - 0.000871252 * cos (7 * z) + ...
                      0.000011896 * cos (8 * z));
      
    case 'define'
      % Make window struct
      w.type         = 'HFT196D';
      w.alpha        = 0;
      w.psll         = 196.2;
      w.rov          = 82.3;
      w.nenbw        = 5.1134;
      w.w3db         = 5.0308;
      w.flatness     = 0.0013;
      w.len          = N;
      w.skip         = 0;
      
      varargout{1}   = w;
  end
  
  % END
