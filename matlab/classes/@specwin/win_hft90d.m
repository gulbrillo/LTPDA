% WIN_HFT90D returns HFT90D window, with N points.
% If mode == 'define', the window values will be empty and all the features
% If mode == 'build', the window values will be calculated
%

function varargout = win_hft90d(w, mode, N)
  
  switch lower(mode)
    
    case 'build'
      n_args = nargin;
      if n_args < 3
        N = w.len;
      end
      % Calculate the values of the window
      z            = [0:N-1]./N * 2 * pi;
      varargout{1} =  (1 - 1.942604 * cos (z) + ...
                       1.340318 * cos (2 * z) - 0.440811 * cos (3 * z) + ...
                       0.043097 * cos (4 * z));
      
    case 'define'
      % Make window struct
      w.type         = 'HFT90D';
      w.alpha        = 0;
      w.psll         = 90.2;
      w.rov          = 76;
      w.nenbw        = 3.8832;
      w.w3db         = 3.8320;
      w.flatness     = -0.0039;
      w.len          = N;
      w.skip         = 0;
      
      varargout{1}   = w;
  end
  
  % END
