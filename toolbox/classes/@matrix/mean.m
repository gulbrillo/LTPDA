% MEAN evaluates the meanerse for matrix object.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: MEAN evaluates the mean for matrix objects.
%
% CALL:        obj = mean(mat)
%              obj = mat.mean()
%
% <a href="matlab:utils.helper.displayMethodInfo('matrix', 'mean')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = mean(varargin)
  
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
  [as, matrix_invars, ~] = utils.helper.collect_objects(varargin(:), 'matrix', in_names);
  [pl, pl_invars, ~]     = utils.helper.collect_objects(varargin(:), 'plist', in_names);
  
  % Decide on a deep copy or a modify
  bs = copy(as, nargout);
  
  % Combine input plists and default plist
  usepl = applyDefaults(getDefaultPlist(), pl);
  
  % get dimension
  dim = usepl.find('DIM');
  
  % get size
  for ii = 1:numel(bs)
    s = bs(ii).osize;
    
    % check dimension
    switch dim
      % mean along rows
      case 1
        for jj = 1:s(2)
          obj = bs(ii).getObjectAtIndex(1,jj);
          objSum(jj) = obj;
          objName = sprintf('mean(%s',obj.name);
          for kk = 2:s(1)
            obj = bs(ii).getObjectAtIndex(kk,jj);
            objSum(jj) = objSum + obj;
            objName = sprintf('%s, %s', objName, obj.name);
          end
          objSum(jj) = objSum(jj)./s(1);
          objName = sprintf('%s)',objName);
          objSum(jj).setName(objName);
        end
        
        bs(ii).setObjs(objSum);
        
        % mean along columns
      case 2
        for jj = 1:s(1)
          obj = bs(ii).getObjectAtIndex(jj,1);
          objSum(jj) = obj;
          objName = sprintf('mean(%s',obj.name);
          for kk = 2:s(2)
            obj = bs(ii).getObjectAtIndex(jj,kk);
            objSum(jj) = objSum + obj;
            objName = sprintf('%s, %s', objName, obj.name);
          end
          objSum(jj) = objSum(jj)./s(2);
          objName = sprintf('%s)',objName);
          objSum(jj).setName(objName);
        end
        
        bs(ii).setObjs(objSum');
        
        % error
      otherwise
        error('parameter DIM must be 1 or 2');
    end
    
    
    if ~callerIsMethod
      % set name
      bs(ii).setName(sprintf('mean(%s)', as(ii).name));
      
      % Add history
      bs(ii).addHistory(getInfo('None'), usepl, [matrix_invars(ii)], [as(ii).hist]);
    end
    
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
  pl = plist();
  
  % DIM
  p = param(...
    {'DIM', ['Matrix dimension on which to take the mean (1 or 2)']},...
    paramValue.DOUBLE_VALUE(1)...
    );
  pl.append(p);
end

