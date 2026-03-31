% CROSS implements cross operator for matrix objects.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: CROSS implements cross operator for matrix objects.
%
% CALL:        obj = cross(obj1,obj2);
%
%
% <a href="matlab:utils.helper.displayMethodInfo('matrix', 'cross')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = cross(varargin)
  
  callerIsMethod = utils.helper.callerIsMethod;
  
  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  % make sure we have a place for output
  if nargout == 0
    error('### Cross operator can not be used as a modifier.');
  end
  
  % make sure we have two inputs
  if nargin ~= 2
    error('### Cross product is a binary operator requiring two and only two input objects');
  end
  
  % Input variable names
  in_names = cell(2,1);
  
  % collect input 1 and check type and size
  mat1 = varargin{1};
  if ~isa(mat1,'matrix')
    error('### Cross product requires inputs of type matrix');
  end
  in_names{1} = mat1.name;
  if isempty(in_names{1})
    in_names{1} = inputname(1);
  end
  
  % one of the dimensions had better be 3
  size1 = mat1.osize();
  if ~any(size1==3)
    error('### Inputs to cross product must be Nx3');
  end
  % transpose if necessary
  if size1(2)~=3
    mat1 = transpose(mat1);
  end
  
  % collect input 2 and check type and size
  mat2 = varargin{2};
  if ~isa(mat2,'matrix')
    error('### Cross product requires inputs of type matrix');
  end
  in_names{2} = mat2.name;
  if isempty(in_names{2})
    in_names{2} = inputname(2);
  end
  size2 = mat2.osize();
  if ~any(size2==3)
    error('### Inputs to cross product must be Nx3');
  end
  % transpose if necessary
  if size2(2)~=3
    mat2 = transpose(mat2);
  end
  % size should match mat1
  if size(mat2,1)~=size(mat1,1)
    error('### Inputs to cross product must both be Nx3');
  end
  
  objs1 = toArray(mat1);
  objs2 = toArray(mat2);
  N = size(objs1,1);
  
  for ii = 1:N
    
    % apply cross product
    outObjs(ii,1) = objs1(ii,2).*objs2(ii,3)-objs1(ii,3).*objs2(ii,2);
    outObjs(ii,2) = objs1(ii,3).*objs2(ii,1)-objs1(ii,1).*objs2(ii,3);
    outObjs(ii,3) = objs1(ii,1).*objs2(ii,2)-objs1(ii,2).*objs2(ii,1);
    
    outObjs(ii,1).simplifyYunits();
    outObjs(ii,2).simplifyYunits();
    outObjs(ii,3).simplifyYunits();
    
    % set names
    outObjs(ii,1).setName(sprintf('cross(%s,%s)',in_names{1},in_names{2}));
    outObjs(ii,2).setName(sprintf('cross(%s,%s)',in_names{1},in_names{2}));
    outObjs(ii,3).setName(sprintf('cross(%s,%s)',in_names{1},in_names{2}));
    
  end
  
  % generate matrix output
  out = matrix(outObjs);
  out.setName(sprintf('cross(%s,%s)',in_names{1},in_names{2}));
  
  % add history
  if ~callerIsMethod
    out.addHistory(getInfo('None'), [], {inputname(1), inputname(2)}, [mat1.hist mat2.hist]);
  end
  
  
  varargout{1} = out;
  
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