% ELEMENTOP applies the given operator to the data.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: ELEMENTOP applies the given operator to the data.
%
% CALL:        a = elementOp(callerIsMethod, @getInfo, @getDefaultPlist, op, opname, opsym, aosNames, varargin(:));
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function res = elementOp(varargin)
  
  
  import utils.const.*
  
  % Settings
  callerIsMethod = varargin{1};
  getInfo = varargin{2};
  getDefaultPlist = varargin{3};
  
  if callerIsMethod
    dpl = [];
    infoObj = [];
  else
    % Check if this is a call for parameters
    if utils.helper.isinfocall(varargin{end}{:})
      res = getInfo(varargin{end}{3});
      return
    end
    
    dpl = getDefaultPlist();
    infoObj = getInfo('None');
    
  end
  
  op     = varargin{4};
  opname = varargin{5};
  opsym  = varargin{6};
  
  % variable names
  varnames = varargin{7};
  
  % Collect AO inputs but preserve the element shapes
  % ... also collect numeric terms and preserve input names
  argsin = varargin{8};
  
  plin = [];
  aos         = {};
  aosVarNames = {};
  
  if numel(argsin) == 1
    for kk=1:numel(argsin{1})
      aos = [aos {argsin{1}(kk)}];
      if ~callerIsMethod
        aosVarNames = [aosVarNames varnames(1)];
      end
    end
  else
    for kk=1:numel(argsin)
      if isa(argsin{kk}, 'ao')
        aos = [aos argsin(kk)];
        if ~callerIsMethod
          aosVarNames = [aosVarNames varnames(kk)];
        end
      elseif isnumeric(argsin{kk}) || islogical(argsin{kk})
        % When promoting the number to an AO, we simply call the fromVals.
        a = fromVals(ao, plist('vals', argsin{kk}), callerIsMethod);
        aos = [aos {a}];
        if all(size(argsin{kk}) == [1 1])
          aosVarNames = [aosVarNames {num2str(argsin{kk})}];
        elseif any(size(argsin{kk}) == [1 1])
          aosVarNames = [aosVarNames 'vector'];
        else
          aosVarNames = [aosVarNames 'matrix'];
        end
      elseif isa(argsin{kk}, 'plist')
        if isempty(plin)
          plin = argsin{kk};
        else
          plin = combine(plin, argsin{kk});
        end
      end
    end
  end
  
  % Combine input PLIST with default PLIST
  if callerIsMethod
    axis = 'y';
    pl = [];
  else
    pl = applyDefaults(dpl, plin);
    axis = pl.find_core('axis');
    % operate at least the y-values
    if isempty(axis)
      axis = 'y';
    end
  end
  
  if numel(aos) < 2
    error('### A %s operator requires at least two AO inputs.', opname)
  end
  
  if numel(aos) > 2
    
    % we recursively pass back to this method
    res     = copy(aos{1}, 1);
    if isempty(aosVarNames)
      resName = 'unknown';
    else
      resName = aosVarNames{1};
    end
    for kk=2:numel(aos)
      if ~isempty(aosVarNames)
        aoname = aosVarNames{kk};
      else
        aoname = 'unknown';
      end
      res = ao.elementOp(callerIsMethod, getInfo, getDefaultPlist, op, opname, opsym, {resName, aoname}, {res, aos{kk}});
      resName = res.name;
    end
    
  else % args == 2
    
    a1 = aos{1};
    a2 = aos{2};
    
    %%%%%%%%%%   Rule 3:
    if numel(a1) > 1 && numel(a2) > 1
      if isVector(a1) && isVector(a2) && numel(a1) ~= numel(a2)
        error('### It is not possible to %s two AO vectors of different lengths', opname);
      end
    end
    
    %%%%%%%%%%   Rule 8
    if ismatrix(a1) && isVector(a2)
      if nrows(a2) > 1 && nrows(a2) ~= nrows(a1)
        error('### The number of rows in AO matrix should match the number of rows in the column vector.');
      elseif ncols(a2)>1 && ncols(a2) ~= ncols(a1)
        error('### The number of cols in AO matrix should match the number of cols in the row vector.');
      end
    end
    if ismatrix(a2) && isVector(a1)
      if nrows(a1) > 1 && nrows(a1) ~= nrows(a2)
        error('### The number of rows in AO matrix should match the number of rows in the column vector.');
      elseif ncols(a1)>1 && ncols(a1) ~= ncols(a2)
        error('### The number of cols in AO matrix should match the number of cols in the row vector.');
      end
    end
    
    %%%%%%%%%%   Rule 9
    if ismatrix(a1) && ismatrix(a2)
      if ~isequal(size(a1), size(a2))
        error('### Two AO matrices must be the same size to %s them.', opname);
      end
    end
    
    %------------- Now perform operation
    
    if numel(a1) == 1 && numel(a2) == 1
      
      %%%%%%%%%%   Rule 1: single AO + single AO
      res = ao.initObjectWithSize(1,1);
      operateSingleObject(res, a1, [], a2, []);
      
    elseif isVector(a1) && numel(a2) == 1
      
      %%%%%%%%%%   Rule 2a: vector + single AO
      res = ao.initObjectWithSize(size(a1));
      
      for ii = 1:numel(a1);
        operateSingleObject(res(ii), a1(ii), ii, a2, []);
      end
      
    elseif numel(a1) == 1 && isVector(a2)
      
      %%%%%%%%%%   Rule 2b: single AO + vector
      res = ao.initObjectWithSize(size(a2));
      
      for ii = 1:numel(a2);
        operateSingleObject(res(ii), a1, [], a2(ii), ii);
      end
      
    elseif isVector(a1) && isVector(a2) && numel(a1) == numel(a2)
      
      %%%%%%%%%%   Rule 4: vector + vector
      res = ao.initObjectWithSize(size(a1));
      
      for ii = 1:numel(a1);
        operateSingleObject(res(ii), a1(ii), ii, a2(ii), ii);
      end
      
    elseif ismatrix(a1) && numel(a2) == 1
      
      %%%%%%%%%%   Rule 5a: matrix + single AO
      res = ao.initObjectWithSize(size(a1));
      
      for ii = 1:numel(a1);
        operateSingleObject(res(ii), a1(ii), ii, a2, []);
      end
      
    elseif numel(a1) == 1 && ismatrix(a2)
      
      %%%%%%%%%%   Rule 5b: single AO + matrix
      res = ao.initObjectWithSize(size(a2));
      
      for ii = 1:numel(a2);
        operateSingleObject(res(ii), a1, [], a2(ii), ii);
      end
      
    elseif ismatrix(a1) && isVector(a2) && size(a1,1) == length(a2)
      
      %%%%%%%%%%   Rule 6a: matrix NP + vector N
      res = ao.initObjectWithSize(size(a1));
      
      for nn = 1:size(a1,1)
        for pp = 1:size(a1,2)
          operateSingleObject(res(nn,pp), a1(nn,pp), [nn pp], a2(nn), nn);
        end
      end
      
    elseif isVector(a1) && ismatrix(a2) && size(a2,1) == length(a1)
      
      %%%%%%%%%%   Rule 6b: vector N + matrix NP
      res = ao.initObjectWithSize(size(a2));
      
      for nn = 1:size(a2,1)
        for pp = 1:size(a2,2)
          operateSingleObject(res(nn,pp), a1(nn), nn, a2(nn,pp), [nn pp]);
        end
      end
      
    elseif ismatrix(a1) && isVector(a2) && size(a1,2) == length(a2)
      
      %%%%%%%%%%   Rule 7a: matrix NP + vector P
      res = ao.initObjectWithSize(size(a1));
      
      for nn = 1:size(a1,1)
        for pp = 1:size(a1,2)
          operateSingleObject(res(nn,pp), a1(nn,pp), [nn pp], a2(pp), pp);
        end
      end
      
    elseif isVector(a1) && ismatrix(a2) && size(a2,2) == length(a1)
      
      %%%%%%%%%%   Rule 7b: vector P + matrix NP
      res = ao.initObjectWithSize(size(a2));
      
      for nn = 1:size(a2,1)
        for pp = 1:size(a2,2)
          operateSingleObject(res(nn,pp), a1(pp), pp, a2(nn,pp), [nn pp]);
        end
      end
      
    elseif ismatrix(a1) && ismatrix(a2) && size(a1,1) == size(a2,1) && size(a1,2) == size(a2,2)
      
      %%%%%%%%%%   Rule 10: matrix NP + matrix NP
      res = ao.initObjectWithSize(size(a2));
      
      for nn = 1:size(a1,1)
        for pp = 1:size(a1,2)
          operateSingleObject(res(nn,pp), a1(nn,pp), [nn pp], a2(nn,pp), [nn pp]);
        end
      end
      
    else
      error('### Should not happen.')
    end
    
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  % DESCRIPTION: Applies the given operator to single input objects.
  %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  function operateSingleObject(res, a1, a1Idx, a2, a2Idx)
    
    % Set data object
    res.data = operateData(a1, a2, op, axis);
    
    if callerIsMethod
      % do nothing
    else
      % Set name
      n1 = getName(a1.name, aosVarNames{1}, a1Idx);
      n2 = getName(a2.name, aosVarNames{2}, a2Idx);
      res.name = sprintf('(%s %s %s)', n1, opsym, n2);
      % Set description
      if ~isempty(a1.description) || ~isempty(a2.description)
        if isempty(a1.description)
          res.description = a2.description;
        elseif isempty(a2.description)
          res.description = a1.description;
        else
          res.description = strtrim([a1.description, ', ', a2.description]);
        end
      end
      % Set plotinfo
      if ~isempty(a1.plotinfo) || ~isempty(a2.plotinfo)
        res.plotinfo = combine(a1.plotinfo, a2.plotinfo);
      end
      res.addHistory(infoObj, pl, {n1, n2}, [a1.hist a2.hist]);
    end
    
  end
  
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               Local Functions                               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Applies the given operator to the data object.
%
function data = operateData(a1, a2, op, axis)
  
  if isDataCompatible(a1, a2, op)
    
    data = getDataObject(a1.data, a2.data, op);
    
    operateValues(data, a1.data, a2.data, op, axis);
    operateError(data, a1.data, a2.data, op, axis);
    operateUnits(data, a1.data, a2.data, op, axis);
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Checks if the data objects are compatible
%
function res = isDataCompatible(a1, a2, op)
  
  d1 = a1.data;
  d2 = a2.data;
  
  TOL = eps;
  
  %%%%% check: Data types
  if (isa(d1, 'fsdata') && isa(d2, 'tsdata')) || ...
      isa(d2, 'fsdata') && isa(d1, 'tsdata')
    error('### Can not operate time-series data to frequency-series data for the %s operator.', op);
  end
  
  %%%%% check: Frequency for tsdata
  if  isa(d1, 'tsdata') && isa(d2, 'tsdata') && ...
      d1.isprop_core('fs') && d2.isprop_core('fs') && ...
      ~isempty(d1.fs) && ~isempty(d2.fs) && ...
      ~isnan(d1.fs) && ~isnan(d2.fs) && ...
      abs(d1.fs - d2.fs) > TOL
    error('### The objects have different sample rates. Please resample one of the objects.')
  end
  
  %%%%% check: Y units
  if any(strcmpi(op, {'plus', 'minus'}))
    if ~isempty(d1.yunits.strs) && ~isempty(d2.yunits.strs)
      [u1, s1] = toSI(d1.yunits);
      [u2, s2] = toSI(d2.yunits);
      if ~isequal(u1, u2) || ~isequal(s1, s2)
        error('### Y units should be equivalent for the %s operator %s <-> %s', op, char(a1.yunits), char(a2.yunits));
      end
    end
  end
  
  %%%%% check: X units for all data types
  if ~isa(d1, 'cdata') && ~isa(d2, 'cdata')
    if ~isempty(d1.xunits.strs) && ~isempty(d2.xunits.strs)
      if ~isequal(d1.xunits, d2.xunits)
        error('### X units should be equal for the %s operator', op);
      end
    end
  end
  
  %%%%% check: X base of the fsdata objects
  if isa(d1, 'fsdata') && isa(d2, 'fsdata') && ~utils.helper.eq2eps(a1.data.getX, a2.data.getX)
    error('### It is not possible to perform this operation on frequency-series data if the x values are not the same.');
  end
  
  %%%%% check: X base of the xydata objects
  if isa(d1, 'xydata') && isa(d2, 'xydata') && ~utils.helper.eq2eps(a1.data.getX, a2.data.getX)
    error('### It is not possible to perform this operation on xydata series if the x values are not the same.');
  end
  
  %%%%% check: X base of the tsdata objects
  msg = sprintf('### It is not possible to perform this operation on tsdata series if the x values are not the same [%s.x ~= %s.x].', a1.name, a2.name);
  if isa(d1, 'tsdata') && isa(d2, 'tsdata')
    evenly_d1 = evenly(d1);
    evenly_d2 = evenly(d2);
    if xor(evenly_d1, evenly_d2)
      error(msg);
    elseif evenly_d1 && evenly_d2
      if ~utils.helper.eq2eps(d1.nsecs, d2.nsecs) || ~utils.helper.eq2eps(d1.fs, d2.fs)
        error(msg);
      end
    else
      x1 = a1.data.getX;
      x2 = a2.data.getX;
      if ~utils.helper.eq2eps(x1 - x1(1), x2 - x2(1))
        error(msg);
      end
    end
  end
  
  res = true;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Decide which data object should be used as the output object.
