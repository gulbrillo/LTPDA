% SOP apply a symbolic operation to the expression.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: SOP apply a symbolic operation to the expression.
% objects.
%
% CALL:        obj = sop(mdl, plist)
%              obj = mdl.sop(plist)
%
% <a href="matlab:utils.helper.displayMethodInfo('smodel', 'sop')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function sop(mdls, callerIsMethod, smodel_invars, operation, args, pl, info, varargin)
  
  import utils.const.*
  
  if isempty(operation)
    error('### Please give a valid symbolic operator');
  end
    
  % Loop over the input objects
  for jj = 1:numel(mdls)
    % Message
    utils.helper.msg(msg.PROC1, 'applying %s to %s ', operation, mdls(jj).name);
    
    % Fix syntax (replacing .* with * and so) to allow symbolic evaluation
    mdls(jj).expr.s = utils.prog.convertComString(mdls(jj).expr.s , 'ToSymbolic');
    
    % Go symbolic now
%     d = feval(operation, sym(mdls(jj).expr.s), args{:});
    d = feval(operation, evalin(symengine, mdls(jj).expr.s), args{:});
    
    % Go back to string
    mdls(jj).expr.s = utils.prog.mup2mat(d);
    
    % Replace * like expressions with .* to allow numeric evaluation
    mdls(jj).expr.s = utils.prog.convertComString(mdls(jj).expr.s , 'FromSymbolic');
        
    % In the case of transforms, sets the new x variable
    switch lower(operation)
      case {'laplace', 'ilaplace', 'fourier', 'ifourier', 'ztrans', 'iztrans'}
        if ~isempty(args)
          % The return variable is the last argument
          mdls(jj).xvar = args{end};
        end
      otherwise
    end

    if ~callerIsMethod
      % Set new AO name
      mdls(jj).name = [operation '(' smodel_invars{jj} ')'];
      % Add history step
      mdls(jj).addHistory(info, pl, smodel_invars(jj), mdls(jj).hist);
    end
  end
  
end

