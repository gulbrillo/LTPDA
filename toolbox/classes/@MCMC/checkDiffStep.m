%
% Utility function to check the differentiation step of the algorithm
%
function algo = checkDiffStep(algo, in_step, p0)
  
  Nparams = numel(double(p0));
  
  % Handle dstep if is empty
  if isempty(in_step)
    dstep = 1e-2.*ones(1, Nparams);
  else
    dstep = double(in_step);
  end
  
  % Check the dimension of diff. step
  if numel(dstep) ~= Nparams
    error('### The differentiation step is not equal the number of parameters...')
  end
       
  algo.diffStep = dstep;
  
end

% END