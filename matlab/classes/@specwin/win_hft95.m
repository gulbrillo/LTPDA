% WIN_HFT95 returns HFT95 window, with N points.
% If mode == 'define', the window values will be empty and all the features
% If mode == 'build', the window values will be calculated
%

function varargout = win_hft95(w, mode, N)
  
  switch lower(mode)
    
    case 'build'
      n_args = nargin;
      if n_args < 3
        N = w.len;
      end
      % Calculate the values of the window
      z            = [0:N-1]./N * 2 * pi;
      varargout{1} = (1 - 1.9383379 * cos (z) + ...
                      1.3045202 * cos (2 * z) - 0.4028270 * cos (3 * z) + ...
                      0.0350665 * cos (4 * z));
      
    case 'define'
      % Make window struct
      w.type         = 'HFT95';
      w.alpha        = 0;
      w.psll         = 95;
      w.rov          = 75.6;
      w.nenbw        = 3.8112;
      w.w3db         = 3.759;
      w.flatness     = 0.0044;
      w.len          = N;
      w.skip         = 0;
      
      varargout{1}   = w;
  end
  
  % END
