% LTPDA_TF is the abstract class which defines transfer functions.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: LTPDA_TF is the abstract class which defines transfer functions.
%
% SUPER CLASSES: ltpda_uoh < ltpda_uo < ltpda_obj
%
% SUB CLASSES:   miir, mfir, pzmodel, rational, parfrac, ltpda_filter
%
% LTPDA_TF PROPERTIES:
%
%     Protected Properties (read only)
%       description   - description of the object
%       hist          - history of the object (history object)
%       name          - name of the object
%       iunits        - input units of the object
%       ounits        - output  units of the object
%
% LTPDA_TF METHODS:
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
%       resp            - Returns the complex response of a transfer
%                         function as an Analysis Object.
%       save            - Overloads save operator for ltpda objects.
%       setDescription  - Sets the 'description' property of an ltpda_uoh
%                         object.
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
%                         repository.
%
%     Abstract Methods
%       char
%       copy
%       display
%
% SEE ALSO:    miir, mfir, pzmodel, parfrac, rational, ltpda_uoh, ltpda_uo, ltpda_obj
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

classdef (Hidden = true) ltpda_tf < ltpda_uoh
  
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                            Property definition                            %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  %---------- Protected read-only Properties ----------
  properties (SetAccess = protected)
    iunits = unit(); % input units of the object
    ounits = unit(); % output  units of the object
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                          Check property setting                           %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods
    function set.iunits(obj, val)
      if ischar(val)
        val = unit(val);
      elseif isa(val, 'unit')
      else
        error('### The value for the property ''iunits'' must be a char or a unit-object');
      end
      obj.iunits = val;
    end
    function set.ounits(obj, val)
      if ischar(val)
        val = unit(val);
      elseif isa(val, 'unit')
      else
        error('### The value for the property ''ounits'' must be a char or a unit-object');
      end
      obj.ounits = val;
    end
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                                Constructor                                %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods
    function obj = ltpda_tf(varargin)
    end
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                             Methods (public)                              %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = public)
    varargout = resp(varargin)
    varargout = setIunits(varargin)
    varargout = setOunits(varargin)
    varargout = simplifyUnits(varargin);
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
      ii = utils.helper.generic_getInfo(varargin{:}, 'ltpda_tf');
    end
    
    function out = SETS()
      out = {};
    end
    
    function out = getDefaultPlist()
      out = [];
    end
    
    function obj = initObjectWithSize(varargin)
      obj = ltpda_tf.newarray([varargin{:}]);
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
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                              Methods (abstract)                           %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Abstract, Access = protected)
    r = respCore(obj, f)
  end
  
end

