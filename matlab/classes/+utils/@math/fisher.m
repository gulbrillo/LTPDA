%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Compute Fisher matrix
%
%  Parameters are:
%   fin       - input 1st channel (numerica matrix)
%   S         - noise both channels (numerical matrix)
%   mdl       - model (matrix or ssm)
%   params    - parameters
%   numparams - numerical value of parameters
%   lp        - Vector denoting the log-scale parameters
%   freqs     - frequnecies being evaluated
%   dstep     - differentation step
%   ngrid     - Grid
%   inNames   - inNames for SSM
%   outNames  - outNames for SSM
%
function [FisMat dstep] = fisher(fin,S,mdl,params,numparams,lp,freqs,dstep,ngrid,ranges,inNames,outNames)

  import utils.const.*

  Nin  = size(fin,2);
  con  = ones(1,numel(params));
  
  % Checking for parameters in log-space
  ind            = find(lp == 1);
  numparams(ind) = exp(numparams(ind));
  con(ind)       = numparams(ind);

  if ~isempty(mdl) && isa(mdl,'matrix')
    % compute built-in matrix
    for i = 1:numel(mdl.objs)
        % set Xvals
        h(i) = mdl.getObjectAtIndex(i).setXvals(freqs);
        % set alias
        h(i).assignalias(mdl.objs(i),plist('xvals',freqs));
        % set paramaters
        h(i).setParams(params,numparams);
    end
    % differentiate and eval
    for i = 1:length(params)

      utils.helper.msg(msg.IMPORTANT, sprintf('computing symbolic differentiation with respect %s',params{i}), mfilename('class'), mfilename);
      % differentiate symbolically
      for ii = 1:numel(mdl.objs)

        dH(ii) = con(i)*diff(h(ii),params{ii});

        % evaluate
        dd(ii) = eval(dH(ii));

      end
    end
    
    % defining # of inputs and outputs
    Nout = size(mdl,1);
    
    % rearrange the transfer functions
    d(:,:,:,i) = reshape(dd,numel(dd(:,1)),Nout,Nin);

  elseif ~isempty(mdl) && isa(mdl,'ssm')

    meval = copy(mdl,1);
    % set parameter values
    meval.doSetParameters(params, numparams);
    
    % defining # of inputs and outputs
    Nout = numel([meval.outputs(:).ports]);

    % case no diff. step introduced
    if isempty(dstep)

        utils.helper.msg(msg.IMPORTANT, ...
        sprintf('computing optimal differentiation steps'), mfilename('class'), mfilename);

        if isempty(ranges)
            error('### Please input upper and lower ranges for the parameters: ''ranges''')
        end

        if isempty(ngrid)
            error('### Please input a number of points for the grid to compute the diff. step : ''ngrid''')
        end

        % look for numerical differentiation step
        dstep = utils.math.diffStepFish(fin,S,meval,params,ngrid,ranges,freqs,inNames,outNames);
    end

    % Loop over the input/output ports to store their names
    ports  = [meval.inputs(:).ports];
    for ii = 1:numel(ports)
      inNames{ii} = ports(ii).name;
    end
    
    ports  = [meval.outputs(:).ports];
    for ii = 1:numel(ports)
      outNames{ii} = ports(ii).name;
    end
    
    % differentiate and eval
    for i = 1:length(params)

      utils.helper.msg(msg.IMPORTANT, ...
      sprintf('computing numerical differentiation with respect %s, Step:%4.2d ',params{i},dstep(i)), mfilename('class'), mfilename);
    
      % differentiate numerically
      dH = meval.parameterDiff(plist('names', params(i),'values',dstep(i)));

      for jj = 1:Nout
        % create plist with correct outNames (since parameterDiff change them)
        outputs{jj} = strrep(outNames{jj},'.', sprintf('_DIFF_%s.',params{i})); 
      end
      
      spl = plist(...
          'outputs',    outputs, ...
          'inputs',     inNames, ...
          'reorganize', true,    ...
          'f',          freqs);

      % do bode
      dd  = bode(dH, spl);

      % get numbers
      dd = con(i)*dd.objs.y;

      % rearrange the transfer functions
      d(:,:,:,i) = reshape(dd,numel(dd(:,1)),Nout,Nin);

    end

  else
      error('### please introduce models for the transfer functions')
  end

  FisMat = zeros(length(params));
   
  % compute Fisher Matrix (only upper triangle, it must be symmetric)
  for i =1:length(params)
    for j =i:length(params)

      % Get the template
      h = utils.math.mult(d(:,:,:,i), fin);

      % Multiplying at once produces error.
      g = utils.math.mult(S, utils.math.mult(d(:,:,:,j), fin));

      FisMat(i,j) = sum(real(utils.math.ctmult(h , g)));

    end
  end

  % fill lower triangle
  for j =1:length(params)
    for i =j:length(params)
      FisMat(i,j) = FisMat(j,i);
    end
  end


end

% END