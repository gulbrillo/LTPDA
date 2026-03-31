% tdChi2 computes the chi-square for a parameter estimate.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: tdChi2 computes the chi-square in time domain for an input
%              pest. The system measured outputs, inputs and models must be 
%              contained in the plist. Also whitening filters for each
%              output may be taken into account.
%
% CALL:        obj = tdChi2(objs,pl);
%              
% INPUTS:      obj - must be a single pest
%
% <a href="matlab:utils.helper.displayMethodInfo('pest', 'tdChi2')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = tdChi2(varargin)

  %%% Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  import utils.const.*
  utils.helper.msg(msg.PROC3, 'running %s/%s', mfilename('class'), mfilename);
  
  % Collect input variable names
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
  
  % Collect all AOs and plists
  [pests, pest_invars] = utils.helper.collect_objects(varargin(:), 'pest', in_names);
  pl              = utils.helper.collect_objects(varargin(:), 'plist', in_names);
 
  
  % combine plists
  pl = applyDefaults(getDefaultPlist(), pl);
  
  % Extract necessary parameters
  inputs    = pl.find_core('inputs');
  outputs   = pl.find_core('outputs');
  models    = pl.find_core('models');
  WF        = pl.find_core('WhiteningFilters');
  Ncut      = pl.find_core('Ncut');
  Npad      = pl.find_core('Npad');
    
  if nargout == 0
    error('### tdChi2 cannot be used as a modifier. Please give an output variable.');
  end
  
  if ~all(isa(pests, 'pest'))
    error('### tdChi2 must be only applied to pest objects.');
  end
  
  % Determine the class
  outClass = class(outputs);
  
  % Check ouputs
  if isempty(outputs)
    error('### Please give the outputs');
  end
  switch outClass
    case 'ao'
      N = numel(outputs);
      if N>1
        error('### Please give the outputs in a MATRIX');
      end
    case 'matrix'
      N = numel(outputs);
      if N>1
        error('### Please give the outputs in a COLLECTION of MATRIXs');
      end
      if outputs.ncols>1
        outputs = outputs.';
      end
    case 'collection'
      N = numel(outputs.objs);
      for ii=1:N
        if outputs.objs{ii}.ncols>1
          outputs.objs{ii} = outputs.objs{ii}.';
        end
      end
    otherwise
      error('### Unknown class for outputs');
  end
    
  % Check inputs
  if isempty(inputs)
    error('### Please give the inputs');
  end
  if ~strcmp(class(inputs),outClass)
    error('### Please give inputs as the same class of outputs');
  end
  switch outClass
    case 'ao'
      if numel(inputs)>1
        error('### Please give the inputs in a MATRIX');
      end
    case 'matrix'
      if numel(inputs)>1
        error('### Please give the inputs in a COLLECTION of MATRIXs');
      end
      if inputs.ncols>1
        inputs = inputs.';
      end
    case 'collection'
      for ii=1:numel(inputs.objs)
        if inputs.objs{ii}.ncols>1
          inputs.objs{ii} = inputs.objs{ii}.';
        end
      end
  end
  
  % Check models
  if isempty(models)
    error('### Please give the transfer function models');
  end
  switch outClass
    case 'ao'
      if ~strcmp(class(models),'smodel')
        error('### Please, give the transfer function in a SMODEL.');
      end
      if numel(models)>1
        error('### The size of the transfer function SMODEL does not match with the number of inputs/outputs.');
      end
    case {'matrix','collection'}
      if ~strcmp(class(models),'matrix')
        error('### Please, give the transfer function in a MATRIX of SMODELs.');
      end
      for ii=1:N
        if strcmp(outClass,'matrix')
          checkSz = models.nrows~=outputs.nrows || models.ncols~=inputs.nrows;
        elseif strcmp(outClass,'collection')
          checkSz = models.nrows~=outputs.objs{ii}.nrows || models.ncols~=inputs.objs{ii}.nrows;
        end
        if checkSz
          error('### The size of the transfer function MATRIX does not match with the number of inputs/outputs.');
        end
      end
  end
   
  % Check whitening filters
  whiten = ~isempty(WF);
  if whiten
    switch outClass
    case 'ao'
      if numel(WF)>1 || ~any(strcmp(class(WF),{'miir','fiir','filterbank'}))
        error('### Please give the whitening filters in a FIIR, MIIR or FILTERBANK');
      end
    case {'matrix','collection'}
      if ~strcmp(class(WF),'matrix')
        error('### Please give the whitening filters in a MATRIX of FIIRs, MIIRs or FILTERBANKs');
      end      
      for ii=1:N
        if strcmp(outClass,'matrix')
          checkSz = WF.nrows~=outputs.nrows && WF.ncols~=outputs.nrows;
        elseif strcmp(outClass,'collection')
          checkSz = WF.nrows~=outputs.objs{ii}.nrows && WF.ncols~=outputs.objs{ii}.nrows;
        end
        if checkSz
          error('### The size of the whitening filters MATRIX does not match with the number of outputs.');
        end
      end
    end
  end   
    
  
  % Actual computation
  
  chi2 = zeros(N,1);
  Ndata = zeros(N,1);
  
  % Subs unwanted params
  if strcmp(outClass,'matrix') || strcmp(outClass,'collection')
    for kk=1:numel(models.objs)
      models.objs(kk).setParams(pests.names,pests.y);
      models.objs(kk).subs(setdiff(models.objs(kk).params,pests.names));
    end
  else
    models.setParams(pests.names,pests.y);
    models.subs(setdiff(models.params,pests.names));
  end
  
  for ii=1:N
        
        % Time-domain template
        if strcmp(outClass,'matrix') || strcmp(outClass,'collection')
          template = fftfilt(inputs.objs{ii},models,plist('Npad',Npad));
        else
          template = fftfilt(inputs,models,plist('Npad',Npad));
        end
        
        % Residues
        if strcmp(outClass,'matrix') || strcmp(outClass,'collection')
          res = template-outputs.objs{ii};
        else
          res = template-outputs;
        end

        % Whiten
        if whiten
          res = filter(res,WF);
        end

        % Split-out transients
        if ~isempty(Ncut) || Ncut~=0
          res = split(res,plist('samples',[Ncut+1,Inf]));
        end

        % Compute chi2 & dof
        if strcmp(outClass,'matrix') || strcmp(outClass,'collection')
          chi2(ii) = sum(sum((res.objs.y).^2));
          Ndata(ii) = max(size(res.objs.y))*min(size(res.objs.y));
        else
          chi2(ii) = sum((res.y).^2);
          Ndata(ii) = numel(res.y);
        end
    
  end 
   
  % Compute total chi2 & dof
  chi2 = sum(chi2);
  dof = sum(Ndata)-numel(pests.y);
  
  % Output pest
  out = copy(pests,1);
  out = out.setChi2(chi2/dof);
  out = out.setDof(dof);
  out = out.setName(['tdChi2(' pests.name ')']);
  
  out.addHistory(getInfo('None'), pl, pest_invars(:), [pests(:).hist]);
     
  % Set outputs
  if nargout > 0
    varargout{1} = out;
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
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.helper, '', sets, pl);
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

