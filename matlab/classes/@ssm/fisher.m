% FISHER.M Fisher matrix calculation for SSMs.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Compute Fisher matrix for State Space Models.
%
%  The parameters are:
%
%   mdl       - SSM
%   data      - A structure array containing the data (help ao2strucArrays)
%   params    - parameters
%   values    - numerical value of parameters
%   lp        - Vector denoting the log-scale parameters
%   freqs     - frequnecies being evaluated
%   dstep     - differentation step
%   ngrid     - Grid
%
function [FMall, dstep] = fisher(mdl,data,params,values,lp,freqs,dstep,ngrid,ranges)
  
  import utils.const.*
  
  Nin  = size(data(1).input,2);
  con  = ones(1,numel(params));
  Nexp = numel(data);
  
  % Initialise
  FMall = zeros(numel(params));
  
  % Checking for parameters in log-space
  ind         = find(lp == 1);
  values(ind) = exp(values(ind));
  con(ind)    = values(ind);
  
  % Copying model
  meval = copy(mdl,1);
  % Setting parameter values
  meval.doSetParameters(params, values);
  
  % Defining # of inputs and outputs
  Nout    = numel([meval.outputs(:).ports]);
  outputs = cell(1,Nout);
  
  % Checking if freqs is a cell array
  if isnumeric(freqs)
    freqs = {freqs};
  elseif ~iscell(freqs)
    error(['### The frequencies to perform the analysis should be in a cell array '...
      '(if there are multiple experiments) or a numerical vector.'])
  end
  
  % Loop over the input/output ports to store their names
  ports    = [meval.inputs(:).ports];
  inNames  = cell(1,numel(ports));
  
  for ii = 1:numel(ports)
    inNames{ii} = ports(ii).name;
  end
  
  ports    = [meval.outputs(:).ports];
  outNames = cell(1,numel(ports));
  
  for ii = 1:numel(ports)
    outNames{ii} = ports(ii).name;
  end
  
  for kk = 1:Nexp
    
    % Case: no diff. step introduced
    if isempty(dstep)
      
      utils.helper.msg(msg.PROC1, ...
        sprintf('Computing optimal differentiation steps'), mfilename('class'), mfilename);
      
      if isempty(ranges)
        error('### Please input upper and lower ranges for the parameters: ''ranges''')
      end
      
      if isempty(ngrid)
        error('### Please input a number of points for the grid to compute the diff. step : ''ngrid''')
      end
      
      % Looking for th numerical differentiation step
      dstep = diffStepFish(meval,data(kk),params,ngrid,ranges,freqs{kk});
    end
    
    utils.helper.msg(msg.PROC1, sprintf('Analysis of experiment #%d',kk), mfilename('class'), mfilename);
    
    % Differentiate and eval
    for ii = 1:length(params)
      
      utils.helper.msg(msg.PROC1, ...
        sprintf('computing numerical differentiation with respect %s, Step:%4.2d ',params{ii},dstep(ii)), mfilename('class'), mfilename);
      
      % Differentiate numerically
      dH = meval.parameterDiff(plist('names', params(ii),'values',dstep(ii)));
      
      for jj = 1:Nout
        % Create plist with correct outNames (since parameterDiff change them)
        outputs{jj} = strrep(outNames{jj},'.', sprintf('_DIFF_%s.',params{ii}));
      end
      
      spl = plist(...
        'outputs',    outputs, ...
        'inputs',     inNames, ...
        'reorganize', true,    ...
        'f',          freqs{kk});
      
      % Bode
      dd  = bode(dH, spl);
      
      % Get numbers
      dd = con(ii)*dd.objs.y;
      
      % Re-arrange the transfer functions
      d(:,:,:,ii) = reshape(dd,numel(dd(:,1)),Nout,Nin);
      
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