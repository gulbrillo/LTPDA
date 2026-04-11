% SETDATA sets the 'data' property of the ao.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: SETDATA sets the 'data' property of the ao.
%
% CALL:        objs.setData(dataObj);
%              objs = objs.setData(dataObj);
%
% INPUTS:      dataObj: Must be a ltpda_data object:
%                       tsdata, fsdata, xydata, xyzdata, cdata
%
% NOTE: this is NOT meant to be calleded by users!
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function setData(a, data)
  a.data = data;
end
