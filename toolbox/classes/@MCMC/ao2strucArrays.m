% AO2NUMMATRICES.m
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: ao2strucArrays is used to restructure the data for 
%              parameter estimation algorithms. It assumes that AOs have the correct
%              dimensionality: The rows denote the channels and the collumns
%              denote the experiment.
%
%              The output is an array of structire objects containing 
%              the data necessary for the MCMC class. 
%
% CALL:        struct = ao2strucArrays(out, pl); 
%      
% OUTPUT:      struct : A structure array with the data in pure numerical form.
%                        
%                        struc(Nexp).inputs
%                        struc(Nexp).outputs
%                        struc(Nexp).noise
%
%              For inputs and outputs its (freqs x inputs/output)
%              and for S its (freqs x outputs x outputs).
%
% NK 2012     
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'ao2numMatrices')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = ao2strucArrays(varargin)
  
  % Check if this is a call for parameters
  if nargin == 3 && utils.helper.isinfocall(varargin{:})
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
  pl = utils.helper.collect_objects(varargin(:), 'plist', in_names);
  
  % Combine plists
  pl = applyDefaults(getDefaultPlist, pl);
  
  fout = find(pl, 'out');
  fin  = find(pl, 'in');
  S    = find(pl, 'S');
  Nexp = find(pl, 'Nexp');
  
  data(Nexp).input  = [];
  data(Nexp).output = [];
  data(Nexp).noise  = [];
  
  for k = 1:Nexp
    
    if ~isempty(S)
      if isa(S, 'matrix')
        for rr = 1:size(S(k).objs,1)
          for cc = 1:size(S(k).objs,2)
            % Creating 3-D double matrix (freqs X outputs X outputs)
            data(k).noise(:, rr, cc) = S(k).getObjectAtIndex(rr,cc).y;
          end
        end
      elseif isa(S,'ao')
        for rr = 1:size(S(:,1,k),1)
          for cc = 1:size(S(1,:,k),2)
            % Creating 3-D double matrix (freqs X outputs X outputs)
            data(k).noise(:, rr, cc) = S(rr,cc,k).y;
          end
        end
      else
        error('### ''S'' must be either an AO or a MATRIX object.')
      end
    else
      data(k).noise(1,1,1) = 1;
    end
    
    if ~isempty(fin)
      if isa(fin, 'ao')
        Nin = numel(fin(:,k));
        for ch = 1:Nin
          data(k).input(:, ch) = fin(ch,k).y;
        end
      elseif isa(fin,'matrix')
        Nin = numel(fin(k).objs);
        for ch = 1:Nin
          data(k).input(:, ch) = fin(k).objs(ch).y;
        end
      else
        error('### ''in'' must be either an AO or a MATRIX object.')
      end
    else
      data(k).input(1,1) = 1;
    end

    % Get output depending the calling method
    if ~isempty(fout)
      if isa(fout, 'ao')
        Nout = numel(fout(:,k));
        for ch = 1:Nout
          % numfout(:, ch, k) = fout(ch,k).y;
          data(k).output(:, ch) = fout(ch,k).y;
        end
      elseif isa(fin,'matrix')
        Nout = numel(fout(k).objs);
        for ch = 1:Nout
          data(k).output(:, ch) = fout(k).objs(ch).y;
        end
      else
        error('### ''in'' must be either an AO or a MATRIX object.')
      end
    else
      data(k).output(1,1) = 1;
    end

  end
  
  % set outputs
  output = {data};
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
function plout = getDefaultPlist()
  persistent pl;  
  if ~exist('pl', 'var') || isempty(pl)
    pl = buildplist();
  end
  plout = pl;  
end

function plout = buildplist(varargin)
  
  plout = plist();

  % Input
  p = param({'in','A matrix array of input signals.'}, paramValue.EMPTY_STRING);
  plout.append(p);
  
  % Output
  p = param({'Out','A matrix array of output signals.'}, paramValue.EMPTY_STRING);
  plout.append(p);
  
  % Noise
  p = param({'S','A matrix array of the inverse noise cross-spectrum (PSD).'}, paramValue.EMPTY_STRING);
  plout.append(p);
  
  % Nexp
  p = param({'Nexp','The number of the experiments.'}, paramValue.EMPTY_DOUBLE);
  plout.append(p);

end


