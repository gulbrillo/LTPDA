% TOPLIST creates a plist representing the specwin object.
%
% CALL:   pl = w.toPlist;
% 

function pl = toPlist(win)
  switch lower(win.type)
    case 'kaiser'
      pl = plist('win', win.type, 'length', win.len, 'psll', win.psll);
    case 'levelledhanning'
      pl = plist('win', win.type, 'length', win.len, 'levelorder', win.levelorder);
    otherwise
      pl = plist('win', win.type, 'length', win.len);
  end
end
 