% DATA2D is the abstract base class for 2-dimensional data objects.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: DATA2D is the base class for 2-dimensional data objects. This is
%              an abstract class.
%
% SUPER CLASSES: ltpda_data < ltpda_nuo < ltpda_obj
%
% SEE ALSO: ltpda_data, fsdata, tsdata, xydata, data3D
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

classdef (Hidden = true) data2D < ltpda_data
  
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                            Property definition                            %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  %---------- Public (read/write) Properties  ----------
  properties (GetAccess = public, SetAccess = public)
    xaxis = []; % an ltpda_vector object
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
    %--- xaxis
    function set.xaxis(obj, val)
      if  ~isempty(val) && ~isa(val, 'ltpda_vector')
        error('### The value for the property ''xaxis'' must be an ltpda_vector object');
      end
      obj.xaxis = val;
    end
  end
  
  % -------- Getter Methods ------
  methods
    function value = x(obj, varargin)
      % Returns the x values of the data object.
      switch nargin
        case 1
          value = obj.xaxis.data;
        case 2
          value = obj.xaxis.data(varargin{1});
        otherwise
          error('Incorrect inputs');
      end
    end
    
    function value = dx(obj, varargin)
      % Returns the dx values of the data object.
      switch nargin
        case 1
          value = obj.xaxis.ddata;
        case 2
          value = obj.xaxis.ddata(varargin{1});
        otherwise
          error('Incorrect inputs');
      end
    end
    
    function value = xunits(obj)
      % Returns the xunits of the data object.
      value = obj.xaxis.units;
      if isempty(value)
        value = unit();
      end
    end
    
    function value = xaxisname(obj)
      % Returns the name of the x-axis.
      value = obj.xaxis.name;
    end
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                                Constructor                                %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods
    function obj = data2D(varargin)
      createXaxis(obj);
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
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                              Methods (protected)                          %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = protected)
    varargout = fromStruct(varargin)
    
    function createXaxis(obj)
      obj.xaxis = ltpda_vector();
      obj.xaxis.setName('x');
    end
    
    function xaxisDataWillChange(varargin)
      % This method validates the inputs for 'x'
      % obj       = varargin{1};
      % newValues = varargin{2};
      if ~isempty(varargin{2})
        if ~isnumeric(varargin{2}) && ~islogical(varargin{2}) || ~isvector(varargin{2})
          error('### The x-values must be a numeric vector.')
        end
      end
    end
    
    function xaxisDdataWillChange(varargin)
      % This method validates the inputs for 'dx'.
      % This method is only necessary for the case that we have evenly
      % sampled data and the user want to set 'dx'. The ltpda_vector()
      % class can not keep the shape of the y-axis because there are no
      % x-values who have the shape of the y-values. Only here in the data
      % do we have access to the shape of the y-values.
      obj       = varargin{1};
      newValues = varargin{2};
      if ~isempty(varargin{2}) && isempty(obj.xaxis.data)
        dataSz = size(obj.yaxis.data);
        valSz  = size(newValues);
        if ~isnumeric(newValues)
          error('### The value for the property ''ddata'' must be a numeric value');
        elseif numel(newValues) == 1
          % Accept a single value
          % xaxisDdataDidChange() will change it to a vector
        elseif ~all(dataSz == valSz) && ~all(dataSz == fliplr(valSz))
          error('### The value for the property ''ddata'' must have the length 0, 1 or the same shape of the data-values. ddata [%d,%d] data [%d,%d]', size(newValues), size(obj.yaxis.data));
        end
      end
    end
    
    function yaxisDataWillChange(varargin)
      % This method validates the inputs for 'y'
      % obj       = varargin{1};
      % newValues = varargin{2};
      if ~isempty(varargin{2})
        if ~isnumeric(varargin{2}) && ~islogical(varargin{2}) || ~isvector(varargin{2})
          error('### The y-values must be a numeric vector.')
        end
      end
    end
    
    function xaxisDataDidChange(varargin)
      obj = varargin{1};
      if ~isempty(obj.xaxis) && ~isempty(obj.yaxis) && ~isempty(obj.xaxis.data) && ~isempty(obj.yaxis.data)
        % if both axis are not empty then check that the x-axis match to
        % the y-axis
        if xor(iscolumn(obj.xaxis.data), iscolumn(obj.yaxis.data)) && numel(obj.xaxis.data) ~= 1
          obj.xaxis.transpose();
        end
      end
    end
    
    function xaxisDdataDidChange(varargin)
      obj = varargin{1};
      if ~isempty(obj.xaxis) && ~isempty(obj.yaxis) && ~isempty(obj.xaxis.ddata) && ~isempty(obj.yaxis.data)
        % if both axis are not empty then check that check if the shape of
        % 'dx' match to the y-axis
        obj       = varargin{1};
        newValues = varargin{2};
        if numel(newValues) == 1
          if ~isempty(obj.xaxis.data)
            % Expand to the size of the x-axis
            newValues = newValues*ones(size(obj.xaxis.data));
            obj.xaxis.setDdata(newValues);
          else
            % Expand to the size of the x-axis
            newValues = newValues*ones(size(obj.yaxis.data));
            obj.xaxis.setDdata(newValues);
          end
        end
        % Check that the shape of 'Dx' match to 'y'
        if xor(iscolumn(obj.yaxis.data), iscolumn(newValues))
          obj.xaxis.setDdata(newValues.');
        end
      end
    end
    
    function yaxisDataDidChange(varargin)
      obj = varargin{1};
      if ~isempty(obj.xaxis) && ~isempty(obj.yaxis) && ~isempty(obj.xaxis.data) && ~isempty(obj.yaxis.data)
        % if both axis are not empty then check that the x-axis match to
        % the y-axis
        if xor(iscolumn(obj.xaxis.data), iscolumn(obj.yaxis.data)) && numel(obj.xaxis.data) ~= 1
          obj.xaxis.transpose();
        end
      end
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
      ii = utils.helper.generic_getInfo(varargin{:}, 'data2D');
    end
    
    function out = SETS()
      out = {};
    end
    
    function out = getDefaultPlist()
      out = [];
    end
    
  end
  
end

