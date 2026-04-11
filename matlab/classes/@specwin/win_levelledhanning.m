% WIN_LEVELLEDHANNING returns Hanning window, with N points and levelCoef levelling order
% If mode == 'define', the window values will be empty and all the features
% If mode == 'build', the window values will be calculated
%

function varargout = win_levelledhanning(w, mode, N, levelCoef)
  
  switch lower(mode)
    
    case 'build'
      n_args = nargin;
      if n_args < 3
        N = w.len;
      end
      if n_args < 4
        levelCoef = w.levelorder;
      end
      % Calculate the values of the window
      z = (1:N)./(N+1);
      v = 0.5 * (1 - cos(2*pi*z));
      
      for jj = 1:levelCoef
        v = v.*(2-v);
      end
      varargout{1} = v/norm(v)*length(v)^0.5;
      
    case 'define'
      % Make window struct
      w.type     = 'levelledHanning';
      w.len          = N;
      w.levelorder   = levelCoef;
      w.skip         = 0;
      
      varargout{1}   = w;
  end
  
  % END
