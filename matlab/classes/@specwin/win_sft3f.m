% WIN_SFT3F returns SFT3F window, with N points.
% If mode == 'define', the window values will be empty and all the features
% If mode == 'build', the window values will be calculated
%

function varargout = win_sft3f(w, mode, N)
  
  switch lower(mode)
    
    case 'build'
      n_args = nargin;
      if n_args < 3
        N = w.len;
      end
      % Calculate the values of the window
      z            = [0:N-1]./N * 2 * pi;
      varargout{1} = 0.26526 - 0.5 * cos (z) + 0.23474 * cos (2 * z);
      
    case 'define'
      % Make window struct
      w.type         = 'SFT3F';
      w.alpha        = 0;
      w.psll         = 31.7;
      w.rov          = 66.7;
      w.nenbw        = 3.1681;
      w.w3db         = 3.1502;
      w.flatness     = 0.0082;
      w.len          = N;
      w.skip         = 0;
      
      varargout{1}   = w;
  end
  
  % END
