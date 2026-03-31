% PSD computes the PSD of the time-series in a ltpda_container object.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: PSD computes the PSD of the time-series in a ltpda_container object.
%
% CALL:        out = psd(in, pl);
%
% Note: this is just a wrapper of ao/psd. Each AO in the ltpda_container is passed
% to ao/psd with the input plist. 
% 
% INPUTS:      in      -  input ltpda_container objects 
%              pl      -  parameter list
%
% OUTPUTS:     out     -  output ltpda_container objects 
%
% <a href="matlab:utils.helper.displayMethodInfo('ltpda_container', 'psd')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = psd(varargin)
  
  % Define the method
  methodName = mfilename;
  
  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  if nargout == 0
    error('### ltpda_container %s method can not be used as a modifier.', methodName);
  end
    
  % Collect input variable names
  in_names = cell(size(varargin));
  try for ii = 1:nargin, in_names{ii} = inputname(ii); end; end
  
  % Collect all ltpda_container objects and plists
  [ms, obj_invars, rest] = utils.helper.collect_objects(varargin(:), 'ltpda_container', in_names);
  [pl, pl_invars, rest]     = utils.helper.collect_objects(varargin(:), 'plist', in_names);
  
  % call the ltpda_container wrapper
  varargout{1} = wrapper(ms, pl, getInfo('None'), obj_invars, methodName);  
  
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
