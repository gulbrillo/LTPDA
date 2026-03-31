%
% Calculate the covariance of a given model (SSM or MATRIX)
%
% This function calls the <class>/fisher to calculate the 
% Fisher Information Matrix.
%
% CALL: algorithm.calculateCovariance()
%
% fin, Sn, freqs
%
% NK 2013
%
function algo = calculateCovariance(algo)
  
  import utils.const.*
  
  if isempty(algo.loglikelihood)
    error('### For the calculation of the covariance matrix, first the log-likelihood function must be built.')
  end
  
  % Get the p0 and check if it's pest
  [p0, paramNames] = algo.checkP0class(algo.params.find('X0'), algo.params.find('fitparams'));
  
  % Handle dstep if is empty
  algo.checkDiffStep(algo.params.find('diffstep'), p0);

  if isempty(algo.params.find('cov')) && ~(~algo.params.find('mhsample') && algo.params.find('simplex'))
    
    % Remove noise parameters from the calculation of the fisher matrix
    np     = algo.params.find('noise parameters index');    
    llhver = algo.params.find('llh ver');
    % Check parameter values in case of fitting the noise levels
    p0     = checkParamsForFisher(p0, np, paramNames);

    switch class(algo.model)
     case 'mfh'
       
       %%%%%%%%%%%%%%%%%%% Compute Fisher Matrix MFH %%%%%%%%%%%%%%%%%%%%%%
       if ~any(strcmpi(llhver, {'td ao', 'td core'}))
         % remove keys: avoid warnings
         remKeys = {'PLOT FITS', 'NOISE WIN', 'NS', 'INVERSE', 'NOUT', 'P0', 'BIN GROUPS'...
                    'ETAS', 'TRANSFORM', 'YUNITS', 'VERSION', 'NAME', 'TS FH', 'NU', 'S'};

         fpl = subset(algo.params, getKeys(remove(mfh.getInfo('fisher').plists, remKeys)));

         % check for frequencies. The mfh/fisher function does not support an
         % array of frequencies.
         if isempty(algo.params.find('frequencies'))
           freqs = [algo.params.find('f1'), algo.params.find('f2')];
         else
           freqs = [min(algo.params.find('frequencies')), max(algo.params.find('frequencies'))];
         end

         % set the noise in the internal plist
         fpl.pset('noise',       algo.noise, ...
                  'frequencies', freqs,...
                  'p0',          p0,...
                  'diffstep',    algo.diffStep,...
                  'version',     llhver);

         % Compute Fisher matrix
         FisMat = fisher(algo.model, fpl);  
         
       else
         % Using the Hessian matrix to get an estimation of the errors
         C      = double(paramCovMat(algo.model, p0, algo.diffStep, 1, 'Jacobian', []));
         FisMat = [];
       end
       
      otherwise

       %%%%%%%%%%%%%%%%%%% Compute Fisher Matrix SSM %%%%%%%%%%%%%%%%%%%%%%

       % Copy the model from th input
       model = copy(algo.model, 1);

       % Simplify the model for bode
       try
         model.setParameters(plist('names',paramNames,'values',double(algo.params.find('x0'))));
         model.simplify(plist('inputs', algo.params.find('InNames'), 'outputs', algo.params.find('outNames')));
       catch
         % Do nothing (For the cases of the old MATRIX models)
       end

       % Compute Fisher matrix
       [FisMat, diffstep] = fisher(...
                              model,...
                              algo.loglikelihood.procinfo.find('data'),...
                              algo.getParamNames(),...
                              double(p0),...
                              algo.logParams,...
                              algo.freqs,...
                              algo.params.find('DIFFSTEP'), ...
                              algo.params.find('NGRID'), ...
                              algo.params.find('STEPRANGES')...
                              );

       % Set the diff. step
       algo.diffStep = diffstep;
       
    end
    
    % Inverse is the optimal covariance matrix
    if ~any(strcmpi(llhver, {'td ao', 'td core'}))
      if algo.params.find('PINV') && isempty(algo.params.find('TOL'))
        C = pinv(FisMat);
      elseif algo.params.find('PINV')
        C = pinv(FisMat,tol);
      else
        C = FisMat\eye(size(FisMat));
      end
    end

    % Regularize?
    C = checkSPD(C, algo);
    
    % Check if the version is the 'noise fit' and build a propper block-diagonal
    % covariance.
    if strcmpi(llhver, 'noise fit v1')
      C = blkdiag(C, algo.loglikelihood.procinfo.find('noise cov'));
    end

    % Get the correlation 
    corr = utils.math.cov2corr(C);

    % Store into AO
    C = ao(C, plist('name', 'Covariance Matrix'));

    % Store the FIM in the procinfo property
    C.setProcinfo(plist('FisMat',FisMat,'diffstep',algo.diffStep,'correlation',corr));

    % Set the covariance
    algo.covariance = C;

    try
      % Print on screen the error from the FIM
      sigma = pest(sqrt(diag(double(C))));
      sigma.setName('Error');
      
      % Set the parameter names
      sigma.setNames(paramNames);

      % Make sure we get column data
      p0 = double(p0);
      if ~iscolumn(p0)
        p0 = p0.';
      end

      % Get relative error
      reler = pest(100*abs(double(sigma)./p0));
      reler.setName('Relative Error %');
      % Set the parameter names
      reler.setNames(paramNames);
      
      % Define the p0 point
      p0_pest = setName(pest(p0, paramNames), 'p0');

      % Make table
      table(p0_pest, sigma,reler)
    catch Me
      fprintf('### Could not create a table with the estimated errors... [%s] \n', Me.message)
    end
  
    
  else
    
    % Just set it, if it is already provided
    algo.covariance = algo.params.find('cov');
    
  end
  
  % Add history step
  algo.addHistory(getInfo, plist.EMPTY_PLIST(), {}, [algo.hist]);
  
