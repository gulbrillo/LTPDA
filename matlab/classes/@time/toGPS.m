% TOGPS returns the gps seconds corresponding to this time object.
% 
% CALL:
%         gps = t.toGPS()
% 
% 
% M Hewitson 29-06-14
% 
% 
function varargout = toGPS(varargin)

  tobjs = utils.helper.collect_objects(varargin(:), 'time', {});
  
  out = [];
  for kk=1:numel(tobjs)
    utc = tobjs(kk).format('yyyy-mm-dd HH:MM:SS');
    gps = utils.timetools.utc2gps(utc);
    out = [out gps];
  end
  
  varargout{1} = out;
end
% END