% TRANSPOSE implements transpose operator for matrix objects.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: transpose implements transpose operator for a matrix object.
%
% CALL:        obj = obj.';
%              obj = transpose(obj);
%
% <a href="matlab:utils.helper.displayMethodInfo('matrix', 'transpose')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = transpose(varargin)
  
  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  % Collect input variable names
  in_names = cell(size(varargin));
  for ii = 1:nargin
    in_names{ii} = inputname(ii);
  end
  
  % Collect all matrices and plists
  [as, matrix_invars, rest] = utils.helper.collect_objects(varargin(:), 'matrix', in_names);
  [pl, pl_invars, rest]     = utils.helper.collect_objects(rest(:), 'plist', in_names);
  
  % Combine plists
  usepl = applyDefaults(getDefaultPlist(), pl);
  
  % decide to do a deep copy
  bs = copy(as, nargout);
  
  % run over input objects
  for jj = 1:numel(bs) 
    % dimension of the elements
    s1 = bs(jj).nrows;
    s2 = bs(jj).ncols;
    
    trp = bs(jj).objs.initObjectWithSize(s2, s1);
    for ii = 1:s1
      for kk = 1:s2
        trp(kk,ii) = bs(jj).objs(ii, kk);
      end
    end
    bs(jj).objs = trp;

    % set Name
    bs(jj).name = sprintf('transpose(%s)', as(jj).name);
    % add history
    bs(jj).addHistory(getInfo('None'), usepl, matrix_invars(jj), as(jj).hist); 
  end
  varargout{1} = bs;
  
  
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
    sets = {'Default'};
    pls  = getDefaultPlist;
  end
  % Build info object
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.aop, '', sets, pls);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    getDefaultPlist
%
% DESCRIPTION: Get Default Plist
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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
