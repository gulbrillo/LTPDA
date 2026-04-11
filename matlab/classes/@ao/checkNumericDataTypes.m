% CHECKNUMERICDATATYPES Throws an error for AOs if the numeric data types doesn't match to an AO method.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: CHECKNUMERICDATATYPES Throws an error for AOs if the numeric
%              data types doesn't match to the supported numeric data type
%              of an AO method.
%              This method checks only the y-values.
%
% CALL:        aos.checkDataType(methodInfoObject);
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function checkNumericDataTypes(aos, mInfoObj)
  
  % Loop over AOs
  for tt=1:numel(aos)
    numType = class(aos(tt).data.yaxis.data);
    if ~any(strcmp(mInfoObj.supportedNumTypes, numType))
      stack = dbstack();
      error('### The method ao/%s doesn''t support the numerical data type [%s] for object [%s].', stack(2).name, numType, aos(tt).name);
    end
  end
  
end
