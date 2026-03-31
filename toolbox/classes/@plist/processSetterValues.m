% PROCESSSETTERVALUES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: PROCESSSETTERVALUES
%
% CALL:        [objs, vals] = processSetterValues(objs, rest, pName)
%
% IMPUTS:      objs:  Array of objects
%              rest:  Cell-array with possible values
%              pName: Property name of objs
%
% OUTPUTS:     objs: It is necessary to pass objs back because it is
%                    possible that one of the input PLISTs was a
%                    configuration PLIST.
%              vals: A cell-array with the value we want to set.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [objs, values] = processSetterValues(objs, pls, rest, pName, defValue)
  
  for kk = 1:numel(objs)
    % If the input objects here PLISTs have a PLIST with a single key with
    % the property name then is this a configuration PLIST.
    if nparams(objs(kk)) == 1 && isparam_core(objs(kk), pName)
      pls = objs(kk);
      % Remove configuration PLIST from the input PLISTs
      objs(kk) = [];
      break;
    end
  end
  
  % Call super class
  [objs, values] = processSetterValues@ltpda_uo(objs, pls, rest, pName, defValue);
  
end
