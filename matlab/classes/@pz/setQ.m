% SETQ Set the property 'q'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: SETQ Set the property 'q' and computes 'ri'
%
% CALL:        obj = obj.setQ(1);
%              obj = setQ(obj, 1);
%
% INPUTS:      obj - is a pz object
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function ii = setQ(ii, val)

  %%% decide whether we modify the pz-object, or create a new one.
  ii = copy(ii, nargout);

  %%% set 'q'
  ii.q = val;
  %%% Then compute and set ri
  ii.ri = pz.fq2ri(ii.f, ii.q);

end
