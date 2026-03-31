% SUM adds all the elements of smodel objects arrays.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: SUM adds all the elements of smodel objects arrays.
%
% CALL:        obj = sum(mdl_mat)
%              obj = mdl_mat.sum()
%              obj = sum(mdl_mat, dim)              % Not yet implemented!
%              obj = mdl_mat.sum(plist('dim', dim)) % Not yet implemented!
%
% <a href="matlab:utils.helper.displayMethodInfo('smodel', 'sum')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function out = sum(varargin)
  
  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    out = getInfo(varargin{3});
    return
  end
  
  if nargout == 0
    error('### sum cannot be used as a modifier. Please give an output variable.');
  end
  
  % Collect input variable names
  in_names = cell(size(varargin));
  for ii = 1:nargin
    in_names{ii} = inputname(ii);
  end
  
  % Collect all smodels and plists
  [as, smodel_invars, rest] = utils.helper.collect_objects(varargin(:), 'smodel', in_names);
  [pl, pl_invars, rest]         = utils.helper.collect_objects(varargin(:), 'plist', in_names);
  
  % Combine plists
  usepl = applyDefaults(getDefaultPlist(), pl);
  
  % Check the model parameters
  for jj = 1:numel(as)
    for kk = 1:jj
      if ~strcmp(as(kk).xvar, as(jj).xvar)
        warning('### Two of the models have different X variables. Taking the first');
      end
      if ~isequal(as(kk).xvals, as(jj).xvals)
        warning('### Two of the models have different X data. Taking the first');
      end
    end
  end
  
  % Copy the object
  out = copy(as(1), 1);
  expression = ['(' as(1).expr.s ')'];
  name = ['(' as(1).name ')'];
  
  for jj = 2:numel(as)
    expression = [expression ' + (' as(jj).expr.s ')'];
    name = [name ' + (' as(jj).name ')'];
    out.params = [out.params as(jj).params];
    out.values = [out.values as(jj).values];
  end
  
  out.expr = msym(expression);
  out.name = name;
  
  % The flag 'first' is since R2012b a legacy option. But we still support
  % R2011a. That's the reason why we don't use the option 'stable'.
  [out.params,ii,jj] = unique(out.params, 'first');
  out.values = out.values(ii);
  
  if ~isequal(ii,jj)
    warning('Some parameters were not unique. Parameters from the first model were taken.');
  end
  
  % Add history
  out.addHistory(getInfo('None'), usepl, {inputname(1)}, [as(:).hist]);
  
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
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.op, '', sets, pls);
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
  pl = plist('dim', []);
end
