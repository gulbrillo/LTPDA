%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Look for differentiation step for a given parameter and
%
%  Parameters are:
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function best = diffStepFish(fin,S,meval,params,ngrid,ranges,freqs,inNames,outNames)

% remove aux file if existing
if exist('diffStepFish.txt','file') == 2
    ! rm diffStepFish.txt
end

Nin  = size(fin,2);

% defining # of inputs and outputs
Nout = numel(outNames);

step = ones(ngrid,numel(params));
% build matrix of steps
% for ii = 1:length(params)
%       step(:,ii) = [] logspace(ranges(1,ii),ranges(2,ii),ngrid);
% end
for ii = 1:ngrid
    step(ii,:) = ranges(1,:);
end

% step(:,1) = logspace(ranges(1,1),ranges(2,1),ngrid);

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
        h = utils.math.mult(d(:,:,:,i), fin);

        % Multiplying at once produces error.
        g = utils.math.mult(S, utils.math.mult(d(:,:,:,j), fin));

        FisMat(i,j) = sum(real(utils.math.ctmult(h , g)));

      end
    end

    detFisMat = det(FisMat);
    R = [step(jj,:) detFisMat];
    save('diffStepFish.txt','R','-ascii','-append');
    Rmat = [Rmat; R];

    toc
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

