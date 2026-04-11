% CHECKDATATYPE Throws an error for AOs with a specified data-type.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: CHECKDATATYPE Throws an error for AOs with a specified data-type.
%
% CALL:        aos.checkDataType('tsdata', 'cdata');
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function checkDataType(aos, varargin)
  
  % Loop over the data-types
  for tt=1:nargin-1
    dType = varargin{tt};
    
    for aa = 1:numel(aos)
      if isa(aos(aa).data, dType)
        stack = dbstack();
        error('### The method %s/%s doesn''t work for %s type AO.', class(aos), stack(2).name, dType);
      end
    end
  end
  
end
