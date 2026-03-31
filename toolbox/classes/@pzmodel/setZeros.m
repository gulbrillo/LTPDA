% SETZEROS Set the property 'zeros' of a pole/zero model.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: SETZEROS Set the property 'zeros' of a pole/zero model.
%
% CALL:        obj = obj.setZeros(zeros);
%
% INPUTS:      obj   - is a pzmodel object
%              zeros - cell-array      --> {[f1,q1], f2, c3}
%                      comma separated --> [f1,q1], f2, c3
%                      zero-array      --> [pz(f1,q1), pz(f2), pz(c3)]
%
%                      f:     frequency
%                      [f,q]: frequency and Q
%                      c:     complex representation
%
% EXAPLES:     obj = obj.setZeros(3, [8 1]);
%              obj = obj.setZeros(3, [8 1], 7);
%              obj = obj.setZeros([pz(3), pz(8,1), pz(7)]);
%              obj = setZeros(obj, pz(2));
%
% <a href="matlab:utils.helper.displayMethodInfo('pzmodel', 'setZeros')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = setZeros(varargin)
  
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
          varargin{1}(ii).zeros = [varargin{2:end}];
        else
          varargin{1}(ii).zeros = pz(varargin(2:end));
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
  
  %%% If pls contains only one plist with the only key 'zeros' then set the
  %%% property with a plist.
  if length(pls) == 1 && isa(pls, 'plist') && nparams(pls) == 1 && isparam_core(pls, 'zeros')
    rest = find_core(pls, 'zeros');
  end
  
  %%% Combine plists
  if isempty(pls)
    pls = plist('zeros', rest);
  else
    pls = pls.combine(plist('zeros', rest));
  end
  
  % Decide on a deep copy or a modify
  bs = copy(as, nargout);
  
  % Loop over AOs
  for j=1:numel(bs)
    if isa(rest{1}, 'pz')
      bs(j).zeros = rest{1};
    else
      bs(j).zeros = pz(rest);
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
  % Zeros
  p = param({'zeros', 'A zero-array of the model.'}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
end

