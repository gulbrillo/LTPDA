% WIN_SFT3M returns SFT3M window, with N points.
% If mode == 'define', the window values will be empty and all the features
% If mode == 'build', the window values will be calculate%

function varargout = win_sft3m(w, mode, N)
  
  switch lower(mode)
    
    case 'build'
      n_args = nargin;
      if n_args < 3
        N = w.len;
      end
      % Calculate the values of the window
      z            = [0:N-1]./N * 2 * pi;
      varargout{1} = 0.28235 - 0.52105 * cos (z) + 0.19659 * cos (2 * z);
      
    case 'define'
      % Make window struct
      w.type         = 'SFT3M';
      w.alpha        = 0;
      w.psll         = 44.2;
      w.rov          = 65.5;
      w.nenbw        = 2.9452;
      w.w3db         = 2.9183;
      w.flatness     = -0.0115;
      w.len          = N;
      w.skip         = 0;
      
      varargout{1}   = w;
  end
  
  % END
