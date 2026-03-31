% FILTER implements N-dim filter operator for matrix objects.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: FILTER implements N-dim filter operator for matrix objects.
%
% CALL:        output = filter(input,filt);
%
% <a href="matlab:utils.helper.displayMethodInfo('matrix', 'filter')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = filter(varargin)
  
  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  if nargout == 0
    error('### Matrix filter operator can not be used as a modifier.');
  end
  
  % Collect input variable names
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
  
  mat1 = varargin{2}; % matrix filter
  mat2 = varargin{1}; % input matrix of data
    
  % check we do have the right objects
  if (any(~isa(mat1.objs,'ltpda_filter')) ||  any(~isa(mat1.objs,'filterbank'))) && any(~isa(mat2.objs,'ao')) 
    error('### Second matrix objects must be ltpda_filter and first matrix objects must be ao');
  end
  
  [rw1,cl1] = size(mat1.objs);
  [rw2,cl2] = size(mat2.objs);
  
  % Check input model dimensions
  if ((rw1 == 1) && (rw2 == 1) && (cl1 == 1) && (cl2 == 1))
    ids = '1D';
  else
    if (cl1 ~= rw2)
      error('!!! Matrices inner dimensions must agree')
    else
      ids = 'ND';
    end
  end
  
  switch ids
    case '1D'
      % init output
      mat = copy(mat2,1);
      
      mat.objs = filter(mat2.objs, mat1.objs);
      mat.addHistory(getInfo('None'), [], {inputname(1), inputname(2)}, [mat1.hist mat2.hist]);
      
    case 'ND'
      % init output
      estr = sprintf('nobjs(%s,%s) = %s;',num2str(rw1),num2str(cl2),class(mat2.objs(1)));
      eval(estr)
      mat = matrix(nobjs,plist('shape',[rw1,cl2]));
      
      % do row by colum product
      for kk = 1:rw1
        for jj = 1:cl2
          % fix the first element of the sum
          try % try to do filter
            tobj = filter(mat2.objs(1,jj),mat1.objs(kk,1));
          catch ME % if input ao is empty filter output an error and tobj is set to zero
            tobj = [];
          end
          for zz = 2:cl1
            try % try to do filter
              if isempty(tobj)
                tobj = filter(mat2.objs(zz,jj),mat1.objs(kk,zz));
              else
                tobj = tobj + filter(mat2.objs(zz,jj),mat1.objs(kk,zz));
              end
            catch ME % if input ao is empty filter output an error and tobj is added to zero
%               tobj = tobj + 0;
            end
          end
          % simplify y units
          tobj_yu = tobj.yunits;
          tobj_yu.simplify;
          tobj.setYunits(tobj_yu);
          % simplify x units
          if ~isempty(tobj.xunits)
            tobj_xu = tobj.xunits;
            tobj_xu.simplify;
            tobj.setXunits(tobj_xu);
          end
          mat.objs(kk,jj) = tobj;
        end
      end
      mat(:).addHistory(getInfo('None'), [], {inputname(1), inputname(2)}, [mat1(:).hist mat2(:).hist]);
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
