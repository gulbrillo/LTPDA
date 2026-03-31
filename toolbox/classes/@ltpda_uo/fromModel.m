% FROMMODEL Construct an a built in model
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    fromModel
%
% DESCRIPTION: Construct an ltpda user object from a built-in model
%
% CALL:        a = fromModel(a, pl)
%
% PARAMETER:   pl: Parameter list object
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [obj, ii, fcnname, pl] = fromModel(obj, pl)
  
  % Get the name of the model the user wants
  model = find_core(pl, 'built-in');
  
  % Get a list of user model directories
  paths = utils.models.getBuiltinModelSearchPaths();
  
  for jj = 1:numel(paths)
    utils.helper.msg(utils.const.msg.PROC3, 'looking for models in %s', paths{jj});
  end
  
  % Give an error if the model name is a number
  if isnumeric(model)
    error(['### This syntax is no more supported. Please choose a model from the list you can obtain with: ' ...
    '''%s.getBuiltInModels'''], class(obj));
  end
  
  % Give an error if the model name is empty
  if isempty(model)
    error(['### No model specified. Please choose one from the list you can obtain with: ' ...
    '''%s.getBuiltInModels'''], class(obj));
  end
  
  % Find the matching model
  try
    fcnname = sprintf('%s_model_%s', class(obj), model);
    ii = obj.getInfo(class(obj), 'From Built-in Model');
    [obj, pl] = feval(fcnname, pl, ii);
  catch ME
    if strcmp(ME.identifier, 'MATLAB:UndefinedFunction') && length(ME.stack) == 3
      % If the model is missing, tell the user
      error(['### Model named ''%s'' not found. Please choose one from the list you can obtain with: ' ...
        '''%s.getBuiltInModels'''], model, class(obj));
    else
      % If the error is different, just notify the user
      rethrow(ME);
    end
  end
  
end