function plo = buildplist()
  plo = plist();
  
  % Outputs
  p = param({'Outputs', 'The system outputs. Must be an AO, a MATRIX or a COLLECTION of MATRIXs, one per each experiment.'}, paramValue.EMPTY_DOUBLE);
  plo.append(p);
  
  % Inputs
  p = param({'Inputs', 'The system inputs. Must be an AO, a MATRIX or a COLLECTION of MATRIXs, one per each experiment.'}, paramValue.EMPTY_DOUBLE);
  plo.append(p);
   
  % Models
  p = param({'Models', 'The system transfer function SMODELs. Must be a SMODEL or a MATRIX of SMODELs.'}, paramValue.EMPTY_DOUBLE);
  plo.append(p);
  
  % Whitening filters
  p = param({'WhiteningFilters', 'The output whitening filters. Must be a MIIR, FIIR, FILTERBANK or a MATRIX.'}, paramValue.EMPTY_DOUBLE);
  plo.append(p);
  
  % Ncut
  p = param({'Ncut', 'The number of points to cut out initial whitening filter transients.'}, paramValue.EMPTY_DOUBLE);
  plo.append(p);
  
  % Npad
  p = param({'Npad', 'The number of points to zero-pad the input for ifft. If left empty, a data length is assumed.'}, paramValue.EMPTY_DOUBLE);
  plo.append(p);
  
end
