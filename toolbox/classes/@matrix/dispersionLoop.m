% DISPERSION computes the dispersion function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: dipersionLoop computes the dispersion function in loop
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

function varargout = dispersionLoop(varargin)
  
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
  nloop = find_core(pl,'iterations');
  
  
  % Decide on a deep copy or a modify
  in = copy(mtxs, 1);
  n = copy(mtxns, 1);
  mdl = copy(mmdl, 1);
  
  % Get number of experiments
  nexp = numel(in);
  
  % pre-process input (fft + interpolate + normalise)
  
  % fft
  fin = fft(in);
  
  % N should get before spliting, in order to convert correctly from psd to
  % fft
  N = length(fin(1).getObjectAtIndex(1).x);
  
  % Get rid of fft f =0, reduce frequency range if needed
  if ~isempty(f1) && ~isempty(f2)
    fin = split(fin,plist('frequencies',[f1 f2]));
  end
  
  for ii = 1: numel(fin.objs)
    
    % interpolate at some frequencies (to reduce computing time)
    fint = interp(fin.objs(ii),plist('vertices',freqs,'method','linear'));
    
    % normalise  so that total power is 1
    norm = (fint.y)'*(fint.y);
    if norm ~= 0
      fin.objs(ii) =  fint/sqrt(norm);
    else
      fin.objs(ii) =  fint;
    end
  end
  
  FMall = zeros(numel(params),numel(params));
  
  % iterations to design input
  for ii = 1:nloop
    
    % modify input if not in the first loop
    if ii > 1
      % loop over objects in the matrix
      for jj = 1: numel(fin.objs)
        % new design (newDesign = oldDesign * dispersion / Nparamers)
        fin.objs(jj) = fin.objs(jj).*d(:,ii-1)/numel(params);
        % normalise to so that total power is 1
        norm = (fin.objs(jj).y)'*(fin.objs(jj).y);
        if norm ~= 0
          fin.objs(jj) =  fin.objs(jj)/sqrt(norm);
        else
          fin.objs(jj) =  fin.objs(jj);
        end
      end
      % store current input
      inStr(ii-1) = copy(fin, 1);
    end
    
    % loop over experiments
    for kk = 1:nexp
      
      utils.helper.msg(msg.IMPORTANT, sprintf('Analysis of experiment #%d',kk), mfilename('class'), mfilename);
      
      if (((numel(n(1).objs)) == 1) && (numel(in(1).objs) == 1))
        
        % use signal fft to get frequency vector.
        i1 = fin(kk).getObjectAtIndex(1,1);
        freqs = i1.x;
        % second channel is not used
        i2 = ao(plist('type','fsdata','xvals',0,'yvals',0));
        
        
        [d(:,ii),FisMat]= utils.math.dispersion_1x1(i1,i2,n(kk),mdl,params,numparams,freqs,N,pl,inNames,outNames);
        % store Fisher Matrix for this run
        FM{ii} = FisMat;
        % adding up
        FMall = FMall + FisMat;
        
        
      elseif (((numel(n(1).objs)) == 2) && (numel(in(1).objs) == 2))
        % use signal fft to get frequency vector. Take into account signal
        % could be empty or set to zero
        % 1st channel
        if all(fin(kk).getObjectAtIndex(1,1).y == 0) || isempty(fin(kk).getObjectAtIndex(1,1).y)
          i1 = ao(plist('type','fsdata','xvals',0,'yvals',0));
        else
          i1 = fin(kk).getObjectAtIndex(1,1);
          freqs = i1.x;
        end
        % 2nd channel
        if all(fin(kk).getObjectAtIndex(2,1).y == 0) || isempty(fin(kk).getObjectAtIndex(2,1).y)
          i2 = ao(plist('type','fsdata','xvals',0,'yvals',0));
        else
          i2 = fin(kk).getObjectAtIndex(2,1);
          freqs = i2.x;
        end
        
        [d(:,ii),FisMat]= utils.math.dispersion_2x2(i1,i2,n(kk),mdl,params,numparams,freqs,N,pl,inNames,outNames);
        % store Fisher Matrix for this run
        FM{ii} = FisMat;
        % adding up
        FMall = FMall + FisMat;
        
      end
      
    end
    
  end
  
  for ii = 1:nloop
    disp(ii) = ao(plist('Xvals',freqs,'Yvals',d(:,ii),'type','fsdata','fs',in.objs(1).fs,'name',''));
  end
  
  % Fisher Matrix in the procinfo
  disp.setProcinfo(plist('FisMat',FisMat));
  
  if nargout == 1
    varargout{1} = disp;
  elseif nargout == 2
    varargout{1} = disp;
    varargout{2} = inStr;
  end
  
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
  
  p = plist({'FitParams', 'Parameters of the model'}, paramValue.EMPTY_STRING);
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
  
  p = plist({'inNames','The input names for the SSM.'}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
  p = plist({'outNames','The output names for the SSM.'}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
  p = plist({'paramsvalues','The numerical parameter values.'}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
  p = plist({'iterations','The total number of iterations.'}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
end
