% MSYM LTPDA symbolic class class constructor.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: MSYM LTPDA symbolic class class constructor.
%              This class is used for the expression in a smodel object.
%
% CONSTRUCTORS:
%
%       s = msym()       - creates an empty msym object.
%       s = msym(str)    - creates a msym object with the expression str.
%
% SEE ALSO: smodel
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

classdef (Hidden = true) msym < ltpda_nuo
  
  properties
    s = '';
  end
  
  methods
    
    function ms = msym(varargin)
      
      if isstruct(varargin{1})
        ms.s = varargin{1}.s;
      else
        if ischar(varargin{1})
          ms.s = varargin{1};
        elseif isnumeric(varargin{1})
          ms.s = mat2str(varargin{1});
        elseif isa(varargin{1}, 'msym')
          ms.s = varargin{1}.s;
        else
          error('### Unknown class [%s] to convert it to a symbolic class.', class(varargin{1}));
        end
      end
      
    end
    
  end
  
  methods (Static = true)
    function obj = initObjectWithSize(varargin)
      obj = msym.newarray([varargin{:}]);
    end
  end
  
  methods (Static = true, Hidden = true)
    varargout = loadobj(varargin)
    varargout = update_struct(varargin);
  end
  
end
