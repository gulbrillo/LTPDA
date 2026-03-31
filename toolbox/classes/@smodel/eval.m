% EVAL evaluates the symbolic model and returns an AO containing the numeric data.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: EVAL evaluates the symbolic model and returns an AO
%              containing the numeric data.
%
% CALL:        mdl = eval(mdl)
%
% <a href="matlab:utils.helper.displayMethodInfo('smodel', 'eval')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = eval(varargin)
  
  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  % Collect input variable names
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
  
  % Collect all SMODELs
  [mdl, mdl_invars] = utils.helper.collect_objects(varargin(:), 'smodel', in_names);  
  
  if numel(mdl) ~= 1
    error('### eval can only evaluate one model at a time.');
  end
  
  % Apply defaults to plist
  pl = applyDefaults(getDefaultPlist(), varargin{:});  
  
  % Put together the plist to build the AO
  pl_ao = plist();
  
  % get the output Y values
  yout = mdl.double();
  
  % get the output X values
  xout = find_core(pl, 'output x');
  
  % Check the X axis properties (values, type, units)
  switch class(xout)
    case 'ao'
      % In this case, we just copy the object and change the values of the y field
      bs = copy(xout, true);
      % Set y values
      bs.setY(yout);
      % Clear the errors
      bs.setDy([]);
      % Set y units
      bs.setYunits(mdl.yunits);
      
    case 'double'
      if ~isempty(xout)
        % set the X values
        if numel(xout) ~= numel(yout)
          error('LTPDA:err:SizeMismatch', 'The ''y'' field of the destination object has different size than the input ''x'' values');
        end
        pl_ao.pset('xvals', xout);
        
        % set the output X units
        pl_ao.pset('xunits', find_core(pl, 'output xunits'));
        
        % output object data type
        data_type = find_core(pl, 'output type');
        if isempty(data_type)
          data_type = 'cdata';
        end
        pl_ao.pset('type', data_type);
        
        switch data_type
          case 'tsdata'
            % set T0
            pl_ao.pset('t0', find_core(pl, 't0'));
          case {'fsdata', 'xydata'}
            % nothing to do
          case 'cdata'
            % inconsistency
            error('LTPDA:err:InfoMismatch', 'You set the [output x] property, but also specified class ''%s'' for the [output data] property', data_type);
          otherwise
            error('LTPDA:err:UnsupportedClass', 'Unsupported class ''%s'' for the [output data] property', data_type);
        end
        % set the Y values
        pl_ao.pset('yvals', yout);

      else
        % No more info available on the object. Go for a cdata AO
        % set the Y values
        pl_ao.pset('vals', yout);
      end
      
      % Set Y units
      pl_ao.pset('yunits', mdl.yunits);
      
      % Build the AO
      bs = ao(pl_ao);
    otherwise
      error('LTPDA:err:UnsupportedClass', 'Unsupported class ''%s'' for the [output x] property', class(xout));
  end


  % Set name
  bs.setName(sprintf('eval(%s)', mdl.name));
  % Add history
  bs.addHistory(getInfo('None'), pl, mdl_invars, mdl.hist);
  
  % Set output
  varargout{1} = bs;
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
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.helper, '', sets, pl);
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
  pl = plist();
  
  % output type
  pv = paramValue.DATA_TYPES;
  % Add an 'empty' at the end of the list
  pv{2} = [pv{2} {''}];
  p = param({'output type',['Choose the output data type.<br>']}, pv);
  p.val.setValIndex(1);
  pl.append(p);
 
  % output x
  p = param({'output x', ['The X values for the output data ao. This can be:<ul>'...
    '<li>a double vector </li>' ...
    '<li>an ao, in this case the output is a copy of this object BUT the ''y'' field is calculated from the model</li></ul>' ...
    ]}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
  % output Xunits
  p = param({'output xunits','The X units for the output data ao'},  paramValue.STRING_VALUE(''));
  pl.append(p);

  % T0
  p = param({'T0', ['The UTC time of the first sample. <br>' ...
    'Note this applies only to the case where you specify ''output type'' to be ''tsdata''']}, {1, {'1970-01-01 00:00:00.000'}, paramValue.OPTIONAL});
  pl.append(p);
  
end

