% WIN_RECTANGULAR returns rectangular window, with N points.
% If mode == 'define', the window values will be empty and all the features
% If mode == 'build', the window values will be calculated
%

function varargout = win_rectangular(w, mode, N)
  
  switch lower(mode)
    
    case 'build'
      n_args = nargin;
      if n_args < 3
        N = w.len;
      end
      % Calculate the values of the window
      
      varargout{1} = ones(1, N);
      
    case 'define'
      % Make window struct
      w.type         = 'Rectangular';
      w.alpha        = 0;
      w.psll         = 13.3;
      w.rov          = 0.0;
      w.nenbw        = 1.0;
      w.w3db         = 0.8845;
      w.flatness     = -3.9224;
      w.len          = N;
      w.skip         = 0;
      
      varargout{1}   = w;
  end
  
  % END
