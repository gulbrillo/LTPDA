% LTPDA_USERCLASSES lists all the LTPDA user object types.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: LTPDA_USERCLASSES lists all the LTPDA user object types.
%
% CALL:        classes = ltpda_userclasses()
%
% INPUTS:
%
% OUTPUTS:     classes - a cell array with a list of recognised LTPDA user object types
%
% Returns a list of all ltpda classes which are derived from the ltpda_uo
% class.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function classes_out = ltpda_userclasses(varargin)

  %   prefs = getappdata(0, 'LTPDApreferences');
  %   vl = double(prefs.getDisplayPrefs.getDisplayVerboseLevel);
  %   LTPDAprefs('display', 'verboseLevel', -1);
  
  persistent classes
  persistent meta_ltpda_uo
  
  if isempty(classes)
    classes = utils.helper.ltpda_classes;
    meta_ltpda_uo = meta.class.fromName('ltpda_uo');
    
    for ii = 1:numel(classes)
      try
        m = meta.class.fromName(classes{ii});
        if ~(meta_ltpda_uo >= m) || m.Abstract
          classes{ii} = {};
        end
      catch
        classes{ii} = {};
      end
    end
    
    classes = classes(~cellfun('isempty', classes));
    classes = sort(classes);
  end
  
  classes_out = classes;
end

function result = isabstract(cl)

  mi = eval(['?' cl]);

  hasAbstractMethod = false;
  for kk=1:numel(mi.Methods)
    if mi.Methods{kk}.Abstract
      hasAbstractMethod = true;
      break;
    end
  end

  hasAbstractProperty = false;
  if ~hasAbstractMethod
    for kk=1:numel(mi.Properties)
      if mi.Properties{kk}.Abstract
        hasAbstractProperty = true;
        break;
      end
    end
  end

  if hasAbstractProperty || hasAbstractMethod
    result = true;
  else
    result = false;
  end

end

