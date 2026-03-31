% LINLSQSVD Linear least squares with singular value decomposition
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: Linear least square problem with singular value
% decomposition
%
% ALGORITHM: % It solves the problem
%
%        Y = HX
%
% where X are the parameters, Y the measurements, and H the linear
% equations relating the two.
% It is able to perform linear identification of the parameters of a
% multichannel systems. The results of different experiments on the same
% system can be passed as input. The algorithm, thanks to the singular
% value decomposition, extract the maximum amount of information from each
% single channel and for each experiment. Total information is then
% combined to get the final result.
%            
% CALL: [a,Ca,Corra,Vu,bu,Cbu,Fbu,mse,dof,ppm] = utils.math.linlsqsvd(H1,...,HN,Y);
%       [a,Ca,Corra,Vu,bu,Cbu,Fbu,mse,dof,ppm] = utils.math.linlsqsvd(H1,...,HN,Y,errthres);
%       [a,Ca,Corra,Vu,bu,Cbu,Fbu,mse,dof,ppm] = utils.math.linlsqsvd(H1,...,HN,Y,errthres,knwpars);
% 
% If the experiment is 1 then H1,...,HN and Y are aos.
% If the experiments are M, then H1,...,HN and Y are Mx1 matrix objects
% with the aos relating to the given experiment in the proper position.
% 
% INPUT:
%               - Hi represent the columns of H
%               - Y represent the measurement set
%               - sThreshold it's a threshold for singular values. It is a
%               number, typically 1. It will remove singular values larger
%               than sThreshold which corresponds to removing svd parameters estimated
%               with an error larger than sThreshold.
%               - knwpars A struct array with the fields:
%                   pos - a number indicating the corresponding position of
%                     the parameter (corresponding column of H)
%                   value - the value for the parameter
%                   err - the uncertainty associated to the parameter
% 
% OUTPUT:
%   a:      params values
%   Ca:     fit covariance matrix for A
%   Corra:  fit correlation matrix for A
%   Vu:     is the complete conversion matrix
%   Cbu:    is the new variables covariance matrix
%   Fbu:    is the information matrix for the new variable
%   mse:    is the fit Mean Square Error
%   dof:    degrees of freedom for the global estimation
%   ppm:    number of svd parameters per measurements, provides also the
%   number of independent combinations of parameters per each singular
%   measurement. The coefficients of the combinations are then stored in Vu
% 
% <a href="matlab:utils.helper.displayMethodInfo('matrix', 'linfitsvd')">Parameter Sets</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function  [a,Ca,Corra,Vu,bu,Cbu,Fbu,mse,dof,ppm] = linlsqsvd(varargin)
  
  
  
  %%% get input params
  if isstruct(varargin{end})
    kwnpars   = varargin{end};
    if isnumeric(varargin{end-1})
      sThreshold = varargin{end-1};
      A = varargin{1:end-2};
    else
      A = varargin{1:end-1};
      sThreshold = [];
    end
  else
    kwnpars = [];
    if isnumeric(varargin{end})
      sThreshold = varargin{end};
      A = varargin{1:end-1};
    else
      A = varargin{:};
      sThreshold = [];
    end
  end
  
 
  %%% sort between one or multiple experiments
  exps = struct;
  
  if isa(A(1),'ao') % one experiment
    % Build matrices for lscov
    C = A(1:end-1);
    Y = A(end);

    H = C(:).y;
    y = Y.y;
    exps.fitbasis = H;
    exps.fitdata = y;
  elseif isa(A(1),'matrix') % multiple experiments
    % run over input objects and experiments
    for jj=1:numel(A(1).objs)
      C = [];
      for ii=1:numel(A)-1
        D = A(ii).objs(jj).y;
        % willing to work with columns
        if size(D,1)<size(D,2)
          D = D.';
        end
        C = [C D];
      end
      y = A(end).objs(jj).y;
      exps(jj).fitbasis = C;
      exps(jj).fitdata = y;
    end
  else
    error('Unknown input data type!')
  end
  
  %%% do fit
  if ~isempty(kwnpars) && isfield(kwnpars,'pos')
    if ~isempty(sThreshold)
      [a,Ca,Corra,Vu,bu,Cbu,Fbu,mse,dof,ppm] = utils.math.linfitsvd(exps,kwnpars,sThreshold);
    else
      [a,Ca,Corra,Vu,bu,Cbu,Fbu,mse,dof,ppm] = utils.math.linfitsvd(exps,kwnpars);
    end
  else
    if ~isempty(sThreshold)
      [a,Ca,Corra,Vu,bu,Cbu,Fbu,mse,dof,ppm] = utils.math.linfitsvd(exps,sThreshold);
    else
      [a,Ca,Corra,Vu,bu,Cbu,Fbu,mse,dof,ppm] = utils.math.linfitsvd(exps);
    end
  end
  
  
  
  
end
    