%
function dout = getDataObject(d1, d2, op)
  
  % The output data object is always a copy.
  if isa(d1, 'data2D') && isa(d2, 'data2D')
    if numel(d1.getY) > 1
      dout = copy(d1, 1);
    elseif numel(d2.getY) > 1
      dout = copy(d2, 1);
    else
      dout = copy(d1, 1);
    end
  elseif isa(d1, 'data2D') && isa(d2, 'cdata')
    dout = copy(d1, 1);
  elseif isa(d1, 'cdata') && isa(d2, 'data2D')
    dout = copy(d2, 1);
  else
    dout = copy(d1, 1);
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Evaluate the output values.
%
function operateValues(dout, d1, d2, op, axis)
  
  if strcmp(op, 'mtimes') || strcmp(op, 'mrdivide')
    y = feval(op, d1.y, d2.y);
  else
    y = feval(op, d1.getY, d2.getY);
  end
  
  if isa(dout, 'cdata')
    if any(find(axis == 'y'))
      dout.setY(y);
    else
      error('cdata objects only have y axis');
    end
  else
    if any(find(axis == 'y'))
      dout.setY(y);
    end
    if any(find(axis == 'x'))
      dout.setX(feval(op, d1.getX, d2.getX));
    end
  end
  
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Evaluate the errors
%
function operateError(dout, d1, d2, op, axis)
  
  % Define function for the errors
  switch op
    case {'plus', 'minus'}
      err = @(err1, err2, val1, val2) sqrt(err1.^2 + err2.^2);
    case {'times', 'mtimes'}
      err = @(err1, err2, val1, val2) sqrt((val2.*err1).^2 + (val1.*err2).^2 + (err1.*err2).^2);
    case {'rdivide', 'mrdivide'}
      err = @(err1, err2, val1, val2) sqrt(((1./val2).*err1).^2 + ((-val1./val2.^2).*err2).^2 + ((val1./val2.^3).*(err2.^2)).^2 + (((-1./val2).^2).*err1.*err2).^2);
    case 'power'
      err = @(err1, err2, val1, val2) err1 .* abs(val2 .* val1.^(val2-1));
    case 'mpower'
      if numel(d2.getY) == 1
        err = @(err1, err2, val1, val2) err1 .* abs(val2 .* val2.^(val2-1));
      else
        err = @(err1, err2, val1, val2) [];
      end
    otherwise
      err = @(err1, err2, val1, val2) [];
  end
  
  % Compute the error for the y-axis
  if isa(dout, 'cdata')
    if any(find(axis == 'y'))
      if ~isempty(d1.dy) || ~isempty(d2.dy)
        
        dy1 = d1.getDy;
        dy2 = d2.getDy;
        
        if isempty(dy1)
          dy1 = zeros(size(d1.getY));
        end
        if isempty(dy2)
          dy2 = zeros(size(d2.getY));
        end
        
        dy = err(dy1, dy2, d1.getY, d2.getY);
      else
        dy = [];
      end
      dout.setDy(dy);
    else
      warning('!!! The output data object is a ''cdata'' object and you operate only on the x-axis but this axis doesn''t exist on a cdata object.');
    end
    
  else
    
    % Compute the error for the y-axis
    if any(find(axis == 'y'))
      if ~isempty(d1.dy) || ~isempty(d2.dy)
        
        dy1 = d1.getDy;
        dy2 = d2.getDy;
        
        if isempty(dy1)
          dy1 = zeros(size(d1.getY));
        end
        if isempty(dy2)
          dy2 = zeros(size(d2.getY));
        end
        
        dy = err(dy1, dy2, d1.getY, d2.getY);
      else
        dy = [];
      end
      dout.setDy(dy);
    end
    
