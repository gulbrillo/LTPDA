% MTIMES implements mtimes operator for matrix objects.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: MTIMES implements mtimes operator for matrix objects.
%
% CALL:        obj = obj1 * obj2
%              obj = mtimes(obj1,obj2);
%              obj = mtimes(obj1,obj2,obj3) == mtimes(add(obj1,obj2),obj3)
%
% <a href="matlab:utils.helper.displayMethodInfo('matrix', 'mtimes')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = mtimes(varargin)
  
  callerIsMethod = utils.helper.callerIsMethod;
  
  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  if nargout == 0
    error('### Matrix multiplication operator can not be used as a modifier.');
  end
  
  % Collect input variable names
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
  
  mat1 = varargin{1};
  mat2 = varargin{2};
  
  if isnumeric(mat1) || ischar(mat1)
    expr = mat1;
    varNames{1} = num2str(expr);
    % build a numeric/char object of the same size of mat2
    mat1 = copy(mat2,1);
    % check we do not have filters
    if any(isa(mat1.objs,'ltpda_filter'))
      error('### Undefined function or method %s for input arguments of type ltpda_filter',op);
    end
    for ii=1:numel(mat1.objs)
      mat1.objs(ii)=expr;
      mat1.objs(ii).setName(varNames{1});
      if ismethod(mat1.objs(ii), 'setXunits')
        mat1.objs(ii).setXunits(mat2.objs(ii).xunits);
      end
    end
  end
  if isnumeric(mat2) || ischar(mat2)
    expr = mat2;
    varNames{2} = num2str(expr);
    % build a numeric/char object of the same size of mat1
    mat2 = copy(mat1,1);
    % check we do not have filters
    if any(isa(mat2.objs,'ltpda_filter'))
      error('### Undefined function or method %s for input arguments of type ltpda_filter',op);
    end
    for ii=1:numel(mat2.objs)
      mat2.objs(ii)=expr;
      mat2.objs(ii).setName(varNames{2});
      if ismethod(mat2.objs(ii), 'setXunits')
        mat2.objs(ii).setXunits(mat1.objs(ii).xunits);
      end
    end
  end
  
  % init output
  mat = copy(mat1,1);
  
  % check we do not have filters
  if any(isa(mat1.objs,'ltpda_filter')) || any(isa(mat2.objs,'ltpda_filter')) 
    error('### Undefined function or method %s for input arguments of type ltpda_filter',op);
  end
  
  [rw1,cl1] = size(mat1.objs);
  [rw2,cl2] = size(mat2.objs);
  
  % Check input model dimensions
  if ((rw1 == 1) && (rw2 == 1) && (cl1 == 1) && (cl2 == 1))
    ids = '1D';
  elseif ((rw1 == 1) && (cl1 == 1))
    ids = 'scalar';
  else
    if (cl1 ~= rw2)
      error('!!! Matrices inner dimensions must agree')
    else
      ids = 'ND';
    end
  end
  
  switch ids
    case '1D'
      
      mat.objs = mat1.objs * mat2.objs;
      if ~callerIsMethod
        mat.addHistory(getInfo('None'), [], {inputname(1), inputname(2)}, [mat1.hist mat2.hist]);
      end    
    case 'scalar'
      % init output
      estr = sprintf('nobjs(%s,%s) = %s;',num2str(rw2),num2str(cl2),class(mat2.objs(1)));
      eval(estr)
      mat = matrix(nobjs,plist('shape',[rw2,cl2]));
            
      % do element by element product
      for kk = 1:rw2
        for jj = 1:cl2
          
          tobj = mat1.objs(1,1).*mat2.objs(kk,jj);
          % simplify y units
          tobj_yu = tobj.yunits;
          tobj_yu.simplify;
          tobj.setYunits(tobj_yu);
          if isa(tobj, 'data2D')
            % simplify x units
            if ~isempty(tobj.xunits)
              tobj_xu = tobj.xunits;
              tobj_xu.simplify;
              tobj.setXunits(tobj_xu);
            end
          end
          mat.objs(kk,jj) = tobj;
        end
      end
      if ~callerIsMethod
        mat(:).addHistory(getInfo('None'), [], {inputname(1), inputname(2)}, [mat1(:).hist mat2(:).hist]);
      end
      
    case 'ND'
      % init output
      estr = sprintf('nobjs(%s,%s) = %s;',num2str(rw1),num2str(cl2),class(mat1.objs(1)));
      eval(estr)
      mat = matrix(nobjs,plist('shape',[rw1,cl2]));
      
      % do row by colum product
      for kk = 1:rw1
        for jj = 1:cl2
          % fix the first element of the sum
          tobj = mat1.objs(kk,1).*mat2.objs(1,jj);
          for zz = 2:cl1
            tobj = tobj + mat1.objs(kk,zz).*mat2.objs(zz,jj);
          end
          % simplify y units
          tobj_yu = tobj.yunits;
          tobj_yu.simplify;
          tobj.setYunits(tobj_yu);
          if isa(tobj, 'data2D')
            % simplify x units
            if ~isempty(tobj.xunits)
              tobj_xu = tobj.xunits;
              tobj_xu.simplify;
              tobj.setXunits(tobj_xu);
            end
          end
          mat.objs(kk,jj) = tobj;
        end
      end
      if ~callerIsMethod
        mat(:).addHistory(getInfo('None'), [], {inputname(1), inputname(2)}, [mat1(:).hist mat2(:).hist]);
      end
  end
  
  varargout{1} = mat;
  
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
  ii.setArgsmin(2);
  ii.setModifier(false);
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
  if exist('pl', 'var')==0 || isempty(pl)
    pl = buildplist();
  end
  plout = pl;  
end

function pl = buildplist()
  pl = plist.EMPTY_PLIST;
end
