% WIN_HFT223D returns HFT223D window, with N points.
% If mode == 'define', the window values will be empty and all the features
% If mode == 'build', the window values will be calculated
%

function varargout = win_hft223d(w, mode, N)
  
  switch lower(mode)
    
    case 'build'
      n_args = nargin;
      if n_args < 3
        N = w.len;
      end
      % Calculate the values of the window
      z            = [0:N-1]./N * 2 * pi;
      varargout{1} = (1 - 1.98298997309 * cos(z) + ...
                      1.75556083063 * cos (2 * z) - 1.19037717712 * cos (3 * z) + ...
                      0.56155440797 * cos (4 * z) - 0.17296769663 * cos (5 * z) + ...
                      0.03233247087 * cos (6 * z) - 0.00324954578 * cos (7 * z) + ...
                      0.00013801040 * cos (8 * z) - 0.00000132725 * cos (9 * z));
    case 'define'
      % Make window struct
      w.type         = 'HFT223D';
      w.alpha        = 0;
      w.psll         = 223;
      w.rov          = 83.3;
      w.nenbw        = 5.3888;
      w.w3db         = 5.3;
      w.flatness     = -0.0011;
      w.len          = N;
      w.skip         = 0;
      
      varargout{1}   = w;
  end
  
  % END
