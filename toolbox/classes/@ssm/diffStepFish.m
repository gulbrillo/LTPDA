% DIFFSTEPFISH.M Search for a differantiation step
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Look for differentiation step for a given parameter for SSMs.
%
%  Parameters are:
%   
%   mdl       - SSM
%   data      - A structure array containing the data (help ao2strucArrays)
%   params    - parameters
%   freqs     - frequnecies being evaluated
%   ngrid     - Grid
%
function best = diffStepFish(mdl,data,params,ngrid,ranges,freqs)
  
  import utils.const.*
  
  % remove aux file if existing
  if exist('diffStepFish.txt','file') == 2
    ! rm diffStepFish.txt
  end
  
  % Copying model
  meval = copy(mdl,1);
  
  % Defining # of inputs and outputs
  Nout = numel([meval.outputs(:).ports]);
  Nin  = size(data.input,2);
  
  % Init
  outputs = cell(1,Nout);
  step = ones(ngrid,numel(params));
  
  for ii = 1:ngrid
    step(ii,:) = ranges(1,:);
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
  
  for kk = 1:length(params)
    
    step(:,kk) = logspace(log10(ranges(1,kk)),log10(ranges(2,kk)),ngrid);
    Rmat = [];
    
    for jj = 1:ngrid
      for ii = 1:length(params)
        
        tic
        % differentiate numerically
        dH = meval.parameterDiff(plist('names', params(ii),'values',step(jj,ii)));
        % create plist with correct outNames (since parameterDiff change them)
        for ll = 1:Nout
          % create plist with correct outNames (since parameterDiff change them)
          outputs{ll} = strrep(outNames{ll},'.', sprintf('_DIFF_%s.',params{ii})); % 2x2 case
        end
        
        spl = plist(...
          'outputs',    outputs, ...
          'inputs',     inNames, ...
          'reorganize', true,    ...
          'f',          freqs);
        
        % do bode
        dd  = bode(dH, spl);
        
        % get numbers
        dd = dd.objs.y;
        
        % rearrange the transfer functions
        d(:,:,:,ii) = reshape(dd,numel(dd(:,1)),Nout,Nin);
        
      end
      
      % compute Fisher Matrix
      for i =1:length(params)
        for j =1:length(params)
          
          % Get the template
          h = utils.math.mult(d(:,:,:,i), data.input);
          
          % Multiplying at once produces error.
          g = utils.math.mult(data.noise, utils.math.mult(d(:,:,:,j), data.input));
          
          FisMat(i,j) = sum(real(utils.math.ctmult(h , g)));
          
        end
      end
      
      detFisMat = det(FisMat);
      R = [step(jj,:) detFisMat];
      save('diffStepFish.txt','R','-ascii','-append');
      Rmat = [Rmat; R];
      
      utils.helper.msg(msg.PROC1, sprintf('%s',toc), mfilename('class'), mfilename);
    end
    
    % look for the stable step: compute diff and
    % look for the smallest one in absolute value
    % The smallest slope marks the plateau
    diffDetFisMat = abs(diff(Rmat(:,end)));
    lowdet = diffDetFisMat(1);
    ind = 2;
    for k = 1:numel(diffDetFisMat)
      if diffDetFisMat(k) < lowdet
        lowdet = diffDetFisMat(k);
        ind = k+1; % index give by diff = x(2) - x(1). We take the step corresponding to x(2)
      end
    end
    
    step(:,kk) = step(jj,kk)*ones(ngrid,1);
    
  end
  
  step(:,end) = logspace(log10(ranges(1,end)),log10(ranges(2,end)),ngrid);
  best = step(1,:);
  
end

