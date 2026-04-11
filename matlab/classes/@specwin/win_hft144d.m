% WIN_HFT144D returns HFT144D window, with N points.
% If mode == 'define', the window values will be empty and all the features
% If mode == 'build', the window values will be calculated
%

function varargout = win_hft144d(w, mode, N)
  
  switch lower(mode)
    
    case 'build'
      n_args = nargin;
      if n_args < 3
        N = w.len;
      end
      % Calculate the values of the window
      z            = [0:N-1]./N * 2 * pi;
      varargout{1} = (1 - 1.96760033 * cos (z) ...
                    + 1.57983607 * cos (2 * z) - 0.81123644 * cos (3 * z) + ...
                      0.22583558 * cos (4 * z) - 0.02773848 * cos (5 * z) + ...
                      0.00090360 * cos (6 * z));
      
    case 'define'
      % Make window struct
      w.type         = 'HFT144D';
      w.alpha        = 0;
      w.psll         = 144.1;
      w.rov          = 79.9;
      w.nenbw        = 4.5386;
      w.w3db         = 4.4697;
      w.flatness     = 0.0021;
      w.len          = N;
      w.skip         = 0;
      
      varargout{1}   = w;
  end
  
  % END
