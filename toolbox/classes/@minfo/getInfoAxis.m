function ii = getInfoAxis(method, getDefaultPlist, objclass, package, category, fileversion, varargin)
  
  if nargin == 7 && strcmpi(varargin{1}{1}, 'None')
    sets = {};
    pls  = [];
  elseif nargin == 7 && ~isempty(varargin{1}{1})
    sets = varargin{1};
    pls  = getDefaultPlist(sets{1});
  else
    sets = {'1D', '2D', '3D'};
    pls = [];
    for kk=1:numel(sets)
      pls  = [pls getDefaultPlist(sets{kk})];
    end
  end
  % Build info object
  ii = minfo(method, objclass, package, category, fileversion, sets, pls);
end