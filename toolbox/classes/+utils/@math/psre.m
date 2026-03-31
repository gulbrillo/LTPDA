%
% Potential Scale Reduction Factor estimation
%
% Used to check for fails of 2 MCMC investigations 
% to converge to the same target distribution.
%
% If input is a single MCMC investigation, it computes
% the PSRF in the second and last third of the chains.
%
% CALL:     status   = psre(dbg_info, chain1, chain2)
%           status   = psre(dbg_info, chain1)
%           status   = psre(chain1)
%
% INPUTS:   chains   : the MCMC chains matrices (fxNparams)
%           
%           dbg_info : True/False flag to prind on screen
%
% OUTPUT:   status   : a matlab strucure object
%
%           status.R    : PSRF
%           status.neff : Number of efficient samples
%           status.B    : Between sequence variances
%           status.V    : Mixture-of-sequences variances
%           status.W    : Within sequence variances
%
% NK 2012
%

function status = psre(varargin) 

  if nargin == 1
    
    dbg_info = false;
    
    C   = varargin{1};
    n   = floor(size(C,1)/3);
    c1  = C(1:n,:);
    c2  = C((end-n+1):end,:);
    con = 3/2;
    
  elseif nargin == 2
    
    dbg_info = varargin{1};
    
    C   = varargin{2};
    n   = floor(size(C,1)/3);
    c1  = C(1:n,:);
    c2  = C((end-n+1):end,:);
    con = 3/2;
    
  elseif nargin == 3
    
    dbg_info = varargin{1};
    
    c1  = varargin{2};
    c2  = varargin{3};
    con = 1;
    
    if size(c1) ~= size(c2)
      error('### Chains must be of the same length.')
    end
        
  else
 
    error('### Unknown number of inputs. Please check again...');
    
  end
  
  [N,D,~] = size(c1);
  % Calculate means W of the variances
  x1 = c1 - repmat(mean(c1),N,1);
  x2 = c2 - repmat(mean(c2),N,1);
  W  = x1'*x1 + x2'*x2;
  
  W  = W / (2*(N-1));
  
  % Calculate variances Vm of the means.
  m  = mean(reshape(mean([c1 c2]),D,2)');
  x1 = mean(c1) - m;
  x2 = mean(c2) - m;
  Vm = x1'*x1 + x2'*x2;

  % Calculate reduction factors
  E    = sort(abs(eig(W \ Vm)));
  R    = (N-1)/N + E(end) * 3/2;
  V    = (N-1) / N * W + 3/2 * Vm;
  R    = sqrt(R);  
  B    = Vm*N;
  neff = con*mean(min(diag(2*N*V./B),2*N));
  
  status.R    = R;
  status.neff = neff;
  status.B    = B;
  status.V    = V;
  status.W    = W;
  
  if dbg_info 
    desc = 'Potential Scale Reduction Factor      ';
    fprintf(['* ', desc, ': = %s \n'], num2str(R)) 
  end
  
end