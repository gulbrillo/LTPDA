% MELEMENTOP applies the given matrix operator to the data.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: MELEMENTOP applies the given matrix operator to the data.
%
% CALL:
%              a = melementOp(callerIsMethod, op, opname, opsym, minfo, pl, a1, a2,...)
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = melementOp(varargin)
  
  import utils.const.*
  
  % Settings
  callerIsMethod = varargin{1};
  op     = varargin{2};
  opname = varargin{3};
  opsym  = varargin{4};
  % Info to pass to history
  iobj = varargin{5};
  pl = varargin{6};
  
  % variable names
  varnames = varargin{8};
  
  % Collect AO inputs but preserve the element shapes
  % ... also collect numeric terms and preserve input names
  argsin = varargin{7};
  args = {};
  in_names = {};
  for kk=1:numel(argsin)
    if isa(argsin{kk}, 'ao')
      args = [args argsin(kk)];
      in_names = [in_names varnames(kk)];
    elseif isnumeric(argsin{kk})
      % When promoting the number to an AO, we have to be sure to call
      % the fromVals and allow it to add history.
      a = fromVals(ao, plist('vals', argsin{kk}), 0);
      args = [args {a}];
      if all(size(argsin{kk}) == [1 1])
        in_names = [in_names num2str(argsin{kk})];
      elseif any(size(argsin{kk}) == [1 1])
        in_names = [in_names 'vector'];
      else
        in_names = [in_names 'matrix'];
      end
    end
  end
  
  if numel(args) < 2
    error('### %s operator requires at least two AO inputs.', opname)
  end
  
  if numel(args) == 2
    
    % get the two arrays
    a1 = args{1};
    a2 = args{2};
    
    % check the data
    for kk=1:numel(a1)
      if ~isa(a1(kk).data, 'ltpda_data')
        error('### one of the input AOs has an empty data field');
      end
    end
    for kk=1:numel(a2)
      if ~isa(a2(kk).data, 'ltpda_data')
        error('### one of the input AOs has an empty data field');
      end
    end
    
    % Here we operate on two AO arrays according to the rules
    
    %---------- Deal with error cases first
    r1 = size(a1,1);
    c1 = size(a1,2);
    r2 = size(a2,1);
    c2 = size(a2,2);
    
    %== Rule 4: [1xN] */ [Nx1]
    if r1 == 1 && r2 == 1 && c1==c2 && c1>1
      error('### It is not possible to %s two AO vectors of size [1xN]', opname);
    end
    
    %== Rule 6: [Nx1] */ [Nx1]
    if r1 == r2 && c1==1 && c2==1 && r1>1
      error('### It is not possible to %s two AO vectors of the size [Nx1]', opname);
    end
    
    %== Rule 7: [NxP] */ [Nx1]
    if r1 == r2 && c1>1 && c2==1 && c1~=r1 && r1>1
      error('### It is not possible to %s [NxP] and [Nx1]', opname);
    end
    
    %== Rule 8: [NxP] */ [Px1]
    if c1 == c2 && r1>1 && r2==1 && c1>1
      error('### It is not possible to %s [NxP] and [1xP]', opname);
    end
    
    %== Rule 9: [NxP] */ [NxP]
    if isequal(size(a1), size(a2)) && r1>1 && c1>1
      if size(a1,1) ~= size(a1,2)
        error('### It is not possible to %s [NxP] and [NxP]', opname);
      end
    end
    
    
    %------------- Now perform operation
    if numel(a1)==1 || numel(a2)==1
      
      % Rules 1,2,5
      if isvector(a1) || isvector(a2) || ismatrix(a1) || ismatrix(a2)
        % Rule 2,5: vector or matrix + single AO
        if isvector(a1) || ismatrix(a1)
          res = copy(a1,1);
          for ee=1:numel(res)
            res(ee).data = compatibleData(res(ee),a2);
            res(ee).data.setY(operate(a1(ee), a2));
            res(ee).data.setDy(operateError(a1(ee), a2));
            % set history and name
            if ~callerIsMethod
              names = getNames(in_names, res(ee), ee, a2, []);
              res(ee).addHistory(iobj, pl, names(1:2), [res(ee).hist a2.hist]);
              res(ee).name = names{3};
            end
            res(ee).data.setYunits(getYunits(a1(ee), a2));
          end
        else
          res = copy(a2,1);
          for ee=1:numel(res)
            res(ee).data = compatibleData(res(ee),a1);
            res(ee).data.setY(operate(a2(ee), a1));
            res(ee).data.setDy(operateError(a2(ee), a1));
            % set history and name
            if ~callerIsMethod
              names = getNames(in_names, a1, [], res(ee), ee);
              res(ee).addHistory(iobj, pl, names(1:2), [a1.hist res(ee).hist]);
              res(ee).name = names{3};
            end
            res(ee).data.setYunits(getYunits(a1, a2(ee)));
          end
        end
      else
        % Rule 1: [1x1] */ [1x1]
        res = copy(a1,1);
        res.data = compatibleData(res,a2);
        res.data.setY(operate(a1, a2));
        res.data.setDy(operateError(a1, a2));
        % set history and name
        if ~callerIsMethod
          names = getNames(in_names, res, [], a2, []);
          res.addHistory(iobj, pl, names(1:2), [res.hist a2.hist]);
          res.name = names{3};
        end
        res.data.setYunits(getYunits(a1, a2));
      end
    elseif isvector(a1) && isvector(a2) && r1==1 && c2==1 && r2==c1
      % Rule 3: [1xN] */ [Nx1]
      if strcmp(op, 'mrdivide')
        error('### It is not possible to divide two matrices with different sizes');
      end
      res = [];
      if strcmp(op, 'mtimes')
        inner = 'times';
      else
        inner = 'rdivide';
      end
      
      for ee=1:numel(a1)
        if isempty(res)
          res = feval(inner,a1(ee),a2(ee));
        else
          res = res + feval(inner,a1(ee),a2(ee));
        end
      end
    elseif isvector(a1) && isvector(a2) && r1>1 && c1==1 && r2==1 && c2>1
      % Rule 5: [Nx1] */ [1xM]
      res(r1,c2) = ao();
      for kk=1:r1
        for ll=1:c2
          res(kk,ll) = feval(op,a1(kk),a2(ll));
        end
      end
    elseif ismatrix(a1) && (ismatrix(a2) || isvector(a2))
      if strcmp(op, 'mrdivide') && ~isequal(size(a1),size(a2))
        error('### Can only divide matrices of the same size');
      end
      % Rule 10: matrix */ matrix
      res(r1,c2) = ao;
      for kk=1:r1
        for ll=1:c2
          res(kk,ll) = feval(op,a1(kk,:),a2(:,ll));
        end
      end
    else
      error('### The inputs were not properly handled. This shouldn''t happen.');
    end
    
    % Did something go wrong?
    if isempty(res)
      error('### The inputs were not properly handled. This shouldn''t happen.');
    end
    
  else
    % we recursively pass back to this method
    res = copy(args{1}, 1);
    for kk=2:numel(args)
      res = feval(op, res, args{kk});
    end
  end
  
  % Set output
  varargout{1} = res;
  
  %---------- nested functions
  
  %-------------------------------------------------
  % Check the two inputs have compatible data types
  function dout = compatibleData(a1,a2)
    %== Data types
    if (isa(a1.data, 'fsdata') && isa(a2.data, 'tsdata')) || ...
        isa(a2.data, 'fsdata') && isa(a1.data, 'tsdata')
      error('### Can not %s time-series data to frequency-series data.', opname);
    end
    % check X units for all data types
    if ~isa(a1.data, 'cdata') && ~isa(a2.data, 'cdata')
      if ~isempty(a1.data.xunits.strs) && ~isempty(a2.data.xunits.strs)
        if ~isequal(a1.data.xunits, a2.data.xunits)
          error('### X units should be equal for the %s operator', op);
        end
      end
    end
    
    % determine output data type
    d1 = copy(a1.data,1);
    d2 = copy(a2.data,1);
    
    if isa(d1, 'data2D') && isa(d2, 'data2D')
      if numel(d1.y) > 1
        dout = d1;
      elseif numel(d2.y) > 1
        dout = d2;
      else
        dout = d1;
      end
    elseif isa(d1, 'data2D') && isa(d2, 'cdata')
      dout = d1;
    elseif isa(d1, 'cdata') && isa(d2, 'data2D')
      dout = d2;
    else
      dout = d1;
    end
    
  end
  
  function uo = getYunits(a1, a2)
    % For other operators we need to apply the operator
    uo = feval(op, a1.data.yunits, a2.data.yunits);
  end
  
  % Perform the desired operation on the data
  function y = operate(a1, a2)
    y = feval(op, a1.data.y, a2.data.y);
  end
  
  % Perform the desired operation on the data uncertainty
  function dy = operateError(a1, a2)
    
    if ~isempty(a1.dy) || ~isempty(a2.dy)
      
      da1 = a1.dy;
      da2 = a2.dy;
      
      if isempty(da1)
        da1 = zeros(size(a1.y));
      end
      if isempty(da2)
        da2 = zeros(size(a2.y));
      end
      
      switch op
        case {'plus', 'minus'}
          dy = sqrt(da1.^2 + da2.^2);
        case {'times', 'mtimes'}
          dy = sqrt( (da1./a1.y).^2 + (da2./a2.y).^2 ) .* abs(a1.y.*a2.y);
        case {'rdivide', 'mrdivide'}
          dy = sqrt( (da1./a1.y).^2 + (da2./a2.y).^2 ) .* abs(a1.y./a2.y);
        otherwise
          dy = [];
      end
      
    else
      dy = [];
    end
    
  end
  
  %-----------------------------------------------
  % Get two new AO names from the input var names,
  % the input AO names, and the indices.
  function names = getNames(in_names, a1, jj, a2, kk)
    
    % First variable name
    if isempty(a1.name)  && ~isempty(in_names{1})
      if ~isempty(jj)
        if numel(jj) == 1
          names{1} = sprintf('%s(%d)', in_names{1}, jj);
        else
          names{1} = sprintf('%s(%d,%d)', in_names{1}, jj(1), jj(2));
        end
      else
        names{1} = in_names{1};
      end
    else
      if ~isempty(jj)
        if numel(jj) == 1
          %           names{1} = sprintf('%s(%d)', a1.name, jj);
          names{1} = sprintf('%s', a1.name);
        else
          %           names{1} = sprintf('%s(%d,%d)', a1.name, jj(1), jj(2));
          names{1} = sprintf('%s', a1.name);
        end
      else
        names{1} = a1.name;
      end
    end
    % Second variable name
    if isempty(a2.name) && ~isempty(in_names{2})
      if isempty(in_names{2})
        in_names{2} = a2.name;
      end
      if ~isempty(kk)
        if numel(kk) == 1
          names{2} = sprintf('%s(%d)', in_names{2}, kk);
        else
          names{1} = sprintf('%s(%d,%d)', in_names{2}, kk(1), kk(2));
        end
      else
        names{2} = in_names{2};
      end
    else
      names{2} = a2.name;
      if ~isempty(kk)
        if numel(kk) == 1
          %           names{2} = sprintf('%s(%d)', a2.name, kk);
          names{2} = sprintf('%s', a2.name);
        else
          %           names{2} = sprintf('%s(%d,%d)', a2.name, kk(1), kk(2));
          names{2} = sprintf('%s', a2.name);
        end
      else
        names{2} = a2.name;
      end
    end
    
    % The output AO name
    names{3} = sprintf('(%s%s%s)', names{1}, opsym, names{2});
  end
  
  %-------------------------------------
  % Return true if the input is a matrix
  function r = ismatrix(a)
    if nrows(a) > 1 && ncols(a) > 1
      r = true;
    else
      r = false;
    end
  end
  
  %-------------------------------------
  % Return true if the input is a vector
  function r = isvector(a)
    if (nrows(a)==1 && ncols(a)>1) || (ncols(a)==1 && nrows(a)>1)
      r = true;
    else
      r = false;
    end
  end
  
  %-------------------------------------
  % Return numnber of rows in the array
  function r = nrows(a)
    r = size(a,1);
  end
  
  %-------------------------------------
  % Return numnber of cols in the array
  function r = ncols(a)
    r = size(a,2);
  end
  
  
end % End of add



% END
