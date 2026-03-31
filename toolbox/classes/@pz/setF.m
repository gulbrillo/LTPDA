% SETF Set the property 'f'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: SETF Set the property 'f' and computes 'ri'
%
% CALL:        obj = obj.setF(1);
%              obj = setF(obj, 1);
%
% INPUTS:      obj - is a pz object
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function ii = setF(ii, val)

  %%% decide whether we modify the pz-object, or create a new one.
  ii = copy(ii, nargout);

  %%% set 'f'
  ii.f = val;
  %%% Then compute and set ri
  ii.ri = pz.fq2ri(ii.f, ii.q);
end
