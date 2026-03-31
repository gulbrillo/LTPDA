function out = eval(f, varargin)
  
  import utils.const.*
  persistent emptyPlist
  
  callerIsMethod = utils.helper.callerIsMethod;
  
  hists = f.hist;
  
  if numel(varargin) == 1 && isa(varargin{1}, 'plist')
    pl = varargin{1};
    iObjs = pl.find_core('inputobjects');
    hpl = plist('inputobjects', iObjs);
    
  elseif numel(varargin) > 0
    iObjs = varargin;
    if ~callerIsMethod
      hpl = plist('inputobjects', iObjs);
    else
      if isempty(emptyPlist)
        emptyPlist = plist();
      end
      
      hpl = emptyPlist;
    end
  else
    hpl = plist();
    iObjs = f.inputObjects;
    
  end
  
  % Check inputs
  if numel(iObjs) == 1 && isa(iObjs{1}, 'pest') 
    if ~isempty(f.paramsDef) && ~all(strcmp(f.paramsDef.names, iObjs{1}.names))
      [~, index] = ismember(f.paramsDef.names, iObjs{1}.names);
      if all(index > 0)
        f.paramsDef = iObjs{1};
        f.applyDef;
        f.resetCachedProperties;
      end
    end
  end
  
  % if we received no inputs, use the defaults.
  if isempty(iObjs) && ~isempty(f.paramsDef)
    iObjs = {f.paramsDef};
  end
      
  if numel(iObjs) ~= numel(f.inputs)
    error('Incorrect inputs in [%s]', f.func);
  end
  
  if isempty(f.funcHandle)
    
    inVars   = f.inputs;
    inVarStr = sprintf('%s,', inVars{:});
    inVarStr = inVarStr(1:end-1);
    
    strExpr = sprintf('@(%s) (%s)', inVarStr, f.func);
    
    % declare constants
    for kk=1:numel(f.constants)
      eval(sprintf('%s = f.constObjects{kk};', char(f.constants{kk})));
    end
    
    % declare input functions
    for kk=1:numel(f.subfuncs)
      ff = f.subfuncs(kk);
      eval(sprintf('%s = f.subfuncs(kk);', ff.name));
      strExpr = regexprep(strExpr, ['(' ff.name ')([\(\s]+)'], '$1.eval$2'); 
    end
    
    utils.helper.msg(msg.PROC1, 'evaluating expression %s', strExpr);
        
    % now create function handle
    % It is necessary to create the function handle with 'eval' because
    % this command creates also an anchor to this workspace which holds for
    % example the constant objects. The function 'str2func' doesn't create
    % this anchor and that means the constant objects are lost.
    fh = eval(strExpr);    
    f.funcHandle = fh;
    
  end
  
  % transform inputs
  if f.numeric
    for kk=1:numel(iObjs)
      iObjs{kk} = double(iObjs{kk});
    end
  end
  
  % if the inputs are a numeric array, assume the order, and use the params
  % definition to pass in a pest
  if ~isempty(f.paramsDef) && f.numeric == 0
    p0 = [iObjs{:}];
    if isnumeric(p0)
      if numel(p0) ~= numel(f.paramsDef.y)
        error('The numeric input does not have the same number of values as the parameter definition');
      end
      p0 = f.paramsDef.setY(iObjs{:});
    end
  
    % override inputs with the new pest
    iObjs = {p0};    
  end
  
  % call function handle
  out = f.funcHandle(iObjs{:});
    
  % add history etc
  if ~callerIsMethod
    % check for ao
    if isnumeric(out)
      out = ao(out);
    end
    ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.sigproc, '', 'None', []);
    out.setName(f.name);
    out.addHistory(ii, hpl, [], hists);
  end
end

% END