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
  
  % Add data
  if ~isempty(obj.data)
    
    if isa(obj.data, 'cdata')
      
      % Add y
      pl.append('vals', obj.data.y);
      % Add dy
      appendProperty(pl, obj.data, 'dy');
      % Add yunits
      appendProperty(pl, obj.data, 'yunits');
      
    else
      
      % Add general properties of the xydata, tsdata and fsdata class
      
      % Add y
      pl.append('yvals', obj.data.y);
      % Add dy
      appendProperty(pl, obj.data, 'dy');
      % Add yunits
      appendProperty(pl, obj.data, 'yunits');
      % Add x
      pl.append('xvals', obj.data.x);
      % Add dx
      appendProperty(pl, obj.data, 'dx');
      % Add xunits
      appendProperty(pl, obj.data, 'xunits');
      
      if isa(obj.data, 'xydata')
        % Add data type
        pl.append('type', 'xydata');
        
      elseif isa(obj.data, 'tsdata')
        
        % Add fs
        appendProperty(pl, obj.data, 'fs');
        % Add t0
        appendProperty(pl, obj.data, 't0');
        % Add data type
        pl.append('type', 'tsdata');
        
      elseif isa(obj.data, 'fsdata')
        
        % Add fs
        appendProperty(pl, obj.data, 'fs');
        % Add t0
        appendProperty(pl, obj.data, 't0');
        % Add enbw
        appendProperty(pl, obj.data, 'enbw');
        % Add navs
        appendProperty(pl, obj.data, 'navs');
        % Add data type
        pl.append('type', 'fsdata');
        
      else
        error('### This method doesn''t support a data object of the class %s', class(obj.data));
      end
    end
    
  end
  
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

