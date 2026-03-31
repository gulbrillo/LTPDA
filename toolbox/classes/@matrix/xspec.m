% MATRIX/XSPEC applies the given cross-spectral density method to the vecor
% AOs contained within matrix. 
% 
% CALL:  mout = xspec(min, method, pl);
% 

function mout = xspec(ms, method, pl)
  
  import utils.const.*
  
  if nargout == 0
    error('### %s cannot be used as a modifier. Please give an output variable.', method);
  end
  
  if numel(ms) ~= 1
    error('matrix/%s requires a single input matrix of size Nx1 or 1xN', method);
  end
  
  if ~ms.isvector
    error('matrix/%s requires a single input matrix of size Nx1 or 1xN', method);
  end
  
  
  % Compute cross-spectrum with xspec
  Nobjs = numel(ms.objs);
  out = ao.initObjectWithSize(Nobjs, Nobjs);
  for rr = 1:Nobjs
    for cc = 1:Nobjs
      
      utils.helper.msg(msg.MNAME, 'computing %s(%d, %d) from %s to %s...', method, rr, cc, ms.objs(rr).name, ms.objs(cc).name);
      out(rr, cc) = feval(method, ms.objs(rr), ms.objs(cc), pl);
      out(rr, cc).clearHistory();
      
    end
  end
  
  % make output matrix
  mout = matrix(out);
  
end