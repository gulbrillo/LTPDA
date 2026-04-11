% WIN_HFT116D returns HFT116D window, with N points.
% If mode == 'define', the window values will be empty and all the features
% If mode == 'build', the window values will be calculated
%

function varargout = win_hft116d(w, mode, N)
  
  switch lower(mode)
    
    case 'build'
      n_args = nargin;
      if n_args < 3
        N = w.len;
      end
      % Calculate the values of the window
      z            = [0:N-1]./N * 2 * pi;
      varargout{1} = (1 - 1.9575375 * cos (z) + ...
                      1.4780705 * cos (2 * z) - 0.6367431 * cos (3 * z) + ...
                      0.1228389 * cos (4 * z) - 0.0066288 * cos (5 * z));
      
    case 'define'
      % Make window struct
      w.type         = 'HFT116D';
      w.alpha        = 0;
      w.psll         = 116.8;
      w.rov          = 78.2;
      w.nenbw        = 4.2186;
      w.w3db         = 4.1579;
      w.flatness     = -0.0028;
      w.len          = N;
      w.skip         = 0;
      
      varargout{1}   = w;
  end
  
  % END
