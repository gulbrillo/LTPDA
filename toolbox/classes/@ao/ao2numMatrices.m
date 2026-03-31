% ao2numMatrices transforms AO objects to numerical matrices.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: ao2numMatrices transforms AO objects to numerical matrices.
%              Used to restructure the data for parameter estimation
%              algorithms. It assumes that AOs have the correct
%              dimensionality: The rows denote the channels and the collumns
%              denote the experiment.
%
% CALL:        outData = ao2numMatrices(out, pl);
%
% OUTPUT:      outData : A cell array with the pure numerical matrices.
%                        {inputs, outputs, S}
%
%              For inputs and outputs its (freqs x inputs/output x experiments)
%              and for S its (freqs x inputs x outputs x experiments).
%
% NK 2012
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'ao2numMatrices')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = ao2numMatrices(varargin)
  
  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  % Method can not be used as a modifier
  if nargout == 0
    error('### ao2numMatrices cannot be used as a modifier. Please give an output variable.');
  end
  
  % Collect input variable names
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
  
  % Collect all AOs smodels and plists
  [aos_in, ~] = utils.helper.collect_objects(varargin(:), 'ao', in_names);
  pl          = utils.helper.collect_objects(varargin(:), 'plist', in_names);
  
  % Combine plists
  pl = applyDefaults(getDefaultPlist, pl);
  
  % copy input aos
  fout = copy(aos_in,1);
  
  fin  = find_core(pl, 'in');
  S    = find_core(pl, 'S');
  Nexp = find_core(pl, 'Nexp');
  
  for k = 1:Nexp
    
    if ~isempty(S)
      if isa(S, 'matrix')
        for rr = 1:size(S(k).objs,1)
          for cc = 1:size(S(k).objs,2)
            % Creating 4-D double matrix (freqs X inputs X outputs X experiments)
            Sn(:, rr, cc, k) = S(k).getObjectAtIndex(rr,cc).y;
          end
        end
      elseif isa(S,'ao')
        for rr = 1:size(S(:,1,k),1)
          for cc = 1:size(S(1,:,k),2)
            % Creating 4-D double matrix (freqs X inputs X outputs X experiments)
            Sn(:, rr, cc, k) = S(rr,cc,k).y;
          end
        end
      else
        error('### ''S'' must be either an AO or a MATRIX object.')
      end
    else
      Sn(1,1,k) = 1;
    end
    
    if ~isempty(fin)
      if isa(fin, 'ao')
        Nin = numel(fin(:,k));
        for ch = 1:Nin
          numfin(:, ch, k)   = fin(ch,k).y;
        end
      elseif isa(fin,'matrix')
        Nin = numel(fin(k).objs);
        for ch = 1:Nin
          numfin(:, ch, k)   = fin(k).objs(ch).y;
        end
      else
        error('### ''in'' must be either an AO or a MATRIX object.')
      end
    else
      numfin(1,1,k) = 1;
    end
    
    % Get output depending the calling method
    if ~isempty(fout)
      
      Nout = numel(fout(:,k));
      
      for ch = 1:Nout
        numfout(:, ch, k) = fout(ch,k).y;
      end
      
    else
      
      numfout(1,1,k) = 1;
      
    end
    
  end
  
  numMats = {numfin, numfout, Sn};
  
  % set outputs
  output = {numMats};
  varargout = output(1:nargout);
  
end


%--------------------------------------------------------------------------
% Get Info Object
%--------------------------------------------------------------------------
function ii = getInfo(varargin)
  ii = minfo.getInfoAxis(mfilename, @getDefaultPlist, mfilename('class'), 'ltpda', utils.const.categories.op, '', varargin);
end

%--------------------------------------------------------------------------
% Get Default Plist
%--------------------------------------------------------------------------
function plout = getDefaultPlist(set)
  persistent pl;
  persistent lastset;
  if ~exist('pl', 'var') || isempty(pl) || ~strcmp(lastset, set)
    pl = buildplist(set);
    lastset = set;
  end
  plout = pl;
end

function plout = buildplist(varargin)
  
  plout = plist();
  
  % Input
  p = param({'in','A matrix array of input signals.'}, paramValue.EMPTY_STRING);
  plout.append(p);
  
  % Noise
  p = param({'S','A matrix array of the inverse noise cross-spectrum (PSD).'}, paramValue.EMPTY_STRING);
  plout.append(p);
  
  % Nexp
  p = param({'Nexp','The number of the experiments.'}, paramValue.EMPTY_DOUBLE);
  plout.append(p);
  
end


