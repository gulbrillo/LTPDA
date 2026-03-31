% spflat measures the flatness of a given spectrum
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% DESCRIPTION: spflat measures the flatness of a given spectrum using the
% spectral flatness measure method reported in [1]. It outputs the spectral
% flatness coefficient:
% 
% 0 <= sw <= 1
% 
% If the spectrum is peaky then sw is near 0. The more the spectrum is flat
% the more sw in near to 1. The sw coefficient is practically calculated by
% the ratio between geometric mean and arithmetic mean of the spectrum.
% 
% CALL:
% 
%         sw = spflat(S)
% 
% INPUTS:
% 
%         - S sample power spectrum. More than one sample spectrum can be
%         input if they are combined in a single nxm matrix. The algorithm
%         calculates sw for each spectrum.
% 
% OUTPUT:
% 
%         - sw spectral flatness coefficient. If more than one spectrum
%         are input sw is a row vector. 
% 
% REFERENCES:
% 
%         [1] S. M. Kay, Modern spectral estimation:Theory and Application,
%         Prentice Hall, Englewood Cliffs (1988) ISBN-10: 0130151599. Pages
%         ??.
%
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function sw = spflat(S)
  
  % willing to work with columns  
  [a,b] = size(S);
  if a>1 && b>1
    warning('Matlab:MultipleSpectra','A matrix of data was input; Spectral Flatness Coefficient will be calculated for each column')
  else
    if a<b
      S = S.';
    end
  end
  Ns = size(S,1);
  gmean = exp(sum(log(S))./Ns);
  sw = gmean./mean(S);
  
end