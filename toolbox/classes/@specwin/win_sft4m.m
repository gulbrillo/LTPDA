% WIN_SFT4M returns SFT4M window, with N points.
% If mode == 'define', the window values will be empty and all the features
% If mode == 'build', the window values will be calculated
%

function varargout = win_sft4m(w, mode, N)
  
  switch lower(mode)
    
    case 'build'
      n_args = nargin;
      if n_args < 3
        N = w.len;
      end
      % Calculate the values of the window
      z            = [0:N-1]./N * 2 * pi;
      varargout{1} = 0.241906 - 0.460841 * cos(z) ...
                   + 0.255381 * cos (2 * z) - 0.041872 * cos (3 * z);
      
    case 'define'
      % Make window struct
      w.type         = 'SFT4M';
      w.alpha        = 0;
      w.psll         = 66.5;
      w.rov          = 72.1;
      w.nenbw        = 3.3868;
      w.w3db         = 3.3451;
      w.flatness     = -0.0067;
      w.len          = N;
      w.skip         = 0;
      
      varargout{1}   = w;
  end
  
  % END
