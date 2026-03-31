% MODELHELPER_CHECKPARAMETERS compare the user requested parameter names to
% the model parameter names.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION:  MODELHELPER_CHECKPARAMETERS compare the user requested parameter names to
% the model parameter names.
%
% CALL:   pl = modelHelper_checkParameters(pl, defaultPlist)
%
% INPUTS:
%         'pl' - the user plist
%         'paramNames'  - the model's parameter plist
%
% OUTPUTS:
%
%        'pl' - plist of model parameters.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  pl = modelHelper_checkParameters(pl, modelname, paramNames)
  
  setNames = pl.find('param names');
  
  for kk=1:numel(setNames)
    
    pname = setNames{kk};
    
    if ~ismember(pname, paramNames)
      warning('Model %s does not contain a parameter <%s>', modelname, pname);
    end
    
  end

end
