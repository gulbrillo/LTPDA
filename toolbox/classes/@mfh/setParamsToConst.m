% SETPARAMSTOCONST set the given parameters to be constant in the model.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: SETPARAMSTOCONST set the given parameters to be constant in
%              the model.
%
% The function handle is minimised a function of its 'inputs' by calling
% MATLAB's fminsearch() function.
%
% CALL:
%            fh = setParamsToConst(fh, pest)
%            fh = setParamsToConst(fh, pl)
%
% INPUTS:      fh   - input function handle object (@mfh)
%            pest   - input parameter definition pest
%              pl   - input parameter list
%
% OUTPUTS:    min   - output mfh object with the specified parameters fixed
%
% <a href="matlab:utils.helper.displayMethodInfo('mfh', 'setParamsToConst')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varargout = setParamsToConst(varargin)
  
  % callerIsMethod = utils.helper.callerIsMethod;
  
  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  % Collect input variable names
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
  
  % Collect all function handles
  [ifhs, f_invars, rest] = utils.helper.collect_objects(varargin(:), 'mfh', in_names);
  [pls, ~, rest] = utils.helper.collect_objects(rest(:), 'plist', in_names);
  
  % apply defaults
  pl = applyDefaults(getDefaultPlist(), pls);
  
  % process inputs
  if ~isempty(rest)
    p0s = rest{1};
  else
    p0s = pl.find('p0');
  end
  
  % process p0s
  if ischar(p0s)
    p0s = {p0s};
  else
    % try a cast to a pest
    p0s = pest(p0s);
  end
  
  if numel(p0s) > 1 && numel(p0s) ~= numel(ifhs)
    error('Please specify a single pest or one per input model');
  end
  
  % copy if needed
  fhs = copy(ifhs, nargout);
  
  % loop over input models
  for ff=1:numel(fhs)
    
    obj = fhs(ff);
    
    if iscellstr(p0s)
      % then we assume that the user wants to use the default parameter
      % definitions
      p0s = obj.paramsDef.subset(plist('parameters', p0s));
    end
    
    if ~isa(p0s, 'pest')
      error('Please specifiy the named parameters to be replaced in a pest object or a cell-array, or anything that can be cast to a pest object via the pest constructor.');
    end
    
    if numel(p0s) == 1
      p0 = p0s;
    else
      p0 = p0s(ff);
    end
    
    % Look for each parameter    
    for kk=1:numel(p0.y)
      pname = p0.names{kk};
      
      % check through inputs of the model
      for ii=1:numel(obj.inputs)
        if ~isempty(obj.paramsDef) % Check if the paramsDef field is empty
          iname = obj.paramsDef.names{ii};
          
          for pp=1:numel(obj.paramsDef)
            
            if any(strcmp(obj.paramsDef(pp).names, iname))
              
              % look for the parameter inside this pest
              idx = find(strcmp(pname, obj.paramsDef(pp).names));
              
              if numel(idx) == 1
                
                % remove it from here
                obj.paramsDef(pp).removeParameters(pname);
                
                % add a constant
                pconst = LTPDANamedItem(pname, '', p0.yunits(kk));
                obj.constants = [obj.constants {pconst}];
                if obj.numeric
                  obj.constObjects = [obj.constObjects {p0.y(kk)}];
                else
                  obj.constObjects = [obj.constObjects {p0.find(pname)}];
                end
                
              end % End found parameters
            end % end found input pest
            
            % if the pest is empty, we can remove it
            if isempty(obj.paramsDef(pp).y)
              obj.paramsDef(pp) = [];
              obj.inputs(pp) = [];
            end
            
          end % end loop over def pests
        end
      end % end loop over inputs
    end % end loop over param names
    
    % loop over sub-models
    for kk=1:numel(obj.subfuncs)
      obj.subfuncs(kk).setParamsToConst(p0);
    end
    
    % re-apply definitions to build function
    obj.applyDef();
    
    % add history
    obj.addHistory(getInfo('None'), pl, f_invars, [obj.hist p0.hist]);
    
  end % End loop over input objects
  
  % Set output
  varargout = utils.helper.setoutputs(nargout, fhs);
  
end % End setParamsToConst




%--------------------------------------------------------------------------
% Get Info Object
%--------------------------------------------------------------------------
function ii = getInfo(varargin)
  if nargin == 1 && strcmpi(varargin{1}, 'None')
    sets = {};
    pl   = [];
  else
    sets = {'Default'};
    pl   = getDefaultPlist();
  end
  % Build info object
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.sigproc, '', sets, pl);
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

function pl = buildplist()
  
  % empty plist
  pl = plist();
  
  % p0
  p = param({'p0', 'A pest object describing the parameters to be set to constant. Give one object to be used for all input models, or one pest object per input model.'}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
end

