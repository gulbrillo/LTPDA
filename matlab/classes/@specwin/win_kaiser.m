% WIN_KAISER returns Kaiser window, with N points and psll peak sidelobe level.
% If mode == 'define', the window values will be empty and all the features
% If mode == 'build', the window values will be calculated
%

function varargout = win_kaiser(w, mode, N, psll)
  
  switch lower(mode)
    
    case 'build'
      n_args = nargin;
      if n_args < 3
        N = w.len;
      end
      
      % Compute window samples
      % - here we adjust to make the window asymmetric
      v = kaiser(N+1, pi*w.alpha)';
      varargout{1} = v(1:end-1);
      
    case 'define'
      % Make window struct
      w.type         = 'Kaiser';
      w.alpha        = specwin.kaiser_alpha(psll);
      w.psll         = psll;
      w.rov          = specwin.kaiser_rov(w.alpha);
      w.nenbw        = specwin.kaiser_nenbw(w.alpha);
      w.w3db         = specwin.kaiser_w3db(w.alpha);
      w.flatness     = specwin.kaiser_flatness(w.alpha);
      w.len          = N;
      w.skip         = 0;
      
      varargout{1}   = w;
  end
