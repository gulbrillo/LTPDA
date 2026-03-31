% PLOTLOGLIKELIHOOD.M
%
% Plots a given loglikelihood 2-D slices with respect the parameters.
% 
%    CALL:  MCMC.plotLogLikelihood(plist)
%
%    NOTE:  This function will produce one figure with several subplots.  
%           For optimal results use it in the case of 
%           fewer than nine parameters.
%
% EXAMPLE:  MCMC.plotLogLikelihood(plist('function',    myfunc,...
%                                        'param names', {'p1', 'p2'},...
%                                        'x0',          [0 0.5],...
%                                        'step',        [0.01 1e-6],...
%                                        'range',       {[-1 1], [0 1]},...
%                                        'colormap',    summer)) 
%
%
%<a href="matlab:utils.helper.displayMethodInfo('MCMC', 'MCMC.plotLogLikelihood')">ParametersDescription</a>
%
% NK 2013
% 

function varargout = plotLogLikelihood(varargin)
  
  %%% Check if this is a call for parameters
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
  pl = utils.helper.collect_objects(varargin(:), 'plist', in_names);
  
  % combine plists
  pl          = applyDefaults(getDefaultPlist(), pl);
  
  func        = find_core(pl, 'function');
  step        = find_core(pl, 'step');
  range       = find_core(pl, 'range');
  levels      = find_core(pl, 'levels');
  inivals     = find_core(pl, 'x0');
  paramNames  = find_core(pl, 'param names');
  ptype       = find_core(pl, 'plot type');
  prnt        = find_core(pl, 'message');
  fontsize    = find_core(pl, 'font size');
  edgecol     = find_core(pl, 'edgecolor');
  linestl     = find_core(pl, 'LineStyle');
  REG         = find_core(pl, 'norm');
  clrline     = find_core(pl, 'color line');
  
  % Get the colormap
  map = find_core(pl, 'colormap');
  
  if isempty(step) || isempty(range) || isempty(inivals) || isempty(func)
    error(['### Please check inputs. Fields ''step'', ''function'', '...
          ' ''x0'' and ''range'' are necessary.'])
  end
    
  if isempty(paramNames)
    for ii = 1:size(inivals)
      paramNames{ii} = sprintf('p%d',ii);
    end
  end
  
  if ~any(strncmpi({'surf', 'contour', 'contourf'}, ptype, 8))
    error('### Please choose one of the available options for ''plot type''.')
  end
  
  % Initializing
  vals = inivals;
  ind  = 0;
  len  = length(paramNames)-1;
  lal  = 1;
  
  % create figure
  figure;
  
  % Loop over the parameters
  for rr =1:len
    for cc = rr + 1:len + 1
      
      % Create meshgrid
      [X, Y] = meshgrid(range{rr}(1):step(rr):range{rr}(2) , range{cc}(1):step(cc):range{cc}(2));
      
      % Initializing
      gg   = 1;
      logL = zeros(size(Y,1), size(X,2));
      
      if isempty(logL)
        error('### Empty matrix error. Please check again the settings ''STEP'' and ''RANGE''.')
      end
          
      for ii = X(1,1):step(rr):X(1,size(X,2))
        dd = 1;
        for jj = Y(1,1):step(cc):Y(size(Y,1),1)
          
          vals([rr cc]) = [ii jj];
          
          aologL      = func(vals);
          logL(dd,gg) = aologL.y;
          dd = dd+1;
          
        end
        gg = gg+1;
      end
      
      if prnt
        fprintf('- Finished calculating the LLH for parameter %s against %s. \n', paramNames{rr}, paramNames{cc})
      end
      
      if (len * round(double(ind)/len) == ind) && ind ~= 0;
        ind        = ind + 1 + lal;
        lal        = lal + 1;
        prinLabels = true;
      else
        ind        = ind + 1;
        prinLabels = false;
      end
      
      % Subplot
      subplot(len, len, ind)
      
      % get max
      if REG
        maxL = max(max(logL(isfinite(logL))));
      else
        maxL = 1;
      end
      
      % check if there are infs
      logL(~isfinite(logL)) = NaN;
      
      switch ptype
        case 'contour'
          if ~isempty(clrline)
            contour(X, Y, logL/maxL, levels, 'Linecolor', clrline, 'LineStyle', linestl)
          else
            contour(X, Y, logL/maxL, levels)
          end
        case 'contourf'
          [~, ch] = contourf(X, Y, logL/maxL, levels);
          set(ch,'edgecolor',edgecol, 'LineStyle', linestl);
        case 'surf'
          surf(X, Y, logL/maxL, 'EdgeColor',edgecol, 'LineStyle', linestl, 'FaceLighting', 'phong');
      end
      
      xlim([X(1,1) X(1,end)])
      ylim([Y(1,1) Y(end,1)])
      view(-90,90) 
      set(gca,'ydir','reverse')
      set(gca,'FontSize',fontsize)

      if prinLabels || ind == 1;
        xlabel(paramNames{rr},'FontSize', fontsize)
        ylabel(paramNames{cc},'FontSize', fontsize)
      else
        set(gca,'XTickLabel','')
        set(gca,'YTickLabel','')
      end
      vals = inivals;
    end
  end
  
  % Set colormap
  colormap(map)
  
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
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.helper, '', sets, pl);
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
  
  p = param({'function','The function to evaluate. Must be dependent only to the numerical vector of the parameters.'}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
  p = param({'norm','Divide with the maximum value of the function. Helpful in case of large intuitive numbers.'}, paramValue.TRUE_FALSE);
  pl.append(p);
  
  p = param({'plot type','The type of plot to use. Must choose between ''surf'', ''contour'', and ''contourf''.'}, {1, {'surf', 'contour', 'contourf'}, paramValue.OPTIONAL});
  pl.append(p);
  
  p = param({'levels','The number of levels of the contour plot.'}, paramValue.DOUBLE_VALUE(30));
  pl.append(p);
  
  p = param({'colormap','Choose a colormap for the surface plots (as a string). For more details, type >> help colormap'}, paramValue.STRING_VALUE('jet'));
  pl.append(p);
  
  p = param({'edgecolor','For the case of ''contourf'' and ''surf'', the color of the edges can be defined.'}, paramValue.STRING_VALUE('none'));
  pl.append(p);
  
  p = param({'LineStyle','Set the lineStyle for the edges.'}, paramValue.STRING_VALUE('-'));
  pl.append(p);
  
  p = param({'color line','Choose a color for the line of the contour plots. If left empty the default colormap will be used. '}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
  p = param({'x0','The numerical values of the parameters.'}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
  p = param({'range','A cell array containing the ranges of the parameters. For example, for a case with two parameters, then ranges = {[-1 1], [0 3]};'}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
  p = param({'step','The steps to calculate the function.'}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
  p = param({'param names','Cell array of names of the parameters to be assigned to the plot. If left empty some default names will be used.'}, paramValue.EMPTY_STRING);
  pl.append(p);
  
  p = param({'message','True-False flag. If true, a message is printed in screen every time a sulface subplot is calculated.'}, paramValue.TRUE_FALSE);
  pl.append(p);
  
  p = param({'font size','The font size of the x axis and y axis labels.'}, paramValue.DOUBLE_VALUE(10));
  pl.append(p);
  
end
% END
