% DIFF differentiates the data in AO.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: DIFF differentiates the data in AO. The result is a data
%              series the same length as the input series.
%              In case of method 'diff' computes the difference between two samples, in which
%              case the resulting time object has the length of the input
%              series -1 sample.
% CALL:        bs = diff(a1,a2,a3,...,pl)
%              bs = diff(as,pl)
%              bs = as.diff(pl)
%
% INPUTS:      aN   - input analysis objects
%              as   - input analysis objects array
%              pl   - input parameter list
%
% OUTPUTS:     bs   - array of analysis objects, one for each input,
%                     containing the differentiated data
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'diff')">Parameters Description</a>
%
% REFERENCES:
% [1] L. Ferraioli, M. Hueller and S. Vitale, Discrete derivative
%     estimation in LISA Pathfinder data reduction,
%     <a
%     href="matlab:web('http://www.iop.org/EJ/abstract/0264-9381/26/9/094013/','-browser')">Class. Quantum Grav. 26 (2009) 094013.</a>
% [2] L. Ferraioli, M. Hueller and S. Vitale, Discrete derivative
%     estimation in LISA Pathfinder data reduction
%     <a href="matlab:web('http://arxiv.org/abs/0903.0324v1','-browser')">http://arxiv.org/abs/0903.0324v1</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = diff(varargin)
  
  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  callerIsMethod = utils.helper.callerIsMethod;
  
  if callerIsMethod
    in_names = {};
  else
    import utils.const.*
    utils.helper.msg(msg.PROC3, 'running %s/%s', mfilename('class'), mfilename);
    
    % Collect input variable names
    in_names = cell(size(varargin));
    try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
  end
  
  % Collect all AOs
  [as, ao_invars] = utils.helper.collect_objects(varargin(:), 'ao', in_names);
  
  % Decide on a deep copy or a modify
  bs = copy(as, nargout);
  
  % Apply defaults to plist
  pl = applyDefaults(getDefaultPlist, varargin{:});
  
  % Extract method
  method = find_core(pl, 'method');
  
  % Extract order
  der_order = find_core(pl, 'order');
  if isnumeric(der_order)
    switch der_order
      case 0
        der_order = 'zero';
      case 1
        der_order = 'first';
      case 2
        der_order = 'second';
      otherwise
        error('Unknown order [%d]', der_order);
    end
  end
  
  for jj = 1:numel(bs)
    
    % collect yunits
    yunits = bs(jj).data.yunits;
    
    % collect xunits if we have it
    if isa(bs(jj).data, 'data2D')
      xunits = bs(jj).data.xunits;
    else
      xunits = unit();
    end
    
    % Compute derivative with selected method
    switch lower(method)
      
      case 'diff'         
        % handle y
        y      = bs(jj).data.getY;
        switch lower(der_order)
          case 'zero'
            z = y;
          case {'first', 'one'}
            z     = diff(y);
          case {'second', 'two'}
            z     = diff(diff(y));
          otherwise
            error('Unknown order [%s]', der_order);
        end
        
        % and x if we have it
        if isa(bs(jj).data, 'data2D')
          x      = bs(jj).data.getX;
          switch lower(der_order)
            case 'zero'
              newX = x;
              xunits = unit();
            case {'first', 'one'}
              newX   = x(1:end-1); % cut the last sample from the time series to make x and y same length
            case {'second', 'two'}
              newX   = x(1:end-2); % cut the last two samples from the time series to make x and y same length
              xunits = xunits.^2;
            otherwise
              error('Unknown order [%s]', der_order);
          end
        end
        
        % now we can set the new values safely
        bs(jj).data.setY(z);
        if isa(bs(jj).data, 'data2D')
          bs(jj).data.setX(newX);
        end
        
      case '2point'
        cdataError(bs(jj).data, method);
        x      = bs(jj).data.getX;
        y      = bs(jj).data.getY;
        switch lower(der_order)
          case 'zero'
            z      = y;
            newX   = x;
            xunits = unit();
          case {'first', 'one'}
            [newX, z] = ao.diff2p_core(x, y);
          case {'second', 'two'}
            % Do it in two steps: first
            [newX, z] = ao.diff2p_core(x, y);
            % Do it in two steps: second
            [newX, z] = ao.diff2p_core(newX, z);
            xunits = xunits.^2;
          otherwise
            error('Unknown order [%s]', der_order);
        end
        
        bs(jj).data.setY(z);
        bs(jj).data.setX(newX);
        
      case '3point'
        cdataError(bs(jj).data, method);
        x  = bs(jj).data.getX;
        y  = bs(jj).data.getY;
        switch lower(der_order)
          case 'zero'
            z          = y;
            xunits     = unit();
          case {'first', 'one'}

            dx = diff(x);            
            z = ao.diff3p_core(y,dx);            
            
          case {'second', 'two'}
            if bs(jj).data.evenly
              dx = 1/bs(jj).fs;
            else
              dx = diff(x);
            end
            % Do it in two steps: first
            z = ao.diff3p_core(y, dx);
            % Do it in two steps: second
            z = ao.diff3p_core(z, dx);
            xunits = xunits.^2;
          otherwise
            error('Unknown order [%s]', der_order);
        end
        bs(jj).data.setY(z);
        
      case '5point'
        cdataError(bs(jj).data, method);
        x  = bs(jj).data.getX;
        y  = bs(jj).data.getY;
        switch lower(der_order)
          case 'zero'
            z          = y;
            xunits     = unit();
          case {'first', 'one'}
            dx = diff(x);
            z  = ao.diff5p_core(x, y, dx);
          case {'second', 'two'}
            dx = diff(x);
            % Do it in two steps: first
            z = ao.diff5p_core(x, y, dx);
            % Do it in two steps: second
            z = ao.diff5p_core(x, z, dx);
            xunits     = xunits.^2;
          otherwise
            error('Unknown order [%s]', der_order);
        end
        bs(jj).data.setY(z);
        
      case 'order2'
        cdataError(bs(jj).data, method);
        x     = bs(jj).data.getX;
        dx    = diff(x);
        y     = bs(jj).data.getY;
        z     = zeros(size(y));
        m     = length(y);
        % y'(x1)
        z(1) = (1/dx(1)+1/dx(2))*(y(2)-y(1))+...
          dx(1)/(dx(1)*dx(2)+dx(2)^2)*(y(1)-y(3));
        % y'(xm)
        z(m) = (1/dx(m-2)+1/dx(m-1))*(y(m)-y(m-1))+...
          dx(m-1)/(dx(m-1)*dx(m-2)+dx(m-2)^2)*(y(m-2)-y(m));
        % y'(xi) (i>1 & i<m)
        dx1 = repmat(dx(1:m-2),1,1);
        dx2 = repmat(dx(2:m-1),1,1);
        y1 = y(1:m-2); y2 = y(2:m-1); y3 = y(3:m);
        z(2:m-1) = 1./(dx1.*dx2.*(dx1+dx2)).*...
          (-dx2.^2.*y1+(dx2.^2-dx1.^2).*y2+dx1.^2.*y3);
        bs(jj).data.setY(z);
        
      case 'order2smooth'
        cdataError(bs(jj).data, method);
        x  = bs(jj).data.getX;
        y  = bs(jj).data.getY;
        dx = diff(x);
        m  = length(y);
        if max(abs(diff(dx)))>sqrt(eps(max(abs(dx))))
          error('### The x-step must be constant for method ''ORDER2SMOOTH''')
        elseif m<5
          error('### Length of y must be at least 5 for method ''ORDER2SMOOTH''.')
        end
        h = mean(dx);
        z = zeros(size(y));
        % y'(x1)
        z(1) = sum(y(1:5).*[-54; 13; 40; 27; -26])/70/h;
        % y'(x2)
        z(2) = sum(y(1:5).*[-34; 3; 20; 17; -6])/70/h;
        % y'(x{m-1})
        z(m-1) = sum(y(end-4:end).*[6; -17; -20; -3; 34])/70/h;
        % y'(xm)
        z(m) = sum(y(end-4:end).*[26; -27; -40; -13; 54])/70/h;
        % y'(xi) (i>2 & i<(N-1))
        Dc = [2 1 0 -1 -2];
        tmp = convn(Dc,y)/10/h;
        z(3:m-2) = tmp(5:m);
        bs(jj).data.setY(z);
        
      case 'filter'
        error('### Comming soon');
        
      case 'fps'
        cdataError(bs(jj).data, method);
        coeff = find_core(pl, 'COEFF');
        x  = bs(jj).data.getX;
        dx = x(2)-x(1);
        fs = 1/dx;
        y  = bs(jj).data.getY;
        params = struct('ORDER', der_order, 'COEFF', coeff, 'FS', fs);
        z = utils.math.fpsder(y, params);
        bs(jj).data.setY(z);
        % setting units
        switch lower(der_order)
          case 'zero'
            xunits = unit();
          case {'first', 'one'}
            % do nothing
          case {'second', 'two'}
            xunits = xunits.^2;
        end
        
      otherwise
        error('### Unknown method for computing the derivative.');
    end
    
    % set y units
    bs(jj).data.setYunits(yunits./xunits);

    % see if we can collapse the x data
    if isa(bs(jj).data, 'tsdata')
      bs(jj).data.collapseX;
    end
        
    if ~callerIsMethod
      % name for this object
      bs(jj).name = sprintf('diff(%s)', ao_invars{jj});
      % add history
      bs(jj).addHistory(getInfo('None'), pl, ao_invars(jj), bs(jj).hist);
    end
  end
  
  % Clear the errors since they don't make sense anymore
  clearErrors(bs);
    
  % Set output
  varargout = utils.helper.setoutputs(nargout, bs);
