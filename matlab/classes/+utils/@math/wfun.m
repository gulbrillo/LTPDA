% WFUN defines weighting factor for fitting procedures ctfit, dtfit.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION
% 
%     Defines the weigthing factor for the fitting procedure performed by
%     ctfit and dtfit.
% 
% CALL:
% 
%     weight = wfun(y,weightparam)
% 
% INPUT:
% 
%     y: are the set of data to be fitted
%     weightparam: is a parameter for the swhitching procedure. Admitted
%     values are:
%       weightparam = 1 --> equal weights (one) for each point. This is the
%       default option.
%       weightparam = 2 --> weight with the inverse of absolute value of
%       data
%       weightparam = 3 --> weight with square root of the inverse of
%       absolute value of data
%       weightparam = 4 --> weight with the inverse of the square mean
%       spread
%       
% 
% OUTPUT:
% 
%     weight: is the set of weighting factors
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function weight = wfun(y,weightparam)

  [a,b] = size(y);

  opt = 0; % default value
  if ~isempty(weightparam)
    opt = weightparam;
  end

  switch opt
    case 0
      disp(' Using external weights... ')
    case 1
      weight = ones(a,b); % equal weights for each point
    case 2
      weight = 1./abs(y); % weight with the inverse of absolute value of data
    case 3
      weight = 1./sqrt(abs(y)); % weight with square of the inverse of absolute value of data
    case 4
      my = mean(y,max(a,b));
      weight = 1./((y-my).^2); % weight with the inverse of the square mean spread
  end