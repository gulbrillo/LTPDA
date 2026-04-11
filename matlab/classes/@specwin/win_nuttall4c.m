% WIN_NUTTALL4C returns Nuttall4c window, with N points.
% If mode == 'define', the window values will be empty and all the features
% If mode == 'build', the window values will be calculated
%

function varargout = win_nuttall4c(w, mode, N)
  
  switch lower(mode)
    
    case 'build'
      n_args = nargin;
      if n_args < 3
        N = w.len;
      end
      % Calculate the values of the window
      z            = [0:N-1]./N * 2 * pi;
      varargout{1} = 0.3635819 - 0.4891775 * cos (z) + 0.1365995 * cos (2 * z) - 0.0106411 * cos (3 * z);
      
    case 'define'
      % Make window struct
      w.type         = 'Nuttall4c';
      w.alpha        = 0;
      w.psll         = 98.1;
      w.rov          = 65.6;
      w.nenbw        = 1.9761;
      w.w3db         = 1.8687;
      w.flatness     = -0.8506;
      w.len          = N;
      w.skip         = 0;
      
      varargout{1}   = w;
  end
  
  % END
