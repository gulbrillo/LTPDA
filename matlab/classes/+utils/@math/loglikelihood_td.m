%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Compute log-likelihood in time domain assuming a multivariate gaussian
% distribution
% 
% INPUT
% 
% - res, a vector of AOs containing residuals
% - noise, a vector of AOs containing noise
% - cutbefore, followed by the data samples to cut at the starting of the
% data series
% - cutafter, followed by the data samples to cut at the ending of the
% data series
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function loglk = loglikelihood_td(res,noise,varargin)

  cutbefore = [];
  cutafter = [];
  if ~isempty(varargin)
    for j=1:length(varargin)
      if strcmp(varargin{j},'cutbefore')
        cutbefore = varargin{j+1};
      end
      if strcmp(varargin{j},'cutafter')
        cutafter = varargin{j+1};
      end
    end
  end
  
  nres = numel(res);
  loglk = 0;
  
  for ii=1:nres
    
    yres = res(ii).y;
    ynoise = noise(ii).y;
    % willing to work with rows
    if size(yres,2)<size(yres,1)
      yres = yres.';
    end
    if size(ynoise,2)<size(ynoise,1)
      ynoise = ynoise.';
    end
    if ~isempty(cutbefore)
      yres(1:cutbefore) = [];
      ynoise(1:cutbefore) = [];
    end
    if ~isempty(cutafter)
      yres(end-cutafter:end) = [];
      ynoise(end-cutafter:end) = [];
    end
    
%     R = utils.math.Rcovmat(yres);
%     
%     xx = R\yres.';
%     Ndim = numel(yres);
%     
%     loglk = loglk + abs(xx'*xx)./Ndim;

    cmat = utils.math.xCovmat(ynoise);
    
    [L,p] = chol(cmat,'lower');
    if p==0
      xx = L\yres.';
      Ndim = numel(yres);
    else
      q = p-1;
      yyres = yres(1:q);

      xx = L\yyres.';
      Ndim = numel(yyres);
    end
    
    loglk = loglk + abs(xx'*xx)./Ndim;
    
    
  end
  
  
  %%% get cros terms
  if nres>1
  
    for ii=1:nres-1
      for jj=ii+1:nres
        
        yres1 = res(ii).y;
        yres2 = res(jj).y;
        ynoise1 = noise(ii).y;
        ynoise2 = noise(jj).y;
        % willing to work with rows
        if size(yres1,2)<size(yres1,1)
          yres1 = yres1.';
        end
        if size(yres2,2)<size(yres2,1)
          yres2 = yres2.';
        end
        if size(ynoise1,2)<size(ynoise1,1)
          ynoise1 = ynoise1.';
        end
        if size(ynoise2,2)<size(ynoise2,1)
          ynoise2 = ynoise2.';
        end
        if ~isempty(cutbefore)
          yres1(1:cutbefore) = [];
          yres2(1:cutbefore) = [];
          ynoise1(1:cutbefore) = [];
          ynoise2(1:cutbefore) = [];
        end
        if ~isempty(cutafter)
          yres1(end-cutafter:end) = [];
          yres2(end-cutafter:end) = [];
          ynoise1(end-cutafter:end) = [];
          ynoise2(end-cutafter:end) = [];
        end
        
%         Rx = utils.math.Rcovmat(yres1);
%         Ry = utils.math.Rcovmat(yres2);
%         
%         xx = Rx\yres1.';
%         yy = Ry\yres2.';
%         
%         Ndim = numel(yres1);
% 
%         loglk = loglk + 2.*abs(xx'*yy)./Ndim;
        
        cmat = utils.math.xCovmat(ynoise1,ynoise2);
    
        [L,p] = chol(cmat,'lower');
        if p==0
          xx = L\yres1.';
          Ndim = numel(yres1);
          yy = L\yres2.';
        else
          q = p-1;
          yyres1 = yres1(1:q);
          yyres2 = yres2(1:q);

          xx = L\yyres1.';
          Ndim = numel(yyres1);
          yy = L\yyres2.';
        end

        loglk = loglk + 2.*abs(xx'*yy)./Ndim;
        
        
      end
    end
    
  end


end