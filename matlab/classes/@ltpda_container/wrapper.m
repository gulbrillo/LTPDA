% WRAPPER applies the given method to each object in the object.
%
% CALL
%          out = wrapper(objs, pl, info, inputnames, methodName)
%

function varargout = wrapper(objs, pl, info, inputnames, methodName, varargin)
  
  % Prepare a plist to be stored in the history
  hist_pl    = applyDefaults(ltpda_container.getInfo(methodName).plists, pl);
  
  % Deep copy.
  % This is necessary because wrapperEval copies only the inner objects
  out = copy(objs, 1);
  
  % loop over number of objects
  for ii = 1:numel(out)
    if ~isempty(pl)
      out(ii) = wrapperEval(out(ii), methodName, pl, varargin{:});
    else
      out(ii) = wrapperEval(out(ii), methodName, varargin{:});
    end
    out(ii).addHistory(info, hist_pl, cellstr(inputnames(ii)), [out(ii).hist]);
  end
  
  varargout{1} = out;
  
end

