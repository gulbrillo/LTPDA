% SETRI Set the property 'ri' and computes 'f' and 'q'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: SETRI Set the property 'ri' and computes 'f' and 'q'
%
% CALL:        obj = obj.setRI(val);
%              obj = setRI(obj, val);
%
% INPUTS:      obj - is a pz object
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function ii = setRI(ii, val)

  %%% decide whether we modify the pz-object, or create a new one.
  ii = copy(ii, nargout);

  if numel(val) == 1
    % add conjugate
    val = [val conj(val)];
  elseif numel(val) == 2
    if val(1) ~= conj(val(2))
      error('### Please enter a conjugate pair to specify a complex pole.');
    end
  else
    error('### A pole/zero must be defined with a conjugate pair or a single complex number');
  end

  %%% set 'ri'
  ii.ri = val;
  %%% Then compute and set f and Q
  [f,q] = pz.ri2fq(ii.ri);
  ii.f = f;
  ii.q = q;
end
