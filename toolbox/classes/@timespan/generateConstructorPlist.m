% GENERATECONSTRUCTORPLIST generates a PLIST from the properties which can rebuild the object.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: GENERATECONSTRUCTORPLIST generates a PLIST from the
%              properties which can rebuild the object.
%
% CALL:        pl = obj.generateConstructorPlist();
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'generateConstructorPlist')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function pl = generateConstructorPlist(varargin)
  
  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    pl = getInfo(varargin{3});
    return
  end
  
  obj = varargin{1};
  pl = plist();
  
  % Add procinfo
  appendProperty(pl, obj, 'procinfo');
  
  % Add plotinfo
  appendProperty(pl, obj, 'plotinfo');
  
  % Add name
  appendProperty(pl, obj, 'name', false);
  
  % Add description
  appendProperty(pl, obj, 'description');
  
  % Add start time
  appendProperty(pl, obj, 'startT');

  % Add end time
  appendProperty(pl, obj, 'endT');
  
  % Add timeformat
  appendProperty(pl, obj, 'timeformat');
  
  % Add timezone
  appendProperty(pl, obj, 'timezone');
  
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               Local Functions                               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    appendProperty
%
% CALL:        appendProperty(pl, obj, propName)
%              appendProperty(pl, obj, propName, isemptyCheck)
%
% DESCRIPTION: Get Info Object
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function appendProperty(pl, obj, propName, isemptyCheck)
  
  if nargin <= 3
    isemptyCheck = true;
  end
  
  if isemptyCheck
    if ~isempty(obj.(propName))
      pl.append(propName, obj.(propName));
    else
      % Don't append the property to the PLIST
    end
  else
    pl.append(propName, obj.(propName));
  end
  
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    getInfo
%
% DESCRIPTION: Get Info Object
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function ii = getInfo(varargin)
  if nargin == 1 && strcmpi(varargin{1}, 'None')
    sets = {};
    pl   = [];
  else
    sets = {'Default'};
    pl   = getDefaultPlist;
  end
  % Build info object
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.internal, '', sets, pl);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    getDefaultPlist
%
% DESCRIPTION: Get Default Plist
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function plout = getDefaultPlist()
  persistent pl;  
  if exist('pl', 'var')==0 || isempty(pl)
    pl = buildplist();
  end
  plout = pl;  
end

function pl = buildplist()
  pl = plist.EMPTY_PLIST;
end

