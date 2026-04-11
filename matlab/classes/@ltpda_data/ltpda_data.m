% LTPDA_DATA is the abstract base class for ltpda data objects.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION:   LTPDA_DATA is the base class for ltpda data objects.
%                This is an abstract class.
%
% SUPERCLASSES: ltpda_nuo < ltpda_obj
%
% SEE ALSO:    data2D, ltpda_nuo, ltpda_obj, cdata
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

classdef (Hidden = true) ltpda_data < ltpda_nuo
  
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                            Property definition                            %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  %---------- Public (read/write) Properties  ----------
  properties (GetAccess = public, SetAccess = public)
    yaxis  = []; % an ltpda_vector object
  end
  
  %---------- Protected read-only Properties ----------
  properties (GetAccess = public, SetAccess = protected)
  end
  
  %---------- Private Properties ----------
  properties (GetAccess = public, SetAccess = private)
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                          Check property setting                           %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods
    %--- Yaxis
    function set.yaxis(obj, val)
      if ~isempty(val) && ~isa(val, 'ltpda_vector')
        error('### The value for the property ''yaxis'' must be an ltpda_vector object');
      end
      obj.yaxis = val;
    end
  end
  
  % -------- Getter Methods ------
  methods
    
    function value = y(obj, varargin)
      % Returns the y values of the data object.
      switch nargin
        case 1
          value = obj.yaxis.data;
        case 2
          value = obj.yaxis.data(varargin{1});
        otherwise
          error('Incorrect inputs');
      end
    end
    
    function value = dy(obj, varargin)
      % Returns the dy values of the data object.
      switch nargin
        case 1
          value = obj.yaxis.ddata;
        case 2
          value = obj.yaxis.ddata(varargin{1});
        otherwise
          error('Incorrect inputs');
      end
    end
    
    function value = yunits(obj)
      % Returns the yunits of the data object.
      value = obj.yaxis.units;
      if isempty(value)
        value = unit();
      end
    end
    
    function value = yaxisname(obj)
      % Returns the name of the y-axis.
      value = obj.yaxis.name;
    end
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                                Constructor                                %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods
    function obj = ltpda_data(varargin)
      createYaxis(obj);
    end
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                              Methods (public)                             %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods
    function ts = getTimespan(varargin)
      ts = [];
    end
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                              Methods (hidden)                             %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Hidden = true)
    varargout = attachToDom(varargin)
    varargout = fromDom(varargin)
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                              Methods (protected)                          %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = protected)
    varargout = fromStruct(varargin)
    
    function createYaxis(obj)
      obj.yaxis = ltpda_vector();
      obj.yaxis.setName('y');
    end
    
    function yaxisDataWillChange(varargin)
      %       disp('ltpda_data: yaxisDataWillChange');
      % obj       = varargin{1};
      % newValues = varargin{2};
      if ~isempty(varargin{2})
        if ~isnumeric(varargin{2}) && ~islogical(varargin{2}) || ~ismatrix(varargin{2})
          error('### The y-values must be numeric and a matrix.')
        end
      end
    end
    
    function yaxisDataDidChange(varargin)
      %       disp('ltpda_data: yaxisDataDidChange');
    end
    
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                              Methods (private)                            %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = private)
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                         Methods (static, hidden)                          %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Static = true, Hidden = true)
    varargout = loadobj(varargin)
    varargout = update_struct(varargin)
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                              Methods (static)                             %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Static)
    
    function ii = getInfo(varargin)
      ii = utils.helper.generic_getInfo(varargin{:}, 'ltpda_data');
    end
    
    function out = SETS()
      out = {};
    end
    
    function out = getDefaultPlist()
      out = [];
    end
    
  end
  
end

