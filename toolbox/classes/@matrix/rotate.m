% ROTATE applies rotation factor to matrix objects
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: ROTATE applies rotation factor to matrix objects
%
% CALL:        B = rotate(A, pl)
%              B1 = rotate(A1, pl)
%              Bs = rotate(As, ang)
%
% INPUTS:      Ai    - matrix object(s) with AOs, size: [2 1] or [1 2]
%              pl   - parameter list
%              ang  - rotation angle as cdata AO or double
%
% Please notice that a positive rotation angle means rotating counterclockwise
% if we use the standard right-handed coordinate system, where x axis goes to 
% the right and where y axis goes up.
%
% OUTPUTS:     Bi  - matrix object(s) with AOs, size: [2 1] or [1 2] with rotated data
%
% <a href="matlab:utils.helper.displayMethodInfo('matrix', 'rotate')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = rotate(varargin)
   
  % check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  import utils.const.*
  utils.helper.msg(msg.PROC3, 'running %s/%s', mfilename('class'), mfilename);
  
  % collect input variable names
  in_names = cell(size(varargin));
  for ii = 1:nargin,in_names{ii} = inputname(ii); end
  
  % collect all MATRIX, AOs and plists
  [ms, matrix_invars, rest] = utils.helper.collect_objects(varargin(:), 'matrix', in_names);
  [pli,  invars, rest]  = utils.helper.collect_objects(rest(:), 'plist', in_names);
  
  % make copies or handles to inputs
  bs = copy(ms, nargout);
  
  % combine plists
  pl = applyDefaults(getDefaultPlist, pli);
  
  % collect input histories
  inhists = copy([ms.hist], true);
  
  % exctracts info about the rotation angle from the plist
  ang = mfind(pl, 'ang', 'angle');
  
  switch class(ang)
    case 'double'
      % look in rest
      if ang == 0 && ~isempty(rest)
        ang = rest{1};
        % store angle into the plist to add it to history
        pl.pset('ang', ang);
      end
    case 'ao'
    otherwise
      error('### wrong container %s for the rotation angle. It can be a double or an ao', class(ang))
  end
  
  if isa(ang, 'ao')
    % extract value
    ang = ang.y;
  end
  
  % check that ang is a number
  if isempty(ang) || ~isnumeric(ang) || numel(ang) ~= 1
    error('### rotation angle must be scalar value');
  end

  % Loop over input MATRIX objects
  for jj = 1 : numel(bs)
    % deal with columns
    if ~isequal(size(bs(jj).objs), [1 2]) && ~isequal(size(bs(jj).objs), [2 1])
      error('### rotate accepts only 2x1 or 1x2 matrices')
    end
    
    % construct rotation matrix
    m = [ cos(ang)   -sin(ang)
          sin(ang)    cos(ang) ];
    
    % arrange input values into a column vector
    xy = [ transpose(bs(jj).objs(1).y); transpose(bs(jj).objs(2).y) ];
    
    % apply the rotation matrix
    xyr = m * xy;
    
    % set output values
    bs(jj).objs(1).data.setY(xyr(1,:));
    bs(jj).objs(2).data.setY(xyr(2,:));
    
    % set name
    bs(jj).setName(sprintf('rotate(%s)', matrix_invars{jj}));
    
    % update history
    bs(jj).addHistory(getInfo('None'), pl, matrix_invars, inhists);
    
  end
  
  % Set output
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

%--------------------------------------------------------------------------
% Get Info Object
%--------------------------------------------------------------------------
function ii = getInfo(varargin)
  if nargin == 1 && strcmpi(varargin{1}, 'None')
    sets = {};
    pls   = [];
  else
    sets = {'Default'};
    pls   = getDefaultPlist;
  end
  % build info object
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.op, '', sets, pls);
  ii.setArgsmin(1);
  ii.setOutmin(1);
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
  p = param({'ang', 'The angle to rotate by. It can be a double or an AO.'}, paramValue.DOUBLE_VALUE(0));
  pl.append(p);
  
end