end

%
% GetInfo function
%
function ii = getInfo(varargin)
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.helper, '', {}, plist.EMPTY_PLIST);
end

%
% Check Parameters for the Fisher calculation. It removes the noise 
% parameters and keeps the system parameters only. They are passed to the 
% fisher calculation.
%
function pnew = checkParamsForFisher(p0, np, paramNames)
  
  pnew       = double(p0);
  pnew(np)   = [];
  pnames     = paramNames;
  pnames(np) = [];
  pnew       = pest(pnew, pnames);
  if isa(p0, 'pest')
    yunits     = p0.yunits;
    pnew.setYunits(yunits);
  end
end

%
% Function to check if the calculated covariance matrix is positive definite
%
function C = checkSPD(C, algo)

 % Check the matrix
  try
    chol(double(C));
  catch
    if algo.params.find('Regularize')
      [V, D]  = eig(C);
      d       =diag(D);
      d(d<=0) =eps;      
      C       = V*diag(d)*V';
    elseif algo.params.find('nearestSPD')
      C       = nearestSPD(C);
    else
      warning('The resulting fisher matrix is not positive definite');
    end
  end

end

function Ahat = nearestSPD(A)
%  nearestSPD - the nearest (in Frobenius norm) Symmetric Positive Definite matrix to A
%  usage: Ahat = nearestSPD(A)
%
%  From Higham: "The nearest symmetric positive semidefinite matrix in the
%  Frobenius norm to an arbitrary real matrix A is shown to be (B + H)/2,
%  where H is the symmetric polar factor of B=(A + A')/2."
%
%  http://www.sciencedirect.com/science/article/pii/0024379588902236
%
%  arguments: (input)
%   A - square matrix, which will be converted to the nearest Symmetric
%     Positive Definite Matrix.
%
%  Arguments: (output)
%  Ahat - The matrix chosen as the nearest SPD matrix to A.

%   Copyright (c) 2013, John D'Errico
%   All rights reserved.
% 
%   Redistribution and use in source and binary forms, with or without
%   modification, are permitted provided that the following conditions are
%   met:
% 
%       * Redistributions of source code must retain the above copyright
%         notice, this list of conditions and the following disclaimer.
%       * Redistributions in binary form must reproduce the above copyright
%         notice, this list of conditions and the following disclaimer in
%         the documentation and/or other materials provided with the distribution
% 
%   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
%   AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
%   IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
%   ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
%   LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
%   CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
%   SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
%   INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
%   CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
%   ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
%   POSSIBILITY OF SUCH DAMAGE.

  if nargin ~= 1
    error('Exactly one argument must be provided.')
  end

  % test for a square matrix A
  [r,c] = size(A);
  if r ~= c
    error('A must be a square matrix.')
  elseif (r == 1) && (A <= 0)
    % A was scalar and non-positive, so just return eps
    Ahat = eps;
    return
  end

  % symmetrize A into B
  B = (A + A')/2;

  % Compute the symmetric polar factor of B. Call it H.
  % Clearly H is itself SPD.
  [~, Sigma, V] = svd(B);
  H = V*Sigma*V';

  % get Ahat in the above formula
  Ahat = (B+H)/2;

  % ensure symmetry
  Ahat = (Ahat + Ahat')/2;

  % test that Ahat is in fact PD. if it is not so, then tweak it just a bit.
  p = 1;
  k = 0;
  while p ~= 0
    [~,p] = chol(Ahat);
    k = k + 1;
    if p ~= 0
      % Ahat failed the chol test. It must have been just a hair off,
      % due to floating point trash, so it is simplest now just to
      % tweak by adding a tiny multiple of an identity matrix.
      mineig = min(eig(Ahat));
      Ahat = Ahat + (-mineig*k.^2 + eps(mineig))*eye(size(A));
    end
  end
end

% End of calculateCovariance