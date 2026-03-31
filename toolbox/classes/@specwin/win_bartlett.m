% WIN_BARTLETT returns Bartlett window, with N points.
% If mode == 'define', the window values will be empty and all the features
% If mode == 'build', the window values will be calculated
%

function varargout = win_bartlett(w, mode, N)
  
  switch lower(mode)
    
    case 'build'
      n_args = nargin;
      if n_args < 3
        N = w.len;
      end
      % Calculate the values of the window
      z            = [0:N-1]./N;
      v = z * 2;
      idx = find(v > 1);
      v(idx) = 2 - v(idx);
      varargout{1} = v;
      
    case 'define'
      % Make window struct
      w.type         = 'Bartlett';
      w.alpha        = 0;
      w.psll         = 26.5;
      w.rov          = 50;
      w.nenbw        = 1.3333;
      w.w3db         = 1.2736;
      w.flatness     = -1.8242;
      w.len          = N;
      w.skip         = 0;
      
      varargout{1}   = w;
  end
  
  % END
