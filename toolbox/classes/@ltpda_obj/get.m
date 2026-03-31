% GET get a property of a object.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: GET get a property of a object.
%
% CALL:        val = get(obj, 'prop_name');
%
% <a href="matlab:utils.helper.displayMethodInfo('ltpda_obj', 'get')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = get(varargin)

  %%% Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end

  obj       = varargin{1};
  prop_name = varargin{2};
  
  %%% Some input checks
  if nargin ~= 2
    error('### This method accepts only two inputs');
  end
  if numel(obj) ~= 1
    error('### This method works only for one input object.')
  end
  if ~(ischar(prop_name) || isa(prop_name, 'plist'))
    error('### Please define the property name as a string of in a plist.')
  end
  
  %%% If prop_name is a plist then extrat the poperty name from the plist.
  if isa(prop_name, 'plist')
    prop_name = find_core(prop_name, 'property');
    if isempty(prop_name)
      error ('### The plist does not contain the ''key'' = ''property''');
    end
  end

  %%% Return the property of the analysis object
  if any(strcmp(prop_name, properties(obj)))
    varargout{1} = obj.(prop_name);
  else
    error('### ''%s'' is not a valid %s-object property.', prop_name, class(obj));
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
% HISTORY:     05-01-2009 Ingo Diepholz
%                Creation.
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
  ii.setModifier(false);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    getDefaultPlist
%
% DESCRIPTION: Get Default Plist
%
% HISTORY:     11-07-07 M Hewitson
%                Creation.
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
  pl = plist({'property', 'Property name you want to get.'}, '');
end

