% MODELHELPER_PROCESSINPUTPLIST processes the input parameters plists for
% the ssm models.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION:  MODELHELPER_PROCESSINPUTPLIST processes the input parameters plists for
% the ssm models.
%
% CALL:   pl = modelHelper_processInputPlist(pl, defaultPlist)
%
% INPUTS:
%         'pl' - the user plist
%         'defaultPlist'  - the model's default plist
%
% OUTPUTS:
%
%        'pl' - plist of model parameters.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  pl = modelHelper_processInputPlist(pl, defaultPlist)
  
  setNames = pl.find('param names');
  setValues = pl.find('param values');
  
  removePlParam = {};
  for k=1:pl.nparams
    loc_key = pl.params(k).key;
    if ~defaultPlist.isparam( loc_key )
      loc_value = pl.params(k).getVal;
      if ~isa(loc_value, 'double') || numel(loc_value)~=1
        warning(['### the ssm constructor tried to set the parameter ' loc_key ' as a numerical (double) physical parameter '...
          ' because it is not in the default plist of this model. ' ...
          'However it could not be done for the class "' class(loc_value) '" and the size [' num2str(size(loc_value)) ']. '...
          'Please remove this parameter from your user plist.'])
      else
        setNames  = [setNames  {loc_key}]; %#ok<AGROW>
        setValues = [setValues loc_value]; %#ok<AGROW>
        removePlParam = [removePlParam loc_key ]; %#ok<AGROW>
      end
    end
  end
  pl.removeKeys(removePlParam);
  pl.pset('param names', setNames);
  pl.pset('param values', setValues);
end
