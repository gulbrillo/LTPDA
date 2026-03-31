% GETPUBLICMETHODS returns a cell array of the public methods for the given
% class.
% 
% CALL: [methods, minfos] = getPublicMethods(classname);
% 

function [mths, infos] = getPublicMethods(cl)
  
  fprintf('   collecting methods for %s class...\n', cl);
  
  cms = eval(['?' cl]);
  m = [cms.Methods{:}];
  if isempty(m)
    mths = {};
    infos = [];
    return;
  end
  idx_static = [m(:).Static];
  idx_hidden = [m(:).Hidden];
  idx_public = strcmpi({m(:).Access}, 'public');
  
  dc = [m(:).DefiningClass];
  idx_handle = strcmpi({dc(:).Name}, 'handle');
  
  idx = ~idx_static & ~idx_hidden & idx_public & ~idx_handle;
  
  m = m(idx);
  if isempty(m)
    mths = {};
    infos = [];
    return;
  end
  mths = {m(:).Name};
  
  infos = [];
  cmd = sprintf('%s.getInfo', cl);
  for kk=1:numel(m)
    try
      ii = feval(cmd, m(kk).Name);
      %         disp(['    found method: ' mt.Name]);
      infos = [infos ii];
    catch
      mths{kk} = '';
      infos = [infos minfo];
      warning('### could not get info about: %s', m(kk).Name);
    end
    
  end
  
  idx = ~cellfun('isempty', mths);
  mths = mths(idx);
  infos = infos(idx);
  
  [mths,i,j] = unique(mths);
  infos = infos(i);  
  
  
end