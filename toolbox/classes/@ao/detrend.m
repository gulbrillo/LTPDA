% DETREND detrends the input analysis object using a polynomial of degree N.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: DETREND detrends the input analysis object using a
%              polynomial of degree N.
%
% CALL:        b = detrend(a1,a2,a3,..., pl)
%
% INPUTS:      aN  - a list of analysis objects
%              pl  - a parameter list
%
% OUTPUTS:     b - array of analysis objects
%
%              If the last input argument is a parameter list (plist) it is used.
%              The following parameters are recognised.
%
% NOTE: detrend uses two possible algorithms. By default, or if the order 
% is higher than 10, then a MATLAB code is used which is typically much
% slower, but giving coefficents that can be easily called within pest/eval.
% A fast C-code implementation is also available for orders less than 11. 
% You can force the use of the C code using a plist option. When interpreting the
% resulting coefficients, you must be clear which algorithm was used. For
% the C-code algorithm, the coefficients are scaled from the original by
% 
%     z = 2.*ii/(n-1)-1;
% 
% such that the functional form (for a three-coefficient example) that is
% subtracted from the data can be recovered with:
% 
% fitted_c = c.y(3).*z.^2 + c.y(2).*z + c.y(1); 
% 
% 
% The procinfo field of the output AOs is filled with the following key/value
% pairs:
%
%    'COEFFS' - pest object with coefficients describing the subtracted trend function
%               Note that they correspond to physical trend coefficents
%               only if using the (default) option 'M-FILE ONLY'. In the
%               case of using the (faster) C-code algorithm, see the note above.
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'detrend')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = detrend(varargin)
  
  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  callerIsMethod = utils.helper.callerIsMethod;
  
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
  
  % Unpack parameter list
  % Leaving the "N" for backwards compatibility
  order = find(pl, 'N', find_core(pl, 'order'));
  m_file = find_core(pl, 'M-FILE ONLY');
  
  % Loop over analysis objects
  for jj = 1:numel(bs)
    % check data
    if ~isa(bs(jj).data, 'tsdata')
      warning('!!! This method only works with time-series at the moment. Skipping %s', ao_invars{jj});
    else
      if ~isempty(find(pl, 'times'))
        % Evaluate the trend only on a limited section
        cs = split(bs(jj), plist('times', find(pl, 'times')));
        cd = detrend(cs, plist('order', order, 'M-FILE ONLY', true));
        p = cd.procinfo.find('coeffs');
        t = eval(p, plist('xdata', bs(jj), 'xfield', 'x'));
        y = bs(jj).data.getY - t.y;
        c = p.y;
      else
        % detrend with polynomial
        if m_file
          if order >= 0
            [y,c] = polydetrend(bs(jj).data.getX, bs(jj).data.getY, order);
          else
            y = bs(jj).data.getY;
            c = [];
          end
        else
          try
            [y,c] = ltpda_polyreg(bs(jj).data.getY, order);
            c = flipud(c);
          catch ME
            warning('!!! failed to execture ltpda_polyreg.mex. Using m-file call.');
            mfile = true;
            if order >= 0
              [y,c] = polydetrend(bs(jj).data.getX, bs(jj).data.getY, order);
            else
              y = bs(jj).data.getY;
              c = [];
            end
          end
        end
      end
      % set the values in the y and procinfo fields
      bs(jj).data.setY(y);
      
      % build a pest object with the coefficients
      units = unit.initObjectWithSize(1, order + 1);
      names = [];
      mdl   = [];
      
      if order >= 0
        for kk = 1:order+1
          ll = order - kk + 1;
          units(kk) = bs(jj).data.yunits / simplify((unit(bs(jj).data.xunits)).^(ll));
          names{kk} = ['P' num2str(ll)];
          mdl = [mdl '+P' num2str(ll) '*t.^' num2str(ll) ' '];
        end
        model = smodel(mdl);
        model.setXvar('t');
        
        coeff = pest(plist(...
          'paramNames', names, ...
          'y', c, ...
          'dy', zeros(size(c)), ...
          'yunits', units ...
          ));
        bs(jj).procinfo = plist('coeffs', coeff.setModels(model));
      end
      
      if ~callerIsMethod
        % add name
        bs(jj).name = sprintf('detrend(%s)', ao_invars{jj});
        % add history
        bs(jj).addHistory(getInfo('None'), pl, ao_invars(jj), as(jj).hist);
      end
      % Clear the errors since they don't make sense anymore
      clearErrors(bs(jj));
      
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
  
  % order, N
  p = param({'order', ['The order of detrending:<ul>', ...
    '<li>-1 - no detrending</li>', ...
    '<li>0 - subtract mean</li>', ...
    '<li>1 - subtract linear fit</li>', ...
    '<li>N - subtract fit of polynomial, order N</li></ul>']}, {3, {-1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9}, paramValue.SINGLE});
  p.addAlternativeKey('N');
  pl.append(p);
  
  % m-file only
  p = param({'M-FILE ONLY', 'Using M-file call'}, paramValue.TRUE_FALSE);
  pl.append(p);
  
  % split to fit only a fraction
  p = param({'TIMES', ['Evaluate the trend only on a limited data segment, and then detrend the whole data set.<br>' ...
    'An array of start/stop times to split by. <br>The times should be relative' ...
    'to the object reference time (t0).']}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
end

function [y,p] = polydetrend(varargin)
  % POLYDETREND detrends the input data vector with a polynomial.
  %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  % DESCRIPTION: POLYDETREND detrends the input data vector with a
  %              polynomial.
  %
  % CALL:        [y,p] = polydetrend(x,order);
  %
  % INPUTS:      x     - vector of x values
  %              order - order of polynomial to fit and subtract
  %
  % OUTPUTS:     y   - detrended data
  %              p   - coefficients fitted to the trend function
  %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  if nargin == 2
    x     = varargin{1};
    order = varargin{2};
    t     = [1:length(x)].';
  elseif nargin == 3
    t     = varargin{1};
    x     = varargin{2};
    order = varargin{3};
  else
    error('### incorrect inputs.');
  end
  
  % fit polynomial
  p = polyfit(t, x, order);
  
  % make polynomial series
  py = polyval(p, t);
  
  % detrend
  y = x - py;
end
% END

