% WIN_HFT169D returns HFT169D window, with N points.
% If mode == 'define', the window values will be empty and all the features
% If mode == 'build', the window values will be calculated
%

function varargout = win_hft169d(w, mode, N)
  
  switch lower(mode)
    
    case 'build'
      n_args = nargin;
      if n_args < 3
        N = w.len;
      end
      % Calculate the values of the window
      z            = [0:N-1]./N * 2 * pi;
      varargout{1} = (1 - 1.97441843 * cos (z) ...
        + 1.65409889 * cos (2 * z) - 0.95788187 * cos (3 * z) + ...
        0.33673420 * cos (4 * z) - 0.06364622 * cos (5 * z) + ...
        0.00521942 * cos (6 * z) - 0.00010599 * cos (7 * z));
      
    case 'define'
      % Make window struct
      w.type         = 'HFT169D';
      w.alpha        = 0;
      w.psll         = 169.5;
      w.rov          = 81.2;
      w.nenbw        = 4.8347;
      w.w3db         = 4.7588;
      w.flatness     = 0.0017;
      w.len          = N;
      w.skip         = 0;
      
      varargout{1}   = w;
  end
  
  % END
