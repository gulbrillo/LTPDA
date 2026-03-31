% MAINFNC is the main function call for all built-in models.
% 
% CALL:
%     varargout = mainFnc(inputs, modelFilename, getModelDescription, getModelDocumentation, getVersion, versionTable)
% 
% A typical call from the built-in model main function will look like:
% 
%   varargout = utils.models.mainFnc(varargin(:), ...
%     mfilename, ...
%     @getModelDescription, ...
%     @getModelDocumentation, ...
%     @getVersion, ...
%     @versionTable);
% 
% INPUTS:
%                 inputs - cell-array of inputs to the built-in model
%          modelFilename - the full filename of the model (typically you use mfilename)
%    getModelDescription - a function handle to the getModelDescription function
%  getModelDocumentation - a function handle to the getModelDocumentation function
%             getVersion - a function handle to the getVersion function
%           versionTable - a function handle to the versionTable function
% 

function varargout = mainFnc(inputs, modelFilename, getModelDescription, getModelDocumentation, getVersion, versionTable, varargin)
  
  % Process inputs
  [info, pl, constructorInfo, fcn] = utils.models.processModelInputs(inputs, ...
    modelFilename, ...
    getModelDescription, ...
    getModelDocumentation, ...
    getVersion, ...
    versionTable, ...
    varargin{:});
  
  if ~isempty(info)
    varargout{1} = {info};
    return;
  end
  
  % Apply defaults to the plist we pass to the function. This leaves the
  % original plist alone for going in the history. We need exceptions for
  % the constructor plist keys and VERSION, since they are not defined in
  % the model version plist.
  exceptions = [constructorInfo.plists.getKeys() {'VERSION'}];
  
  % Additional exceptions come from any model which supports 'parameters',
  % like SSM models because these don't appear in the default plist. We
  % need a try-catch here because models which don't support 'parameters'
  % will just die if you call them like this - not so nice.
  try
    parameters = fcn('parameters');
    exceptions = [exceptions parameters.names];
  end
  
  if ~strcmp(constructorInfo.mclass, 'ssm')
    fpl = applyDefaults(fcn('plist'), pl, exceptions);
  else
    fpl = combine(pl, fcn('plist'));
  end
  
  % also, if this model supports a random stream setting, then we need to
  % make sure the history plist caches the state
  if fpl.isparam('RAND_STREAM')
    fpl.getSetRandState;
  end
  
  % Build the object
  out = fcn(fpl);
  
  % Set the method version string in the minfo object
  if ~isempty(constructorInfo) && utils.helper.isSubclassOf(class(out), 'ltpda_uoh')
    % If this is a user-call via a constructor, then we add history
    out = addHistoryStep(out, constructorInfo, fpl);
  end
  
  if nargout > 0
    varargout{1} = {out, fpl};
  else
    error('!!! Invalid number of output')
  end
  
end
