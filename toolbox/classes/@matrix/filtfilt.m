% FILTFILT overrides the filtfilt function for matrices of analysis objects.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: FILTFILT overrides the filtfilt function for matrices of analysis objects.
%              Applies the input digital IIR filter to every analysis object contained in the input matrix
%              forwards and backwards. If the input analysis object contains a
%              time-series (tsdata) then the filter is applied using the normal
%              recursion algorithm. The output analysis object contains a tsdata
%              object.
%
%              If the input analysis object contains a frequency-series (fsdata)
%              then the response of the filter is computed and then multiplied
%              with the input frequency series. The output analysis object
%              contains a frequency series.
%
% CALL:        out = filtfilt(in, filt);
%
% INPUTS:      in      -  input matrix with AOs
%              filt    -  matrix with filter objects
%
% OUTPUTS:     out     -  output matrix objects
%
% <a href="matlab:utils.helper.displayMethodInfo('matrix', 'filtfilt')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = filtfilt(varargin)
  
  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  if nargout == 0
    error('### Matrix filtfilt method can not be used as a modifier.');
  end
  
  % Collect input variable names
  in_names = cell(size(varargin));
  for ii = 1:nargin
    in_names{ii} = inputname(ii);
  end
  
  % Collect inputs
  data_matrix   = varargin{1}; % input matrix of data
  filter_matrix = varargin{2}; % matrix filter
  % Supporting also a case where the user passes a single filter
  if ~isa(filter_matrix, 'matrix')
    filter_matrix = matrix(filter_matrix);
  end
  
  % check we do have the right objects
  if any(~isa(data_matrix.objs, 'ao'))
    error('### The objects in the first matrix must be ao');
  end
  if any(~isa(filter_matrix.objs, 'ltpda_filter')) || any(~isa(filter_matrix.objs, 'filterbank'))
    error('### The objects in the second matrix must be ltpda_filter');
  end
  
  [filter_matrix_rw, filter_matrix_cl] = size(filter_matrix.objs);
  [data_matrix_rw, data_matrix_cl] = size(data_matrix.objs);
  
  % Check input model dimensions
  if ((filter_matrix_rw == 1) && (data_matrix_rw == 1) && (filter_matrix_cl == 1) && (data_matrix_cl == 1))
    ids = '1D';
  else
    if (filter_matrix_cl ~= data_matrix_rw)
      error('!!! Matrices inner dimensions must agree')
    else
      ids = 'ND';
    end
  end
  
  switch ids
    case '1D'
      % init output
      mat = copy(data_matrix, 1);
      
      mat.objs = filtfilt(data_matrix.objs, filter_matrix.objs);
      mat.addHistory(getInfo('None'), [], {inputname(1), inputname(2)}, [filter_matrix.hist data_matrix.hist]);
      
    case 'ND'
      % init output
      estr = sprintf('nobjs(%s,%s) = %s;', num2str(filter_matrix_rw), num2str(data_matrix_cl), class(data_matrix.objs(1)));
      eval(estr)
      mat = matrix(nobjs, plist('shape', [filter_matrix_rw, data_matrix_cl]));
      
      % do row by colum product
      for kk = 1:filter_matrix_rw
        for jj = 1:data_matrix_cl
          % fix the first element of the sum
          try % try to do filter
            tobj = filtfilt(data_matrix.objs(1, jj), filter_matrix.objs(kk, 1));
          catch ME % if input ao is empty filter output an error and tobj is set to zero
            tobj = [];
          end
          for zz = 2:filter_matrix_cl
            try % try to do filter
              if isempty(tobj)
                tobj = filtfilt(data_matrix.objs(zz,jj), filter_matrix.objs(kk, zz));
              else
                tobj = tobj + filtfilt(data_matrix.objs(zz,jj), filter_matrix.objs(kk, zz));
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
      mat(:).addHistory(getInfo('None'), [], {inputname(1), inputname(2)}, [filter_matrix(:).hist data_matrix(:).hist]);
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
    ii = ao.getInfo(mfilename());
    sets = ii.sets;
    pls = [];
    for kk=1:numel(sets)
      pls = [pls getDefaultPlist(sets{kk})];
    end
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

%--------------------------------------------------------------------------
% Get Default Plist
%--------------------------------------------------------------------------
function plout = getDefaultPlist(set)
  persistent pl;
  persistent lastset;
  if ~exist('pl', 'var') || isempty(pl) || ~strcmp(lastset, set)
    pl = buildplist(set);
    lastset = set;
  end
  plout = pl;
end

function pl = buildplist(set)
  
  ii = ao.getInfo(mfilename(), set);
  pl = ii.plists(1);
  
end
