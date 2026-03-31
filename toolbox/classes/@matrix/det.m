% DET evaluates the determinant for matrix object.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: DET evaluates the determinant for matrix objects.
%              The objects must belong to the same class (e.g. ao, smodel, ...)
%              The result is an object of the class itself
%
% CALL:        obj = det(mat)
%              obj = mat.det()
%
% <a href="matlab:utils.helper.displayMethodInfo('matrix', 'det')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function out = det(varargin)
  
  callerIsMethod = utils.helper.callerIsMethod;
  
  if callerIsMethod
    as = [varargin{:}];
  else    
    % Check if this is a call for parameters
    if utils.helper.isinfocall(varargin{:})
      out = getInfo(varargin{3});
      return
    end
    
    % Collect input variable names
    in_names = cell(size(varargin));
    try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
    
    % Collect all matrices and plists
    [as, matrix_invars, rest] = utils.helper.collect_objects(varargin(:), 'matrix', in_names);
    [pl, pl_invars, rest]     = utils.helper.collect_objects(varargin(:), 'plist', in_names);
    
    % Combine input plists and default plist
    usepl = applyDefaults(getDefaultPlist(), pl);
  end
  
  % extract objects
  objmat = as.objs;
  
  % we check now the dimensionality to be sure to have a square matrix
  [rw, cl] = size(objmat);
  if rw ~= cl
    error('### Matrix must be square');
  end

  % Let's go with textbook definition
  switch cl
    case 0
      % To be compliant with definition. 
      % Here we choose to output an ao, so we can have history; 
      % if used with other objetcs (ao, smodel, ...) it will be promoted anyways
      out = ao(1);
    case 1
      out = objmat;
    case 2
      out = objmat(1,1) .* objmat(2,2) - objmat(2,1) .* objmat(1,2);
    otherwise
      dmod_minor = eval(sprintf('%s.initObjectWithSize(1,cl);', class(objmat)));
      
      % Cache these objects not to produce them iteratively
      coeff_minus = ao(-1);
      coeff_plus = ao(1);
      for jj = 1:cl
        Amod = objmat;
        Amod(1,:) = [];
        Amod(:,jj) = [];
        Am = matrix(Amod);
        if (-1).^(jj+1) > 0
          coeff = coeff_plus;
        else
          coeff = coeff_minus;
        end
        dmod_minor(jj) = objmat(1,jj) .* det(Am) * coeff;
      end
      % sum over elements
      out = dmod_minor(1);
      for kk = 2:numel(dmod_minor)
        out = out + dmod_minor(kk);
      end
  end

  if ~callerIsMethod
    % Set name
    out.setName(sprintf('det(%s)', in_names{1}));
    
    % Add history
    out.addHistory(getInfo('None'), usepl, {inputname(1)}, [as(:).hist]);
  end
  
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

