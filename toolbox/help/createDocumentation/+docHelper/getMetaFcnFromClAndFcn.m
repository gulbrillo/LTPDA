% GETMETAFCNFROMCLANDFCN returns the meta information of a function specified by the class and function name.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: GETMETAFCNFROMCLANDFCN returns the meta information of a
%              function specified by the class and function name.
%
% CALL:        m = docHelper.getMetaFcnFromClAndFcn(cl, fcn)
%
% INPUTS:      cl  - String of the class name
%              fcn - String of the function name
%
% VERSION:     $Id$
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function metaFcn = getMetaFcnFromClAndFcn(cl, fcn)
  
  if ischar(cl) && ischar(fcn)
    metaCl = meta.class.fromName(cl);
    
    % Get the meta-method objects from the meta.class
    metaFcns = docHelper.getMetaMethList(metaCl);

    idx = strcmp({metaFcns.Name}, fcn);
	
    metaFcn = metaFcns(idx);
    if numel(metaFcn) ~= 1
      error('### There is something wrong because I found more or less than one meta information of the function [%s]', fcn);
    end
  else
    error('### Please use two strings for the class and function name.');
  end
  
end
