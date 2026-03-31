% SETPOLES Set the property 'poles' of a pole/zero model.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: SETPOLES Set the property 'poles' of a pole/zero model.
%
% CALL:        obj = obj.setPoles(poles);
%
% INPUTS:      obj   - is a pzmodel object
%              poles - cell-array      --> {[f1,q1], f2, c3}
%                      comma separated --> [f1,q1], f2, c3
%                      pole-array      --> [pz(f1,q1), pz(f2), pz(c3)]
%
%                      f:     frequency
%                      [f,q]: frequency and Q
%                      c:     complex representation
%
% EXAPLES:     obj = obj.setPoles(3, [8 1]);
%              obj = obj.setPoles(3, [8 1], 7);
%              obj = obj.setPoles([pz(3), pz(8,1), pz(7)]);
%              obj = setPoles(obj, pz(2));
%
% <a href="matlab:utils.helper.displayMethodInfo('pzmodel', 'setPoles')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = setPoles(varargin)
  
  %%% Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  %%% Internal call: Only one object + don't look for a plist
  if utils.helper.callerIsMethod
    
    %%% decide whether we modify the first object, or create a new one.
    varargin{1} = copy(varargin{1}, nargout);
    
    for ii = 1:numel(varargin{1})
      if ~isempty(varargin{2})
        if isa(varargin{2}, 'pz')
          varargin{1}(ii).poles = [varargin{2:end}];
        else
          varargin{1}(ii).poles = pz(varargin(2:end));
        end
      end
    end
    varargout{1} = varargin{1};
    return
  end
  
  import utils.const.*
  utils.helper.msg(msg.PROC3, 'running %s/%s', mfilename('class'), mfilename);
  
  % Collect input variable names
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
  
  % Collect all AOs
  [as, ao_invars,rest] = utils.helper.collect_objects(varargin(:), 'ltpda_tf', in_names);
  [pls,  invars, rest] = utils.helper.collect_objects(rest(:), 'plist');
  
  %%% If pls contains only one plist with the only key 'poles' then set the
  %%% property with a plist.
  if length(pls) == 1 && isa(pls, 'plist') && nparams(pls) == 1 && isparam_core(pls, 'poles')
    rest = find_core(pls, 'poles');
  end
  
  %%% Combine plists
  if isempty(pls)
    pls = plist('poles', rest);
  else
    pls = pls.combine(plist('poles', rest));
  end
  
  % Decide on a deep copy or a modify
  bs = copy(as, nargout);
  
  % Loop over AOs
  for j=1:numel(bs)
    if isa(rest{1}, 'pz')
      bs(j).poles = rest{1};
    else
      bs(j).poles = pz(rest);
    end
    bs(j).addHistory(getInfo('None'), pls, ao_invars(j), bs(j).hist);
  end
  
  %%% Set output
  if nargout == numel(bs)
    % List of outputs
    for ii = 1:numel(bs)
      varargout{ii} = bs(ii);
    end
  else
    % Single output
    varargout{1} = bs;
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               Local Functions                               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------
% Get Info Object
%--------------------------------------------------------------------------
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

%--------------------------------------------------------------------------
% Get Default Plist
%--------------------------------------------------------------------------
function plout = getDefaultPlist()
  persistent pl;  
  if exist('pl', 'var')==0 || isempty(pl)
    pl = buildplist();
  end
  plout = pl;  
end

function pl = buildplist()
  pl = plist();
  % Poles
  p = param({'poles', 'A pole-array of the model.'}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
end

