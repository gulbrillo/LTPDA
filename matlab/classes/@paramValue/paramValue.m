% PARAMVALUE object class constructor.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: Parameter value object class constructor.
%              Create a parameter value object.
%
% SUPERCLASSES: ltpda_nuo < ltpda_obj
%
% CONSTRUCTORS:
%
%       p = paramValue();             - creates an empty parameter value
%       p = paramVAlue(pl)            - creates a parameter value from a
%                                       parameter list with the keys:
%                                       'valIndex', 'options' and 'selection'
%       p = paramValue(valIdx,  ...
%                      options)       - creates a parameter value from
%                                       value index and the options
%       p = paramValue(valIdx,  ...
%                      options, ...
%                      selectionMode) - creates a parameter value from
%                                       value index, options and
%                                       selection mode.
%
% SEE ALSO: ltpda_obj, ltpda_nuo, param, plist
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

classdef (Sealed = true, Hidden = true) paramValue < ltpda_nuo
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                            Property definition                            %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  %---------- Public (read/write) Properties  ----------
  properties
  end
  
  %---------- Protected read-only Properties ----------
  properties (SetAccess = protected)
    valIndex = -1; % Index to the value inside 'options'
    options = {}; % Possible values for 'val' if they exist
    selection = 0; % Selection mode for the 'options'
    property = struct([]); % A list which contains all additional infromation about the value like: min, max, ...
    readonly = false;
  end
  
  %---------- Protected Properties ----------
  properties (SetAccess = protected)
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                          Check property setting                           %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods
    function set.valIndex(obj, val)
      if obj.readonly
        error('Parameter value is readonly. Copy the plist before trying to modify it.');
      end
      if isnumeric(val)
        obj.valIndex = val;
      else
        error('### The value for the property ''valIndex'' must be a index (Interger) to the options. The value is from the class %s', class(val));
      end
    end
    function set.options(obj, val)
      if obj.readonly
        error('Parameter value is readonly. Copy the plist before trying to modify it.');
      end
      if iscell(val)
        obj.options = val;
      else
        error('### The value for the property ''options'' must be a cell with all possible values. The value is from the class %s', class(val));
      end
    end
    function set.selection(obj, val)
      if obj.readonly
        error('Parameter value is readonly. Copy the plist before trying to modify it.');
      end
      if isnumeric(val)
        obj.selection = val;
      else
        error('### The value for the property ''selection'' must be a Interger. The value is from the class %s', class(val));
      end
    end
    function set.property(obj, val)
      if obj.readonly
        error('Parameter value is readonly. Copy the plist before trying to modify it.');
      end
      obj.property = val;
    end
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                                Constructor                                %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods
    function obj = paramValue(varargin)
      
      switch nargin
        case 0
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%%   no input   %%%%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          
          % Do nothing
          
        case 1
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%%   one input   %%%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          
          if isa(varargin{1}, 'paramValue')
            %%%%%%%%%%  obj = paramValue(paramValue)   %%%%%%%%%%
            obj = copy(varargin{1}, 1);
            
          elseif isa(varargin{1}, 'plist')
            %%%%%%%%%%  obj = paramValue(plist)   %%%%%%%%%%
            
            if nparams(varargin{1}) == 0
              %%%%%%%%%%  obj = paramValue(plist())   %%%%%%%%%%
              %%% is the plist is empty then return an empty paramValue object
              
            else
              %%%%%%%%%%  pl  = plist('valIndex', 1, 'OPTIONS', {'a', 'b'}, 'SELECTION', 0) %%%%%%%%%%
              %%%%%%%%%%  obj = paramValue(pl)                                              %%%%%%%%%%
              pl = varargin{1};
              pl_valIndex  = pl.find_core('valIndex');
              pl_options   = pl.find_core('options');
              pl_selection = pl.find_core('selection');
              
              % Set the value index to 1 if there is only one option.
              if isempty(pl_valIndex) && numel(pl_options) == 1
                pl_valIndex = 1;
              end
              
              if isempty(pl_valIndex)
                error('### building a parameter from a plist requires one value index in the plist is called ''valIndex''');
              end
              if isempty(pl_options)
                error('### building a parameter from a plist requires at least one option in the plist is calles ''options''');
              end
              
              obj.valIndex = pl_valIndex;
              obj.options  = pl_options;
              if ~isempty(pl_selection)
                obj.selection = pl_selection;
              end
            end
            
          elseif isstruct(varargin{1})
            %%%%%%%%%%  obj = paramValue(struct)   %%%%%%%%%%
            obj = fromStruct(obj, varargin{1});
            
          else
            error('### Unknown single input paramValue constructor');
          end
          
        case 2
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%%   two inputs   %%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          
          %%%%%%%%%%  obj = paramValue(valIndex, {options})   %%%%%%%%%%
          obj.valIndex = varargin{1};
          obj.options  = varargin{2};
          
        case 3;
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%   three inputs   %%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          
          %%%%%%%%  obj = paramValue(valIndex, {options}, selection)   %%%%%%%%
          obj.valIndex  = varargin{1};
          obj.options   = varargin{2};
          if varargin{3} ~= obj.selection
            obj.selection = varargin{3};
          end
        otherwise
          error('### Unknown number of arguments.');
      end
      
      % Plausibility check.
      if ~(obj.valIndex <= numel(obj.options))
        error('### The valIndex must point to one element inside the ''options''. But valIndex is %d and the length of ''options'' is %d', obj.valIndex, numel(obj.options));
      end
      
    end
  end
  
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                              Methods (public)                             %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods
    
    varargout = getVal(varargin)
    varargout = getOptions(varargin)
    
    varargout = setValIndex(varargin)
    varargout = setValIndexAndOptions(varargin)
    varargout = setOptions(varargin)
    varargout = setSelection(varargin)
    
    varargout = setProperty(varargin)
    varargout = getProperty(varargin)
    
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
    
    
    % Param Value types
    function out = EMPTY_STRING
      out = '';
    end
    function out = EMPTY_DOUBLE
      out = [];
    end
    function out = EMPTY_CELL
      out = {};
    end
    
    function out = YES_NO
      out = {1, {'yes', 'no'}, paramValue.SINGLE};
    end
    function out = NO_YES
      out = {1, {'no', 'yes'}, paramValue.SINGLE};
    end
    
    function out = DATA_TYPES
      out = {4,{'tsdata', 'fsdata', 'xydata', 'cdata'}, paramValue.SINGLE};
    end
    
    function out = WINDOW
      prefs = getappdata(0, 'LTPDApreferences');
      dwin = find(strcmpi(char(prefs.getMiscPrefs.getDefaultWindow), specwin.getTypes));
      out = {dwin, specwin.getTypes, paramValue.SINGLE};
    end
    
    function out = STRING_VALUE(s)
      out = {1, {s}, paramValue.OPTIONAL};
    end
    
    function out = DOUBLE_VALUE(v)
      out = {1, {v}, paramValue.OPTIONAL};
    end
    
    function out = DETREND_ORDER
      out = {1, {-1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9}, paramValue.SINGLE};
    end
    
    function out = TRUE_FALSE
      out = {1, {true, false}, paramValue.SINGLE};
    end
    
    function out = FALSE_TRUE
      out = {1, {false, true}, paramValue.SINGLE};
    end
    
    function out = TIMEFORMAT
      prefs = getappdata(0, 'LTPDApreferences');
      tf = {...
        'dd-mm-yyyy HH:MM:SS', ...
        'yyyy-mm-dd HH:MM:SS', ...
        'dd-mm-yyyy HH:MM:SS.FFF', ...
        'yyyy-mm-dd HH:MM:SS.FFF', ...
        'HH:MM:SS dd-mm-yyyy', ...
        'HH:MM:SS yyyy-mm-dd', ...
        'HH:MM:SS.FFF dd-mm-yyyy', ...
        'HH:MM:SS.FFF yyyy-mm-dd', ...
        'dd.mm.yyyy HH:MM:SS', ...
        'yyyy.mm.dd HH:MM:SS', ...
        'dd.mm.yyyy HH:MM:SS.FFF', ...
        'yyyy.mm.dd HH:MM:SS.FFF', ...
        'HH:MM:SS dd.mm.yyyy', ...
        'HH:MM:SS yyyy.mm.dd', ...
        'HH:MM:SS.FFF dd.mm.yyyy', ...
        'HH:MM:SS.FFF yyyy.mm.dd', ...
        'MM:SS', ...
        'MM:SS.FFF'};
      
      idx = find(strcmp(char(prefs.getTimePrefs.getTimestringFormat), tf));
      if isempty(idx)
        tf = [{char(prefs.getTimePrefs.getTimestringFormat)} tf];
        idx = 1;
      end
      out = {idx, tf, paramValue.OPTIONAL};
    end
    
    function out = TIMEZONE
      prefs = getappdata(0, 'LTPDApreferences');
      tz = utils.timetools.getTimezone;
      
      idx = find(strcmp(prefs.getTimePrefs.getTimeTimezone(), tz));
      out = {idx, tz, paramValue.SINGLE};
    end
    
    function res = OPTIONAL(); res = 0; end
    function res = SINGLE();   res = 1; end
    function res = MULTI();    res = 2; end
    function str = getSelectionMode(val)
      switch val
        case 0
          str = 'OPTIONAL';
        case 1
          str = 'SINGLE';
        case 2
          str = 'MULTI';
        otherwise
          str = '''selection'' is not valid!';
      end
    end
    
    function ii = getInfo(varargin)
      ii = utils.helper.generic_getInfo(varargin{:}, 'paramValue');
    end
    
    function out = SETS()
      out = {'Default'};
    end
    
    function out = getDefaultPlist(set)
      switch lower(set)
        case 'default'
          out = plist();
        otherwise
          error('### Unknown set [%s]', set');
      end
    end
    
    function obj = initObjectWithSize(varargin)
      obj = paramValue.newarray([varargin{:}]);
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