%     % Compute the error for the x-axis
%     if any(find(axis == 'x'))
%       if ~isempty(d1.dx) || ~isempty(d2.dx)
%         
%         dx1 = d1.getDx;
%         dx2 = d2.getDx;
%         
%         if isempty(dx1)
%           dx1 = zeros(size(d1.getX));
%         end
%         if isempty(dx2)
%           dx2 = zeros(size(d2.getX));
%         end
%         
%         dx = err(dx1, dx2, d1.getX, d2.getX);
%       else
%         dx = [];
%       end
%       dout.setDx(dx);
%     end
    
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Evaluate the units
%
function operateUnits(data, d1, d2, op, axis)
  if utils.helper.ismember(op, {'or', 'and', 'xor', 'lt', 'le', 'gt', 'ge', 'eq', 'ne'})
    data.setYunits('');
  elseif utils.helper.ismember(op, {'plus', 'minus'})
    % return the first non-empty
    if ~isempty(d1.yunits.strs)
      data.setYunits(d1.yunits);
    else
      data.setYunits(d2.yunits);
    end
  elseif utils.helper.ismember(op, {'power', 'mpower'})
    if numel(d2.getY) == 1
      data.setYunits(feval(op, d1.yunits, d2.getY));
    else
      data.setYunits('');
    end
  else
    % For other operators we need to apply the operator
    data.setYunits(feval(op, d1.yunits, d2.yunits));
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function name = getName(objName, varName, idx)
  
  if strcmpi(objName, 'none') || isempty(objName)
    if ~isempty(varName)
      useName = varName;
    else
      useName = objName;
    end
    % Set the name depending to the index
    if isempty(idx)
      name = useName;
    elseif numel(idx) == 1
      name = sprintf('%s(%d)', useName, idx(1));
    else
      name = sprintf('%s(%d,%d)', useName, idx(1), idx(2));
    end
  else
    name = objName;
  end
  
  if isempty(name)
    name = 'unknown';
  end
  
end

function res = isVector(a)
  res = any(size(a) > 1) && any(size(a) == 1);
end

function res = ismatrix(a)
  res = all(size(a) > 1);
end

%-------------------------------------
% Return number of rows in the array
function r = nrows(a)
  r = size(a,1);
end

%-------------------------------------
% Return number of cols in the array
function r = ncols(a)
  r = size(a,2);
end
