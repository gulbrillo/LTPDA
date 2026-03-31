% FFTFILT fft filter for matrix objects
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: FFTFILT fft filter for matrix objects
%
% CALL:        output = fftfilt(input,filter)
%
% <a href="matlab:utils.helper.displayMethodInfo('matrix', 'fftfilt')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varargout = fftfilt(varargin)
  
  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  % Collect input variable names
  in_names = cell(size(varargin));
  for ii = 1:nargin
    in_names{ii} = inputname(ii);
  end
  
  % Collect all smodels and plists
  % [as, matrix_invars, rest] = utils.helper.collect_objects(varargin(:), 'matrix', in_names);
  [pl, pl_invars, rest]     = utils.helper.collect_objects(varargin(:), 'plist', in_names);
  
  % Merge with default plist
  pl = applyDefaults(getDefaultPlist, pl);
  
  % separate data and filter matrices
  is = varargin{1};
  filt = varargin{2};
  
  [rw1,cl1] = size(filt.objs); % size filter
  [rw2,cl2] = size(is.objs); % size input signals
  % consistency check
  if (cl1 ~= rw2)
    error('!!! Matrices inner dimensions must agree')
  end
  
  % init output
  nobjs = feval(sprintf('%s.initObjectWithSize', class(is.objs(1))), rw1, cl2);
  os = matrix(nobjs,plist('shape',[rw1,cl2]));
  
  % get number of Bins for zero padding
  Npad = find_core(pl,'Npad');
  % do row by colum product
  for kk = 1:rw1
    for jj = 1:cl2
      % fix the first element of the sum
      try % try to do filter
        tobj = fftfilt_core(copy(is.objs(1,jj),1), copy(filt.objs(kk,1),1), Npad);
      catch ME %  if the input ao is empty, ao/filter output an error and tobj is set to []
        tobj = [];
      end
      for zz = 2:cl1
        try % try to do filter
          if isempty(tobj)
            tobj = fftfilt_core(copy(is.objs(zz,jj),1), copy(filt.objs(kk,zz),1), Npad);
          else
            tobj = tobj + fftfilt_core(copy(is.objs(zz,jj),1), copy(filt.objs(kk,zz),1), Npad);
          end
        catch ME %  if the input ao is empty, ao/filter output an error
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
      os.objs(kk,jj) = tobj;
    end
  end
  
  if nargout == 1
    varargout{1} = os;
  else
    error('Set at least one output value')
  end
  
end

%--------------------------------------------------------------------------
% Get Info Object
%--------------------------------------------------------------------------
function ii = getInfo(varargin)
  
  if nargin == 1 && strcmpi(varargin{1}, 'None')
    sets = {};
    pls  = [];
  else
    sets = {'Default'};
    pls  = getDefaultPlist;
  end
  % Build info object
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.op, '', sets, pls);
  ii.setModifier(false);
end

%--------------------------------------------------------------------------
% Get Default Plist
%--------------------------------------------------------------------------
function plout = getDefaultPlist()
  persistent pl;  
  if exist('pl', 'var')==0 || isempty(pl)
    pl = buildplist();
  end
  plout = pl;  
end

function pl = buildplist()
  pl = plist();
  
  % Number of bins for zero padding
  p = param({'Npad', 'Number of bins for zero padding.'}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
end
