% LTPDANAMEDITEM is a base class for naming various items.
%
% CALL:
%         item = LTPDANamedItem(name)
%         item = LTPDANamedItem(name, description)
%         item = LTPDANamedItem(name, description, units)
%
% LTPDANamedItem properties:
%
%                 name - The name for this item
%          description - Description
%                units - Units associated with this item
%
% See also: ltpda_uo
%
% M Hewitson 2015-10-03
%
%
classdef LTPDANamedItem < ltpda_uo
  
  properties (SetAccess=protected)
    units               = ''; % The units of the signal (intended to override what's in the MIB)
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                                Setter Rules                               %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  methods
    
    % Rule for: units
    function set.units(obj, val)
      if ~isempty(val)
        if ischar(val)
          obj.units = unit(val);
        elseif isa(val, 'unit')
          obj.units = val;
        else
          error('The unit should be specified as a string or a unit object');
        end
      end
    end
    
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                                Constructor                                %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  methods
    
    function p = LTPDANamedItem(varargin)
      
      switch numel(varargin)
        case 0
          %%%%%%%%%%   p = LTPDANamedItem()   %%%%%%%%%%
          
        case 1
          if ischar(varargin{1})
            %%%%%%%%%%   p = LTPDANamedItem('name')   %%%%%%%%%%
            p.name = varargin{1};
            
          elseif isstruct(varargin{1})
            %%%%%%%%%%  p = LTPDANamedItem(struct)   %%%%%%%%%%
            p = fromStruct(p, varargin{1});
            
          else
            error(LTPDANamedItem.createErrorStr(varargin{:}));
          end
          
        case 2 % LTPDANamedItem(name, description)
          
          if isa(varargin{1},  'org.apache.xerces.dom.ElementImpl') && ...
              isa(varargin{2}, 'history')
            %%%%%%%%%%   p = LTPDANamedItem(DOM node, history-objects)   %%%%%%%%%%
            p = fromDom(p, varargin{1}, varargin{2});
            return;
            
          elseif ischar(varargin{1}) && ischar(varargin{2})
            %%%%%%%%%%   p = LTPDANamedItem('name', 'desc')   %%%%%%%%%%
            p.name        = varargin{1};
            p.description = varargin{2};
            
          else
            error(LTPDANamedItem.createErrorStr(varargin{:}));
          end
          
        case 3 % LTPDANamedItem(name, description, units)
          
          if ischar(varargin{1}) && ischar(varargin{2}) && (ischar(varargin{3}) || isa(varargin{3}, 'unit'))
            %%%%%%%%%%   p = LTPDANamedItem('name', 'desc', 's')   %%%%%%%%%%
            %%%%%%%%%%   p = LTPDANamedItem('name', 'desc', unit('s'))   %%%%%%%%%%
            p.name        = varargin{1};
            p.description = varargin{2};
            p.units       = varargin{3};
            
          else
            error(LTPDANamedItem.createErrorStr(varargin{:}));
          end
          
        otherwise
          error(LTPDANamedItem.createErrorStr(varargin{:}));
      end
      
    end % End of constructor
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                              Methods (public)                             %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  methods
    
    function out = char(objs)
      % CHAR returns the name of the given objects. For
      % more than one item, a cell-array is returned.
      %
      % CALL
      %         names = char(items);
      %
      out = {};
      for kk=1:numel(objs)
        out = [out {objs(kk).name}];
      end
      if numel(out) == 1
        out = out{1};
      end
    end % End char()
    
    function out = aliases(objs)
      % aliases are defined for some daughter classes (MTelemetry and it's
      % daughters LTPDATelemetry and ST7Telemetry). Here we provide a
      % default behavior with no aliases.
      out = {};
    end % End aliases()
    
    function out = preferredAliasName(objs)
      % preferred aliases are defined for some daughter classes (MTelemetry
      % and it's daughters LTPDATelemetry and ST7Telemetry). Here we
      % provide a default behavior that returns the names.
      if numel(objs) == 1
        out = objs.name;
      else
        out = {objs.name};
      end
    end % End preferredAliasName()
    
    function itemNames = getAllParameterNames(item)
      if numel(item) > 1
        error('This method works only for one %s object', class(item));
      end
      itemNames = {item.name};
    end
    
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = public, Hidden = true)
    varargout = attachToDom(varargin)
    varargout = fromDom(varargin)
  end
  
  methods (Access = public, Static = true, Hidden = true)
    varargout = loadobj(varargin)
    varargout = update_struct(varargin)
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                            Methods (static)                               %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  methods (Static=true)
    
    varargout = listGroups(varargin)
    varargout = listContentsOfGroup(varargin)

    function obj = initObjectWithSize(varargin)
      obj = LTPDANamedItem.newarray([varargin{:}]);
    end
    function ii = getInfo(varargin)
      ii = utils.helper.generic_getInfo(varargin{:}, mfilename('class'));
    end
  end
  
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                              Methods (protected)                          %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = protected)
    varargout = fromStruct(varargin)
  end
  
end
% END
