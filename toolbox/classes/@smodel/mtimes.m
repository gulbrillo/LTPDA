% MTIMES implements mtimes operator for smodel objects.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: MTIMES implements mtimes operator for smodel objects.
%
% CALL:        obj = obj1 * obj2
%              obj = mtimes(obj1,obj2);
%
% <a href="matlab:utils.helper.displayMethodInfo('smodel', 'mtimes')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function mdl = mtimes(varargin)
  
  callerIsMethod = utils.helper.callerIsMethod;
  
  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    mdl = getInfo(varargin{3});
    return
  end
  
  if nargout == 0
    error('### Matrix multiplication operator can not be used as a modifier.');
  end
  
  mdl1 = varargin{1};
  mdl2 = varargin{2};
  
  % Convert numbers into a smodel object
  if isnumeric(mdl1)
    mdl1 = smodel(mdl1);
  end
  if isnumeric(mdl2)
    mdl2 = smodel(mdl2);
  end
  
  %----------------- Gather the input objects names and history
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
  
  % Convert cdata aos into a smodel object
  if isa(mdl2, 'ao')
    if isa(mdl2.data, 'cdata') && numel(mdl2.data.y) == 1
      mdl2 = smodel(mdl2.y);
    else
      error('### It is not possible to multiply the two objects!');
    end
  end
  
  [rw1,cl1] = size(mdl1);
  [rw2,cl2] = size(mdl2);
  
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
      
      mdl = copy(mdl1, true);
      mdl.expr = msym(['(' mdl.expr.s ')*(' mdl2.expr.s ')']);
      mdl.name = ['(' mdl.name ')*(' mdl2.name ')'];

      smodel.mergeFields(mdl1, mdl2, mdl, 'params', 'values');
      smodel.mergeFields(mdl1, mdl2, mdl, 'aliasNames', 'aliasValues');
      smodel.mergeFields(mdl1, mdl2, mdl, 'xvar', 'xvals');
      smodel.mergeFields(mdl1, mdl2, mdl, 'xvar', 'xunits');
      smodel.mergeFields(mdl1, mdl2, mdl, 'xvar', 'trans');
      
      if ~callerIsMethod
        mdl.addHistory(getInfo('None'), [], in_names, [mdl1.hist mdl2.hist]);
      end
      
    case 'ND'
      % some consistence checks
      if ~all(strcmp({mdl2(:).xvar}, mdl1(1).xvar))
        warning('### The models have different X variables. Taking the first');
      end
      if ~all(cellfun(@(x)isequal(x, mdl1(1).xvals),{mdl2(:).xvals}))
        warning('### The models have different X data. Taking the first');
      end
      
      % init output
      mdl = smodel.newarray([rw1 cl2]);
      % init expression strins array
      tmst = cell(rw1,cl2);
      % do raw by colum product
      for kk = 1:rw1
        for jj = 1:cl2
          tmst{kk,jj} = ['(' mdl1(kk,1).expr.s ').*(' mdl2(1,jj).expr.s ')'];
          mdl(kk,jj).params = [mdl1(kk,1).params mdl2(1,jj).params];
          mdl(kk,jj).values = [mdl1(kk,1).values mdl2(1,jj).values];
          unt = simplify(unit(mdl1(kk,1).yunits).*unit(mdl2(1,jj).yunits));
          for rr = 2:cl1
            tmst{kk,jj} = ['(' tmst{kk,jj} ')+(' '(' mdl1(kk,rr).expr.s ').*(' mdl2(rr,jj).expr.s ')' ')'];
            mdl(kk,jj).params = [mdl(kk,jj).params mdl1(kk,rr).params mdl2(rr,jj).params];
            mdl(kk,jj).values = [mdl(kk,jj).values mdl1(kk,rr).values mdl2(rr,jj).values];
            % check on yunits
            unt2 = simplify(unit(mdl1(kk,rr).yunits).*unit(mdl2(rr,jj).yunits));
            if ~isequal(unt, unt2)
              error('!!! Units for the elements of %s*%s[%d,%d] must be the same',in_names{1},in_names{2},kk,jj);
            end
          end
          mdl(kk,jj).expr = msym(tmst{kk,jj});
          mdl(kk,jj).name = ['(' in_names{1} '*' in_names{2} ')[' num2str(kk) ',' num2str(jj) ']'];
          [mdl(kk,jj).params,i,j] = unique(mdl(kk,jj).params, 'first');
          mdl(kk,jj).values = mdl(kk,jj).values(i);
          mdl(kk,jj).xvar = mdl1(kk,1).xvar;
          mdl(kk,jj).xvals = mdl1(kk,1).xvals;
          mdl(kk,jj).xunits = mdl1(kk,1).xunits;
          mdl(kk,jj).yunits = unt;
        end
      end
      
      if ~callerIsMethod
        mdl(:).addHistory(getInfo('None'), [], in_names, [mdl1.hist, mdl2.hist]);
      end
      
  end
  
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               Local Functions                               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------
% Get Info Object
%--------------------------------------------------------------------------
function ii = getInfo(varargin)
  
  if nargin == 1 && strcmpi(varargin{1}, 'None')
    sets = {};
    pl   = [];
  else
    sets = {'Default'};
    pl   = getDefaultPlist();
  end
  % Build info object
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.aop, '', sets, pl);
  ii.setArgsmin(2);
  ii.setModifier(false);
end

%--------------------------------------------------------------------------
% Get Default Plist
%--------------------------------------------------------------------------
function plout = getDefaultPlist()
  persistent pl;  
  if ~exist('pl', 'var') || isempty(pl)
    pl = buildplist();
  end
  plout = pl;  
end

function pl = buildplist()
  pl = plist.EMPTY_PLIST;
end
