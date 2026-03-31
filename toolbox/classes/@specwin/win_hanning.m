% WIN_HANNING returns Hanning window, with N points.
% If mode == 'define', the window values will be empty and all the features
% If mode == 'build', the window values will be calculated
%

function varargout = win_hanning(w, mode, N)
  
  switch lower(mode)
    
    case 'build'
      n_args = nargin;
      if n_args < 3
        N = w.len;
      end
      % Calculate the values of the window
      z            = [0:N-1]./N * 2 * pi;
      varargout{1} = 0.5 * (1 - cos(z));
      
    case 'define'
      % Make window struct
      w.type         = 'Hanning';
      w.alpha        = 0;
      w.psll         = 31.5;
      w.rov          = 50;
      w.nenbw        = 1.5;
      w.w3db         = 1.4382;
      w.flatness     = -1.4236;
      w.len          = N;
      w.skip         = 0;
      
      varargout{1}   = w;
  end
  
  % END
