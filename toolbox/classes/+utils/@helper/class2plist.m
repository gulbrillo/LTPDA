% CLASS2PLIST create a plist from the class properties.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: CLASS2PLIST create a plist from the class properties.
%
% CALL:        pl = class2plist('class_name');
%              pl = class2plist(obj);
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function pl = class2plist(varargin)

  props = properties(varargin{1});

  if isobject(varargin{1})
    obj = varargin{1};
  elseif ischar(varargin{1})
    obj = feval(varargin{1});
  else
    error('### Unknown input.');
  end

  pl = plist();

  % Loop over properties
  for jj=1:length(props)
    % get property
    p = props{jj};
    pl.append(p, obj.(p));
  end

end

