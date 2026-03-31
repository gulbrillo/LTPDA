%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Compute cross covariance matrix of two data series
% 
% CALL 
% 
% Get autocovariance
% cmat = xCovmat(x)
% cmat = xCovmat(x,[])
% cmat = xCovmat(x,[],'cutbefore',10,'cutafter',10)
% 
% Get crosscovariance
% cmat = xCovmat(x,y)
% cmat = xCovmat(x,y,'cutbefore',10,'cutafter',10)
% 
% INPUT
% 
% - x, y, data series
% - cutbefore, followed by the data samples to cut at the starting of the
% data series
% - cutafter, followed by the data samples to cut at the ending of the
% data series
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function cmat = xCovmat(x,y,varargin)

  acov = true;
  % willing to work with columns
  if size(x,1)<size(x,2)
    x = x.';
  end
  % subtract the mean
  x = x - mean(x);
  if nargin > 1
    if ~isempty(y) % crosscovariance
      acov = false;
      if size(y,1)<size(y,2)
        y = y.';
      end
      y = y - mean(y);
    end
  end
  
  nx = size(x,1);

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
  
  if acov % autocovariance
    
    % init trim matrix
    trim = zeros(nx,nx);
    % fillin the trim matrix
    for ii=1:nx
      trim(1:nx-ii+1,ii) = x(ii:nx,1);
    end
    %trim = sparse(trim);
    cmat = trim*conj(trim);
    % normalization
    %nmat = sparse(triu(ones(nx,nx),0));
    nmat = triu(ones(nx,nx),0);
    nmat = rot90(nmat);
    normat = nmat*nmat;
    cmat = cmat./normat;
    %cmat = full(cmat);
    
    if ~isempty(cutbefore)
      % cut rows
      cmat(1:cutbefore,:)=[];
      % cut columns
      cmat(:,1:cutbefore)=[];
    end
    [nn,mm]=size(cmat);
    if ~isempty(cutafter)
      % cut rows
      cmat(nn-cutafter:nn,:)=[];
      % cut columns
      cmat(:,mm-cutafter:mm)=[];
    end
    
  else % cross covariance
    
    % init trim matrix
    trimx = zeros(nx,nx);
    trimy = zeros(nx,nx);
    % fillin the trim matrix
    for ii=1:nx
      trimx(1:nx-ii+1,ii) = x(ii:nx,1);
      trimy(1:nx-ii+1,ii) = y(ii:nx,1);
    end
    cmat = trimx*conj(trimy);
    % normalization
    nmat = triu(ones(nx,nx),0);
    nmat = rot90(nmat);
    normat = nmat*nmat;
    cmat = cmat./normat;
    
    if ~isempty(cutbefore)
      % cut rows
      cmat(1:cutbefore,:)=[];
      % cut columns
      cmat(:,1:cutbefore)=[];
    end
    [nn,mm]=size(cmat);
    if ~isempty(cutafter)
      % cut rows
      cmat(nn-cutafter:nn,:)=[];
      % cut columns
      cmat(:,mm-cutafter:mm)=[];
    end
    
  end
  





end