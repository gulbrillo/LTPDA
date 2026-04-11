%--------------------------------------------------------------------------
%       Check if x0 is empty
%--------------------------------------------------------------------------
function algo = checkXo(algo)

  xo     = algo.params.find('x0');
  params = algo.getParamNames();
  bounds = algo.params.find('range');
  
  if isempty(xo)
    warning('LTPDA:mcmc', ['#### Plist parameter ''x0'' is empty! ' ...
      'Will pick a random value between the ranges specified.'])
    
    for ii = 1:numel(params)
      xo(ii) = bounds(1,ii) + (bounds(2,ii)-bounds(1,ii)).*rand(1,1);
    end
    
  end
  
  algo.params.pset('x0', xo);
  
%   % Add history step
%   algo.addHistory(getInfo, plist.EMPTY_PLIST(), {}, [algo.hist]);

end % End of checkXo