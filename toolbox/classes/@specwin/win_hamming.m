% WIN_HAMMING returns Hamming window, with N points.
% If mode == 'define', the window values will be empty and all the features
% If mode == 'build', the window values will be calculated
%

function varargout = win_hamming(w, mode, N)
  
  switch lower(mode)
    
    case 'build'
      n_args = nargin;
      if n_args < 3
        N = w.len;
      end
      % Calculate the values of the window
      z            = [0:N-1]./N * 2 * pi;
      varargout{1} = 0.54 - 0.46 * cos(z);
      
    case 'define'
      % Make window struct
      w.type         = 'Hamming';
      w.alpha        = 0;
      w.psll         = 42.7;
      w.rov          = 50;
      w.nenbw        = 1.3628;
      w.w3db         = 1.3008;
      w.flatness     = -1.7514;
      w.len          = N;
      w.skip         = 0;
      
      varargout{1}   = w;
  end
  
  % END
  
