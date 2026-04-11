% Generate a random walk
% 
% CALL:       wn = randomWalkGen(processLength,stepSize,positiveStepProb)
%             wn = randomWalkGen(processLength,'random',positiveStepProb,range)
%             wn = randomWalkGen(processLength,'gaussian',positiveStepProb,range)
%
% INPUTS:     processLength: Number of samples
%             stepSize: Can have three values:
%               - a number indicating the size of the step. This is the
%               case of a classical random walk with fixed step size.
%               - 'random' generates a random walk with random generted step
%               size. Parameters for random generation are defined in
%               'range' input.
%               - 'gaussian' generatesa random walk with gaussian steps.
%               Parameters of the gaussian are defined in 'range' input.
%             positiveStepProb: Define the probability of having a positive
%             step. Such input is ignored if stepSize is set to 'gaussian'.
%             range: This input is used only if stepSize is set to 'random'
%             or 'gaussian'.
%               - in case of stepSize set to 'random' it an array of two
%               numbers. The two numbers defining the boundaries of the
%               intervall in which uniform random number are generated.
%               - in case of stepSize set to 'gaussian' it an array of two
%               numbers. The two numbers defining the mean of the
%               standard deviation of the gaussian distribution generating
%               the steps.
% 
% 2015-06-26 Luigi Ferraioli
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function wn = randomWalkGen(processLength,stepSize,positiveStepProb,varargin)

% Winer process, random step size in the range defined by input range
process = 'brownian';
if ischar(stepSize)
  range = varargin{1};
  process = stepSize;
  if numel(range)~=2
    error('range should be an array with 2 numbers.');
  end
end

if isempty(positiveStepProb)
  positiveStepProb = 0.5;
end

stepProbSequence = rand(processLength,1);
% get the index of positive step
idxup = stepProbSequence<=positiveStepProb;
% +1 for positive step -1 for negative step
stepsign = ones(processLength,1);
stepsign(~idxup) = -1;

% switch between different process
wn = zeros(processLength,1);
switch lower(process)
  case 'brownian'
    % random walk with fixed step size
    stepsequence = stepsign.*stepSize;
    
  case 'random'
     % random walk with random step size
     stepSizeRnd = range(1) + range(2).*rand(processLength,1);
     stepsequence = stepsign.*stepSizeRnd;
     
  case 'gaussian'
    
     stepsequence = range(1) + range(2).*randn(processLength,1);
     
end

% generate iteratively
for ii=2:processLength
  wn(ii) = wn(ii-1) + stepsequence(ii);
end

end