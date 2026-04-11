


function title = getAltFromFilename(filename)
  
  if strfind(filename, '_cat_funcByCat.html')
    title = sprintf('Categories of %s', upper(strrep(filename, '_cat_funcByCat.html', '')));
  elseif strfind(filename, '_main_funcByCat.html')
    title = sprintf('Main Help Page of %s', upper(strrep(filename, '_main_funcByCat.html', '')));
  elseif strfind(filename, 'ltpda_training')
    title = 'Next';
  elseif strfind(filename, '../..')
    title = 'Previous';
  else
    idx = strfind(filename, '_');
    filename(idx(1)) = '/';
    title = strrep(filename, '.html', '');
    title = sprintf('Method: %s', title);
  end
  
end
