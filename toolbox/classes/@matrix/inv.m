% INV evaluates the inverse for matrix object.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: INV evaluates the inverse for matrix objects.
%
% CALL:        obj = inv(mat)
%              obj = mat.inv()
%
% <a href="matlab:utils.helper.displayMethodInfo('matrix', 'inv')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = inv(varargin)
  
  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  % Check if the method was called by another method
  callerIsMethod = utils.helper.callerIsMethod;
  
  % Collect input variable names
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
  
  % Collect all matrices and plists
  [as, matrix_invars, rest] = utils.helper.collect_objects(varargin(:), 'matrix', in_names);
  [pl, pl_invars, rest]     = utils.helper.collect_objects(varargin(:), 'plist', in_names);
  
  % Decide on a deep copy or a modify
  bs = copy(as, nargout);
  
  % Combine input plists and default plist
  usepl = applyDefaults(getDefaultPlist(), pl);
  
  % do dimension check
  [rw,cl] = size(bs.objs);
  if rw ~= cl
    error('### Matrix must be square');
  end
  
  % cope with the 1x1 matrix case
  if rw==1 && cl==1
    
    C = bs.getObjectAtIndex(1);
    CT = 1./C;
    bs.objs(1) = CT;
    
  else
  
    % get the determinant
    DA = det(bs);

    % build cofactor matrix
    C = copy(bs,1);
    for ii = 1:rw % raw index
      for jj = 1:cl % column index
        % ij Minor of A
        MA = copy(bs,1);
        MA.objs(ii,:) = [];
        MA.objs(:,jj) = [];
        % cofactor
        C.objs(ii,jj) = det(MA).*((-1)^(ii+jj));
      end
    end
    % get the transpose of cofactors matrix
    CT = transpose(C);
    % do inverse
    bs = CT./matrix(DA);
  
  end
  
  if ~callerIsMethod
    % set name
    bs.setName(sprintf('inv(%s)', in_names{1}));
    
    % Add history
    bs.addHistory(getInfo('None'), usepl, [matrix_invars(:)], [as(:).hist]);
  end
  
  varargout{1} = bs;
  
end

%--------------------------------------------------------------------------
% Get Info Object
%--------------------------------------------------------------------------
function ii = getInfo(varargin)
  
  if nargin == 1 && strcmpi(varargin{1}, 'None')
    sets = {};
    pl  = [];
  else
    sets = {'Default'};
    pl  = getDefaultPlist;
  end
  % Build info object
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.op, '', sets, pl);
end

%--------------------------------------------------------------------------
% Get Default Plist
%--------------------------------------------------------------------------

function plout = getDefaultPlist()
  persistent pl;
  if ~exist('pl', 'var') || isempty(pl)
    pl = buildplist();
  end
  plout = pl;
end

function pl = buildplist()
  pl = plist.EMPTY_PLIST;
end

