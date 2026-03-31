% EVAL evaluate a pest object
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: EVAL evaluate a pest model.
%
% CALL:        b = eval(p, pl)
%              b = eval(p, x, pl)
%              b = eval(p, x1, ... , xN, pl)
%              b = eval(p, [x1 ... xN], pl)
%
% INPUTS:      p  - input pest(s) containing parameter values.
%              xi - input ao(s) containing x values (as x or y fields, depending on the 'xfield' parameter)
%              pl - parameter list (see below)
%
% OUTPUTs:     b  - an AO containing the model evaluated at the given X
%                   values, with the given parameter values.
%
% <a href="matlab:utils.helper.displayMethodInfo('pest', 'eval')">Parameters Description</a>
%
% EXAMPLES:
%
% % 1)
% % Prepare the symbolic model
% mdl = smodel(plist('expression', 'a1.*x + a2.*x.^2 + a0', 'xvar', 'x', 'yunits', 'V'));
%
% % Prepare the pest object
%
% p = pest(plist('paramnames', {'a0','a1','a2'}, 'y', [1 2 3], 'models', mdl));
%
% % Evaluate the object
% a1 = eval(p, plist('xdata', ao([1:10])))
% a2 = eval(p, ao([1:10]))
%
% % 2)
% % Prepare the symbolic model
% mdl = smodel(plist('expression', 'a1.*x1 + a2.*x2 + a0', 'xvar', {'x1', 'x2'}, 'yunits', 'm', 'xunits', {'T', 'K'}));
%
% % Prepare the pest object
%
% p = pest(plist('paramnames', {'a0','a1','a2'}, 'y', [1 2 3], 'yunits', {'m', 'T/m', 'K/m'}, 'models', mdl));
%
% % Evaluate the object
% x1 = ao(plist('yvals', [1:10], 'fs', 1, 'yunits', 'T'));
% x2 = ao(plist('yvals', [1:10], 'fs', 1, 'yunits', 'K'));
% a1 = eval(p, plist('xdata', [x1 x2]))
% a2 = eval(p, [x1 x2])
% a3 = eval(p, x1, x2)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = eval(varargin)
  
  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  import utils.const.*
  utils.helper.msg(msg.PROC3, 'running %s/%s', mfilename('class'), mfilename);
  
  % Collect input variable names
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
  
  % Collect all AOs and plists
  [psts, pst_invars, rest] = utils.helper.collect_objects(varargin(:), 'pest', in_names);
  [pl, pl_invars, rest]   = utils.helper.collect_objects(rest, 'plist', in_names);
  [as, as_invars, rest]   = utils.helper.collect_objects(rest, 'ao', in_names);
  [c, c_invars]           = utils.helper.collect_objects(rest, 'cell', in_names);
  
  if nargout == 0
    error('### eval can not be used as a modifier method. Please give at least one output');
  end
  
  % combine plists
  pl = applyDefaults(getDefaultPlist(), pl);
  
  % Extract necessary parameters
  index     = find_core(pl, 'index');
  x = find_core(pl, 'Xdata');
  if ~isempty(as)
    x = as;
  end
  % I don't know how to deal with the history of a cell array of aos
  if ~isempty(c)
    error('Please pass the arguments in a vector or a list')
  end
  
  % Extract the information about the x field, if necessary
  xfield = pl.find_core('xfield');
  switch xfield
    case 'x'
      op = str2func('x');
    case 'y'
      op = str2func('y');
    otherwise
      error('oops')
  end
  
  % Extract the xvals for the smodel, and the output x for the ao
  switch class(x)
    case 'cell'
      switch class(x{1})
        case 'ao'
          data_type = find_core(pl, 'type');
          if isempty(data_type)
            % Nothing to do, output data type will be inherited from the first AO
            if ~isa(x{1}.data, 'cdata')
              out_x      = x{1};
            else
              out_x      = [];
            end
            out_xunits = '';
          else
            % In this case I have to extract the vector with the output x and xunits
            out_x = feval(op, x{1});
            out_xunits = feval(str2func([xfield 'units']), x{1});
          end
        case 'double'
          data_type = find_core(pl, 'type');
          xvals = x;
          switch data_type
            case {'tsdata', 'fsdata', 'xydata'}
              out_x      = x;
              out_xunits = find_core(pl, 'xunits');
            case {'cdata', ''}
              out_x      = [];
              out_xunits = '';
            otherwise
              error('LTPDA error')
          end
        otherwise
      end
    case 'ao'
      data_type = find_core(pl, 'type');
      if isempty(data_type)
        % Nothing to do, output data type will be inherited from the first AO
        if ~isa(x(1).data, 'cdata')
          out_x      = x(1);
        else
          out_x      = [];
        end
        out_xunits = '';
      else
        % In this case I have to extract the vector with the output x and xunits
        out_x = feval(op, x(1));
        out_xunits = feval(str2func([xfield 'units']), x(1));
      end
    case 'double'
      data_type = find_core(pl, 'type');
      xvals = x;
      switch data_type
        case {'tsdata', 'fsdata', 'xydata'}
          out_x      = x;
        case {'cdata', ''}
          out_x      = [];
        otherwise
          error('LTPDA error')
      end
      out_xunits = find_core(pl, 'xunits');
    otherwise
  end
  
  % If the user wants to override the pest/smodel yunits, let's get them
  % This works only if the user sets them to something not empty
  yunits = find_core(pl, 'yunits');
  
  % If we have AOs in a cell....
  if iscell(x) && all(cellfun(@(x)isa(x, 'ao'), x))
    % if we have multiple x, we need to convert the y values into a cell array
    xvals = cellfun(op, x, 'UniformOutput', false);
  elseif isa(x, 'ao')
    % we put the y values in to a cell array
    if numel(x) > 1
      xvals = cellfun(op, num2cell(x), 'UniformOutput', false);
    else
      % ... we take the x values, as per the help
      xvals = feval(op, x);
    end
  end
  
  % Loop over input objects
  for jj = 1:numel(psts)
    
    pst = psts(jj);
    % evaluate models
    m = copy(pst.models, true);
    switch class(m)
      case 'smodel'
        % Make sure the smodel parameters are named the same as the pest
        m(index).setParams(pst.names, pst.y);
        % If the user provided the x vector(s), override the smodel x with these
        if ~isempty(xvals)
          m(index).setXvals(xvals);
        end
        % Go for the model evaluation
        out(jj) = eval(m(index), plist(...
          'output type', data_type, 'output x', out_x, 'output xunits', out_xunits));

        % Setting the units of the evaluated model
        if ~isempty(yunits)
          out(jj).setYunits(yunits);
        end
        
      case 'ao'
        % do linear combination: using lincom
        out(jj) = lincom(m, pst);
        out(jj).simplifyYunits;
        
  
      case 'matrix'
        % check objects of the matrix and switch
        switch class(m(1).objs)
          case 'smodel'
            % Make sure the smodel parameters are named the same as the pest
            for ii = 1:numel(m.objs)
              m.objs(ii).setParams(pst.names, pst.y);
            end
            % If the user provided the x vector(s), override the smodel x with these
            if ~isempty(x)
              for ii = 1:numel(m.objs)
                m.objs(ii).setXvals(x);
              end
            end
            % Go for the model evaluation
            tout = ao.initObjectWithSize(size(m.objs,1),size(m.objs,2));
            for ii=1:size(m.objs,1)
              for kk=1:size(m.objs,2)
                tout(ii,kk) = eval(m.objs(ii,kk), plist(...
                  'output type', data_type, 'output x', out_x));
                % Setting the units of the evaluated model
                if ~isempty(yunits)
                  tout(ii,kk).setYunits(yunits);
                end
              end
            end
            out(jj) = matrix(tout);
          case 'ao'
            % get params from the pest object
            prms = pst.y;
            % build cdata aos
            prmsao = ao.initObjectWithSize(numel(prms),1);
            for ii = 1:numel(prms)
              prmsao(ii) = ao(cdata(prms(ii)));
              prmsao(ii).setYunits(pst.yunits(ii));
            end
            % build matrix for parameters
            prm = matrix(prmsao);
            % build matrix for the model
            mm = ao.initObjectWithSize(numel(m(1).objs),numel(prms));
            for ii = 1:numel(m(1).objs)
              for kk = 1:numel(prms)
                mm(ii,kk) = m(kk).getObjectAtIndex(ii);
              end
            end
            mmat = matrix(mm);
            % eval model
            tout = mmat*prm;
            out(jj) = tout;
        end
      otherwise
        error('### current version of pest/eval needs the ''models'' field to be a smodel')
    end
    
    
    
    % uncertainties for the evaluated model: calculate them from covariance matrix
    if ~isempty(pst.cov) && utils.prog.yes2true(pl.find_core('errors'));
      switch class(m)
        case 'smodel'
          C = pst.cov;
          p = pst.names;
          % here we need a matrix of "functions" which are the derivatives wrt parameters,
          % evaluated at each point x:

          F = [];
          for kk = 1:length(p)
            md = eval(diff(m(index), plist('var', p{kk})));
            F = [F md.y];
          end
          % The formula is:
          % D = F * C * F';
          % and then we need to take
          % dy = sqrt(diag(D))
          if size(md.y, 1) > 1 || numel(md.y) == 1
            % Make sure we work with columns
            out(jj).setDy(sqrt(sum((F * C)' .* F'))');
          else
            out(jj).setDy(sqrt(sum((F' * C)' .* F)));
          end
          
        otherwise
          warning('Propagation of the errors on the model not yet implemented')
      end
    end
    
    % Set output AO name
    name = sprintf('eval(%s,', pst.name);
    for kk = 2:numel(pst)
      name = [name pst(kk).name ','];
    end
    name = [name(1:end-1) ')'];
    out(jj).name = name;
    % Add history
    if isempty(as)
      out(jj).addHistory(getInfo('None'), pl, pst_invars, pst(:).hist);
    else
      out(jj).addHistory(getInfo('None'), pl, {pst_invars as_invars}, [pst(:).hist as(:).hist]);
    end
  end
  
  % Set output
  varargout = utils.helper.setoutputs(nargout, out);
  
end


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
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.sigproc, '', sets, pl);
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
  
  pl = plist();
  
  % INDEX
  p = param({'index', 'Select which model must be evaluated if more than one.'}, paramValue.DOUBLE_VALUE(1));
  pl.append(p);
  
  % XDATA
  p = param({'Xdata', ['The X values to evaluate the model at. This can be:<ul>'...
    '<li>a double vector </li>' ...
    '<li>a cell array of double vectors</li>' ...
    '<li>a single AO (from which the Y data will be extracted)</li>' ...
    '<li>a cell array of AOs (from which the Y data will be extracted)</li></ul>' ...
    ]}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
  % XFIELD
  p = param({'xfield', 'Choose the field to extract the x values from when inputting AOs for parameter ''xdata''.'},  {2, {'x', 'y'}, paramValue.SINGLE});
  pl.append(p);
  
  % TYPE
  pv = paramValue.DATA_TYPES;
  % Add an 'empty' on top of the list
  pv{2} = [{''} pv{2}];
  p = param({'type', ['Choose the data type for the output ao.<br>'...
    'If empty, and if the user input AOs as ''XDATA'', the type will be inherited.']},  pv);
  p.val.setValIndex(1);
  pl.append(p);
  
  % YUNITS
  p = param({'yunits','Unit on Y axis.'},  paramValue.STRING_VALUE(''));
  pl.append(p);
  
  % XUNITS
  p = param({'xunits','Unit on X axis.'},  paramValue.STRING_VALUE(''));
  pl.append(p);
  
  % ERRORS
  p = param({'errors', ['Estimate the uncertainty of the output values based <br>' ...
    'on the parameters covariance matrix']}, paramValue.TRUE_FALSE);
  pl.append(p);
  
end
% END
