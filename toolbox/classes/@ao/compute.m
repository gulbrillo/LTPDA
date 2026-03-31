% COMPUTE performs the given operations on the input AOs.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: COMPUTE performs the given operations on the input AOs.
%
% This is a transparent wrapper for the user selected operations and as such
% doesn't add history.
%
% CALL:        b = compute(a)
%              b = compute(a, pl)
%              b = compute(a, 'a(1) + a(2)./a(3)')
%              b = compute(a, {'a(1) + a(2)./a(3)', 'log10(a(1))'})
%
% PARAMETERS:  'Operations' - a string array describing the operations to
%                             be performed. The input AOs are collected
%                             together into a vector called 'a' and as
%                             such should be so represented in your
%                             operation description.
%
% If no operation is input, then the output is just a copy of the inputs.
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'compute')">Parameters Description</a>
% 
% EXAMPLES: 1) Add the two AOs, x and y, together
%              >> b = compute(x,y, plist('Operations', 'a(1) + a(2)'))
%           or
%              >> b = compute(x,y, 'a(1) + a(2)')
%
%           2) Perform two operations such that the output, b, contains two AOs
%              >> b = compute([x y], z, plist('Operations', {'2.*a(3)./a(1)', 'a(2)-a(1)'}))
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = compute(varargin)

  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end

  import utils.const.*
  utils.helper.msg(msg.PROC3, 'running %s/%s', mfilename('class'), mfilename);
  
  % Collect input variable names
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end

  % Collect all AOs and plists
  [as, ao_invars] = utils.helper.collect_objects(varargin(:), 'ao', in_names);
  [pl, pl_invars] = utils.helper.collect_objects(varargin(:), 'plist', in_names);

  if nargout == 0
    error('### compute cannot be used as a modifier. Please give an output variable.');
  end
  
  % Decide on a deep copy or a modify
  a = copy(as, nargout);

  % combine plists
  pl = applyDefaults(getDefaultPlist(), pl);

  % Look for plist of input char
  ops = '';
  if ischar(varargin{end})
    ops = varargin{end};
  elseif iscell(varargin{end})
    ops = varargin{end};
  else
    ops = find_core(pl, 'Operations');
  end

  % Check we have a cell array
  if ischar(ops)
    ops = {ops};
  end

  % Loop over operations
  bs(length(ops),1) = ao;
  for jj=1:length(ops)
    % evaluate this operation
    if ops{jj}(end) ~= ';'
      ops{jj}(end+1) = ';';
    end
    bs(jj) = eval(ops{jj});
  end

  % Set outputs
  varargout{1} = bs;
end

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
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.sigproc, '', sets, pl);
  ii.setModifier(false);
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
  pl = plist({'Operations', 'A string describing the operations on the vector ''a'' of AOs'}, {1, {'a'}, paramValue.OPTIONAL});
end
% END


