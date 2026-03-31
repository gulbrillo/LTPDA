% modelHelper_declareParameters builds parameters plists for the ssm params field.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: modelHelper_declareParameters 
%                 - builds parameters plists for the ssm params field.
%                 - declares them in the caller workspace
%
% CALL:   params = modelHelper_declareParameters(pl, paramNames, paramValues, paramDescriptions, paramUnits)
%
% INPUTS:
%         'paramNames' - cellstr containing the parameters names
%         'paramValues'  - double array of same size
%         'paramDescriptions'  - cellstr of same size
%         'paramUnits'  - unit array of same size
%         'pl'  - input plist to the model
%
% OUTPUTS:
%
%        'params' - params plist of the symbolic ssm parameters.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [params, numParams] = modelHelper_declareParameters(pl, paramNames, paramValues, paramDescriptions, paramUnits)
  %% using input plist to process parameters
  
  setNames = find(pl, 'param names');
  setValues = find(pl, 'param values');
  withParams = find(pl, 'symbolic params', {});
  
  if ~isempty(find(pl, 'withparams'))
    error('The WITHPARAMS key has been changed to SYMBOLIC PARAMS. Please check your plist');
  end
  if ~isempty(find(pl, 'setnames'))
    error('The SETNAMES key has been changed to PARAM NAMES. Please check your plist');
  end
  if ~isempty(find(pl, 'setvalues'))
    error('The SETVALUES key has been changed to PARAM VALUES. Please check your plist');
  end
  
  if ~(numel(setValues)==numel(setNames))
    error('The number of values is not the same as the number of parameters to set')
  end
  
  %% interface simplification for the user
  if ischar(setNames)
    if ~( strcmpi(setNames, 'all') || strcmpi(setNames, '') || strcmpi(setNames, 'none') ) % if this is not a special user call
      setNames = {setNames};
    elseif strcmpi(setNames, '') || strcmpi(setNames, 'none') % if the user does not want any parameter
       setNames = cell(1,0);
    end
  end
  if ischar(withParams)
    if ~( strcmpi(withParams, 'all') || strcmpi(withParams, '') || strcmpi(withParams, 'none') ) % if this is not a special user call
      withParams = {withParams};
    elseif strcmpi(withParams, '') || strcmpi(withParams, 'none') % if the user does not want any parameter
       withParams = cell(1,0);
    end
  end
  
  %% setting parameters if desired
  for i= 1:numel(setNames)
    setParamPosition = strcmpi(setNames{i}, paramNames);
    paramValues(setParamPosition) = setValues(i);
  end
  
  %% finding symbolic parameters
  if strcmpi(withParams, 'ALL')
    paramPos = true(size(paramNames));
  else
    paramPos = logical(ismember(paramNames, withParams));
  end
  % declaring the parameters used
  for i_params=1:numel(paramNames)
    if paramPos(i_params)
      assignin('caller', paramNames{i_params}, sym(paramNames{i_params}) );
    else
      assignin('caller',paramNames{i_params},paramValues(i_params));
    end
  end
  
  %% deleting fields relevant to unused numerical parameters and building plist
  numParamNames = paramNames(~paramPos);
  numParamValues = paramValues(~paramPos);
  paramNames = paramNames(paramPos);
  paramValues = paramValues(paramPos);
  if ~ isempty(paramDescriptions)
    numParamDescriptions = paramDescriptions(~paramPos);
    paramDescriptions = paramDescriptions(paramPos);
  else
    numParamDescriptions = [];
  end
  if ~ isempty(paramUnits)
    numParamUnits = paramUnits(~paramPos);
    paramUnits = paramUnits(paramPos);
  else
    numParamUnits = [];
  end
    
  params = ssm.buildParamPlist(paramNames, paramValues, paramDescriptions, paramUnits, plist);
  numParams = ssm.buildParamPlist(numParamNames, numParamValues, numParamDescriptions, numParamUnits, plist);
  
  params.setName('params');
  numParams.setName('numparams');
end
