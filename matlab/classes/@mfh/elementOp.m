% ELEMENTOP applies the given operator to the models.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: ELEMENTOP applies the given operator to the model.
%
% CALL:        a = elementOp(callerIsMethod, @getInfo, @getDefaultPlist, op, opname, opsym, mfhNames, varargin(:));
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
  
  % Collect mfh inputs but preserve the element shapes
  % ... also collect numeric terms and preserve input names
  argsin = varargin{8};
  
  plin = [];
  mfhs         = {};
  mfhVarNames = {};
  
  if numel(argsin) == 1
    for kk=1:numel(argsin{1})
      mfhs = [mfhs {argsin{1}(kk)}];
      if ~callerIsMethod
        mfhVarNames = [mfhVarNames varnames(1)];
      end
    end
  else
    for kk=1:numel(argsin)
      if isa(argsin{kk}, 'mfh')
        mfhs = [mfhs argsin(kk)];
        if ~callerIsMethod
          mfhVarNames = [mfhVarNames varnames(kk)];
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
    pl = [];
  else
    pl = applyDefaults(dpl, plin);
  end
  
  if numel(mfhs) < 2
    error('### A %s operator requires at least two mfh inputs.', opname)
  end
  
  if numel(mfhs) > 2
    
    % we recursively pass back to this method
    res     = copy(mfhs{1}, 1);
    resName = mfhVarNames{1};
    for kk=2:numel(mfhs)
      res = mfh.elementOp(callerIsMethod, getInfo, getDefaultPlist, op, opname, opsym, {resName, mfhVarNames{kk}}, {res, mfhs{kk}});
      resName = res.name;
    end
    
  else % args == 2
    
    m1 = mfhs{1};
    m2 = mfhs{2};
    
    %%%%%%%%%%   Rule 3:
    if numel(m1) > 1 && numel(m2) > 1
      if isVector(m1) && isVector(m2) && numel(m1) ~= numel(m2)
        error('### It is not possible to %s two mfh vectors of different lengths', opname);
      end
    end
    
    %%%%%%%%%%   Rule 8
    if ismatrix(m1) && isVector(m2)
      if nrows(m2) > 1 && nrows(m2) ~= nrows(m1)
        error('### The number of rows in mfh matrix should match the number of rows in the column vector.');
      elseif ncols(m2)>1 && ncols(m2) ~= ncols(m1)
        error('### The number of cols in mfh matrix should match the number of cols in the row vector.');
      end
    end
    if ismatrix(m2) && isVector(m1)
      if nrows(m1) > 1 && nrows(m1) ~= nrows(m2)
        error('### The number of rows in mfh matrix should match the number of rows in the column vector.');
      elseif ncols(m1)>1 && ncols(m1) ~= ncols(m2)
        error('### The number of cols in mfh matrix should match the number of cols in the row vector.');
      end
    end
    
    %%%%%%%%%%   Rule 9
    if ismatrix(m1) && ismatrix(m2)
      if ~isequal(size(m1), size(m2))
        error('### Two AmfhO matrices must be the same size to %s them.', opname);
      end
    end
    
    %------------- Now perform operation
    
    if numel(m1) == 1 && numel(m2) == 1
      
      %%%%%%%%%%   Rule 1: single mfh + single mfh
      res = mfh.initObjectWithSize(1,1);
      operateSingleObject(res, m1, [], m2, []);
      
    elseif isVector(m1) && numel(m2) == 1
      
      %%%%%%%%%%   Rule 2a: vector + single mfh
      res = mfh.initObjectWithSize(size(m1));
      
      for ii = 1:numel(m1);
        operateSingleObject(res(ii), m1(ii), ii, m2, []);
      end
      
    elseif numel(m1) == 1 && isVector(m2)
      
      %%%%%%%%%%   Rule 2b: single mfh + vector
      res = mfh.initObjectWithSize(size(m2));
      
      for ii = 1:numel(m2);
        operateSingleObject(res(ii), m1, [], m2(ii), ii);
      end
      
    elseif isVector(m1) && isVector(m2) && numel(m1) == numel(m2)
      
      %%%%%%%%%%   Rule 4: vector + vector
      res = mfh.initObjectWithSize(size(m1));
      
      for ii = 1:numel(m1);
        operateSingleObject(res(ii), m1(ii), ii, m2(ii), ii);
      end
      
    elseif ismatrix(m1) && numel(m2) == 1
      
      %%%%%%%%%%   Rule 5a: matrix + single mfh
      res = mfh.initObjectWithSize(size(m1));
      
      for ii = 1:numel(m1);
        operateSingleObject(res(ii), m1(ii), ii, m2, []);
      end
      
    elseif numel(m1) == 1 && ismatrix(m2)
      
      %%%%%%%%%%   Rule 5b: single mfh + matrix
      res = mfh.initObjectWithSize(size(m2));
      
      for ii = 1:numel(m2);
        operateSingleObject(res(ii), m1, [], m2(ii), ii);
      end
      
    elseif ismatrix(m1) && isVector(m2) && size(m1,1) == length(m2)
      
      %%%%%%%%%%   Rule 6a: matrix NP + vector N
      res = mfh.initObjectWithSize(size(m1));
      
      for nn = 1:size(m1,1)
        for pp = 1:size(m1,2)
          operateSingleObject(res(nn,pp), m1(nn,pp), [nn pp], m2(nn), nn);
        end
      end
      
    elseif isVector(m1) && ismatrix(m2) && size(m2,1) == length(m1)
      
      %%%%%%%%%%   Rule 6b: vector N + matrix NP
      res = mfh.initObjectWithSize(size(m2));
      
      for nn = 1:size(m2,1)
        for pp = 1:size(m2,2)
          operateSingleObject(res(nn,pp), m1(nn), nn, m2(nn,pp), [nn pp]);
        end
      end
      
    elseif ismatrix(m1) && isVector(m2) && size(m1,2) == length(m2)
      
      %%%%%%%%%%   Rule 7a: matrix NP + vector P
      res = mfh.initObjectWithSize(size(m1));
      
      for nn = 1:size(m1,1)
        for pp = 1:size(m1,2)
          operateSingleObject(res(nn,pp), m1(nn,pp), [nn pp], m2(pp), pp);
        end
      end
      
    elseif isVector(m1) && ismatrix(m2) && size(m2,2) == length(m1)
      
      %%%%%%%%%%   Rule 7b: vector P + matrix NP
      res = mfh.initObjectWithSize(size(m2));
      
      for nn = 1:size(m2,1)
        for pp = 1:size(m2,2)
          operateSingleObject(res(nn,pp), m1(pp), pp, m2(nn,pp), [nn pp]);
        end
      end
      
    elseif ismatrix(m1) && ismatrix(m2) && size(m1,1) == size(m2,1) && size(m1,2) == size(m2,2)
      
      %%%%%%%%%%   Rule 10: matrix NP + matrix NP
      res = mfh.initObjectWithSize(size(m2));
      
      for nn = 1:size(m1,1)
        for pp = 1:size(m1,2)
          operateSingleObject(res(nn,pp), m1(nn,pp), [nn pp], m2(nn,pp), [nn pp]);
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
    
    %------------------
    % process func
    if ~isempty(a1.funcDef) && ~isempty(a2.funcDef)
      % combine function definitions
      switch opsym
        case {'+', '-'}
          res.funcDef = [ a1.funcDef ' ' opsym ' ' a2.funcDef ];
        otherwise
          res.funcDef = ['(' a1.funcDef ') ' opsym ' (' a2.funcDef ')'];
      end
      
      % combine parameter definitions
      res.paramsDef = combine(a1.paramsDef, a2.paramsDef);
      
      % set inputs
      res.inputs = {res.paramsDef.name};
      
      % build from definition
      res.applyDef();
      
    else
      switch opsym
        case {'+', '-'}
          res.func = ['(' a1.func ') ' opsym ' (' a2.func ')'];
        otherwise
          res.func = [ a1.func ' ' opsym ' ' a2.func ];
      end
      
      %------------------
      % process inputs
      
      res.inputs = a1.inputs;
      
      for kk=1:numel(a2.inputs)
        if any(strcmp(res.inputs, a2.inputs{kk}))
          warning('The two models share the same input name %s', a2.inputs{kk});
        end
        
        res.inputs = [res.inputs a2.inputs(kk)];
      end
      
    end
    
    %------------------
    % process subfuncs
    
    % need a unique array of subfuncs
    if ~isempty(a1.subfuncs)
      subfuncs = copy(a1.subfuncs, 1);
      names = {subfuncs.name};
      for kk=1:numel(a2.subfuncs)
        f = a2.subfuncs(kk);
        if any(strcmp(f.name, names))
          warning OFF BACKTRACE
          warning('The subfunction %s exists in both input models. Only the first will be kept.', f.name);
          warning ON BACKTRACE
        else
          names = [names {f.name}];
          subfuncs = [subfuncs copy(f, 1)];
        end
      end
    else
      if ~isempty(a2.subfuncs)
        subfuncs = copy(a2.subfuncs, 1);
      else
        subfuncs = [];
      end
    end
    
    res.subfuncs = subfuncs;
    
    %------------------
    % process inputObjects
    res.inputObjects = {};
    
    %------------------
    % process constants
    allconsts = [a1.constants a2.constants];
    [~, IA, ~] = unique(cellfun(@char, allconsts, 'UniformOutput', false), 'stable');
    res.constants = allconsts(IA);
    
    %------------------
    % process constObjects
    constObjs = [a1.constObjects a2.constObjects];
    res.constObjects = constObjs(IA);
    
    
    if callerIsMethod
      % do nothing
    else
      % Set name
      n1 = getName(a1.name, mfhVarNames{1}, a1Idx);
      n2 = getName(a2.name, mfhVarNames{2}, a2Idx);
      res.name = sprintf('%s_%s', n1, n2);
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
