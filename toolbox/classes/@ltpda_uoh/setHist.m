% SETHIST Set the property 'hist'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: SETHIST Set the property 'hist'
%
% CALL:        obj = obj.setHist('new ver');
%              obj = setHist(obj, 'new ver');
%
% INPUTS:      obj - is a general object
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function obj = setHist(obj, val)
  %%% decide whether we modify the ltpda_uoh-object, or create a new one.
  obj = copy(obj, nargout);

  %%% set 'hist'
  obj.hist = val;
end
