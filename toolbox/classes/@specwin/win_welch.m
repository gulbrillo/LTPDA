% WIN_WELCH returns Welch window, with N points.
% If mode == 'define', the window values will be empty and all the features
% If mode == 'build', the window values will be calculated
%

function varargout = win_welch(w, mode, N)
  
  switch lower(mode)
    
    case 'build'
      n_args = nargin;
      if n_args < 3
        N = w.len;
      end
      % Calculate the values of the window
      z            = [0:N-1]./N;
      varargout{1} = 1 - (2 * z - 1).^2;
      
    case 'define'
      % Make window struct
      w.type         = 'Welch';
      w.alpha        = 0;
      w.psll         = 21.3;
      w.rov          = 29.3;
      w.nenbw        = 1.2;
      w.w3db         = 1.1535;
      w.flatness     = -2.2248;
      w.len          = N;
      w.skip         = 0;
      
      varargout{1}   = w;
  end
  
  % END
  
