% WIN_FTSRS returns FTSRS window, with N points.
% If mode == 'define', the window values will be empty and all the features
% If mode == 'build', the window values will be calculated
%

function varargout = win_ftsrs(w, mode, N)
  
  switch lower(mode)
    
    case 'build'
      n_args = nargin;
      if n_args < 3
        N = w.len;
      end
      % Calculate the values of the window
      z            = [0:N-1]./N * 2 * pi;
      varargout{1} =  (1.0 - 1.93 * cos (z) + ...
                       1.29 * cos (2 * z) - 0.388 * cos (3 * z) + 0.028 * cos (4 * z));
      
    case 'define'
      % Make window struct
      w.type         = 'FTSRS';
      w.alpha        = 0;
      w.psll         = 76.6;
      w.rov          = 75.4;
      w.nenbw        = 3.7702;
      w.w3db         = 3.7274;
      w.flatness     = -0.0156;
      w.len          = N;
      w.skip         = 0;
      
      varargout{1}   = w;
  end
  
  % END
