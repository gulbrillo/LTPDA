% PLOTINFO Encapsulates plot information.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: PLOTINFO Encapsulates plot information.
%
% CONSTRUCTORS:
%
%       p = plotinfo();             - creates a plotinfo with the next
%                                     default style
%       p = plotinfo(2);            - creates a plotinfo with the specified style
%       p = plotinfo(pl)            - creates a plotinfo from a
%                                     parameter list with the parameters:
%
%       p = plotinfo(linestyle, linewidth, color);
%       p = plotinfo(linestyle, linewidth, color, marker);
%       p = plotinfo(linestyle, linewidth, color, marker, markersize);
%       p = plotinfo(linestyle, linewidth, color, marker, markersize, includeInLegend, showErrors, axes, figure);
%
% <a href="matlab:utils.helper.displayMethodInfo('plotinfo', 'plotinfo')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

classdef plotinfo < ltpda_nuo
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                            Property definition                            %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  %---------- Public (read/write) Properties  ----------
  properties
  end
  
  %---------- Protected read-only Properties ----------
  properties (SetAccess = public)
    style           = [];
    includeInLegend = true;
    showErrors      = false;
    axes            = []; % axes handle
    figure          = []; % figure handle
    line            = []; % line handle
  end
  
  
  %---------- Protected Properties ----------
  properties (SetAccess = protected)
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                          Check property setting                           %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                                Constructor                                %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods
    function obj = plotinfo(varargin)
      
      switch nargin
        case 0
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%%   no input   %%%%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          
          prefs = getappdata(0, 'LTPDApreferences');
          plotstyles = prefs.getPlotstylesPrefs;
          % get next default plot style
          obj.style = mpipeline.ltpdapreferences.PlotStyle(plotstyles.nextStyle());
          
        case 1
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%%   one input   %%%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          
          if isa(varargin{1}, 'plotinfo')
            %%%%%%%%%%  obj = plotinfo(plotinfo)   %%%%%%%%%%
            obj = copy(varargin{1}, 1);
            
          elseif isnumeric(varargin{1})
            
            prefs = getappdata(0, 'LTPDApreferences');
            plotstyles = prefs.getPlotstylesPrefs;
            if varargin{1} >= plotstyles.numberOfStyles()
              error('Only %d styles are defined. Choose an index in range.', plotstyles.numberOfStyles());
            end
            % get next default plot style
            obj.style = mpipeline.ltpdapreferences.PlotStyle(plotstyles.styleAtIndex(varargin{1}));
            obj.style.setMarkerEdgeColor(obj.style.getColor);
            obj.style.setMarkerFaceColor(obj.style.getColor);
            
          elseif isa(varargin{1}, 'mpipeline.ltpdapreferences.PlotStyle')
            %%%%%%%%%%  obj = plotinfo(plotStyle)   %%%%%%%%%%
            obj.style = varargin{1};
            
          elseif isa(varargin{1}, 'plist')
            %%%%%%%%%%  obj = plotinfo(plist)   %%%%%%%%%%
            
            if nparams(varargin{1}) == 0
              %%%%%%%%%%  obj = plotinfo(plist())   %%%%%%%%%%
              
              % build with the next default style
              prefs = getappdata(0, 'LTPDApreferences');
              plotstyles = prefs.getPlotstylesPrefs;
              % get next default plot style
              obj.style = mpipeline.ltpdapreferences.PlotStyle(plotstyles.nextStyle());
              
            else
              % user input
              pl = varargin{1};
              
              % get info
              ii = plotinfo.getInfo('plotinfo', 'Default');
              
              % apply defaults
              pl = applyDefaults(ii.plists, pl);
              
              % make style
              linestyle  = pl.find_core('linestyle');
              linewidth  = java.lang.Double(pl.find_core('linewidth'));
              color      = utils.prog.mcolor2jcolor(pl.find_core('color'));
              marker     = pl.find_core('marker');
              markersize = java.lang.Double(pl.find_core('markersize'));
              obj.style = mpipeline.ltpdapreferences.PlotStyle(linestyle, linewidth, marker, markersize, color);
              showerrs   = pl.find_core('showerrors');
              if isempty(showerrs) || ~islogical(showerrs)
                obj.showErrors = false;
              else
                obj.showErrors = showerrs;
              end
            end
            
          elseif isstruct(varargin{1})
            %%%%%%%%%%  obj = plotinfo(struct)   %%%%%%%%%%
            obj = fromStruct(obj, varargin{1});
            
          else
            error('### unknown constructor type for plotinfo object.');
          end
        case 2
          
          if isa(varargin{1}, 'org.apache.xerces.dom.ElementImpl')
            %%%%%%%%%%   obj = param(DOM node, history-objects)   %%%%%%%%%%
            obj = fromDom(obj, varargin{1}, varargin{2});
            return
          end
          
        case 3
          % plotinfo(linestyle, linewidth, color);
          linestyle  = varargin{1};
          linewidth  = java.lang.Double(varargin{2});
          color      = utils.prog.mcolor2jcolor(varargin{3});
          marker     = 'none';
          markersize = java.lang.Double(find(plotinfo.getDefaultPlist('Default'), 'markersize'));
          obj.style = mpipeline.ltpdapreferences.PlotStyle(linestyle, linewidth, marker, markersize, color);
          
        case 4
          % plotinfo(linestyle, linewidth, color, marker);
          linestyle  = varargin{1};
          linewidth  = java.lang.Double(varargin{2});
          color      = utils.prog.mcolor2jcolor(varargin{3});
          marker     = varargin{4};
          markersize = java.lang.Double(find(plotinfo.getDefaultPlist('Default'), 'markersize'));
          obj.style = mpipeline.ltpdapreferences.PlotStyle(linestyle, linewidth, marker, markersize, color);
          
        case 5
          if isa(varargin{1}, 'mpipeline.ltpdapreferences.PlotStyle')
            % plotinfo(style, includeInLegend, showErrors, axes, figure);
            obj.style           = varargin{1};
            obj.includeInLegend = varargin{2};
            obj.showErrors      = varargin{3};
            obj.axes            = varargin{4};
            obj.figure          = varargin{5};
            
          else
            % plotinfo(linestyle, linewidth, color, marker, markersize);
            linestyle  = varargin{1};
            linewidth  = java.lang.Double(varargin{2});
            color      = utils.prog.mcolor2jcolor(varargin{3});
            marker     = varargin{4};
            markersize = java.lang.Double(varargin{5});
            obj.style = mpipeline.ltpdapreferences.PlotStyle(linestyle, linewidth, marker, markersize, color);
            
          end
          
        case 9
          % plotinfo(linestyle, linewidth, color, marker, markersize, includeInLegend, showErrors, axes, figure);
          
          linestyle = varargin{1};
          linewidth = java.lang.Double(varargin{2});
          color     = utils.prog.mcolor2jcolor(varargin{3});
          marker    = varargin{4};
          markersize = java.lang.Double(varargin{5});
          
          % make style object
          obj.style = mpipeline.ltpdapreferences.PlotStyle(linestyle, linewidth, marker, markersize, color);
          
          obj.includeInLegend = varargin{6};
          obj.showErrors      = varargin{7};
          obj.axes            = varargin{8};
          obj.figure          = varargin{9};
          
        otherwise
          error('### Unknown number of arguments.');
      end
      
    end
  end
  
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                              Methods (public)                             %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods
    
    function setColor(obj, color)
      % SETCOLOR sets the color of the style of the plotinfo
      %
      % CALL:
      %         pi.setColor('m');
      %         pi.setColor([1 0 1]);
      %
      
      obj.style.setColor(utils.prog.mcolor2jcolor(color));
      disp(obj);
    end
    
    function setLinestyle(obj, style)
      % SETLINESTYLE sets the linestyle of the plotinfo
      %
      % CALL:
      %         pi.setLinestyle('-');
      %
      
      obj.style.setLinestyle(style);
      disp(obj);
    end
    
    function setLinewidth(obj, w)
      % SETLINEWIDTH sets the linewidth of the plotinfo
      %
      % CALL:
      %         pi.setLinewidth(2);
      %
      
      obj.style.setLinewidth(java.lang.Double(w));
      disp(obj);
    end
    
    function setMarker(obj, w)
      % SETMARKER sets the marker of the plotinfo
      %
      % CALL:
      %         pi.setMarker('x');
      %
      
      obj.style.setMarker(w);
      disp(obj);
    end
    
    function setMarkersize(obj, w)
      % SETMARKERSIZE sets the marker size of the plotinfo
      %
      % CALL:
      %         pi.setMarkersize(10);
      %
      
      obj.style.setMarkersize(java.lang.Double(w));
      disp(obj);
    end
    
    function applyLineStyle(obj)
      % APPLYLINESTYLE applies the style to the line handle. If the line
      % property is empty, and error is thrown.
      %
      % CALL:
      %        applyLineStyle(plotinfo)
      %
      
      if isempty(obj.line)
        error('The plotinfo has an empty line handle. The style can''t be applied.');
      end
      
      if isempty(obj.style)
        prefs = getappdata(0, 'LTPDApreferences');
        plotstyles = prefs.getPlotstylesPrefs;
        % get next default plot style
        obj.style = mpipeline.ltpdapreferences.PlotStyle(plotstyles.nextStyle());
      end
      
      lines = obj.line;
      
      for ll=1:numel(lines)
        l = lines(ll);
        if any(strcmp(get(l, 'Type'), {'line', 'hggroup', 'errorbar'}))
          % apply line style only to first line handle (assuming the second is
          % error bars)
          if ll == 1
            set(l, 'LineStyle', char(obj.style.getLinestyle()));
            % apply marker only to first line handle (assuming the second is
            % error bars)
            set(l, 'Marker', char(obj.style.getMarker()));
            
            % apply marker size only to first line handle (assuming the second is
            % error bars)
            set(l, 'MarkerSize', double(obj.style.getMarkersize()));
            
            % apply marker color
            set(l, 'MarkerEdgeColor', double(obj.style.toMATLABColor('MarkerEdgeColor')));
            if (obj.style.getFillmarkers.booleanValue)
              set(l, 'MarkerFaceColor', double(obj.style.toMATLABColor('MarkerFaceColor')));
            end
            
          end
          
          % apply line width
          set(l, 'LineWidth', double(obj.style.getLinewidth()));
          
          % apply color
          set(l, 'Color', obj.style.getMATLABColor());
        elseif any(strcmp(get(l, 'Type'), {'stair'}))
          if ll == 1
            set(l, 'LineStyle', char(obj.style.getLinestyle()));
          end
          % apply line width
          set(l, 'LineWidth', double(obj.style.getLinewidth()));
          
          % apply color
          set(l, 'Color', obj.style.getMATLABColor());
          
        end
      end
      
    end
    
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                              Methods (public, hidden)                     %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Hidden = true)
    varargout = setReadonly(varargin)
  end
  
  methods (Hidden = true)
    varargout = attachToDom(varargin)
    varargout = fromDom(varargin)
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                              Methods (protected)                          %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = protected)
    varargout = fromStruct(varargin)
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                              Methods (private)                            %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = private)
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                          Methods (Static, Public)                         %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Static = true)
    
    function resetStyles()
      % RESETSTYLES resets the styles counter
      %
      % CALL:
      %       plotinfo.resetStyles();
      %
      
      prefs = getappdata(0, 'LTPDApreferences');
      plotstyles = prefs.getPlotstylesPrefs;
      plotstyles.resetStyleIndex();
    end
    
    function ii = getInfo(varargin)
      ii = utils.helper.generic_getInfo(varargin{:}, 'plotinfo');
    end
    
    function out = SETS()
      out = {'Default'};
    end
    
    function out = getDefaultPlist(set)
      switch lower(set)
        case 'default'
          out = plist();
          
          % linestyle
          p = param({'linestyle', 'Specify the line style'}, {1, utils.plottools.allowedLinestyles, paramValue.SINGLE});
          out.append(p);
          
          % linewidth
          p = param({'linewidth', 'Specify the line width'}, paramValue.DOUBLE_VALUE(1));
          out.append(p);
          
          % color
          p = param({'color', 'Specify the line color'}, paramValue.STRING_VALUE('b'));
          out.append(p);
          
          % marker
          p = param({'marker', 'Specify the marker'}, {1, utils.plottools.allowedMarkers, paramValue.SINGLE});
          out.append(p);
          
          % markersize
          p = param({'markersize', 'Specify the marker size'}, paramValue.DOUBLE_VALUE(10));
          out.append(p);
          
          % showerrors
          p = param({'showerrors', 'Specify whether or not errors should be shown on a plot (if they exist).'}, paramValue.FALSE_TRUE);
          out.append(p);
          
        otherwise
          error('### Unknown set [%s]', set');
      end
    end
    
    function obj = initObjectWithSize(varargin)
      obj = plotinfo.newarray([varargin{:}]);
    end
    
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                          Methods (Static, Private)                        %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Static = true, Access = private)
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                         Methods (static, hidden)                          %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Static = true, Hidden = true)
    varargout = loadobj(varargin)
    varargout = update_struct(varargin)
  end
  
end

