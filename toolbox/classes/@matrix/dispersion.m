% DISPERSION computes the dispersion function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: DISPERSION computes the dispersion function
%
% CALL:        bs = dipersion(in,pl)
%
% INPUTS:      in      - matrix objects with input signals to the system
%              model   - symbolic models containing the transfer function model
%
%              pl      - parameter list
%
% OUTPUTS:     bs   - dispersion function AO
%
% <a href="matlab:utils.helper.displayMethodInfo('matrix', 'dispersion')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = dispersion(varargin)
  
  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  import utils.const.*
  utils.helper.msg(msg.PROC3, 'running %s/%s', mfilename('class'), mfilename);
  
  % Method can not be used as a modifier
  if nargout == 0
    error('### crb cannot be used as a modifier. Please give an output variable.');
  end
  
  % Collect input variable names
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
  
  % Collect all AOs smodels and plists
  [mtxs, mtxs_invars] = utils.helper.collect_objects(varargin(:), 'matrix', in_names);
  pl              = utils.helper.collect_objects(varargin(:), 'plist', in_names);
  
  % Combine plists
  pl = applyDefaults(getDefaultPlist, pl);
  
  % get params
  params = find_core(pl,'FitParams');
  numparams = find_core(pl,'paramsValues');
  mmdl = find_core(pl,'model');
  channel = find_core(pl,'channel');
  mtxns = find_core(pl,'noise');
  outModel = find_core(pl,'outModel');
  bmdl = find_core(pl,'built-in');
  f1 = find_core(pl,'f1');
  f2 = find_core(pl,'f2');
  pseudoinv = find_core(pl,'pinv');
  tol = find_core(pl,'tol');
  outNames = find_core(pl,'outNames');
  inNames = find_core(pl,'inNames');
  freqs = find_core(pl,'frequencies');
  
  
  % Decide on a deep copy or a modify
  in = copy(mtxs, nargout);
  n = copy(mtxns, nargout);
  mdl = copy(mmdl, nargout);
  
  % Get number of experiments
  nexp = numel(in);
  
  % pre-process input (fft + interpolate + normalise)
  
  % fft
  fin = fft(in);
  
  for ii = 1: numel(fin.objs)
    
    % interpolate at some frequencies (to reduce computing time)
    fint = interp(fin.objs(ii),plist('vertices',freqs,'method','linear'));
    
    % normalise to so that total power is 1
    norm = sum(fint.y.*conj(fint.y));
    if norm ~= 0
      fin.objs(ii) =  fint/norm;
    end
  end
  
  % N should get before spliting, in order to convert correctly from psd to
  % fft
  N = length(fin(1).getObjectAtIndex(1).x);
  
  % Get rid of fft f =0, reduce frequency range if needed
  if ~isempty(f1) && ~isempty(f2)
    fin = split(fin,plist('frequencies',[f1 f2]));
  end
  
  
  FMall = zeros(numel(params),numel(params));
  % loop over experiments
  for k = 1:nexp
    
    utils.helper.msg(msg.IMPORTANT, sprintf('Analysis of experiment #%d',k), mfilename('class'), mfilename);
    
    if (((numel(n(1).objs)) == 1) && (numel(in(1).objs) == 1))
      
      error('### case 1x1 not implemented yet')
      
      %         % use signal fft to get frequency vector.
      %         i1 = fin(k).getObjectAtIndex(1,1);
      %         freqs = i1.x;
      %
      %         FisMat = utils.math.dispersion_1x1(i1,n(k),mdl,params,numparams,freqs,N,pl,inNames,outNames);
      %         % store Fisher Matrix for this run
      %         FM{k} = FisMat;
      %         % adding up
      %         FMall = FMall + FisMat;
      
    elseif (((numel(n(1).objs)) == 2) && (numel(in(1).objs) == 2))
      % use signal fft to get frequency vector. Take into account signal
      % could be empty or set to zero
      % 1st channel
      if all(fin(k).getObjectAtIndex(1,1).y == 0) || isempty(fin(k).getObjectAtIndex(1,1).y)
        i1 = ao(plist('type','fsdata','xvals',0,'yvals',0));
      else
        i1 = fin(k).getObjectAtIndex(1,1);
        freqs = i1.x;
      end
      % 2nd channel
      if all(fin(k).getObjectAtIndex(2,1).y == 0) || isempty(fin(k).getObjectAtIndex(2,1).y)
        i2 = ao(plist('type','fsdata','xvals',0,'yvals',0));
      else
        i2 = fin(k).getObjectAtIndex(2,1);
        freqs = i2.x;
      end
      
      [d,FisMat]= utils.math.dispersion_2x2(i1,i2,n(k),mdl,params,numparams,freqs,N,pl,inNames,outNames);
      % store Fisher Matrix for this run
      FM{k} = FisMat;
      % adding up
      FMall = FMall + FisMat;
      
    end
    
  end
  
  
  % create AO
  out = ao(plist('Xvals',freqs,'Yvals',d,'type','fsdata','fs',in.objs(1).fs,'name',''));
  % spectrum in the procinfo
  % if channel == 1
  %     out.setProcinfo(plist('S11',S11));
  % elseif channel == 2
  %     out.setProcinfo(plist('S22',S22));
  % end
  % Fisher Matrix in the procinfo
  out.setProcinfo(plist('FisMat',FisMat));
  
  varargout{1} = out;
  
  
end


%--------------------------------------------------------------------------
% Get Info Object
%--------------------------------------------------------------------------
function ii = getInfo(varargin)
  if nargin == 1 && strcmpi(varargin{1}, 'None')
    sets = {};
    pls  = [];
  else
    sets = {'Default'};
    pls  = getDefaultPlist;
  end
  % Build info object
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.sigproc, '', sets, pls);
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
  pl = copy(plist.LPSD_PLIST,1);
  pset(pl,'Navs',1);
  
  p = plist({'f1', 'Initial frequency for the analysis'}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
  p = plist({'f2', 'Final frequency for the analysis'}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
  p = plist({'FitParamas', 'Parameters of the model'}, paramValue.EMPTY_STRING);
  pl.append(p);
  
  p = plist({'model','An array of matrix models'}, paramValue.EMPTY_STRING);
  pl.append(p);
  
  p = plist({'noise','An array of matrices with the cross-spectrum matrices'}, paramValue.EMPTY_STRING);
  pl.append(p);
  
  p = plist({'built-in','Symbolic models of the system as a string of built-in models'}, paramValue.EMPTY_STRING);
  pl.append(p);
  
  p = plist({'frequencies','Array of start/sop frequencies where the analysis is performed'}, paramValue.EMPTY_STRING);
  pl.append(p);
  
  p = plist({'pinv','Use the Penrose-Moore pseudoinverse'}, paramValue.TRUE_FALSE);
  pl.append(p);
  
  p = plist({'tol','Tolerance for the Penrose-Moore pseudoinverse'}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
  p = plist({'diffStep','Numerical differentiation step for ssm models'}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
end
