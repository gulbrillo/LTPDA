% SETNAME Sets the property 'name' of an ltpda_uoh object.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: Sets the property 'name' of an ltpda_uoh object.
%
% CALL:        objs.setName(val);
%              objs.setName(val1, val2);
%              objs.setName(plist('name', val));
%              objs = setName();
%
% EXAMPLE:     objs.setName() -> Sets the name to the variable name.
%                                In this case to 'objs'
%
% INPUTS:      objs: Can be a vector, matrix, list, or a mix of them.
%              val:
%                 1. Single string e.g. 'val'
%                      Each object in objs get this value.
%                 2. Single string in a cell-array e.g. {'val'}
%                      Each object in objs get this value.
%                 3. cell-array with the same number of strings as in objs
%                    e.g. {'val1', 'val2', 'val3'} and 3 objects in objs
%                      Each object in objs get its corresponding value from the
%                      cell-array
%
% <a href="matlab:utils.helper.displayMethodInfo('ltpda_uo', 'setName')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = setName(varargin)
  
  % Check if this is a call from a class method
  callerIsMethod = utils.helper.callerIsMethod;
  
  if callerIsMethod
    in_names = {''};
  else
    % Collect input variable names
    in_names = cell(size(varargin));
    try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
  end
  
  config.propName       = 'name';
  config.propDefVal     = '';
  config.inVarNames     = in_names;
  config.callerIsMethod = callerIsMethod;
  config.setterFcn      = @setterFcn;
  config.getInfoFcn     = @getInfo;
  
  % Call generic setter method
  [varargout{1:nargout}] = setPropertyValue(varargin{:}, config);
  
  % Setter function to set the name
  function value = setterFcn(obj, plHist, value)
    
    if isempty(value) && ~ischar(value)
      value = in_names{1};
      % Here we need to create the plist that will end up in the history
      % because we want this actually variable name to be in the history
      % otherwise the rebuild would end up setting the generated variable
      % name as the object name.
      plHist.pset('name', value);
    end
    
    MAX_LENGTH = 200;
    
    % support any value which can be turned into a char
    value = char(value);
    
    if ~ischar(value)
      error('The ''name'' property requires a string value');
    end
    
    if length(value) > MAX_LENGTH
      chop = floor(MAX_LENGTH/2);
      value = [value(1:chop) ' ... ' value(end-chop:end)];
    end
    
    obj.name = value;
    
  end
  
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               Local Functions                               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.helper, '', sets, pl);
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
  if ~exist('pl', 'var') || isempty(pl)
    pl = buildplist();
  end
  plout = pl;
end

function pl = buildplist()
  pl = plist({'name', 'New name for the object.'}, '');
end