end

function cdataError(data, method)
  % Diff can't work for cdata objects since we need x data
  if isa(data, 'cdata')
    error('### diff/%s doesn''t work with cdata AOs since we need an x-data vector.', method);
  end
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
    pl   = getDefaultPlist;
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
  
  % Method
  p = param({'method', ['The method to use. Choose between:<ul>', ...
    '' ...
    '<li>''diff'' - uses MATLAB''s diff function. For 2D data, the last x sample is dropped.', ...
    '</li>' ...
    '<li>''2POINT'' - 2 point derivative computed as [y(i+1)-y(i)]./[x(i+1)-x(i)]', ...
    '</li>' ...
    '<li>''3POINT'' - 3 point derivative. Compute derivative dx at i as <br>', ...
    '<tt>[y(i+1)-y(i-1)] / [x(i+1)-x(i-1)]</tt><br>', ...
    'For <tt>i==1</tt>, the output is computed as <tt>[y(2)-y(1)]/[x(2)-x(1)]</tt>.<br>', ...
    'The last sample is computed as <tt>[y(N)-y(N-1)]/[x(N)-x(N-1)]</tt>', ...
    '</li>' ...
    '<li>''5POINT'' - 5 point derivative. Compute derivative dx at i as <br>', ...
    '<tt>[-y(i+2)+8*y(i+1)-8*y(i-1)+y(i-2)] / [3*(x(i+2)-x(i-2))]</tt><br>', ...
    'For <tt>i==1</tt>, the output is computed as <tt>[y(2)-y(1)]/[x(2)-x(1)]</tt><br>', ...
    'The last sample is computed as <tt>[y(N)-y(N-1)]/[x(N)-x(N-1)]</tt>', ...
    '</li>' ...
    '<li>''ORDER2'' - Compute derivative using a 2nd order method', ...
    '</li>' ...
    '<li>''ORDER2SMOOTH'' - Compute derivative using a 2nd order method<br>', ...
    'with a parabolic fit to 5 consecutive samples', ...
    '</li>' ...
    '<li>''filter'' - applies an IIR filter built from a single pole at the chosen frequency.<br>', ...
    'The filter is applied forwards and backwards (filtfilt) to achieve the desired f^2<br>', ...
    'response. This only works for time-series AOs.<br>', ...
    'For this method, you can specify the pole frequency with an additional parameter ''F0'' (see below):', ...
    '</li>'...
    '<li>''FPS'' - Calculates five points derivative using utils.math.fpsder.<br>', ...
    'When calling with this option you may add also the parameters <br>''ORDER'' (see below) ', ...
    'and ''COEFF'' (see below)' ...
    '</li>' ...
    ]},  {3, {'DIFF', '2POINT', '3POINT', '5POINT', 'ORDER2', 'ORDER2SMOOTH', 'FILTER', 'FPS'}, paramValue.SINGLE});
  pl.append(p);
  
  % F0
  p = param({'f0','The pole frequency for the ''filter'' method.'}, {1, {'1/Nsecs'}, paramValue.OPTIONAL});
  pl.append(p);
  
  % Order
  p = param({'ORDER', ['Derivative order. <br>', ...
    'This applys only to the cases where ''METHOD'' is set to: <ul>' ...
    '<li>''FPS''</li> <li>''DIFF''</li> <li>''2POINT''</li> <li>''3POINT''</li> <li>''5POINT''</li>']}, {2, {'ZERO', 'FIRST', 'SECOND'}, paramValue.SINGLE});
  pl.append(p);
  
  % Coeff
  p = param({'COEFF', ['Coefficient used for the derivation. <br>', ...
    'This applys only to the case where ''METHOD'' is set to ''FPS''. <br>', ...
    'Refer to the <a href="matlab:doc(''utils.math.fpsder'')">fpsder help</a> for further details']}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
end

