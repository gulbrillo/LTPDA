% LTPDA_FILTER is the abstract base class for ltpda filter objects.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: LTPDA_FILTER is the abstract base class for ltpda filter objects.
%
% SUPER CLASSES: ltpda_tf < ltpda_uoh < ltpda_uo < ltpda_obj
%
% SUB CLASSES:   miir, mfir
%
% LTPDA_FILTER PROPERTIES:
%
%     Protected Properties (read only)
%       a             - set of numerator coefficients
%       description   - description of the object
%       fs            - sample rate that the filter is designed for
%       hist          - history of the object (history object)
%       histout       - input history values to filter
%       infile        - filename if the filter was loaded from file
%       name          - name of the object
%       iunits        - input units of the object
%       ounits        - output units of the object
%
% LTPDA_FILTER METHODS:
%
%     Public Methods
%       bsubmit         - Bsubmits the given collection of objects to an
%                         LTPDA Repository.
%       created         - Returns a time object of the last modification.
%       creator         - Extract the creator(s) from the history.
%       eq              - Overloads the == operator for ltpda objects.
%       get             - Get a property of a object.
%       index           - Index into a 'ltpda_uoh' object array or matrix.
%                         This properly captures the history.
%       isprop          - Tests if the given field is one of the object
%                         properties.
%       ne              - Overloads the ~= operator for ltpda objects.
%       rebuild         - Rebuilds the input objects using the history.
%       report          - Generates an HTML report about the input objects.
%       resp            - Make a frequency response of the filter.
%       impresp         - Make an impulse response of the filter.
%       save            - Overloads save operator for ltpda objects.
%       setDescription  - Sets the 'description' property of an ltpda_uoh
%                         object.
%       setHistout      - Set the property 'histout'
%       setIunits       - Sets the 'iunits' property of the ao.
%       setName         - Set the property 'name'.
%       setOunits       - Sets the 'ounits' property of the ao.
%       setProperties   - Set different properties of an object.
%       string          - Writes a command string that can be used to
%                         recreate the input object(s).
%       submit          - Submits the given collection of objects to an
%                         LTPDA Repository.
%       type            - Converts the input objects to MATLAB functions.
%
%     Static Methods
%       SETS            - Retruns the different sets of the constructor
%       getDefaultPlist - Returns the default plsit for the specified set-name
%       getInfo         - Static method to get information of a method
%       retrieve        - Retrieves a collection of objects from an LTPDA
%                         repository
%
%     Abstract Methods
%       char
%       copy
%       display
%
% SEE ALSO:    miir, mfir, ltpda_tf, ltpda_uoh, ltpda_uo, ltpda_obj
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

classdef (Hidden = true) ltpda_filter < ltpda_tf
  
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                            Property definition                            %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  %---------- Protected read-only Properties ----------
  properties (SetAccess = protected)
    fs      = []; % sample rate that the filter is designed for
    infile  = ''; % filename if the filter was loaded from file
    a       = []; % set of numerator coefficients
    histout = []; % output history values of the filter
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                          Check property setting                           %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods
    function set.fs(obj, val)
      if ~isempty(val)
        if ~isnumeric(val) || ~isreal(val) || val < 0
          error('### The value for the property ''fs'' must be a real positive number');
        end
      end
      obj.fs = val;
    end
    function set.infile(obj, val)
      if ~(ischar(val) || isempty(val))
        error('### The value for the property ''infile'' must be a string');
      end
      obj.infile = val;
    end
    function set.histout(obj, val)
      if ~isempty(val)
        if ~isnumeric(val)
          error('### The value for the property ''histout'' must be a number(s)');
        end
      end
      obj.histout = val;
    end
    function set.a(obj, val)
      if ~isempty(val)
        if ~isnumeric(val)
          error('### The value for the property ''a'' must be a number(s)');
        end
      end
      obj.a = val;
    end
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                                Constructor                                %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods
    function obj = ltpda_filter(varargin)
    end
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                              Methods (public)                             %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = public)
    varargout = setA(varargin)
    varargout = setHistout(varargin)
    varargout = impresp(varargin)
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = public, Hidden = true)
    varargout = attachToDom(varargin)
    varargout = fromDom(varargin)
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                         Methods (public, static)                          %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = public, Static = true)
    function ii = getInfo(varargin)
      ii = utils.helper.generic_getInfo(varargin{:}, 'ltpda_filter');
    end
    
    function out = SETS()
      out = {};
    end
    
    function out = getDefaultPlist()
      out = [];
    end
    
    function obj = initObjectWithSize(varargin)
      obj = ltpda_filter.newarray([varargin{:}]);
    end
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = public, Static = true, Hidden = true)
    varargout = loadobj(varargin)
    varargout = update_struct(varargin)
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                              Methods (protected)                          %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = protected)
    varargout = fromStruct(varargin)
    varargout = respCore(varargin)
    varargout = setInfile(varargin)
    varargout = setFs(varargin)
  end
  
end

