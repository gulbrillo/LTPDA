%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Function fitpriors fits the pdf computed from a pest object.          %
%   It returns matrix (# of params x 3) with the mean, sigma and          %
%   normalization constant for each parameter at each column. -Nikos-     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function params = fitPrior(prior,nparam,chain,bins) 
params = [];

    for ii=1:nparam
    x = linspace(min(prior(:,2*ii-1)),max(prior(:,2*ii-1)),bins);
    y = normpdf(x,mean(chain(:,ii)),std(chain(:,ii)));  
    s=sum(y);
    params(ii,:) = [mean(chain(:,ii)) std(chain(:,ii)) s];
    end
end