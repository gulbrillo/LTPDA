% FROMSPECWIN Construct an ao from a Spectral window
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    fromSpecWin
%
% DESCRIPTION: Construct an ao from a Spectral window
%
% CALL:        a = fromSpecWin(a, win)
%
% PARAMETER:   win: Spectral window object
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function a = fromSpecWin(a, pli)
  
  % get AO info
  ii = ao.getInfo('ao', 'From Window');
  
  % If the user input a specwin object, construct an appropriate plist
  if isa(pli, 'specwin')
    pli = toPlist(pli);
  end
  
  % If the 'win' value in the input plist is a specwin object, expand it in
  % to plist keys
  if isa(pli.find_core('win'), 'specwin')
    win = pli.find_core('win');
    pli.remove('win');
    pli.append(toPlist(win));
  end
  
  % Apply defaults
  pl = applyDefaults(ii.plists, pli);
  win = find_core(pl, 'win');
    
  if ischar(win)
    len = pl.find_core('length');
    switch lower(win)
      case 'kaiser'
        psll = pl.find_core('psll');
        win = specwin(win, len,  psll);
      case 'levelledhanning'
        levelorder = pl.find_core('levelorder');
        win = specwin(win, len, levelorder);
      otherwise
        win = specwin(win, len);
    end
    pl.pset('win', win.type);
  else
    % we have a specwin and we just use the values
  end
  
  % Make a cdata object
  a.data = cdata(win.win);
  if isempty(pl.find_core('name'))
    pl.pset('name', sprintf('ao(%s)', win.type));
  end
  
  % Add history
  a.addHistory(ii, pl, [], []);
  
  % Set Yunits
  a.data.setYunits(pl.find_core('yunits'));
  
  % Set object properties from plist
  a.setObjectProperties(pl, {'yunits'});
  
end


