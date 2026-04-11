% WIN_SFT5M returns SFT5M window, with N points.
% If mode == 'define', the window values will be empty and all the features
% If mode == 'build', the window values will be calculated
%

function varargout = win_sft5m(w, mode, N)
  
  switch lower(mode)
    
    case 'build'
      n_args = nargin;
      if n_args < 3
        N = w.len;
      end
      % Calculate the values of the window
      z            = [0:N-1]./N * 2 * pi;
      varargout{1} =  0.209671 - 0.407331 * cos(z) + ...
        0.281225 * cos (2 * z) - 0.092669 * cos (3 * z) + ...
        0.0091036 * cos (4 * z);
      
    case 'define'
      % Make window struct
      w.type         = 'SFT5M';
      w.alpha        = 0;
      w.psll         = 89.9;
      w.rov          = 76;
      w.nenbw        = 3.8852;
      w.w3db         = 3.8340;
      w.flatness     = 0.0039;
      w.len          = N;
      w.skip         = 0;
      
      varargout{1}   = w;
  end
  
  % END
