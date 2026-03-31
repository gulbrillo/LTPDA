% testHessianMatrix Performs a random study of the n-dimensional error ellipsoide for a given confidence level.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: Performs a random study of the n-dimensional error
% ellipsoide for a given confidence level.
%
% CALL:     out = testHessianMatrix(f,pl)
%
% INPUTS:
%         - f. The function handle representing the cost function.
%
% PARAMETERS:
%         - pars. The set of parameters. (pest object).
%         - confidenceLevel. The desired confidence level for the chi2
%           ellipsoid. (e.g. 0.6827)
%         - nbTest. Number of test steps. (e.g. 50).
%
% OUTPUTS:
%         - out. An ao object with chi2 test values.
%
% NOTE: It works with non-normalized chi2 functions (not divided for the
% number of degrees of freedom).
%
% <a href="matlab:utils.helper.displayMethodInfo('mfh', 'testHessianMatrix')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varargout = testHessianMatrix(varargin)
  
  % Check if this is a call for parameters
  if nargin == 3 && utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  % Use the caller is method flag
  callerIsMethod = utils.helper.callerIsMethod;
  
  if callerIsMethod
    % Assume testHessianMatrix(sys, ..., ...)
    %Define inputs
    narginchk(5, 5);
    f               = varargin{1};
    pars            = varargin{2};
    hessianMatrix   = varargin{3};
    confidenceLevel = varargin{4};
    nbTest          = varargin{5};
    
  else
    
    % Collect input variable names
    in_names = cell(size(varargin));
    try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
    
    % Assume loglikelihood(sys, plist)
    mfh_in = utils.helper.collect_objects(varargin(:), 'mfh',   in_names);
    pl     = utils.helper.collect_objects(varargin(:), 'plist', in_names);
  
    % Combine plists
    pl = applyDefaults(getDefaultPlist, pl);
  
    % copy input ssm
    f = copy(mfh_in,1);
    
    pars            = find_core(pl, 'pars');
    hessianMatrix   = find_core(pl, 'hessianMatrix');
    confidenceLevel = find_core(pl, 'confidenceLevel');
    nbTest          = find_core(pl, 'nbTest');
    
    % Get/Set random stream to the PLIST
    pl.getSetRandState();
  
  end
  
  if isa(pars,'pest')
    % get parameters out
    pars = pars.y;
  end
  if isa(hessianMatrix,'ao')
    % get values out
    hessianMatrix = hessianMatrix.y;
  end
  
  % create function handle
  fh_str = f.function_handle();
  
  % declare objects locally
  declare_objects(f);
  
  % create function handle
  func = eval(fh_str);
  
  Npars = numel(pars);
  
  str = sprintf('A random study of the n-dimensional error ellipsoide for a confidence level of %0.5g',confidenceLevel);
  utils.helper.msg(utils.const.msg.IMPORTANT, str);
  
  Chi2Level = chi2inv(confidenceLevel,Npars);
  
  str = sprintf('Chi2 Level for confidence = %g%%  and number of parameters = %g => %g\n',confidenceLevel*100,Npars,Chi2Level);
  utils.helper.msg(utils.const.msg.IMPORTANT, str);
  
  chi2Ref = func(pars);
  
  Chi2Values = zeros(nbTest,1);
  str = sprintf('Calculating %g random Chi2 on %g isoSurface\n\n',nbTest, Chi2Level);
  utils.helper.msg(utils.const.msg.IMPORTANT, str);
  
  parsMC = zeros(nbTest,Npars);
  
  for nt=1:nbTest
    
    if(mod(nt,10)==0)
      str = sprintf('  %5g ',nt);
      utils.helper.msg(utils.const.msg.IMPORTANT, str);
    end
    
    for n = 1:Npars
      if(n == 1)
        AA = hessianMatrix(1,1);
        BB = 0;
        CC = -Chi2Level;
      else
        CC = 0; BB = 0;
        for i = 1:n-1
          BB = BB + (hessianMatrix(i,n)+hessianMatrix(n,i))*xP(i);
          for j = 1:n-1
            CC = CC + hessianMatrix(i,j)*xP(i)*xP(j);
          end
        end
        CC = CC - Chi2Level;
        AA = hessianMatrix(n,n);
      end
      delta = BB*BB-4*AA*CC;
      %fprintf('n,AA, BB, CC, delta = %12.6g  %12.6g  %12.6g  %12.6g  %12.6g  :  ',n,AA,BB,CC,delta);
      if(delta < 0)
        str = sprintf('\n ..... delta is negative, we stop\n');
        utils.helper.msg(utils.const.msg.IMPORTANT, str);
        return;
      end
      if(n < Npars)
        xP(n) = rand*(-BB + sqrt(delta))/(2*AA);
      else
        xP(n) = (-BB + sqrt(delta))/(2*AA);
      end
      str = sprintf('   x(n) = %g\n',xP(n));
      utils.helper.msg(utils.const.msg.OPROC1, str);
    end
    if size(pars,1)~=size(xP,1)
      xP = xP.';
    end
    p1 = pars + xP;
    yy00 = func(p1);
    Chi2Test = yy00-chi2Ref;
    % store p1
    if size(p1,2)<size(p1,1)
      parsMC(nt,:) = p1.';
    else
      parsMC(nt,:) = p1;
    end
    
    Chi2Values(nt) = Chi2Test;
    %fprintf('nt,Chi2Test = %g %12.6g\n',nt,Chi2Test);
  end
  
  meanChi2 = mean(Chi2Values);
  stdChi2 = std(Chi2Values);
  
  str = sprintf('nt, test MeanChi2 = %3g  %12.6g   :   Ratio = %12.6g  : Std variation = %12.6g\n',nt,meanChi2,meanChi2/Chi2Level,stdChi2);
  utils.helper.msg(utils.const.msg.IMPORTANT, str);
  
  str = sprintf('\nA random study of the n-dimensional error ellipsoide : End\n');
  utils.helper.msg(utils.const.msg.IMPORTANT, str);
  
  
  out = ao(Chi2Values);
  out.setName(sprintf('testHessianMatrix(%s)', f.name));
  
  % add history
  if ~callerIsMethod
    out.addHistory(getInfo('None'), pl, [], f.hist);
  end
  
  varargout = utils.helper.setoutputs(nargout, out);
  
end

%--------------------------------------------------------------------------
% Get Info Object
%--------------------------------------------------------------------------
function ii = getInfo(varargin)
  
  if nargin == 1 && strcmpi(varargin{1}, 'None')
    sets = {};
    pl   = [];
  else
    sets = {'Default'};
    pl   = getDefaultPlist;
  end
  % Build info object
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.sigproc, '', sets, pl);
end

%--------------------------------------------------------------------------
% Get Default Plist
%--------------------------------------------------------------------------
function pl = getDefaultPlist()
  
  pl = plist();

  p = param({'pars', 'The set of parameter values. A NumParams x 1 array or a pest object.'}, paramValue.EMPTY_DOUBLE) ;
  pl.append(p);
  
  p = param({'hessianMatrix', 'The Hessian matrix, NumParams x NumParams array or ao object.'}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
  p = param({'confidenceLevel', 'The desired confidence level for the chi2 ellipsoid.'}, paramValue.DOUBLE_VALUE(0.6827));
  pl.append(p);
  
  p = param({'nbTest', ' Number of test steps.'}, paramValue.DOUBLE_VALUE(50));
  pl.append(p);
  
  pl.append(copy(plist.RAND_STREAM));
  
end
