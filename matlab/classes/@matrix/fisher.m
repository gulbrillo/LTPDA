% FISHER.M Fisher matrix calculation for MATRIX models.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Compute Fisher matrix for MATRIX models.
%
%  The parameters are:
%
%   mdl       - model (matrix or ssm)
%   params    - parameters
%   values    - numerical value of parameters
%   lp        - Vector denoting the log-scale parameters
%   freqs     - frequnecies being evaluated
%   dstep     - differentation step
%   ngrid     - Grid
%
function [FisMat, dstep] = fisher(mdl,data,params,values,lp,freqs,dstep,~,~)
  
  import utils.const.*
  
  Nin  = size(data(1).input,2);
  con  = ones(1,numel(params));
  Nexp = numel(data);
  % Defining # of outputs
  Nout = size(mdl.objs,1);
  
  % Checking for parameters in log-space
  ind         = find(lp == 1);
  values(ind) = exp(values(ind));
  con(ind)    = values(ind);
  
  % Initialise
  FMall = zeros(numel(params));
  
  % Checking if freqs is a cell array
  if isnumeric(freqs)
    freqs = {freqs};
  elseif ~iscell(freqs)
    error(['### The frequencies to perform the analysis should be in a cell array '...
      '(if there are multiple experiments) or a numerical vector.'])
  end
  
  for kk = 1:Nexp
    
    utils.helper.msg(msg.PROC1, sprintf('Analysis of experiment #%d',kk), mfilename('class'), mfilename);
    
    % Compute built-in matrix
    for ii = 1:Nin
      for jj = 1:Nout
        % Set Xvals
        H(jj,ii) = mdl.getObjectAtIndex(jj,ii).setXvals(freqs{kk});
        % Set alias
        H(jj,ii).assignalias(mdl.objs(jj,ii),plist('xvals',freqs{kk}));
        H(jj,ii).setTrans([]);
        % Set paramaters
        H(jj,ii).setParams(params,values);
      end
    end
    % Differentiate and eval
    for jj = 1:length(params)
      
      count = 1;
      
      utils.helper.msg(msg.PROC1, sprintf('computing symbolic differentiation with respect %s',params{jj}), mfilename('class'), mfilename);
      % Differentiate symbolically
      for in = 1:Nin
        for oo = 1:Nout
          
          % Evaluate
          dd(count) = eval(diff(H(oo,in),params{jj}));
          
          count = count + 1;
          
        end
      end
      
      % Get numbers
      dd = con(jj)*dd.y;
      
      % Re-arrange the transfer functions
      d(:,:,:,jj) = reshape(dd,numel(dd(:,1)),Nout,Nin);
      
      clear dd;
        
    end
    
    FisMat = zeros(length(params));
    
    % Compute Fisher Matrix (only upper triangle, it must be symmetric)
    for ii =1:length(params)
      for jj =ii:length(params)
        
        % Get the template
        h = utils.math.mult(d(:,:,:,ii), data(kk).input);
        
        % Multiplying at once produces error.
        g = utils.math.mult(data(kk).noise, utils.math.mult(d(:,:,:,jj), data(kk).input));
        
        FisMat(ii,jj) = sum(real(utils.math.ctmult(h , g)));
        
      end
    end
    
    % Fill lower triangle
    for jj =1:length(params)
      for ii =jj:length(params)
        FisMat(ii,jj) = FisMat(jj,ii);
      end
    end
    
    % Adding up
    FMall = FMall + FisMat;
    
    % Clear d, allow experiments with different data samples
    clear d;
    
  end
  
end

% END