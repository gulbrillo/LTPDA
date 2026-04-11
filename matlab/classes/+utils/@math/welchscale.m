% WELCHSCALE scales the output of welch to be in the required units
%

function [yy, dyy, info] = welchscale(xx, dxx, win, fs, norm, inunits)
  
  nfft = length(win);
  S1   = sum(win);
  S2   = sum(win.^2);
  enbw = fs * S2 / (S1*S1);
  
  if isempty(norm)
    norm = 'None';
  end
  switch lower(norm)
    case 'asd'
      yy = sqrt(xx);
      if isempty(dxx)
        dyy = dxx;
      else
        dyy = 1./2./sqrt(xx) .* dxx;
      end
      info.units = inunits ./ unit('Hz^0.5');
    case 'psd'
      yy = xx;
      dyy = dxx;
      info.units = inunits.^2/unit('Hz');
    case 'as'
      yy = sqrt(xx * enbw);
      if isempty(dxx)
        dyy = dxx;
      else
        dyy = 1./2./sqrt(xx) .* dxx * enbw;
      end
      info.units = inunits;
    case 'ps'
      yy = xx * enbw;
      dyy = dxx * enbw;
      info.units = inunits.^2;
    case 'none'
      yy = xx;
      dyy = dxx;
      info.units = inunits;
    otherwise
      error('Unknown normalisation');
  end
  
  info.nfft = nfft;
  info.enbw = enbw;
  info.norm = norm;
  
end

