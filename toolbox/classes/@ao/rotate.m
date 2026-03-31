% ROTATE applies rotation factor to AOs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: ROTATE applies rotation factor to AOs
%
% CALL:        m = rotate(x, y, pl)
%              m = rotate(x, y, ang)
%
% INPUTS:      x    - analysis object
%              y    - analysis object
%              pl   - parameter list
%              ang  - rotation angle as cdata AO or double
%
% Please notice that a positive rotation angle means rotating counterclockwise
% if we use the standard right-handed coordinate system, where x axis goes to 
% the right and where y axis goes up.
%
% OUTPUTS:     m   - 2x1 aos vector with rotated data [xr;yr]
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'rotate')">Parameters Description</a>
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
  
  % collect all AOs and plists
  [as, ao_invars, rest] = utils.helper.collect_objects(varargin(:), 'ao', in_names);
  [pli,  invars, rest]  = utils.helper.collect_objects(rest(:), 'plist', in_names);
  
  if nargout == 0
    error('### ao/rotate can not be used as a modifier method. Please give at least one output');
  end
  
  % combine plists
  pl = applyDefaults(getDefaultPlist(), pli);
  
  % make copies of inputs
  bs = copy(as, true);
  
  % collect input histories
  inhists = copy([as.hist], true);
  
  % check number of input AO
  switch numel(as)
    case 2
      % exctracts info about the rotation angle from the plist
      ang = mfind(pl, 'angle', 'ang');
      
      if isa(ang, 'ao')
        % extract value
        ang = ang.y;
      else
        % look in rest
        if ang == 0 && ~isempty(rest)
          ang = rest{1};
          % store angle into the plist to add it to history
          pl.pset('ang', ang);
        end
      end
              
    case 3
      % exctracts rotation angle from input AO
      ang = as(3).y;
      % remove angle parameter from the plist
      pl.remove('ang');
      
    otherwise
      error('### wrong number of input AOs. rotate works on two AOs or on three AOs where the third is the rotation angle')
  end
  
  % check that ang is a number
  if isempty(ang) || ~isnumeric(ang) || numel(ang) ~= 1
    error('### rotation angle must be scalar value');
  end
  
  % construct rotation matrix
  m = [ cos(ang)   -sin(ang)
        sin(ang)    cos(ang) ];
         
  % arrange input values into a column vector
  xy = [ transpose(as(1).y); transpose(as(2).y) ];
  
  % apply the rotation matrix
  xyr = m * xy;
  
  % set output values
  bs(1).data.setY(xyr(1,:));
  bs(2).data.setY(xyr(2,:));
  
  for jj = 1:2
    % set name
    bs(jj).setName(sprintf('rotate(%s, %s)', ao_invars{1}, ao_invars{2}));
    
    % update history
    bs(jj).addHistory(getInfo('None'), pl, ao_invars, inhists);
      
  end
  
  % assign output
  varargout{1} = bs;
  
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
  ii.setArgsmin(2);
  ii.setOutmin(2);
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
