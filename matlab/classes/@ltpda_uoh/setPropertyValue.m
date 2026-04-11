%
% CALL:
%        varargout = setPropertyValue(inputs, ...
%                                     input_names, ...
%                                     objectClass, ...
%                                     callerIsMethod, ...
%                                     propName, ...
%                                     setterFcn, ...
%                                     copy, ...
%                                     getInfo)
%
%
function varargout = setPropertyValue(varargin)
  
  % get inputs and configuration structure
  inputs = varargin(1:end-1);
  config = varargin{end};
  config.doCopy = nargout;

  % Check if this is a call for parameters
  if length(inputs) == 3 && utils.helper.isinfocall(inputs{:})
    varargout{1} = config.getInfoFcn(inputs{3});
    return
  end
      
  % call super class method
  [objects, values, pls, obj_invars] = setPropertyValue_core(inputs{:}, config);
  
  % Add history if needed
  if ~config.callerIsMethod
    % Add history
    for jj = 1:numel(objects)
      plh = pls.pset(config.propName, values{jj});
      objects(jj).addHistory(config.getInfoFcn('None'), plh, obj_invars(jj), objects(jj).hist);
    end
  end
  
  % Set output
  varargout = utils.helper.setoutputs(nargout, objects);
end
