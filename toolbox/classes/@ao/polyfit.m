% POLYFIT overloads polyfit() function of MATLAB for Analysis Objects.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: POLYFIT overloads polyfit() function of MATLAB for Analysis
%              Objects. It finds the coefficients of a polynomial P(X) of
%              degree N that fits the data Y best in a least-squares sense:
%              P(1)*X^N + P(2)*X^(N-1) +...+ P(N)*X + P(N+1)
%
% CALL:        bs = polyfit(a1, a2, a3, ..., pl)
%              bs = polyfit(as,pl)
%              bs = as.polyfit(pl)
%
% INPUTS:      aN   - input analysis objects with data to be fitted.
%                   X will be a.x
%                   Y will be a.y
%              as   - input analysis objects array
%              pl   - input parameter list
%
% OUTPUTs:     bs  - An array of pest objects, each with the N+1 fitting coefficients P(j)
%
% NOTE: the data are assumed to be random, so to use the information from polyfit to estimate
%       the covariance matrix of the data, under the assumption chi^2 equals 1.
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'polyfit')">Parameters Description</a>
%
% EXAMPLES:
% 
%   %% Make fake AO from polyval
%   nsecs = 100;
%   fs    = 10;
%   
%   u = unit('fm s^-2');
%   
%   pl = plist('nsecs', nsecs, 'fs', fs, ...
%     'tsfcn', 'polyval([3 2 1 ], t) + 1000*randn(size(t))', ...
%     'xunits', 's', 'yunits', u);
% 
%   a1 = ao(pl);
%   
%   %% Fit a polynomial
%   N = 3;
%   p1 = polyfit(a1, plist('N', N));
%   p2 = polyfit(a1, plist('N', N, 'rescale', true));
%
%   %% Compute fit: evaluating pest
%   %% Here we need to specify that we want to use the 'x' field of 
%   %% the AO a to build the output AO
%   
%   b1 = p1.eval(plist('type', 'tsdata', 'XData', a1, 'Xfield', 'x'));
%   b2 = p2.eval(a1, plist('type', 'tsdata', 'Xfield', 'x'));
%   
%   %% Plot fit
%   iplot(a1, b1, plist('LineStyles', {'', '--'}));
%
%   %% Remove polynomial
%   c = a1-b1;
%   iplot(c)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = polyfit(varargin)
  
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
  
  if nargout == 0
    error('### polyfit can not be used as a modifier method. Please give at least one output');
  end
  
  % Apply defaults to plist
  use_pl = applyDefaults(getDefaultPlist, varargin{:});
  
  % Degree of polynomial to fit
  N       = find_core(use_pl, 'N');
  
  % Center and rescale the data
  rescale = utils.prog.yes2true(find_core(use_pl, 'rescale'));
  
  % Loop over input AOs
  for jj = 1 : numel(as)
        
    if isa(as(jj).data, 'cdata')
      warning('!!! Can''t fit to cdata objects. Skipping AO %s', ao_invars{jj});
      bs = [];
    else      
      % Fit polynomial
      mu = [];
      if rescale
        [p, s, mu] = polyfit(as(jj).x, as(jj).y, N);
      else
        [p, s]     = polyfit(as(jj).x, as(jj).y, N);
      end
            
      % prepare models, units, names
      model_expr = [];
      for kk = 1:N+1        
        names{kk} = ['P' num2str(kk)];        
        units{kk} = simplify(as(jj).data.yunits ./ ((as(jj).xunits).^(N-kk+1))); 
        if kk == 1
          model_expr = [model_expr 'P' num2str(kk) '*X.^' num2str(N-kk+1)];
        else
          model_expr = [model_expr ' + P' num2str(kk) '*X.^' num2str(N-kk+1)];
        end
      end
      model_pl = plist('expression', model_expr, ...
        'params', names, ...
        'values', p, ...
        'xvar', 'X', ...
        'xunits', as(jj).data.xunits.simplify, ...
        'yunits', as(jj).data.yunits.simplify ...
        );
      model = smodel(model_pl);
      if rescale
        model_expr = strrep(model_expr, 'X', '((X-mu)/sigma)');
        model.setExpr(model_expr);
        model.setAliases({'mu', 'sigma'}, {mu(1), mu(2)});
      end
      
      
      % Extract info to make error estimates for the parameters
      Rinv = inv(s.R);
      normr = s.normr;
      df = s.df;
      
      % Estimate covariance matrix
      C = (Rinv * Rinv') * normr^2 / df;
      
      % Assume a Chi^2 of 1
      chi2 = 1;

      % Build new pest objects from these N+1 coefficients
      bs(jj) = pest;
      bs(jj).setY(p);
      bs(jj).setDy(sqrt(diag(C)));
      bs(jj).setCov(C);
      bs(jj).setDof(df);
      bs(jj).setChi2(chi2);
      bs(jj).setNames(names{:});
      bs(jj).setYunits(units);
      bs(jj).setModels(model);
      bs(jj).name = sprintf('polyfit(%s)', ao_invars{jj});
      bs(jj).addHistory(getInfo('None'), use_pl, ao_invars(jj), as(jj).hist);
      % Set procinfo object with some data
      bs(jj).procinfo = plist('S', s, 'mu', mu);
      
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
  ii.setModifier(false);
  ii.setArgsmin(1);
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
  
  % N
  p = param({'N','Degree of polynomial to fit.'}, {2, {0, 1, 2, 3, 4, 5, 6, 7, 8, 9}, paramValue.SINGLE});
  p.addAlternativeKey('order')
  pl.append(p);
  
  % Rescale
  p = param({'rescale',['set to ''true'' or ''false'' to center and ', ...
    'rescale the data before fitting.<br>', ...
    'See "help polyfit" for further details.']}, paramValue.FALSE_TRUE);  
  pl.append(p);
  
end

% END

