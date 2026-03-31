% REMOVEVAL removes values from the input AO(s).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: REMOVEVAL removes user specified value(s) from the input AO(s),
%              such as NaNs, Infs, or 0s. Depending on the values set in the plist,
%              it will replace them with nothing or with an interpolated value
%
% CALL:        b = removeVal(a, pl)
%
% INPUTS:      a  - input array of AOs
%              pl - parameter list with the keys 'axis' and 'method'
%
% OUTPUTS:     b  - output array of AOs
%
% REMARKs:
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'removeVal')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = removeVal(varargin)
  
  callerIsMethod = utils.helper.callerIsMethod;
  
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
  
  % Collect all AOs
  [as, ao_invars] = utils.helper.collect_objects(varargin(:), 'ao', in_names);
  
  
  % Decide on a deep copy or a modify
  bs = copy(as, nargout);
  
  % Apply defaults to plist
  pl = applyDefaults(getDefaultPlist, varargin{:});
  
  % Get parameters
  ax            = find_core(pl, 'axis');
  method        = find_core(pl, 'method');
  value         = find_core(pl, 'value');
  interp_method = find_core(pl, 'interpolation');
  
  %-----------------------
  % Loop over input AOs
  for jj = 1:numel(bs)
    % record input history
    hin = bs(jj).hist;
    
    switch ax
      case {'y', 'x'}
        % Find the index position of the elements to remove
        validValues = true(size(bs(jj).(ax)));
        for kk = 1:numel(value)
          if isnumeric(value(kk))
            if isfinite(value(kk))
              validValues = validValues & bs(jj).(ax) ~= value(kk);
            else
              if isnan(value(kk))
                validValues = validValues & ~isnan(bs(jj).(ax));
              end
              if isinf(value(kk))
                validValues = validValues & ~isinf(bs(jj).(ax));
              end
            end
          end
        end
        
        % Go ahead and act on the data
        switch method
          case 'remove'
            if ~isa(bs(jj).data, 'cdata')
              % for tsdata, fsdata and xydata objects
              x = bs(jj).data.getX();
              y = bs(jj).data.y;
              dx = bs(jj).data.dx;
              dy = bs(jj).data.dy;
              bs(jj).data.setDx([]);
              bs(jj).data.setDy([]);
              % Set X,Y
              bs(jj).data.setXY(x(validValues), y(validValues));
              % Set DY
              if ~isempty(dy) && numel(dy) > 1
                bs(jj).data.setDy(dy(validValues));
              end
              % Set DX
              if ~isempty(dx) && numel(dx) > 1
                bs(jj).data.setDx(dx(validValues));
              end
            else
              % for cdata objects
              y = bs(jj).data.y;
              dy = bs(jj).data.dy;
              bs(jj).data.setDy([]);
              % Set Y
              bs(jj).data.setY(y(validValues));
              % Set DY
              if ~isempty(dy) && numel(dy) > 1
                bs(jj).data.setDy(dy(validValues));
              end
            end
            
            % Set ENBW
            if isprop(bs(jj).data, 'enbw')
              bs(jj).data.setEnbw(bs(jj).enbw(validValues));
            end
            
          case 'interp'
            if ~isa(bs(jj).data, 'cdata')
              % for tsdata, fsdata and xydata objects
              x = bs(jj).data.getX();
              y = bs(jj).data.y;
              dx = bs(jj).data.dx;
              dy = bs(jj).data.dy;
              bs(jj).data.setDx([]);
              bs(jj).data.setDy([]);
              
              % We need at least two valid points to interpolate on
              if sum(validValues) >= 2
                % Set Y
                bs(jj).data.setY(interp1(x(validValues), y(validValues), x, interp_method, 'extrap'));
                % Set DY
                if ~isempty(dy) && numel(dy) > 1
                  bs(jj).data.setDy(interp1(x(validValues), dy(validValues), x, interp_method, 'extrap'));
                end
                % Set DX
                if ~isempty(dx) && numel(dx) > 1
                  bs(jj).data.setDx(interp1(x(validValues), dx(validValues), x, interp_method, 'extrap'));
                end
                % Set ENBW
                if isprop(bs(jj).data, 'enbw')
                  if ~isempty(bs(jj).data.enbw) && numel(bs(jj).data.enbw) > 1
                    bs(jj).data.setEnbw(interp1(x(validValues), bs(jj).enbw(validValues), x, interp_method, 'extrap'));
                  end
                end
              else
                % If we have 0 or 1 valid points, just set them
                % Set X, Y
                bs(jj).data.setXY(x(validValues), y(validValues));
                % Set DY
                if ~isempty(dy) && numel(dy) > 1
                  bs(jj).data.setDy(dy(validValues));
                end
                % Set DX
                if ~isempty(dx) && numel(dx) > 1
                  bs(jj).data.setDx(dx(validValues));
                end
                % Set ENBW
                if isprop(bs(jj).data, 'enbw')
                  bs(jj).data.setEnbw(bs(jj).enbw(validValues));
                end
              end
              
            else
              % for cdata object
              y = bs(jj).data.y;
              dy = bs(jj).data.dy;
              bs(jj).data.setDy([]);
              % We need at least two valid points to interpolate on
              if sum(validValues) >= 2
                % Set Y
                bs(jj).data.setY(interp1(y(validValues), 1:length(y), interp_method, 'extrap'));
                % Set DY
                if ~isempty(dy) && numel(dy) > 1
                  bs(jj).data.setDy(interp1(dy(validValues), 1:length(dy), interp_method, 'extrap'));
                end
              else
                % If we have 0 or 1 valid points, just set them
                % Set Y
                bs(jj).data.setY(y(validValues));
                % Set DY
                if ~isempty(dy) && numel(dy) > 1
                  bs(jj).data.setDy(dy(validValues));
                end
              end
            end
            
          otherwise
            error('### Unrecognised method %s', method);
        end
        
        clear x y dx dy;
        
      otherwise
        utils.helper.msg(msg.IMPORTANT, 'Option %s not recognised, sorry.', ax);
    end
    
    if ~callerIsMethod
      % Add history
      bs(jj).addHistory(getInfo('None'), pl, ao_invars, hin);
    end
    
  end
  
  % Set output
  varargout = utils.helper.setoutputs(nargout, bs);
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
  
  % Value
  p = param({'value', ['The value(s) to remove. Multiple values can be input in a vector.<br>' ...
    'Accepted values are:<ul>' ...
    '<li>NaN</li>' ...
    '<li>Inf</li>' ...
    '<li>Numbers</li></ul>']}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
  % Vertices
  p = param({'axis', 'The axis to check on.'}, ...
    {2, {'x', 'y'}, paramValue.SINGLE});
  pl.append(p);
  
  % Method
  p = param({'method', 'The operation to perform on the values curresponding to NaN.'}, ...
    {1, {'remove', 'interp'}, paramValue.SINGLE});
  pl.append(p);
  
  % Interpolation
  pli = ao.getInfo('interp').plists;
  p = setKey(pli.params(pli.getIndexForKey('method')), 'interpolation');
  p.setOrigin(mfilename);
  p.setDefaultIndex(4);
  
  pl.append(p);
end
