% WIN_HFT248D returns HFT248D window, with N points.
% If mode == 'define', the window values will be empty and all the features
% If mode == 'build', the window values will be calculated
%

function varargout = win_hft248d(w, mode, N)
  
  switch lower(mode)
    
    case 'build'
      n_args = nargin;
      if n_args < 3
        N = w.len;
      end
      % Calculate the values of the window
      z            = [0:N-1]./N * 2 * pi;
      varargout{1} = (1 - 1.985844164102 * cos(z) + ...
                      1.791176438506 * cos (2 * z) - 1.282075284005 * cos (3 * z) + ...
                      0.667777530266 * cos (4 * z) - 0.240160796576 * cos (5 * z) + ...
                      0.056656381764 * cos (6 * z) - 0.008134974479 * cos (7 * z) + ...
                      0.000624544650 * cos (8 * z) - 0.000019808998 * cos (9 * z) + ...
                      0.000000132974 * cos (10 * z));
      
    case 'define'
      % Make window struct
      w.type         = 'HFT248D';
      w.alpha        = 0;
      w.psll         = 248.4;
      w.rov          = 84.1;
      w.nenbw        = 5.6512;
      w.w3db         = 5.5567;
      w.flatness     = 0.0009;
      w.len          = N;
      w.skip         = 0;
      
      varargout{1}   = w;
  end
  
  % END
