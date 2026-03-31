%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Perform a regularization of a PSD for fitting a model using least
% squares.
% 
% CALL: yr = utils.math.regularizePSDForFit(y,psdmod,regularizecoeff,navs)
%
% INPUTS: y - PSD data
%         psdmod - the fit model obtained by a first attempt to fit with
%         least squares
%         regularizecoeff - If you know your regularizing coefficient you
%         can input it. There is no need to provide a model in this case
%         navs - number of averages for the psd calculation
%
% OUTPUTS: yr - regularized psd
%
% ALGORITHM: In case you know your regularizing coefficient then it is
% added to data in log space. The regularizing coefficient can be also
% automatically calculated by a comparison of the histogram of the
% normalized psd and the expected gamma distribution.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function yr = regularizePSDForFit(y,psdmod,regularizecoeff,navs)

  if isempty(regularizecoeff)

    wS = y./psdmod;
    
    
%     % aproximate the difference of the mode
%     histsize = numel(y)/100;
%     if histsize<10
%       histsize = 10;
%     end
% 
%     [hst,xx] = hist(wS,histsize);
% 
%     gm = utils.math.gammapdf(xx,navs,1/navs);
% 
%     [mm,idxm1] = max(hst);
%     xx1 = xx(idxm1);
%     [mm,idxm2] = max(gm);
%     xx2 = xx(idxm2);
% 
%     regge = abs(xx2-xx1);
    
    % approximate the difference of the median
    % get empirical median
    xx1 = median(wS);
    % approximate the median for a gamma dstribution
    xx2 = (1/navs)*gammaincinv(0.5,navs);
    regge = abs(xx2-xx1);
  
    yr = exp(log(y) + regge);
    
%     regge = abs(mean(wS)-1)/2;
%     yr = 10.^(log10(y) + regge*log10(exp(1)));

  else

    yr = exp(log(y) + regularizecoeff);

  end

end
