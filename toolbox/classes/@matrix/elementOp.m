% ELEMENTOP applies the given operator to the input matrices.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: ELEMENTOP applies the given operator to the input matrices.
%
% CALL:        a = elementOp(op, opname, opsym, infoObj, pl, fcnArgIn, varNames)
%
% PARAMETERS:  op       - MATLAB operation name
%              opname   - Name for displaying
%              opsym    - Operation symbol
%              infoObj  - minfo object
%              pl       - default plist
%              fcnArgIn - Input argument list of the calling fcn.
%              varNames - Variable names of the input
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = elementOp(varargin)
  
  import utils.const.*
  
  % Settings
  callerIsMethod = varargin{1};
  op     = varargin{2};
  opname = varargin{3};
  opsym  = varargin{4};
  
  infoObj = varargin{5};
  pl      = varargin{6};
  
  fcnArgIn = varargin{7};
  varNames = varargin{8};
  
  if numel(fcnArgIn) ~=2
    error('### The operator %s can only operate on two inputs', op);
  end
  
  mat1 = fcnArgIn{1};
  mat2 = fcnArgIn{2};
    
  if isnumeric(mat1) || ischar(mat1)
    if ischar(mat1)
      mat1 = eval(mat1);
    end
    nums = mat1;
    varNames{1} = utils.helper.mat2str(nums);
    % build a numeric/char object of the same size of mat2
    mat1 = copy(mat2,1);
    for ii=1:numel(mat1.objs)
      if numel(nums) == numel(mat1.objs)
        expr = nums(ii);
      else
        expr = nums;
      end
      mat1.objs(ii) = feval(class(mat2.objs), expr);
      mat1.objs(ii).setName(num2str(expr));
      if isprop(mat2.objs(ii), 'xunits') || (isa(mat2.objs(ii), 'ao') && ...
          isprop(mat2.objs(ii).data, 'xunits'))
        mat1.objs(ii).setXunits(mat2.objs(ii).xunits);
      end
    end
  end
  if isnumeric(mat2) || ischar(mat2)
    if ischar(mat2)
      mat2 = eval(mat2);
    end
    nums = mat2;
    varNames{2} = utils.helper.mat2str(nums);
    % build a numeric/char object of the same size of mat1
    mat2 = copy(mat1,1);
    for ii=1:numel(mat2.objs)
      if numel(nums) == numel(mat2.objs)
        expr = nums(ii);
      else
        expr = nums;
      end
      mat2.objs(ii) = feval(class(mat1.objs), expr);
      mat2.objs(ii).setName(utils.helper.num2str(expr));
      if isprop(mat2.objs(ii), 'xunits') || (isa(mat2.objs(ii), 'ao') && ...
          isprop(mat2.objs(ii).data, 'xunits'))
        mat2.objs(ii).setXunits(mat1.objs(ii).xunits);
      end
    end
  end
  
  % matrix objects must all contain the same class
  if ~strcmp(class(mat1.objs), class(mat2.objs))
    error('### The %s operator can only apply to matrix objects containing the same class of objects. [%s .* %s]', op, class(mat1.objs), class(mat2.objs));
  end
  
  
  % init output
  mat = copy(mat1,1);
    
  %%%%%%%%%%   If the first or second input is only one object then   %%%%%%%%%%
  %%%%%%%%%%   resize the input to the size of the other object.      %%%%%%%%%%
  if numel(mat1.objs) == 1 && numel(mat1.objs) ~= numel(mat2.objs)
    h1 = mat1.hist;
    obj1 = mat1.objs;
    obj1(1:numel(mat2.objs)) = obj1;
    obj1 = reshape(obj1, size(mat2.objs));
    mat1 = matrix(obj1);
    mat1.name = varNames{1};
    mat1.hist = h1;
  end
  if numel(mat2.objs) == 1 && numel(mat2.objs) ~= numel(mat1.objs)
    h2 = mat2.hist;
    obj2 = mat2.objs;
    obj2(1:numel(mat1.objs)) = obj2;
    obj2 = reshape(obj2, size(mat1.objs));
    mat2 = matrix(obj2);
    mat2.name = varNames{2};
    mat2.hist = h2;
  end
  
  if ~all(size(mat1.objs) == size(mat2.objs))
    error('### The Input objects must have the same size. Size of mat1 [%d %d], mat2 [%d %d]', size(mat1.objs,1),  size(mat1.objs,2), size(mat2.objs,1), size(mat2.objs,2));
  end
  
  % switch between operations
  switch lower(op)
    case 'plus'
      % plus operation
      for kk = 1:numel(mat1.objs)
        mat.objs(kk) = mat1.objs(kk) + mat2.objs(kk);
      end
    case 'minus'
      % minus operation
      for kk = 1:numel(mat1.objs)
        mat.objs(kk) = mat1.objs(kk) - mat2.objs(kk);
      end
    case 'times'
      % times operation
      for kk = 1:numel(mat1.objs)
        mat.objs(kk) = mat1.objs(kk) .* mat2.objs(kk);
      end
    case 'rdivide'
      % rdivide operation
      for kk = 1:numel(mat1.objs)
        mat.objs(kk) = mat1.objs(kk) ./ mat2.objs(kk);
      end
    case 'power'
      % elelment by element power operation
      for kk = 1:numel(mat1.objs)
        mat.objs(kk) = mat1.objs(kk) .^ nums;
      end
  end
  
  if ~callerIsMethod
    mat.name = [varNames{1} opsym varNames{2}];
    mat.addHistory(infoObj, pl, varNames, [mat1.hist mat2.hist]);  
  end
  
  varargout{1} = mat;
  
end

