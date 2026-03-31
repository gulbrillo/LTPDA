% LINEARIZE output the derivatives of the model relative to the parameters.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: LINEARIZE output the derivatives of the model relative to
% the parameters. Output is a collection of models corresponding to the
% derivative of input model for each parameter
%
% CALL:        dmod = linearize(imod)
%
% <a href="matlab:utils.helper.displayMethodInfo('matrix', 'linearize')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varargout = linearize(varargin)

  % utils.helper.msg(msg.PROC3, 'running %s/%s', mfilename('class'), mfilename);

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
  [as, matrix_invars, rest] = utils.helper.collect_objects(varargin(:), 'matrix', in_names);
  [pl, pl_invars, rest]     = utils.helper.collect_objects(rest(:), 'plist', in_names);

  % Merge with default plist
  pl = applyDefaults(getDefaultPlist, pl);

  % get parameters and make sure we are working with a cell array
  pnames = find_core(pl,'Params');
  if isa(pnames, 'char')
    pnames = {pnames};
  end
  
  % decide if sorting
  sorting = find_core(pl,'Sorting');
  if sorting
    pnames = sort(pnames);
  end

  % loop over input matrices
  %dmod(numel(as),1)=collection;
  dmod = collection.initObjectWithSize(numel(as),1);
  for ww=1:numel(as)
    imod=as(ww);
    if strcmpi(class(imod.objs(1)),'smodel')
      % a matrix of smodels is assumed
      % join params
      
      if isempty(pnames) % linearize with respect to all model parameters
        % store a common set of parameters for mod, it is needed for
        % the derivative
        [rw,cl] = size(imod.objs);
        % loop over dimensions
        mpars = {};
        mvals = {};
        for aa = 1:rw
          for bb = 1:cl
            obj = imod.objs(aa,bb);
            [mpars,id1,id2] = union(mpars,obj.params);
            nom1 = mvals(id1);
            nom2 = obj.values(id2);
            mvals = [nom1 nom2];
          end
        end
        for ff = 1:numel(imod.objs)
          imod.objs(ff).setParams(mpars,mvals);
        end

        % it is assumed a common set of parameters for the matrix object
        pnames = imod.objs(1).params;
      end %isempty(pnames)

      % get matrix dimension
      [rw,cl] = size(imod.objs);

      % start linearization
      for ii = 1:numel(pnames)
        tmod = copy(imod,1);
        for jj = 1:rw
          for kk = 1:cl
            tmod.objs(jj,kk) = diff(imod.objs(jj,kk),pnames{ii}); % do symbolic derivative for smodel
            tmod.objs(jj,kk).setName(sprintf('d{%s}/d{%s}',imod.objs(jj,kk).name,pnames{ii}));
          end
        end
        % set the name of the parameter to the matrix, this is important to
        % identify automatically to what derivatives we are referring
        tmod.setName(pnames{ii});
        %       dmod.addObjects(tmod);
        dmod(ww).addObjects(tmod);
      end
      dmod(ww).setName(sprintf('linearize(%s)',imod.name));
    else
      error('Only matrix of smodels supported at the moment')
    end %strcmpi(class(imod.objs(1)),'smodel')

  end

  if nargout == 1
    varargout{1} = dmod;
  elseif nargout == numel(as)
    % List of outputs
    for ii = 1:numel(as)
      varargout{ii} = dmod.index(ii);
    end
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
  
  p = param({'Params', ['Cell array with parameters names with respect to linearize. <br>' ...
    'Leave it empty to linearize with respect to all model parameters']}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
  p = param({'Sorting', ' Decide to sort the lits of input parameters'}, paramValue.TRUE_FALSE);
  pl.append(p);

end
