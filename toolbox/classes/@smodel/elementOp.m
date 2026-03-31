% ELEMENTOP applies the given operator to the input smodels.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: ELEMENTOP applies the given operator to the input smodels.
%
% CALL:        a = elementOp(callerIsMethod, op, opname, opsym, infoObj, pl, fcnArgIn, varNames)
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
  
  if numel(fcnArgIn) ~= 2 && numel(fcnArgIn) ~= 3
    error('### ');
  end
  
  mdl1 = fcnArgIn{1};
  mdl2 = fcnArgIn{2};
  
  %%%%%%%%%%   Convert numbers into a symbolic model object   %%%%%%%%%%
  if isnumeric(mdl1) || ischar(mdl1)
    expr = mdl1;
    varNames{1} = num2str(expr);
    % Create an array with the same size of the second input
    mdl1 = smodel.newarray(size(mdl2));
    % Copy the object and replace the expression
    for ii = 1:numel(mdl2)
      mdl1(ii) = copy(mdl2(ii), true);
      mdl1(ii).yunits = '';
      mdl1(ii).expr = msym(expr);
      % Do not duplicate yunits in case of product/division
      if ~strcmpi(op, 'times') && ~strcmpi(op, 'rdivide')
        mdl1(ii).yunits = mdl2(ii).yunits;
      end
    end
  end
  if isnumeric(mdl2) || ischar(mdl2)
    expr = mdl2;
    varNames{2} = num2str(expr);
    % Create an array with the same size of the first input
    mdl2 = smodel.newarray(size(mdl1));
    % Copy the object and replace the expression
    for ii = 1:numel(mdl1)
      mdl2(ii) = copy(mdl1(ii), true);
      mdl2(ii).yunits = '';
      mdl2(ii).expr = msym(expr);

      % Do not duplicate yunits in case of product/division
      if ~strcmpi(op, 'times') && ~strcmpi(op, 'rdivide')
        mdl2(ii).yunits = mdl1(ii).yunits;
      end
    end
  end
  
  % Convert cdata aos into a smodel object
  if isa(mdl2, 'ao')
    if isa(mdl2.data, 'cdata') && numel(mdl2.data.y) == 1
      expr = mdl2.y;
      % Create an array with the same size of the first input
      mdl2 = smodel.newarray(size(mdl1));
      % Copy the object and replace the expression
      for ii = 1:numel(mdl1)
        mdl2(ii) = copy(mdl1(ii), true);
        mdl2(ii).expr = msym(expr);

      end
    else
      error('### It is not possible to apply %s to the two objects!', opname);
    end
  end
  
  %%%%%%%%%%   If the first or second input is only one object then   %%%%%%%%%%
  %%%%%%%%%%   resize the input to the size of the other object.      %%%%%%%%%%
  if numel(mdl1) == 1 && numel(mdl1) ~= numel(mdl2)
    mdl1(1:numel(mdl2)) = mdl1;
    mdl1 = reshape(mdl1, size(mdl2));
  end
  if numel(mdl2) == 1 && numel(mdl2) ~= numel(mdl1)
    mdl2(1:numel(mdl1)) = mdl2;
    mdl2 = reshape(mdl2, size(mdl1));
  end
  
  if ~all(size(mdl1) == size(mdl2))
    error('### The Input objects must have the same size. Size of model1 [%d %d], model2 [%d %d]', size(mdl1,1),  size(mdl1,2), size(mdl2,1), size(mdl2,2));
  end
  
  %%%%%%%%%%   Add each element inside the array   %%%%%%%%%%
  mdl = smodel.newarray(size(mdl1));
  for kk = 1:numel(mdl1)
    switch opsym
      case {'.*', '*'} 
        if any(strcmp(mdl1(kk).expr.s, {'0','(0)'})) || any(strcmp(mdl2(kk).expr.s, {'0','(0)'}))
          % 0*something = 0
          mdl(kk).expr = msym(['0']);
        else
          mdl(kk).expr = msym(['(' mdl1(kk).expr.s ')' opsym '(' mdl2(kk).expr.s ')']);
        end
      case {'./', '/'}
        if any(strcmp(mdl1(kk).expr.s, {'0','(0)'}))
          % 0/something = 0
          mdl(kk).expr = msym(['0']);
        else
          mdl(kk).expr = msym(['(' mdl1(kk).expr.s ')' opsym '(' mdl2(kk).expr.s ')']);
        end
      case '+'
        if any(strcmp(mdl1(kk).expr.s, {'0','(0)'}))
          % 0 + something = something
          mdl(kk).expr = msym([mdl2(kk).expr.s]);
        elseif any(strcmp(mdl2(kk).expr.s, {'0','(0)'}))
          % something + 0 = something
          mdl(kk).expr = msym([mdl1(kk).expr.s]);
        else
          mdl(kk).expr = msym(['(' mdl1(kk).expr.s ')' opsym '(' mdl2(kk).expr.s ')']);
        end        
      otherwise
        mdl(kk).expr = msym(['(' mdl1(kk).expr.s ')' opsym '(' mdl2(kk).expr.s ')']);
    end
 
    mdl(kk).name = ['(' mdl1(kk).name ')' opsym '(' mdl2(kk).name ')'];
    
    % Merge parameters, alias, xvar, tran fields
    smodel.mergeFields(mdl1(kk), mdl2(kk), mdl(kk), 'params', 'values');
    smodel.mergeFields(mdl1(kk), mdl2(kk), mdl(kk), 'aliasNames', 'aliasValues');
    smodel.mergeFields(mdl1(kk), mdl2(kk), mdl(kk), 'xvar', 'xvals');
    smodel.mergeFields(mdl1(kk), mdl2(kk), mdl(kk), 'xvar', 'xunits');
    smodel.mergeFields(mdl1(kk), mdl2(kk), mdl(kk), 'xvar', 'trans');
    
    % Take care of units
    if strcmpi(op,'times')
      mdl(kk).yunits = simplify(unit(unit(mdl1(kk).yunits).*unit(mdl2(kk).yunits)));
    elseif strcmpi(op,'rdivide')
      mdl(kk).yunits = simplify(unit(unit(mdl1(kk).yunits)./unit(mdl2(kk).yunits)));
    else
      mdl(kk).yunits = mdl1(kk).yunits;
      if ~isequal(mdl1(kk).yunits, mdl2(kk).yunits)
        error('### Y units should be equal for %s', opname);
      end
    end
    
    % Add history
    if ~callerIsMethod
      inname1 = varNames{1};
      inname2 = varNames{2};
      if numel(fcnArgIn{1}) > 1
        [ii, jj] = ind2sub(size(fcnArgIn{1}), kk);
        inname1 = sprintf('%s(%d,%d)', inname1, ii, jj);
      end
      if numel(fcnArgIn{2}) > 1
        [ii, jj] = ind2sub(size(fcnArgIn{2}), kk);
        inname2 = sprintf('%s(%d,%d)', inname2, ii, jj);
      end
      mdl(kk).addHistory(infoObj, pl, {inname1, inname2}, [mdl1(kk).hist mdl2(kk).hist]);
    end
  end
  
  varargout{1} = mdl;
  
end


