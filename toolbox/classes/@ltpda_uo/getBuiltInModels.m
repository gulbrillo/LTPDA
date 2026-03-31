% GETBUILTINMODELS returns a list of the built-in AO models found on the
% system.
% 
% CALL:   ca = ao.getBuiltInModels
% 
% OUTPUTS:
%          ca - a cell-array of models. The first column is the model name;
%               the second column is a description.
% 

function varargout = getBuiltInModels(objName)
  
  paths = utils.models.getBuiltinModelSearchPaths();
  
  for jj = 1:numel(paths)
    utils.helper.msg(utils.const.msg.PROC3, 'looking for models in %s', paths{jj});
  end
  
  % list files in here
  models = {};
  prefix = sprintf('%s_model_', objName);
  NN = 7+length(objName);
  for pp = 1:numel(paths)
    files = utils.prog.filescan(paths{pp}, '.m');
    for ff = 1:numel(files)
      parts = regexp(files{ff}, '(\.)*(\/)*', 'split');
      if strncmp(parts{end-1}, prefix, NN)
        models = [models parts(end-1)];
      end
    end
  end
  
  % Give a list and an error if bsys is empty
  txt = {};
  for k = 1:numel(models)
    try
      txt = [txt; {models{k}(8+length(objName):end), feval(models{k}, 'describe')}];
    catch
      warning('LTPDA:MODEL:DESCRIPTION', '!!! The model "%s" fails for the description.', models{k});
    end
  end
  
  if nargout == 0
    % diplay the text nicely
    maxLen = 0;
    maxDescLen = 0;
    for kk=1:size(txt,1)
      if length(txt{kk,1}) > maxLen
        maxLen = length(txt{kk,1});
      end
      if length(txt{kk,2}) > maxDescLen
        maxDescLen = length(txt{kk,2});
      end
    end
    
    maxLen = maxLen+5;
    lineStr = repmat('-', maxLen+maxDescLen+7,1);
    fprintf('\n%s\n', lineStr);
    fprintf('  Built-in models for class %s\n', objName);
    fprintf('%s\n', lineStr);
    for kk=1:size(txt,1)
      name = txt{kk,1};
      fprintf('%02d) <a href="matlab:help(''%s_model_%s'')">%s</a>%s |  %s\n', kk, objName, name, name, utils.prog.strpad('', maxLen-length(name)), txt{kk,2});
    end
    fprintf('%s\n\n', lineStr);
    
  else
    varargout{1} = txt;
  end
  
end
