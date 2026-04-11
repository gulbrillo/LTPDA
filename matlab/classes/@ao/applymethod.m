% APPLYMETHOD to the analysis object
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: APPLYMETHOD to the analysis object
%              Private static AO function that applies the given method to
%              the given AOs. This is called by all the simple methods like
%              abs, mean, acos, etc.
%
% CALL:        as = applymethod(copyObjects, callerIsMethod, in_names, operatorName, dxFcn, getInfo, getDefaultPlist, varargin)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = applymethod(copyObjects, callerIsMethod, in_names, operatorName, dxFcn, getInfo, getDefaultPlist, varargin)
  
  if callerIsMethod
    
    ao_invars = {};
    % assumed call: b = fcn(a1,a2,a3)
    % assumed call: b = fcn(a1,a2,a3, pl)
    
    if isa(varargin{end}, 'plist')
      as    = varargin{1:end-1};
      pl_in = varargin{end};
    else
      pl_in = [];
      as    = [varargin{:}];
    end
    
    info = [];
    
  else
    % Check if this is a call for parameters
    if utils.helper.isinfocall(varargin{:})
      varargout{1} = getInfo(varargin{3});
      if nargout == 2
        varargout{2} = [];
      end
      return
    end    
    
    % Collect all AOs
    [as, ao_invars, rest] = utils.helper.collect_objects(varargin, 'ao', in_names);
    
    info = getInfo('None');
    
    % Collect the rest of the inputs (should be plists)
    pl_in = utils.helper.collect_objects(rest, 'plist');
  end
  
  % Decide on a deep copy or a modify
  bs = copy(as, copyObjects);
  
  % Loop over the objects
  for jj = 1:numel(bs)
    % Message
    utils.helper.msg(utils.const.msg.PROC3, 'applying %s to %s ', operatorName, bs(jj).name);
    % Apply method to data
    pl = applymethod(bs(jj).data, pl_in, operatorName, getDefaultPlist, dxFcn);
    if ~callerIsMethod
      % Set new AO name
      bs(jj).name = [operatorName '(' ao_invars{jj} ')'];
      % append history
      bs(jj).addHistory(info, pl, ao_invars(jj), bs(jj).hist);
    end
  end  
  
  if nargout == 1
    varargout{1} = bs;
  elseif nargout == 2
    varargout{1} = bs;
    varargout{2} = pl;
  else
    error('### Incorrect outputs');
  end
  
end
