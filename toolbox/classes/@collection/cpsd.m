% CPSD estimates the cross-spectral density between time-series objects in a collection object.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: CPSD estimates the cross-spectral density between time-series objects in a collection object.
%
% CALL:        out = cpsd(in, pl);
%
% Note: this is just a wrapper of ao/cpsd. Each couple of AOs in the collection is passed
% to ao/cpsd with the input plist. 
% 
% INPUTS:      in      -  input collection objects 
%              pl      -  parameter list
%
% OUTPUTS:     out     -  output collection objects 
%
% <a href="matlab:utils.helper.displayMethodInfo('collection', 'cpsd')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = cpsd(varargin)
  
  % Define the method
  methodName = mfilename;
  
  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  if nargout == 0
    error('### collection %s method can not be used as a modifier.', methodName);
  end
  
  % Collect input variable names
  in_names = cell(size(varargin));
  for ii = 1:nargin
    in_names{ii} = inputname(ii);
  end
  
  % Collect all collection objects and plists
  [cs, obj_invars, rest] = utils.helper.collect_objects(varargin(:), 'collection', in_names);
  [pl, pl_invars, rest]     = utils.helper.collect_objects(varargin(:), 'plist', in_names);
  
  out = collection();
  
  % call the cpsd method on the AOs
  % loop over objects
  N = numel(cs.objs);
  for kk = 1:N
    o_kk = cs.objs{kk};
    for jj = 1:N
      idx = N*(kk-1)+jj;
      o_jj = cs.objs{jj};
      if ismethod(o_kk, methodName) && ismethod(o_jj, methodName)
        out.objs{idx}  = feval(methodName, o_kk, o_jj, pl);
        out.names{idx} = sprintf('%s(%s,%s)', upper(methodName), cs.names{kk}, cs.names{jj});
      else
        warning('The %dth object does not have a %s method. Skipping it!', kk, methodName);
        out.objs{idx} = [];
      end
    end
  end
  
  varargout{1} = out;
  
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
    pls  = [];
  else
    ii = ao.getInfo(mfilename);
    sets = ii.sets;
    pls = [];
    for kk=1:numel(sets)
      pls = [pls getDefaultPlist(sets{kk})];
    end
  end
  % Build info object
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.sigproc, '', sets, pls);
  ii.setModifier(false);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    getDefaultPlist
%
% DESCRIPTION: Get Default Plist
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%--------------------------------------------------------------------------
% Get Default Plist
%--------------------------------------------------------------------------
function plout = getDefaultPlist(set)
  persistent pl;
  persistent lastset;
  if ~exist('pl', 'var') || isempty(pl) || ~strcmp(lastset, set)
    pl = buildplist(set);
    lastset = set;
  end
  plout = pl;
end

function pl = buildplist(set)
  
  ii = ao.getInfo(mfilename, set);
  pl = ii.plists(1);

end
  
  