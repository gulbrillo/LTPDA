% LTPDA_VECTOR encapsulates the details of a data vector.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION:   LTPDA_VECTOR encapsulates the details of a data vector.
%
% SUPERCLASSES: ltpda_nuo < ltpda_obj
%
% SEE ALSO:    data2D, ltpda_nuo, ltpda_obj, cdata
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

classdef (Hidden = true) ltpda_vector < ltpda_nuo
  
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                            Property definition                            %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  %---------- Public (read/write) Properties  ----------
  properties (GetAccess = public, SetAccess = public)
  end
  
  %---------- Protected read-only Properties ----------
  properties (GetAccess = public, SetAccess = protected)
  end
  
  %---------- Private Properties ----------
  properties (GetAccess = public, SetAccess = private)
    units  = ''; % units of the data
    data   = []; % data values
    ddata  = []; % errors on values
    name   = ''; % name of the data
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                          Check property setting                           %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods
    %--- units
    function set.units(obj, val)
      if ~ischar(val) && ~isa(val, 'unit') && ~isempty(val)
        error('### The value for the property ''units'' must be a unit-object or a string');
      end
      if ~isempty(val)
        if ischar(val)
          obj.units = unit(val);
        elseif isa(val, 'unit')
          obj.units = val;
        else
          error('### The units value must be a unit or a string');
        end
      else
        obj.units = '';
      end
    end
    
    %--- data
    function set.data(obj, val)
      if ~isempty(val)
        obj.data = transposeValues(obj, val);
        obj.checkDdataShape();
      else
        obj.data = val;
      end
    end
    
    %--- ddata
    function set.ddata(obj, val)
      if ~isempty(val) && ~isempty(obj.data)
        dataSz = size(obj.data);
        valSz  = size(val);
        if ~isnumeric(val)
          error('### The value for the property ''ddata'' must be a numeric value');
        elseif numel(val) == 1
          val = val * ones(size(obj.data));
          % The ddata can be a single value
        elseif ~all(dataSz == valSz) && ~all(dataSz == fliplr(valSz))
          error('### The value for the property ''ddata'' must have the length 0, 1 or the same shape of the data-values. ddata [%d,%d] data [%d,%d]', size(val), size(obj.data));
        end
      end
      obj.ddata = transposeValues(obj, val);
    end
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                                Constructor                                %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods
    
    function obj = ltpda_vector(varargin)
      obj.name = 'Value';
      
      switch nargin
        case 0
          % do nothing
          
        case 1
          if isstruct(varargin{1})
            %%%%%%%%%%   a1 = ao(struct)   %%%%%%%%%%
            obj = fromStruct(obj, varargin{1});
          else
            %%%%%%%%%%   obj = ltpda_vector(data)
            obj.data = varargin{1};
          end
          
        case 2
          if isnumeric(varargin{1}) && isnumeric(varargin{2})
            %%%%%%%%%%   obj = ltpda_vector(data, ddata)
            obj.data  = varargin{1};
            obj.ddata = varargin{2};
          elseif isa(varargin{1}, 'org.apache.xerces.dom.ElementImpl') && isa(varargin{2}, 'history')
            %%%%%%%%%%   obj = ltpda_vector(DOM node, history-objects)   %%%%%%%%%%
            obj = fromDom(obj, varargin{1}, varargin{2});
          else
            error('### Unknown constructor method for two inputs.');
          end
          
        case 3
          %%%%%%%%%%   obj = ltpda_vector(data, ddata, units)
          obj.data  = varargin{1};
          obj.ddata = varargin{2};
          obj.units = varargin{3};
          
        case 4
          %%%%%%%%%%   obj = ltpda_vector(data, ddata, units, name)
          obj.data  = varargin{1};
          obj.ddata = varargin{2};
          obj.units = varargin{3};
          obj.name  = varargin{4};
        otherwise
          error('Incorrect number inputs');
      end
    end
    
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                              Methods (public)                             %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                              Methods (hidden)                             %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Hidden = true)
    varargout = attachToDom(varargin)
    varargout = fromDom(varargin)
    function transpose(obj)
      localData  = obj.data;
      localDdata = obj.ddata;
      obj.data = [];
      obj.data = localData.';
      obj.ddata = localDdata;
    end
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
    
    function val = transposeValues(obj, val)
      
      % the most common case is that the vals are empty, in which case we
      % can return now.
      if isempty(val)
        return
      end
      
      % if we have no data, then the shape of val will set
      if isempty(obj.data)
        return
      end
      
      sval = size(val);
      sd   = size(obj.data);
      
      % the second most common case, where values are being updated but the
      % length is not different.
      if all(sval == sd)
        return
      end
      
      if  ~all(sd == sval) && all(sd == fliplr(sval))
        % Transpose the values if the matrix/vector have the transposed
        % shape. BUT not the same shape.
        val = val.';
      elseif isvector(obj.data) && isvector(val) && xor(iscolumn(obj.data), iscolumn(val))
        % Transpose the values if the data values are a vector and the
        % new values doesn't fit to the current vector.
        val = val.';
      end
      
    end
    
    function checkDdataShape(obj)
      
      % most common case is probably that the errors are empty.
      if isempty(obj.ddata)
        return
      end
      
      % Check the ddata only if there are more than one error values.
      if length(obj.ddata) > 1
        dataSz  = size(obj.data);
        ddataSz = size(obj.ddata);
        if dataSz == fliplr(ddataSz)
          obj.ddata = obj.ddata.';
        elseif ~all(dataSz == ddataSz) && ~all(dataSz == fliplr(ddataSz))
          warning('ltpda_vector:checkDdataShape', '!!! The shape of the error (ddata) doesn''t fit any more to the shape of the data. Set the error (ddata) to an empty array.');
          obj.ddata = [];
        end
      end
    end
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
      ii = utils.helper.generic_getInfo(varargin{:}, 'ltpda_vector');
    end
    
    function out = SETS()
      out = {};
    end
    
    function out = getDefaultPlist()
      out = [];
    end
    
  end
  
end

