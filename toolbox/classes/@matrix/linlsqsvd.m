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
% CALL:                   pars = linfitsvd(H1,...,HN,Y,pl);
% 
% If the experiment is 1 then H1,...,HN and Y are aos.
% If the experiments are M, then H1,...,HN and Y are Mx1 matrix objects
% with the aos relating to the given experiment in the proper position.
% 
% INPUT:
%               - Hi represent the columns of H
%               - Y represent the measurement set
% 
% OUTPUT:
%               - pars: a pest object containing parameter estimation
% 
% 09-11-2010 L Ferraioli
%       CREATION
%
% <a href="matlab:utils.helper.displayMethodInfo('matrix', 'linfitsvd')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = linlsqsvd(varargin)
  
  %%% LTPDA stufs and get data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  import utils.const.*
  utils.helper.msg(msg.OMNAME, 'running %s/%s', mfilename('class'), mfilename);
  
  % Collect input variable names
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
  
  % Collect all ltpdauoh objects
  [mtxs, mtxs_invars] = utils.helper.collect_objects(varargin(:), 'matrix', in_names);
  [pl, invars] = utils.helper.collect_objects(varargin(:), 'plist');
  
  
  inhists = [mtxs(:).hist];

  
  %%% combine plists
  pl = applyDefaults(getDefaultPlist(), pl);
  
  %%% collect inputs names
  argsname = mtxs(end).name;
  
  %%% get input params
  kwnpars    = find_core(pl,'KnownParams');
  sThreshold = find_core(pl,'sThreshold');
  
  
  %%% do fit
%   if ~isempty(kwnpars) && isfield(kwnpars,'pos')
%     [a,Ca,Corra,Vu,bu,Cbu,Fbu,mse,dof,ppm] = utils.math.linlsqsvd(mtxs,kwnpars);
%   else
%     [a,Ca,Corra,Vu,bu,Cbu,Fbu,mse,dof,ppm] = utils.math.linlsqsvd(mtxs);
%   end
  
  if ~isempty(kwnpars) && isfield(kwnpars,'pos')
    if ~isempty(sThreshold)
      [a,Ca,Corra,Vu,bu,Cbu,Fbu,mse,dof,ppm] = utils.math.linlsqsvd(mtxs,sThreshold,kwnpars);
    else
      [a,Ca,Corra,Vu,bu,Cbu,Fbu,mse,dof,ppm] = utils.math.linlsqsvd(mtxs,kwnpars);
    end
  else
    if ~isempty(sThreshold)
      [a,Ca,Corra,Vu,bu,Cbu,Fbu,mse,dof,ppm] = utils.math.linlsqsvd(mtxs,sThreshold);
    else
      [a,Ca,Corra,Vu,bu,Cbu,Fbu,mse,dof,ppm] = utils.math.linlsqsvd(mtxs);
    end
  end
  
  fitparams = cell(1,numel(a));
  nmstr = '';
  for kk=1:numel(a)
    fitparams{kk} = sprintf('a%s',num2str(kk));
    units{kk} = mtxs(end).objs(1).yunits / mtxs(kk).objs(1).yunits;
    units{kk}.simplify;
    if isempty(nmstr)
      nmstr = sprintf('%s*%s',fitparams{kk},mtxs(kk).name);
    else
      nmstr = [nmstr '+' sprintf('%s*%s',fitparams{kk},mtxs(kk).name)];
    end
  end
  
  pe = pest();
  pe.setY(a);
  pe.setDy(sqrt(diag(Ca)));
  pe.setCov(Ca);
  pe.setChi2(mse);
  pe.setNames(fitparams);
  pe.setDof(dof);
  pe.setYunits(units{:});
  pe.name = nmstr;
  pe.setModels(mtxs(1:end-1));
  
  % set History
  pe.addHistory(getInfo('None'), pl, [mtxs_invars(:)], [inhists(:)]);

  
  if nargout == 1
    varargout{1} = pe;
  elseif nargout == 11
    varargout{1} = pe;
    varargout{2} = a;
    varargout{3} = Ca;
    varargout{4} = Corra;
    varargout{5} = Vu;
    varargout{6} = bu;
    varargout{7} = Cbu;
    varargout{8} = Fbu;
    varargout{9} = mse;
    varargout{10} = dof;
    varargout{11} = ppm;
  else
    error('invalid number of outputs!')
  end
  
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
  ii.setArgsmin(2);
  ii.setOutmin(1);
%   ii.setOutmax(1);
  ii.setModifier(false);
end

%--------------------------------------------------------------------------
% Get Default Plist
%--------------------------------------------------------------------------
function plout = getDefaultPlist()
  persistent pl;  
  if exist('pl', 'var')==0 || isempty(pl)
    pl = buildplist();
  end
  plout = pl;  
end

function pl = buildplist()
  
  pl = plist();
  
  p = param({'KnownParams', ['Known Parameters. A struct array with the fields:<ul>'...
    '<li> pos - a number indicating the corresponding position of the parameter (corresponding column of H)</li>'...
    '<li> value - the value for the parameter</li>'...
    '<li> err - the uncertainty associated to the parameter</li>'...
    '</ul>']}, paramValue.EMPTY_CELL);
  pl.append(p);
  
  p = param({'sThreshold',['Fix upper treshold for singular values.'...
    'Singular values larger than the value will be ignored.'...
    'This correspon to consider only parameters combinations with error lower then the value']},...
    paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
  
end
